using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features.Amenities.DTOs;
using YemenBooking.Application.Features.Policies.DTOs;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features.PropertyServices.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Properties.Queries.GetPropertyDetails;

/// <summary>
/// يعالج استعلام تفاصيل العقار.
/// Handles the property details query.
/// </summary>
public class GetPropertyDetailsQueryHandler : IRequestHandler<GetPropertyDetailsQuery, ResultDto<PropertyDetailsDto>>
{
    private readonly IPropertyRepository _propertyRepository;
    private readonly IPropertyTypeRepository _propertyTypeRepository;
    private readonly IPropertyImageRepository _propertyImageRepository;
    private readonly IAmenityRepository _amenityRepository;
    private readonly IPropertyServiceRepository _propertyServiceRepository;
    private readonly IPolicyRepository _policyRepository;
    private readonly IFavoriteRepository _favoriteRepository;
    private readonly IReviewRepository _reviewRepository;
    private readonly ILogger<GetPropertyDetailsQueryHandler> _logger;

    /// <summary>
    /// يهيّئ مثيلاً جديداً من [GetPropertyDetailsQueryHandler].
    /// Initializes a new instance of [GetPropertyDetailsQueryHandler].
    /// </summary>
    public GetPropertyDetailsQueryHandler(
        IPropertyRepository propertyRepository,
        IPropertyTypeRepository propertyTypeRepository,
        IPropertyImageRepository propertyImageRepository,
        IAmenityRepository amenityRepository,
        IPropertyServiceRepository propertyServiceRepository,
        IPolicyRepository policyRepository,
        IFavoriteRepository favoriteRepository,
        IReviewRepository reviewRepository,
        ILogger<GetPropertyDetailsQueryHandler> logger)
    {
        _propertyRepository = propertyRepository;
        _propertyTypeRepository = propertyTypeRepository;
        _propertyImageRepository = propertyImageRepository;
        _amenityRepository = amenityRepository;
        _propertyServiceRepository = propertyServiceRepository;
        _policyRepository = policyRepository;
        _favoriteRepository = favoriteRepository;
        _reviewRepository = reviewRepository;
        _logger = logger;
    }
    /// <summary>
    /// يعالج استعلام تفاصيل العقار الكامل مع الإحصاءات والعلاقات.
    /// Handles the full property details query with statistics and related data.
    /// </summary>
    public async Task<ResultDto<PropertyDetailsDto>> Handle(GetPropertyDetailsQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء استعلام تفاصيل العقار. معرف العقار: {PropertyId}, معرف المستخدم: {UserId}", 
                request.PropertyId, request.UserId);

            // التحقق من صحة البيانات المدخلة
            var validationResult = ValidateRequest(request);
            if (!validationResult.IsSuccess)
            {
                return validationResult;
            }

            // الحصول على العقار
            var property = await _propertyRepository.GetPropertyByIdAsync(request.PropertyId, cancellationToken);
            if (property == null)
            {
                _logger.LogWarning("لم يتم العثور على العقار: {PropertyId}", request.PropertyId);
                return ResultDto<PropertyDetailsDto>.Failed("العقار غير موجود", "PROPERTY_NOT_FOUND");
            }

            // التحقق من أن العقار نشط
            if (!property.IsActive)
            {
                _logger.LogWarning("العقار غير نشط: {PropertyId}", request.PropertyId);
                return ResultDto<PropertyDetailsDto>.Failed("العقار غير متاح حالياً", "PROPERTY_INACTIVE");
            }

            // الحصول على نوع العقار
            var propertyType = await _propertyTypeRepository.GetByIdAsync(property.TypeId, cancellationToken);
            var propertyTypeDto = propertyType != null ? new PropertyTypeDto
            {
                Id = propertyType.Id,
                Name = propertyType.Name ?? string.Empty,
                Description = propertyType.Description ?? string.Empty
            } : new PropertyTypeDto();

            // الحصول على صور العقار
            var images = await _propertyImageRepository.GetByPropertyIdAsync(property.Id, cancellationToken);
            var imageDtos = images?.Select(img => new PropertyImageDto
            {
                Id = img.Id,
                Url = img.Url ?? string.Empty,
                Caption = img.Caption ?? string.Empty,
                IsMain = img.IsMain,
                DisplayOrder = img.DisplayOrder
            }).OrderBy(img => img.DisplayOrder).ToList() ?? new List<PropertyImageDto>();

            // الحصول على وسائل الراحة
            var amenities = await _amenityRepository.GetAmenitiesByPropertyAsync(property.Id, cancellationToken);
            var amenityDtos = amenities?.Select(amenity => new PropertyAmenityDto
            {
                Id = amenity.Id,
                AmenityId = amenity.PropertyTypeAmenity.Amenity.Id,
                Name = amenity.PropertyTypeAmenity.Amenity.Name ?? string.Empty,
                Description = amenity.PropertyTypeAmenity.Amenity.Description ?? string.Empty,
                IconUrl = string.Empty,
                Category = amenity.PropertyTypeAmenity.Amenity.Name ?? string.Empty,
                Icon = amenity.PropertyTypeAmenity.Amenity.Icon,
                IsAvailable = amenity.IsAvailable,
                ExtraCost = amenity.ExtraCost
            }).ToList() ?? new List<PropertyAmenityDto>();
            
            _logger.LogInformation("تم جلب {Count} مرفق للعقار {PropertyId}", amenityDtos.Count, property.Id);

            // الحصول على الخدمات
            var services = await _propertyServiceRepository.GetPropertyServicesAsync(property.Id, cancellationToken);
            var serviceDtos = services?.Select(service => new PropertyServiceDto
            {
                Id = service.Id,
                Name = service.Name ?? string.Empty,
                Price = service.Price,
                Currency = service.Price.Currency ?? "YER",
                PricingModel = service.PricingModel.ToString() ?? string.Empty,
                Description = service.Description ?? string.Empty,
                Icon = service.Icon ?? string.Empty
            }).ToList() ?? new List<PropertyServiceDto>();
            
            _logger.LogInformation("تم جلب {Count} خدمة للعقار {PropertyId}", serviceDtos.Count, property.Id);
            if (serviceDtos.Count == 0)
            {
                _logger.LogWarning("لا توجد خدمات مرتبطة بالعقار {PropertyId}", property.Id);
            }

            // الحصول على السياسات
            var policies = await _policyRepository.GetPropertyPoliciesAsync(property.Id, cancellationToken);
            var policyDtos = policies?.Select(policy => new PropertyPolicyDto
            {
                Id = policy.Id,
                Type = policy.Type.ToString(),
                Description = policy.Description ?? string.Empty
            }).ToList() ?? new List<PropertyPolicyDto>();

            // الحصول على إحصائيات العقار
            // الحصول على إحصائيات التقييم
            var ratingStats = await _reviewRepository.GetPropertyRatingStatsAsync(property.Id, cancellationToken);
            var averageRating = ratingStats.AverageRating;
            var reviewsCount = ratingStats.TotalReviews;
            var bookingCount = await _propertyRepository.GetPropertyBookingCountAsync(property.Id, cancellationToken);

            var unitsCount = await _propertyRepository.GetUnitsCountAsync(property.Id, cancellationToken);
            var servicesCount = await _propertyRepository.GetServicesCountAsync(property.Id, cancellationToken);
            var amenitiesCount = await _propertyRepository.GetAmenitiesCountAsync(property.Id, cancellationToken);
            var paymentsCount = await _propertyRepository.GetPaymentsCountAsync(property.Id, cancellationToken);

            _logger.LogInformation(
                "إحصائيات العقار {PropertyId}: المشاهدات={ViewCount}, الحجوزات={BookingCount}, التقييمات={ReviewsCount}, المتوسط={AvgRating:F2}",
                property.Id,
                property.ViewCount + 1,
                bookingCount,
                reviewsCount,
                averageRating
            );

            _logger.LogInformation(
                "إحصائيات إضافية للعقار {PropertyId}: الوحدات={UnitsCount}, الخدمات={ServicesCount}, المرافق={AmenitiesCount}, المدفوعات={PaymentsCount}",
                property.Id,
                unitsCount,
                servicesCount,
                amenitiesCount,
                paymentsCount
            );

            // التحقق من حالة المفضلات
            bool isFavorite = false;
            if (request.UserId.HasValue && request.UserId.Value != Guid.Empty)
            {
                isFavorite = await _favoriteRepository.IsPropertyFavoriteAsync(request.UserId.Value, property.Id, cancellationToken);
            }

            // تحديث عدد المشاهدات فقط إذا كان المستخدم عميل أو غير مسجل دخول
            var currentViewCount = property.ViewCount;
            if (string.IsNullOrEmpty(request.UserRole) || request.UserRole.Equals("Client", StringComparison.OrdinalIgnoreCase))
            {
                property.ViewCount++;
                property.UpdatedAt = DateTime.UtcNow;
                await _propertyRepository.UpdatePropertyAsync(property, cancellationToken);
                await _propertyRepository.SaveChangesAsync(cancellationToken);
                currentViewCount = property.ViewCount;
                _logger.LogInformation("تم زيادة عداد المشاهدات للعقار {PropertyId} - المستخدم: {UserId}, الدور: {Role}", 
                    property.Id, request.UserId, request.UserRole ?? "غير مسجل");
            }
            else
            {
                _logger.LogInformation("لم يتم زيادة عداد المشاهدات - المستخدم ليس عميل: {Role}", request.UserRole);
            }

            // إنشاء DTO للاستجابة
            var propertyDetailsDto = new PropertyDetailsDto
            {
                Id = property.Id,
                Name = property.Name ?? string.Empty,
                IsApproved = property.IsApproved,
                TypeId = property.TypeId,
                PropertyType = propertyTypeDto,
                Address = property.Address ?? string.Empty,
                City = property.City ?? string.Empty,
                Latitude = property.Latitude,
                Longitude = property.Longitude,
                StarRating = property.StarRating,
                Description = property.Description ?? string.Empty,
                ShortDescription = property.ShortDescription,
                AverageRating = (decimal)averageRating,
                ReviewsCount = reviewsCount,
                ViewCount = currentViewCount,
                BookingCount = bookingCount,
                UnitsCount = unitsCount,
                ServicesCount = servicesCount,
                AmenitiesCount = amenitiesCount,
                PaymentsCount = paymentsCount,
                IsFavorite = isFavorite,
                Currency = property.Currency,
                IsFeatured = property.IsFeatured,
                SystemCommissionRate = property.SystemCommissionRate,
                Images = imageDtos,
                Amenities = amenityDtos,
                Services = serviceDtos,
                Policies = policyDtos
            };

            _logger.LogInformation("تم الحصول على تفاصيل العقار بنجاح. معرف العقار: {PropertyId}", request.PropertyId);

            return ResultDto<PropertyDetailsDto>.Ok(
                propertyDetailsDto, 
                "تم الحصول على تفاصيل العقار بنجاح"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء الحصول على تفاصيل العقار. معرف العقار: {PropertyId}", request.PropertyId);
            return ResultDto<PropertyDetailsDto>.Failed(
                $"حدث خطأ أثناء الحصول على تفاصيل العقار: {ex.Message}", 
                "GET_PROPERTY_DETAILS_ERROR"
            );
        }
    }

    private ResultDto<PropertyDetailsDto> ValidateRequest(GetPropertyDetailsQuery request)
    {
        if (request.PropertyId == Guid.Empty)
        {
            _logger.LogWarning("معرف العقار مطلوب");
            return ResultDto<PropertyDetailsDto>.Failed("معرف العقار مطلوب", "PROPERTY_ID_REQUIRED");
        }

        return ResultDto<PropertyDetailsDto>.Ok(null, "البيانات صحيحة");
    }
}
