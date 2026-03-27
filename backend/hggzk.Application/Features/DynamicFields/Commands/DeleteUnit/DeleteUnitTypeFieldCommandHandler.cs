using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.DynamicFields;
using YemenBooking.Application.Common.Exceptions;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Interfaces;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Application.Common.Models;
using System.Text.Json;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.SearchAndFilters.Services;

namespace YemenBooking.Application.Features.DynamicFields.Commands.DeleteUnit
{
    /// <summary>
    /// يحذف حقلًا ديناميكيًا من نوع الوحدة حذفًا ناعمًا.
    /// Soft-deletes a dynamic field from a unit type.
    /// </summary>
    public class DeleteUnitTypeFieldCommandHandler : IRequestHandler<DeleteUnitTypeFieldCommand, ResultDto<bool>>
    {
        private readonly IUnitTypeFieldRepository _repository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUserService _currentUserService;
        private readonly IAuditService _auditService;
        private readonly ILogger<DeleteUnitTypeFieldCommandHandler> _logger;
    private readonly IUnitIndexingService _indexingService;

        /// <summary>
        /// يُهيِّئ المعالج بالاعتمادات المطلوبة.
        /// Initializes the handler with the required dependencies.
        /// </summary>
        public DeleteUnitTypeFieldCommandHandler(
            IUnitTypeFieldRepository repository,
            IUnitOfWork unitOfWork,
            ICurrentUserService currentUserService,
            IAuditService auditService,
            ILogger<DeleteUnitTypeFieldCommandHandler> logger,
            IUnitIndexingService indexingService)
        {
            _repository = repository;
            _unitOfWork = unitOfWork;
            _currentUserService = currentUserService;
            _auditService = auditService;
            _logger = logger;
            _indexingService = indexingService;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة.
    /// Processes the delete unit type field command and returns the result.
    /// </summary>
        public async Task<ResultDto<bool>> Handle(DeleteUnitTypeFieldCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("بدء معالجة أمر حذف حقل نوع الوحدة: {FieldId}", request.FieldId);

            // التحقق من صحة المعرف
            if (!Guid.TryParse(request.FieldId, out var fieldId))
                throw new BusinessRuleException("InvalidFieldId", "معرف الحقل غير صالح");

            // التحقق من وجود الحقل
            var existingField = await _repository.GetUnitTypeFieldByIdAsync(fieldId, cancellationToken);
            if (existingField == null)
                throw new NotFoundException("UnitTypeField", request.FieldId);

            // صلاحيات المستخدم
            if (_currentUserService.Role != "Admin")
                throw new ForbiddenException("غير مصرح لك بحذف حقل نوع الوحدة");

            // تنفيذ الحذف الناعم ضمن معاملة
            await _unitOfWork.ExecuteInTransactionAsync(async () =>
            {
                var deleted = await _repository.DeleteUnitTypeFieldAsync(fieldId, cancellationToken);
                if (!deleted)
                    throw new BusinessRuleException("DeletionFailed", "فشل حذف حقل نوع الوحدة");

                await _repository.SaveChangesAsync(cancellationToken);

                // تسجيل التدقيق اليدوي مع القيم القديمة فقط
                await _auditService.LogAuditAsync(
                    entityType: "UnitTypeField",
                    entityId: existingField.Id,
                    action: AuditAction.DELETE,
                    oldValues: JsonSerializer.Serialize(new {
                        existingField.Id,
                        existingField.UnitTypeId,
                        existingField.FieldName,
                        existingField.DisplayName
                    }),
                    newValues: null,
                    performedBy: _currentUserService.UserId,
                    notes: $"تم حذف حقل الديناميكي: {existingField.FieldName} من نوع الوحدة {existingField.UnitTypeId} بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})",
                    cancellationToken: cancellationToken);

                _logger.LogInformation("تم حذف حقل نوع الوحدة بنجاح: {FieldId}", existingField.Id);
            });

            // حذف فهارس الحقل من Redis مع retry mechanism
            var indexingSuccess = false;
            var indexingAttempts = 0;
            const int maxIndexingAttempts = 3;
            
            while (!indexingSuccess && indexingAttempts < maxIndexingAttempts)
            {
                try
                {
                    indexingAttempts++;
                    await _indexingService.OnUnitTypeFieldDeletedAsync(
                        existingField.FieldName,
                        existingField.UnitTypeId,
                        cancellationToken);
                    
                    indexingSuccess = true;
                    _logger.LogInformation("✅ تم حذف فهارس Redis للحقل {FieldName} بنجاح (محاولة {Attempt}/{Max})", 
                        existingField.FieldName, indexingAttempts, maxIndexingAttempts);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "⚠️ فشلت محاولة {Attempt}/{Max} لحذف فهارس Redis للحقل {FieldName}", 
                        indexingAttempts, maxIndexingAttempts, existingField.FieldName);
                    
                    if (indexingAttempts < maxIndexingAttempts)
                    {
                        await Task.Delay(TimeSpan.FromSeconds(Math.Pow(2, indexingAttempts - 1)), cancellationToken);
                    }
                    else
                    {
                        _logger.LogCritical("❌ CRITICAL: فشل حذف فهارس Redis بعد {Attempts} محاولات للحقل {FieldName}. " +
                            "الحقل محذوف من DB لكن فهارسه موجودة في Redis! يجب تنظيف يدوي.", 
                            maxIndexingAttempts, existingField.FieldName);
                    }
                }
            }

            return ResultDto<bool>.Ok(true);
        }
    }
} 
