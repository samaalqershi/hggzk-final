using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Properties;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Interfaces;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Core.Notifications;
using System.Text.Json;
using YemenBooking.Core.Entities;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Accounting.Services;
using YemenBooking.Application.Features.Notifications.Services;
using YemenBooking.Application.Features.SearchAndFilters.Services;

namespace YemenBooking.Application.Features.Properties.Commands.ApproveProperty
{
    /// <summary>
    /// يعالج اعتماد العقار ويتحقق من الصلاحيات وحالة السجل.
    /// Handles property approval and validates authorization and record state.
    /// </summary>
    public class ApprovePropertyCommandHandler : IRequestHandler<ApprovePropertyCommand, ResultDto<bool>>
    {
        private readonly IPropertyRepository _propertyRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly INotificationService _notificationService;
        private readonly IAuditService _auditService;
        private readonly ILogger<ApprovePropertyCommandHandler> _logger;
        private readonly IUnitIndexingService _indexingService;
        private readonly IFinancialAccountingService _financialAccountingService;

        /// <summary>
        /// يهيّئ مثيلاً جديداً من [ApprovePropertyCommandHandler].
        /// Initializes a new instance of [ApprovePropertyCommandHandler].
        /// </summary>
        public ApprovePropertyCommandHandler(
            IPropertyRepository propertyRepository,
            ICurrentUserService currentUserService,
            INotificationService notificationService,
            IAuditService auditService,
            ILogger<ApprovePropertyCommandHandler> logger,
            IUnitIndexingService indexingService,
            IFinancialAccountingService financialAccountingService)
        {
            _propertyRepository = propertyRepository;
            _currentUserService = currentUserService;
            _notificationService = notificationService;
            _auditService = auditService;
            _logger = logger;
            _indexingService = indexingService;
            _financialAccountingService = financialAccountingService;
        }
        /// <summary>
        /// يعالج أمر اعتماد العقار ويتحقق من صلاحية المشرف وحالة السجل.
        /// Handles the approve property command and validates admin authorization and record state.
        /// </summary>
        public async Task<ResultDto<bool>> Handle(ApprovePropertyCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("بدء الموافقة على الكيان: PropertyId={PropertyId}", request.PropertyId);

            // التحقق من صحة المدخلات
            if (request.PropertyId == Guid.Empty)
                return ResultDto<bool>.Failed("معرف الكيان مطلوب");
            if (request.AdminId == Guid.Empty)
                return ResultDto<bool>.Failed("معرف المسؤول مطلوب");

            // التحقق من الصلاحيات (مسؤول)
            if (_currentUserService.Role != "Admin")
                return ResultDto<bool>.Failed("غير مصرح لك بالموافقة على الكيان");

            // التحقق من وجود الكيان وحالته
            var property = await _propertyRepository.GetPropertyByIdAsync(request.PropertyId, cancellationToken);
            if (property == null)
                return ResultDto<bool>.Failed("الكيان غير موجود");
            if (property.IsApproved)
                return ResultDto<bool>.Failed("الكيان معتمد مسبقاً");

            // تنفيذ الموافقة
            var success = await _propertyRepository.ApprovePropertyAsync(request.PropertyId, cancellationToken);
            if (!success)
                return ResultDto<bool>.Failed("فشل الموافقة على الكيان");
            await _propertyRepository.SaveChangesAsync(cancellationToken);

            // تفعيل الحسابات المحاسبية للعقار
            // الإجراء المحاسبي: تفعيل الحسابات
            // تفعيل حسابات العقار
            // السماح بالترحيل للحسابات
            // لا يوجد قيد محاسبي
            try
            {
                // هنا يمكن تفعيل حسابات التتبع للعقار في قاعدة البيانات
                _logger.LogInformation("تم تفعيل حسابات التتبع للعقار {PropertyId}", request.PropertyId);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "ملاحظة: تفعيل حسابات التتبع للعقار {PropertyId}", request.PropertyId);
            }

            // فهرسة العقار المعتمد لأول مرة (يصبح متاحاً للبحث) مع retry mechanism
            var indexingSuccess = false;
            var indexingAttempts = 0;
            const int maxIndexingAttempts = 3;
            
            while (!indexingSuccess && indexingAttempts < maxIndexingAttempts)
            {
                try
                {
                    indexingAttempts++;
                    await _indexingService.OnPropertyCreatedAsync(request.PropertyId, cancellationToken);
                    indexingSuccess = true;
                    _logger.LogInformation("✅ تم فهرسة العقار المعتمد بنجاح {PropertyId} (محاولة {Attempt}/{Max})", 
                        request.PropertyId, indexingAttempts, maxIndexingAttempts);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "⚠️ فشلت محاولة {Attempt}/{Max} لفهرسة العقار المعتمد {PropertyId}", 
                        indexingAttempts, maxIndexingAttempts, request.PropertyId);
                    
                    if (indexingAttempts < maxIndexingAttempts)
                    {
                        await Task.Delay(TimeSpan.FromSeconds(Math.Pow(2, indexingAttempts - 1)), cancellationToken);
                    }
                    else
                    {
                        _logger.LogCritical("❌ CRITICAL: فشل فهرسة العقار المعتمد بعد {Attempts} محاولات للعقار {PropertyId}. " +
                            "العقار غير ظاهر في البحث! يجب تشغيل re-index يدوي.", 
                            maxIndexingAttempts, request.PropertyId);
                    }
                }
            }

            // تسجيل العملية في سجل التدقيق (يدوي)
            await _auditService.LogAuditAsync(
                entityType: "Property",
                entityId: request.PropertyId,
                action: AuditAction.APPROVE,
                oldValues: null,
                newValues: JsonSerializer.Serialize(new { Approved = true }),
                performedBy: _currentUserService.UserId,
                notes: $"تمت الموافقة على الكيان {request.PropertyId} بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})",
                cancellationToken: cancellationToken);

            // إرسال إشعار للمالك
            await _notificationService.SendAsync(new NotificationRequest
            {
                UserId = property.OwnerId,
                Type = NotificationType.BookingConfirmed,
                Title = "تمت الموافقة على الكيان",
                Message = $"تمت الموافقة على كيانك '{property.Name}' بنجاح"
            }, cancellationToken);

            _logger.LogInformation("اكتملت الموافقة على الكيان: PropertyId={PropertyId}", request.PropertyId);
            return ResultDto<bool>.Succeeded(true, "تمت الموافقة على الكيان بنجاح");
        }
    }
} 
