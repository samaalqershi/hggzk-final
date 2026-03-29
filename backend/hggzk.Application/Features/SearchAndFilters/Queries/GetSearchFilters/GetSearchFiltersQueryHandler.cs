using MediatR;
using YBQuery = YemenBooking.Application.Features.SearchAndFilters.Queries.GetSearchFilters.GetSearchFiltersQuery;
using System.Linq;
using System.Collections.Generic;
using Microsoft.Extensions.Logging;

using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.SearchAndFilters;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features.SearchAndFilters.DTOs;
using YemenBooking.Application.Features;
using YemenBooking.Application.Features.SearchAndFilters.Services;
using YemenBooking.Core.Indexing.Models;

namespace YemenBooking.Application.Features.SearchAndFilters.Queries.GetSearchFilters;

/// <summary>
/// يعالج جلب البحث الفلاتر ويعيد النتيجة المطلوبة.
/// Processes the Get Search Filters request and returns the requested result.
/// </summary>
public class GetSearchFiltersQueryHandler : IRequestHandler<YBQuery, ResultDto<SearchFiltersDto>>
{
    private readonly IPropertyRepository _propertyRepository;
    private readonly IPropertyTypeRepository _propertyTypeRepository;
    private readonly IAmenityRepository _amenityRepository;
    private readonly IUnitRepository _unitRepository;
    private readonly IUnitTypeRepository _unitTypeRepository;
    private readonly IPropertyServiceRepository _propertyServiceRepository;
    private readonly ILogger<GetSearchFiltersQueryHandler> _logger;
    private readonly ISearchFacetService _searchFacetService;

    /// <summary>
    /// ينشئ مثيلاً جديداً من GetSearchFiltersQueryHandler.
    /// Initializes a new instance of GetSearchFiltersQueryHandler.
    /// </summary>
    /// <param name="propertyRepository">مستودع البيانات العقارية / Real-estate repository.</param>
    /// <param name="propertyTypeRepository">مستودع أنواع العقارات / Property type catalog.</param>
    /// <param name="amenityRepository">مستودع وسيلة الراحة / amenity repository.</param>
    /// <param name="unitRepository">مستودع الوحدة / unit repository.</param>
    /// <param name="unitTypeRepository">مستودع نوع الوحدة / unit Type repository.</param>
    /// <param name="propertyServiceRepository">مستودع خدمات العقارات / Real-estate service catalog.</param>
    /// <param name="logger">مسجل الأحداث / Logger.</param>
    public GetSearchFiltersQueryHandler(
        IPropertyRepository propertyRepository,
        IPropertyTypeRepository propertyTypeRepository,
        IAmenityRepository amenityRepository,
        IUnitRepository unitRepository,
        IUnitTypeRepository unitTypeRepository,
        IPropertyServiceRepository propertyServiceRepository,
        ILogger<GetSearchFiltersQueryHandler> logger,
        ISearchFacetService searchFacetService)
    {
        _propertyRepository = propertyRepository;
        _propertyTypeRepository = propertyTypeRepository;
        _amenityRepository = amenityRepository;
        _unitRepository = unitRepository;
        _unitTypeRepository = unitTypeRepository;
        _propertyServiceRepository = propertyServiceRepository;
        _logger = logger;
        _searchFacetService = searchFacetService;
    }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
    public async Task<ResultDto<SearchFiltersDto>> Handle(YBQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation(
                "بدء استعلام فلاتر البحث الحية. نوع العقار: {PropertyTypeId}, المدينة: {City}",
                request.PropertyTypeId,
                request.City);

            var searchRequest = new PropertyWithUnitsSearchRequest
            {
                City = request.City,
                PropertyTypeId = request.PropertyTypeId,
                GroupByProperty = true,
                PageNumber = 1,
                PageSize = 1
            };

            var searchFilters = await _searchFacetService.BuildFacetsAsync(searchRequest, cancellationToken);

            _logger.LogInformation(
                "تم جلب الفلاتر الحية بنجاح. المدن: {CitiesCount}, أنواع العقارات: {PropertyTypesCount}, وسائل الراحة: {AmenitiesCount}",
                searchFilters.AvailableCities.Count,
                searchFilters.PropertyTypes.Count,
                searchFilters.Amenities.Count);

            return ResultDto<SearchFiltersDto>.Ok(searchFilters, "تم جلب فلاتر البحث بنجاح");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب فلاتر البحث");
            return ResultDto<SearchFiltersDto>.Failed(
                $"حدث خطأ أثناء جلب فلاتر البحث: {ex.Message}", 
                "GET_SEARCH_FILTERS_ERROR"
            );
        }
    }

    private Task PopulateAvailableCities(SearchFiltersDto searchFilters, List<Core.Entities.Property> properties, CancellationToken cancellationToken)
    {
        try
        {
            var cities = properties
                .Where(p => !string.IsNullOrWhiteSpace(p.City))
                .Select(p => p.City!)
                .Distinct()
                .OrderBy(c => c)
                .ToList();

            searchFilters.AvailableCities = cities;
            
            _logger.LogDebug("تم جلب {Count} مدينة متاحة", cities.Count);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب المدن المتاحة");
            searchFilters.AvailableCities = new List<string>();
        }

        return Task.CompletedTask;
    }

    private Task PopulatePriceRange(SearchFiltersDto searchFilters, List<Core.Entities.Property> properties, CancellationToken cancellationToken)
    {
        try
        {
            var allPrices = new List<decimal>();

            if (allPrices.Any())
            {
                searchFilters.PriceRange = new PriceRangeDto
                {
                    MinPrice = allPrices.Min(),
                    MaxPrice = allPrices.Max(),
                    AveragePrice = allPrices.Average()
                };
            }
            else
            {
                searchFilters.PriceRange = new PriceRangeDto
                {
                    MinPrice = 0,
                    MaxPrice = 1000000,
                    AveragePrice = 500000
                };
            }

            _logger.LogDebug("تم تحديد نطاق الأسعار: {MinPrice} - {MaxPrice}", 
                searchFilters.PriceRange.MinPrice, searchFilters.PriceRange.MaxPrice);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب نطاق الأسعار");
            searchFilters.PriceRange = new PriceRangeDto { MinPrice = 0, MaxPrice = 1000000, AveragePrice = 500000 };
        }

        return Task.CompletedTask;
    }

    private async Task PopulatePropertyTypes(SearchFiltersDto searchFilters, List<Core.Entities.Property> properties, CancellationToken cancellationToken)
    {
        try
        {
            // لا تعتمد على خاصية التنقل غير المحمّلة؛ استخدم المفتاح الأجنبي المباشر TypeId
            var propertyTypeIds = properties
                .Select(p => p.TypeId)
                .Where(id => id != Guid.Empty)
                .Distinct()
                .ToList();
            var allPropertyTypes = await _propertyTypeRepository.GetAllAsync(cancellationToken);
            var propertyTypes = allPropertyTypes?.Where(pt => propertyTypeIds.Contains(pt.Id)).ToList();

            if (propertyTypes != null && propertyTypes.Any())
            {
                searchFilters.PropertyTypes = propertyTypes.Select(pt => new YemenBooking.Application.Features.SearchAndFilters.DTOs.PropertyTypeFilterDto
                {
                    Id = pt.Id,
                    Name = pt.Name ?? string.Empty,
                    NameEn = pt.NameEn,
                    PropertiesCount = properties.Count(p => p.TypeId == pt.Id)
                })
                .OrderBy(pt => pt.Name)
                .ToList();
            }

            _logger.LogDebug("تم جلب {Count} نوع عقار متاح", searchFilters.PropertyTypes.Count);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب أنواع العقارات");
            searchFilters.PropertyTypes = new List<YemenBooking.Application.Features.SearchAndFilters.DTOs.PropertyTypeFilterDto>();
        }
    }

    private async Task PopulateAmenities(SearchFiltersDto searchFilters, List<Core.Entities.Property> properties, CancellationToken cancellationToken)
    {
        try
        {
            var allAmenities = await _amenityRepository.GetAllAsync(cancellationToken);
            var allPropertyAmenities = await _amenityRepository.GetAllPropertyAmenitiesAsync(cancellationToken);
            var activePropertyIds = new HashSet<Guid>(properties.Select(p => p.Id));

            // نبني خريطة (معرف المرفق -> قائمة أنواع العقار) بالاعتماد على PropertyTypeAmenity
            var propertyTypeIdsForActiveProperties = properties
                .Select(p => p.TypeId)
                .Where(id => id != Guid.Empty)
                .Distinct()
                .ToList();

            var amenityPropertyTypeMap = new Dictionary<Guid, HashSet<Guid>>();

            foreach (var propertyTypeId in propertyTypeIdsForActiveProperties)
            {
                var typeAmenities = await _amenityRepository.GetAmenitiesByPropertyTypeAsync(propertyTypeId, cancellationToken);
                foreach (var pta in typeAmenities)
                {
                    if (!amenityPropertyTypeMap.TryGetValue(pta.AmenityId, out var set))
                    {
                        set = new HashSet<Guid>();
                        amenityPropertyTypeMap[pta.AmenityId] = set;
                    }

                    if (pta.PropertyTypeId != Guid.Empty)
                    {
                        set.Add(pta.PropertyTypeId);
                    }
                }
            }

            if (allAmenities != null && allAmenities.Any())
            {
                searchFilters.Amenities = allAmenities
                    .Select(a => new YemenBooking.Application.Features.SearchAndFilters.DTOs.AmenityFilterDto
                    {
                        Id = a.Id,
                        Name = a.Name ?? string.Empty,
                        NameEn = a.NameEn,
                        Category = "عام",
                        CategoryEn = "General",
                        Icon = a.Icon ?? string.Empty,
                        PropertiesCount = allPropertyAmenities
                            .Where(pa => activePropertyIds.Contains(pa.PropertyId)
                                         && pa.PropertyTypeAmenity != null
                                         && pa.PropertyTypeAmenity.Amenity != null
                                         && pa.PropertyTypeAmenity.Amenity.Id == a.Id)
                            .Select(pa => pa.PropertyId)
                            .Distinct()
                            .Count(),
                        PropertyTypeIds = amenityPropertyTypeMap.TryGetValue(a.Id, out var typeIds)
                            ? typeIds.ToList()
                            : new List<Guid>()
                    })
                    .OrderBy(a => a.Name)
                    .ToList();
            }

            _logger.LogDebug("تم جلب {Count} وسيلة راحة متاحة", searchFilters.Amenities.Count);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب وسائل الراحة");
            searchFilters.Amenities = new List<YemenBooking.Application.Features.SearchAndFilters.DTOs.AmenityFilterDto>();
        }
    }

    private void PopulateStarRatings(SearchFiltersDto searchFilters, List<Core.Entities.Property> properties)
    {
        try
        {
            var starRatings = properties
                .Where(p => p.StarRating != 0 && p.StarRating > 0)
                .Select(p => p.StarRating)
                .Distinct()
                .OrderBy(r => r)
                .ToList();

            if (!starRatings.Any())
            {
                starRatings = new List<int> { 1, 2, 3, 4, 5 };
            }

            searchFilters.StarRatings = starRatings;
            
            _logger.LogDebug("تم جلب {Count} تصنيف نجوم متاح", starRatings.Count);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب تصنيفات النجوم");
            searchFilters.StarRatings = new List<int> { 1, 2, 3, 4, 5 };
        }
    }

    private async Task PopulateMaxGuestCapacity(SearchFiltersDto searchFilters, List<Core.Entities.Property> properties, CancellationToken cancellationToken)
    {
        try
        {
            var maxCapacities = new List<int>();

            foreach (var property in properties)
            {
                var units = await _unitRepository.GetActiveByPropertyIdAsync(property.Id, cancellationToken);
                if (units != null && units.Any())
                {
                    var propertyMaxCapacity = units.Max(u => u.MaxCapacity);
                    maxCapacities.Add(propertyMaxCapacity);
                }
            }

            searchFilters.MaxGuestCapacity = maxCapacities.Any() ? maxCapacities.Max() : 10;
            
            _logger.LogDebug("تم تحديد الحد الأقصى للسعة: {MaxCapacity}", searchFilters.MaxGuestCapacity);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب الحد الأقصى للسعة");
            searchFilters.MaxGuestCapacity = 10;
        }
    }

    private async Task PopulateUnitTypes(SearchFiltersDto searchFilters, List<Core.Entities.Property> properties, CancellationToken cancellationToken)
    {
        try
        {
            var allUnitTypeIds = new HashSet<Guid>();

            foreach (var property in properties)
            {
                var units = await _unitRepository.GetActiveByPropertyIdAsync(property.Id, cancellationToken);
                foreach (var unit in units)
                {
                    if (unit.UnitTypeId != Guid.Empty)
                    {
                        allUnitTypeIds.Add(unit.UnitTypeId);
                    }
                }
            }

            var unitTypes = await _unitTypeRepository.GetAllUnitTypesAsync(cancellationToken);

            searchFilters.UnitTypes = unitTypes?.Where(ut => allUnitTypeIds.Contains(ut.Id))
                .Select(ut => new UnitTypeFilterDto
                {
                    Id = ut.Id,
                    Name = ut.Name ?? string.Empty,
                    NameEn = ut.NameEn,
                    UnitsCount = properties.Sum(p => p.Units.Count(u => u.UnitTypeId == ut.Id)),
                    IsHasAdults = ut.IsHasAdults,
                    IsHasChildren = ut.IsHasChildren,
                    IsMultiDays = ut.IsMultiDays,
                    IsRequiredToDetermineTheHour = ut.IsRequiredToDetermineTheHour,
                }).OrderBy(ut => ut.Name).ToList() ?? new List<UnitTypeFilterDto>();

            _logger.LogDebug("تم جلب {Count} نوع وحدة متاح", searchFilters.UnitTypes.Count);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب أنواع الوحدات");
            searchFilters.UnitTypes = new List<UnitTypeFilterDto>();
        }
    }

    private async Task PopulateServices(SearchFiltersDto searchFilters, List<Core.Entities.Property> properties, CancellationToken cancellationToken)
    {
        try
        {
            var activePropertyIds = new HashSet<Guid>(properties.Select(p => p.Id));
            var allServices = await _propertyServiceRepository.GetAllAsync(cancellationToken);

            var serviceGroups = allServices
                .Where(s => activePropertyIds.Contains(s.PropertyId))
                .GroupBy(s => new { s.Id, s.Name })
                .Select(g => new ServiceFilterDto
                {
                    Id = g.Key.Id,
                    Name = g.Key.Name ?? string.Empty,
                    NameEn = g.FirstOrDefault()?.NameEn,
                    PropertiesCount = g.Select(s => s.PropertyId).Distinct().Count(),
                    Icon = g.FirstOrDefault()?.Icon ?? "service"
                })
                .OrderBy(s => s.Name)
                .ToList();

            searchFilters.Services = serviceGroups;

            _logger.LogDebug("تم جلب {Count} خدمة متاحة", searchFilters.Services.Count);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب الخدمات");
            searchFilters.Services = new List<ServiceFilterDto>();
        }
    }

    private async Task PopulateDynamicFieldValues(SearchFiltersDto searchFilters, List<Core.Entities.Property> properties, CancellationToken cancellationToken)
    {
        try
        {
            var dynamicValueCounts =
                new Dictionary<(string field, string displayName, string? displayNameEn, string value), int>();

            foreach (var property in properties)
            {
                var units = await _unitRepository.GetActiveByPropertyIdAsync(property.Id, cancellationToken);
                foreach (var unit in units)
                {
                    if (unit.FieldValues == null || !unit.FieldValues.Any()) continue;

                    foreach (var fieldValue in unit.FieldValues)
                    {
                        var fieldName = fieldValue.UnitTypeField?.FieldName ?? string.Empty;
                        var displayName = fieldValue.UnitTypeField?.DisplayName ?? fieldName;
                        var displayNameEn = fieldValue.UnitTypeField?.DisplayNameEn;
                        var valueStr = fieldValue.FieldValue;
                        var key = (fieldName, displayName, displayNameEn, valueStr);
                        if (dynamicValueCounts.ContainsKey(key))
                        {
                            dynamicValueCounts[key]++;
                        }
                        else
                        {
                            dynamicValueCounts[key] = 1;
                        }
                    }
                }
            }

            searchFilters.DynamicFieldValues = dynamicValueCounts.Select(d => new DynamicFieldValueFilterDto
            {
                FieldName = d.Key.field,
                DisplayName = string.IsNullOrWhiteSpace(d.Key.displayName) ? d.Key.field : d.Key.displayName,
                DisplayNameEn = d.Key.displayNameEn,
                Value = d.Key.value,
                Count = d.Value
            }).OrderBy(d => d.DisplayName).ThenBy(d => d.Value).ToList();

            _logger.LogDebug("تم جلب {Count} قيمة حقل ديناميكى", searchFilters.DynamicFieldValues.Count);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب قيم الحقول الديناميكية");
            searchFilters.DynamicFieldValues = new List<DynamicFieldValueFilterDto>();
        }
    }

    private SearchFiltersDto GetDefaultFilters()
    {
        return new SearchFiltersDto
        {
            AvailableCities = new List<string> { "صنعاء", "عدن", "تعز", "الحديدة", "إب" },
            PriceRange = new PriceRangeDto
            {
                MinPrice = 0,
                MaxPrice = 1000000,
                AveragePrice = 500000
            },
            PropertyTypes = new List<YemenBooking.Application.Features.SearchAndFilters.DTOs.PropertyTypeFilterDto>(),
            Amenities = new List<YemenBooking.Application.Features.SearchAndFilters.DTOs.AmenityFilterDto>(),
            UnitTypes = new List<UnitTypeFilterDto>(),
            Services = new List<ServiceFilterDto>(),
            DynamicFieldValues = new List<DynamicFieldValueFilterDto>(),
            StarRatings = new List<int> { 1, 2, 3, 4, 5 },
            MaxGuestCapacity = 10
        };
    }
}
