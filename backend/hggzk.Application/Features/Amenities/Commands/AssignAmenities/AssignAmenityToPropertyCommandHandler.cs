using System;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Amenities;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.ValueObjects;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.SearchAndFilters.Services;

namespace YemenBooking.Application.Features.Amenities.Commands.AssignAmenities
{
    /// <summary>
    /// معالج أمر ربط المرفق بكيان
    /// </summary>
    public class AssignAmenityToPropertyCommandHandler : IRequestHandler<AssignAmenityToPropertyCommand, ResultDto<bool>>
    {
        private readonly IPropertyRepository _propertyRepository;
        private readonly IAmenityRepository _amenityRepository;
        private readonly IPropertyTypeAmenityRepository _propertyTypeAmenityRepository;
        private readonly IPropertyAmenityRepository _propertyAmenityRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly IAuditService _auditService;
        private readonly ILogger<AssignAmenityToPropertyCommandHandler> _logger;
        private readonly IUnitIndexingService _indexingService;

        /// <summary>
        /// يُهيِّئ المعالج بالاعتمادات المطلوبة.
        /// Initializes the handler with the required dependencies.
        /// </summary>
        public AssignAmenityToPropertyCommandHandler(
            IPropertyRepository propertyRepository,
            IAmenityRepository amenityRepository,
            IPropertyTypeAmenityRepository propertyTypeAmenityRepository,
            IPropertyAmenityRepository propertyAmenityRepository,
            ICurrentUserService currentUserService,
            IAuditService auditService,
            ILogger<AssignAmenityToPropertyCommandHandler> logger,
            IUnitIndexingService indexingService)
        {
            _propertyRepository = propertyRepository;
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
    /// Processes the amenity-to-property assignment command and returns the result.
    /// </summary>
        public async Task<ResultDto<bool>> Handle(AssignAmenityToPropertyCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("بدء معالجة أمر ربط المرفق بالكيان: PropertyId={PropertyId}, AmenityId={AmenityId}", request.PropertyId, request.AmenityId);

            try
            {
                // التحقق من صحة المدخلات
                var errors = new List<string>();
                if (request.PropertyId == Guid.Empty)
                    errors.Add("معرف الكيان مطلوب");
                if (request.AmenityId == Guid.Empty)
                    errors.Add("معرف المرفق مطلوب");

                if (errors.Count > 0)
                    return ResultDto<bool>.Failed(errors, "بيانات المدخلات غير صحيحة");

                // التحقق من وجود الكيان والمرفق
                var property = await _propertyRepository.GetByIdAsync(request.PropertyId, cancellationToken);
                if (property == null)
                    return ResultDto<bool>.Failed("الكيان غير موجود");

                var amenity = await _amenityRepository.GetByIdAsync(request.AmenityId, cancellationToken);
                if (amenity == null)
                    return ResultDto<bool>.Failed("المرفق غير موجود");

                // التحقق من الصلاحيات
                var isAdmin = string.Equals(_currentUserService.Role, "Admin", StringComparison.OrdinalIgnoreCase)
                    || string.Equals(_currentUserService.AccountRole, "Admin", StringComparison.OrdinalIgnoreCase)
                    || (_currentUserService.UserRoles?.Any(r => string.Equals(r, "Admin", StringComparison.OrdinalIgnoreCase)) ?? false);
                var isOwnerAuthorized = property.OwnerId == _currentUserService.UserId;
                var isStaffAuthorized = _currentUserService.IsStaffInProperty(request.PropertyId);
                if (!isAdmin && !(isOwnerAuthorized || isStaffAuthorized))
                    return ResultDto<bool>.Failed("ليس لديك صلاحية لربط المرفق بهذا الكيان");

                // التحقق من وجود علاقة نوع الكيان والمرفق
                var pta = await _propertyTypeAmenityRepository
                    .FirstOrDefaultAsync(x => x.PropertyTypeId == property.TypeId && x.AmenityId == request.AmenityId, cancellationToken);
                if (pta == null)
                    return ResultDto<bool>.Failed("المرفق غير مخصص لنوع الكيان");

                // التحقق من عدم وجود الربط مسبقاً
                var exists = await _propertyAmenityRepository
                    .ExistsAsync(x => x.PropertyId == request.PropertyId && x.PtaId == pta.Id, cancellationToken);
                if (exists)
                    return ResultDto<bool>.Failed("المرفق مرتبط مسبقاً بهذا الكيان");

                // التنفيذ: إنشاء ربط
                var propertyAmenity = new PropertyAmenity
                {
                    PropertyId = request.PropertyId,
                    PtaId = pta.Id,
                    IsAvailable = request.IsAvailable,
                    ExtraCost = request.ExtraCost.HasValue ? new Money(request.ExtraCost.Value, "YER") : Money.Zero("YER"),
                    // Description = string.IsNullOrWhiteSpace(request.Description) ? null : request.Description!.Trim()
                };

                await _propertyAmenityRepository.AddAmenityToPropertyAsync(propertyAmenity, cancellationToken);
                await _propertyAmenityRepository.SaveChangesAsync(cancellationToken);

                // الآثار الجانبية: تسجيل العملية في السجل (يدوي) مع اسم المستخدم والمعرف
                var notes = $"تم ربط المرفق بالكيان بنجاح بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})";
                await _auditService.LogAuditAsync(
                    entityType: nameof(PropertyAmenity),
                    entityId: propertyAmenity.Id,
                    action: AuditAction.CREATE,
                    oldValues: null,
                    newValues: System.Text.Json.JsonSerializer.Serialize(new { propertyAmenity.PropertyId, propertyAmenity.PtaId, propertyAmenity.IsAvailable, propertyAmenity.ExtraCost }),
                    performedBy: _currentUserService.UserId,
                    notes: notes,
                    cancellationToken: cancellationToken);

                // تحديث فهرس العقار بعد إضافة المرفق مع retry mechanism
                var indexingSuccess = false;
                var indexingAttempts = 0;
                const int maxIndexingAttempts = 3;
                
                while (!indexingSuccess && indexingAttempts < maxIndexingAttempts)
                {
                    try
                    {
                        indexingAttempts++;
                        await _indexingService.OnPropertyUpdatedAsync(request.PropertyId, cancellationToken);
                        indexingSuccess = true;
                        _logger.LogInformation("✅ تم تحديث فهرس العقار بعد إضافة المرفق {PropertyId} (محاولة {Attempt}/{Max})", 
                            request.PropertyId, indexingAttempts, maxIndexingAttempts);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "⚠️ فشلت محاولة {Attempt}/{Max} لتحديث فهرس العقار بعد إضافة المرفق {PropertyId}", 
                            indexingAttempts, maxIndexingAttempts, request.PropertyId);
                        
                        if (indexingAttempts < maxIndexingAttempts)
                        {
                            await Task.Delay(TimeSpan.FromSeconds(Math.Pow(2, indexingAttempts - 1)), cancellationToken);
                        }
                        else
                        {
                            _logger.LogCritical("❌ CRITICAL: فشل تحديث فهرس العقار بعد {Attempts} محاولات للعقار {PropertyId}. " +
                                "المرفق مضاف في DB لكن غير ظاهر في البحث! يجب تشغيل re-index يدوي.", 
                                maxIndexingAttempts, request.PropertyId);
                        }
                    }
                }

                _logger.LogInformation("تم ربط المرفق بالكيان: PropertyAmenityId={PaId}", propertyAmenity.Id);
                return ResultDto<bool>.Succeeded(true, "تم ربط المرفق بالكيان بنجاح");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ في معالجة أمر ربط المرفق بالكيان: PropertyId={PropertyId}, AmenityId={AmenityId}", request.PropertyId, request.AmenityId);
                return ResultDto<bool>.Failed("حدث خطأ أثناء ربط المرفق بالكيان");
            }
        }
    }
}
