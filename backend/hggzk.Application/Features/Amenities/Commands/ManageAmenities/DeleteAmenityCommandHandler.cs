using System;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Amenities;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using System.Linq;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.SearchAndFilters.Services;

namespace YemenBooking.Application.Features.Amenities.Commands.ManageAmenities
{
    /// <summary>
    /// معالج أمر حذف المرفق
    /// </summary>
    public class DeleteAmenityCommandHandler : IRequestHandler<DeleteAmenityCommand, ResultDto<bool>>
    {
        private readonly IAmenityRepository _amenityRepository;
        private readonly IPropertyTypeAmenityRepository _propertyTypeAmenityRepository;
        private readonly IPropertyAmenityRepository _propertyAmenityRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly IAuditService _auditService;
        private readonly ILogger<DeleteAmenityCommandHandler> _logger;
        private readonly IUnitIndexingService _indexingService;

        /// <summary>
        /// يُهيِّئ المعالج بالاعتمادات المطلوبة.
        /// Initializes the handler with the required dependencies.
        /// </summary>
        public DeleteAmenityCommandHandler(
            IAmenityRepository amenityRepository,
            IPropertyTypeAmenityRepository propertyTypeAmenityRepository,
            IPropertyAmenityRepository propertyAmenityRepository,
            ICurrentUserService currentUserService,
            IAuditService auditService,
            ILogger<DeleteAmenityCommandHandler> logger,
            IUnitIndexingService indexingService)
        {
            _amenityRepository = amenityRepository;
            _propertyTypeAmenityRepository = propertyTypeAmenityRepository;
            _propertyAmenityRepository = propertyAmenityRepository;
            _currentUserService = currentUserService;
            _auditService = auditService;
            _logger = logger;
            _indexingService = indexingService;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة.
    /// Processes the delete amenity command and returns the result.
    /// </summary>
        public async Task<ResultDto<bool>> Handle(DeleteAmenityCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("بدء معالجة أمر حذف المرفق: {AmenityId}", request.AmenityId);

            try
            {
                // التحقق من صحة المدخلات
                var errors = new List<string>();
                if (request.AmenityId == Guid.Empty)
                    errors.Add("معرف المرفق مطلوب");

                if (errors.Count > 0)
                    return ResultDto<bool>.Failed(errors, "بيانات المدخلات غير صحيحة");

                // التحقق من وجود المرفق
                var existingAmenity = await _amenityRepository.GetByIdAsync(request.AmenityId, cancellationToken);
                if (existingAmenity == null)
                    return ResultDto<bool>.Failed("المرفق غير موجود");

                // التحقق من الصلاحيات
                var isAdmin = string.Equals(_currentUserService.Role, "Admin", StringComparison.OrdinalIgnoreCase)
                    || string.Equals(_currentUserService.AccountRole, "Admin", StringComparison.OrdinalIgnoreCase)
                    || (_currentUserService.UserRoles?.Any(r => string.Equals(r, "Admin", StringComparison.OrdinalIgnoreCase)) ?? false);
                if (!isAdmin)
                    return ResultDto<bool>.Failed("غير مصرح لك بحذف المرفق");

                // التحقق من عدم استخدام المرفق بأنواع الكيانات أو الكيانات نفسها
                var isUsedInType = await _propertyTypeAmenityRepository
                    .ExistsAsync(pta => pta.AmenityId == request.AmenityId, cancellationToken);
                if (isUsedInType)
                    return ResultDto<bool>.Failed("لا يمكن حذف المرفق لأنه مرتبط بأنواع الكيانات");

                // إذا كانت هناك وسيلة من هذا النوع مخصصة لعقار، نرفض الحذف
                var ptaIds = await _propertyTypeAmenityRepository
                    .FindAsync(x => x.AmenityId == request.AmenityId, cancellationToken);
                if (ptaIds.Any())
                {
                    var hasPropertyAmenity = await _propertyAmenityRepository
                        .ExistsAsync(pa => ptaIds.Select(p => p.Id).Contains(pa.PtaId), cancellationToken);
                    if (hasPropertyAmenity)
                        return ResultDto<bool>.Failed("لا يمكن حذف المرفق لأنه مستخدم في عقارات حالية");
                }

                // التنفيذ: الحذف الناعم
                existingAmenity.IsDeleted = true;
                existingAmenity.DeletedAt = DateTime.UtcNow;
                existingAmenity.DeletedBy = _currentUserService.UserId;

                await _amenityRepository.UpdateAmenityAsync(existingAmenity, cancellationToken);
                await _amenityRepository.SaveChangesAsync(cancellationToken);

                // الآثار الجانبية: تسجيل العملية في السجل (يدوي) مع اسم المستخدم والمعرف
                var notes = $"تم حذف المرفق بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})";
                await _auditService.LogAuditAsync(
                    entityType: nameof(Amenity),
                    entityId: existingAmenity.Id,
                    action: AuditAction.DELETE,
                    oldValues: System.Text.Json.JsonSerializer.Serialize(new { existingAmenity.Id, existingAmenity.Name }),
                    newValues: null,
                    performedBy: _currentUserService.UserId,
                    notes: notes,
                    cancellationToken: cancellationToken);

                // تحديث مباشر لفهرس العقارات المتأثرة
                try
                {
                    var _ptaIds = await _propertyTypeAmenityRepository
                        .FindAsync(x => x.AmenityId == existingAmenity.Id, cancellationToken);
                    var propertyAmenities = await _propertyAmenityRepository
                        .FindAsync(x => _ptaIds.Select(p => p.Id).Contains(x.PtaId), cancellationToken);

                    foreach (var pa in propertyAmenities)
                    {
                        await _indexingService.OnPropertyUpdatedAsync(pa.PropertyId, cancellationToken);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "تعذرت الفهرسة المباشرة للعقارات بعد حذف المرفق {AmenityId}", existingAmenity.Id);
                }

                _logger.LogInformation("تم حذف المرفق بالمعرف {AmenityId}", existingAmenity.Id);
                return ResultDto<bool>.Succeeded(true, "تم حذف المرفق بنجاح");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ في معالجة أمر حذف المرفق: {AmenityId}", request.AmenityId);
                return ResultDto<bool>.Failed("حدث خطأ أثناء حذف المرفق");
            }
        }
    }
} 
