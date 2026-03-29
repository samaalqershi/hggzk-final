using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Helpers;
using YemenBooking.Application.Features.Policies;
using YemenBooking.Application.Features.Amenities.DTOs;
using YemenBooking.Application.Common.Helpers;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features.PropertyServices.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Properties.Queries.GetPropertyDetails;

/// <summary>
/// يعالج استعلام عرض تفاصيل العقار للعميل.
/// Handles the client property details query.
/// </summary>
public class ClientGetPropertyDetailsQueryHandler : IRequestHandler<GetPropertyDetailsQuery, ResultDto<PropertyDetailsDto>>
{
    private readonly IAmenityRepository _amenityRepository;
    private readonly IPropertyServiceRepository _propertyServiceRepository;
    private readonly IPolicyRepository _policyRepository;
    private readonly IUnitRepository _unitRepository;
    private readonly IPropertyRepository _propertyRepository;
    private readonly IPropertyTypeRepository _propertyTypeRepository;
    private readonly IReviewRepository _reviewRepository;
    private readonly IFavoriteRepository _favoriteRepository;
    private readonly IPropertyImageRepository _propertyImageRepository;
    private readonly ILogger<ClientGetPropertyDetailsQueryHandler> _logger;

    /// <summary>
    /// يهيّئ مثيلاً جديداً من [ClientGetPropertyDetailsQueryHandler].
    /// Initializes a new instance of [ClientGetPropertyDetailsQueryHandler].
    /// </summary>
    public ClientGetPropertyDetailsQueryHandler(
        IAmenityRepository amenityRepository,
        IPropertyServiceRepository propertyServiceRepository,
        IPolicyRepository policyRepository,
        IUnitRepository unitRepository,
        IPropertyRepository propertyRepository,
        IPropertyTypeRepository propertyTypeRepository,
        IReviewRepository reviewRepository,
        IFavoriteRepository favoriteRepository,
        IPropertyImageRepository propertyImageRepository,
        ILogger<ClientGetPropertyDetailsQueryHandler> logger)
    {
        _amenityRepository = amenityRepository;
        _propertyServiceRepository = propertyServiceRepository;
        _policyRepository = policyRepository;
        _unitRepository = unitRepository;
        _propertyRepository = propertyRepository;
        _propertyTypeRepository = propertyTypeRepository;
        _reviewRepository = reviewRepository;
        _favoriteRepository = favoriteRepository;
        _propertyImageRepository = propertyImageRepository;
        _logger = logger;
    }
    /// <summary>
    /// يعالج استعلام تفاصيل العقار الموجه للعميل مع التضمينات الاختيارية.
    /// Handles the client-facing property details query with optional inclusions.
    /// </summary>
    public async Task<ResultDto<PropertyDetailsDto>> Handle(GetPropertyDetailsQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("جلب تفاصيل الكيان {PropertyId} للمستخدم {UserId}", request.PropertyId, request.UserId);

            // التحقق من صحة المعاملات
            if (request.PropertyId == Guid.Empty)
            {
                return ResultDto<PropertyDetailsDto>.Failure("معرف الكيان غير صحيح");
            }

            // البحث عن الكيان
            var property = await _propertyRepository.GetPropertyByIdAsync(request.PropertyId, cancellationToken);

            if (property == null)
            {
                _logger.LogWarning("الكيان غير موجود {PropertyId}", request.PropertyId);
                return ResultDto<PropertyDetailsDto>.Failure("الكيان غير موجود");
            }

            // تحويل إلى DTO
            var propertyDetails = await MapToPropertyDetailsDto(property, request.UserId, request.IncludeUnits);

            _logger.LogInformation("تم جلب تفاصيل الكيان {PropertyId} بنجاح", request.PropertyId);

            return ResultDto<PropertyDetailsDto>.SuccessResult(propertyDetails);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب تفاصيل الكيان {PropertyId}", request.PropertyId);
            return ResultDto<PropertyDetailsDto>.Failure("حدث خطأ أثناء جلب التفاصيل");
        }
    }

    private async Task<PropertyDetailsDto> MapToPropertyDetailsDto(Core.Entities.Property property, Guid? userId, bool includeUnits)
    {
        var dto = new PropertyDetailsDto
        {
            Id = property.Id,
            Name = property.Name,
            NameEn = property.NameEn,
            TypeId = property.TypeId,
            PropertyType = await GetPropertyTypeDto(property.TypeId),
            Address = property.Address,
            AddressEn = property.AddressEn,
            City = property.City,
            CityEn = property.CityEn,
            Latitude = property.Latitude,
            Longitude = property.Longitude,
            StarRating = property.StarRating,
            Description = property.Description,
            DescriptionEn = property.DescriptionEn,
            ShortDescription = property.ShortDescription,
            ShortDescriptionEn = property.ShortDescriptionEn,
            AverageRating = property.AverageRating,
            ReviewsCount = await GetReviewsCount(property.Id),
            ViewCount = property.ViewCount,
            BookingCount = await GetBookingCount(property.Id),
            IsFavorite = await IsInFavorites(property.Id, userId),
            Images = await GetPropertyImages(property.Id),
            Amenities = await GetPropertyAmenities(property.Id),
            Services = await GetPropertyServices(property.Id),
            Policies = await GetPropertyPolicies(property.Id),
            IsApproved = property.IsApproved,
            Currency = property.Currency,
            IsFeatured = property.IsFeatured,
            SystemCommissionRate = property.SystemCommissionRate,
        };

        if (includeUnits)
        {
            try
            {
                var units = await _unitRepository.GetUnitsByPropertyAsync(property.Id, CancellationToken.None);

                dto.Units = units
                    .Where(u => !u.IsDeleted)
                    .Select(u => new YemenBooking.Application.Features.Units.DTOs.UnitDetailsDto
                    {
                        Id = u.Id,
                        PropertyId = u.PropertyId,
                        PropertyName = property.Name ?? string.Empty,
                        PropertyNameEn = property.NameEn,
                        Name = u.Name ?? string.Empty,
                        NameEn = u.NameEn,
                        UnitTypeId = u.UnitTypeId,
                        UnitTypeName = u.UnitType?.Name ?? string.Empty,
                        UnitTypeNameEn = u.UnitType?.NameEn,
                        MaxCapacity = u.MaxCapacity,
                        PricingMethod = u.PricingMethod.ToString(),
                        CustomFeatures = u.CustomFeatures ?? string.Empty,
                        CustomFeaturesEn = u.CustomFeaturesEn
                    })
                    .ToList();

                dto.UnitsCount = dto.Units.Count;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء جلب وحدات العقار {PropertyId}", property.Id);
            }
        }

        return dto;
    }

    private async Task<PropertyTypeDto> GetPropertyTypeDto(Guid propertyTypeId)
    {
        try
        {
            var propertyType = await _propertyTypeRepository.GetPropertyTypeByIdAsync(propertyTypeId);

            if (propertyType == null)
            {
                return new PropertyTypeDto
                {
                Id = Guid.Empty,
                Name = LocalizedText.Choose("غير محدد", "Unspecified"),
                NameEn = "Unspecified",
                Description = LocalizedText.Choose("نوع غير محدد", "Unspecified type")
            };
            }

            return new PropertyTypeDto
            {
                Id = propertyType.Id,
                Name = propertyType.Name,
                NameEn = propertyType.NameEn,
                Description = propertyType.Description ?? string.Empty,
                DescriptionEn = propertyType.DescriptionEn
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في جلب نوع الكيان {PropertyTypeId}", propertyTypeId);
            return new PropertyTypeDto
            {
                Id = Guid.Empty,
                Name = LocalizedText.Choose("غير محدد", "Unspecified"),
                NameEn = "Unspecified",
                Description = LocalizedText.Choose("خطأ في جلب البيانات", "Error loading data")
            };
        }
    }

    private async Task<int> GetReviewsCount(Guid propertyId)
    {
        try
        {
            var (_, totalReviews) = await _reviewRepository.GetPropertyRatingStatsAsync(propertyId);
            return totalReviews;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في جلب عدد المراجعات للكيان {PropertyId}", propertyId);
            return 0;
        }
    }

    private async Task<int> GetBookingCount(Guid propertyId)
    {
        try
        {
            return await _propertyRepository.GetPropertyBookingCountAsync(propertyId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في جلب عدد الحجوزات للكيان {PropertyId}", propertyId);
            return 0;
        }
    }

    private async Task<bool> IsInFavorites(Guid propertyId, Guid? userId)
    {
        try
        {
            if (!userId.HasValue) return false;

            return await _favoriteRepository.ExistsAsync(userId.Value, propertyId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في التحقق من المفضلات للكيان {PropertyId} والمستخدم {UserId}", propertyId, userId);
            return false;
        }
    }

    private async Task<List<PropertyImageDto>> GetPropertyImages(Guid propertyId)
    {
        try
        {
            var images = await _propertyImageRepository.GetImagesByPropertyAsync(propertyId);

            var propertyImages = images
                .OrderBy(img => img.DisplayOrder)
                .ThenBy(img => img.CreatedAt)
                .ToList();

            var dtos = propertyImages.Select(img => new PropertyImageDto
            {
                Id = img.Id,
                PropertyId = img.PropertyId,
                UnitId = img.UnitId,
                SectionId = img.SectionId,
                PropertyInSectionId = img.PropertyInSectionId,
                UnitInSectionId = img.UnitInSectionId,
                CityName = img.CityName,
                Name = img.Name ?? string.Empty,
                Url = img.Url ?? string.Empty,
                SizeBytes = img.SizeBytes,
                Type = img.Type ?? string.Empty,
                Category = img.Category,
                Caption = img.Caption ?? string.Empty,
                AltText = img.AltText ?? string.Empty,
                Tags = img.Tags ?? string.Empty,
                Sizes = img.Sizes ?? string.Empty,
                IsMain = img.IsMain || img.IsMainImage,
                DisplayOrder = img.DisplayOrder != 0 ? img.DisplayOrder : img.SortOrder,
                UploadedAt = img.UploadedAt,
                Status = img.Status,
                Is360 = img.Is360,
                AssociationType = img.UnitId.HasValue ? "Unit" : "Property"
            }).ToList();

            return dtos;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في جلب صور الكيان {PropertyId}", propertyId);
            return new List<PropertyImageDto>();
        }
    }

    private async Task<List<PropertyAmenityDto>> GetPropertyAmenities(Guid propertyId)
    {
        try
        {
            var amenities = await _amenityRepository.GetAmenitiesByPropertyAsync(propertyId, CancellationToken.None);

            var amenityDtos = amenities?.Select(amenity => new PropertyAmenityDto
            {
                Id = amenity.Id,
                AmenityId = amenity.PropertyTypeAmenity.Amenity.Id,
                Name = amenity.PropertyTypeAmenity.Amenity.Name ?? string.Empty,
                NameEn = amenity.PropertyTypeAmenity.Amenity.NameEn,
                Description = amenity.PropertyTypeAmenity.Amenity.Description ?? string.Empty,
                CategoryEn = amenity.PropertyTypeAmenity.Amenity.NameEn,
                IconUrl = string.Empty,
                Category = amenity.PropertyTypeAmenity.Amenity.Name ?? string.Empty,
                Icon = amenity.PropertyTypeAmenity.Amenity.Icon,
                IsAvailable = amenity.IsAvailable,
                ExtraCost = amenity.ExtraCost
            }).ToList() ?? new List<PropertyAmenityDto>();

            _logger.LogInformation("تم جلب {Count} مرفق للكيان {PropertyId}", amenityDtos.Count, propertyId);

            return amenityDtos;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في جلب وسائل الراحة للكيان {PropertyId}", propertyId);
            return new List<PropertyAmenityDto>();
        }
    }

    private async Task<List<PropertyServiceDto>> GetPropertyServices(Guid propertyId)
    {
        try
        {
            var services = await _propertyServiceRepository.GetPropertyServicesAsync(propertyId, CancellationToken.None);

            var serviceDtos = services?.Select(service => new PropertyServiceDto
            {
                Id = service.Id,
                Name = service.Name ?? string.Empty,
                NameEn = service.NameEn,
                Price = service.Price,
                Currency = service.Price.Currency ?? "YER",
                PricingModel = service.PricingModel.ToString() ?? string.Empty,
                Description = service.Description ?? string.Empty,
                DescriptionEn = service.DescriptionEn,
                Icon = service.Icon ?? string.Empty
            }).ToList() ?? new List<PropertyServiceDto>();

            _logger.LogInformation("تم جلب {Count} خدمة للكيان {PropertyId}", serviceDtos.Count, propertyId);

            return serviceDtos;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في جلب خدمات الكيان {PropertyId}", propertyId);
            return new List<PropertyServiceDto>();
        }
    }

    private async Task<List<PropertyPolicyDto>> GetPropertyPolicies(Guid propertyId)
    {
        try
        {
            var policies = await _policyRepository.GetPropertyPoliciesAsync(propertyId, CancellationToken.None);

            return policies.Select(policy => new PropertyPolicyDto
            {
                Id = policy.Id,
                PolicyType = policy.Type.ToString(),
                PolicyContent = policy.Description ?? string.Empty,
                IsActive = policy.IsActive,
                Type = policy.Type.ToString(),
                Description = policy.Description ?? string.Empty,
                DescriptionEn = policy.DescriptionEn,
                RulesEn = policy.RulesEn,
                RulesJson = policy.Rules,
                Rules = PolicyRulesMapper.BuildRulesDictionary(policy)
            }).ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في جلب سياسات الكيان {PropertyId}", propertyId);
            return new List<PropertyPolicyDto>();
        }
    }
}
