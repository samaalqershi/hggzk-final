using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.SearchAndFilters.Services;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Entities;
using System.Text.Json;
using YemenBooking.Application.Features.DynamicFields.DTOs;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features.Units.DTOs;
using YemenBooking.Core.Indexing.Models;

namespace YemenBooking.Application.Features.Units.Queries.SearchUnits
{
    /// <summary>
    /// يعالج البحث عن الوحدات ويعيد النتيجة المطلوبة.
    /// Processes the Search Units request and returns the requested result.
    /// </summary>
    public class SearchUnitsQueryHandler : IRequestHandler<SearchUnitsQuery, PaginatedResult<UnitDto>>
    {
        private readonly IUnitSearchEngine _unitSearchEngine;
        private readonly ICurrentUserService _currentUserService;
        private readonly IUnitRepository _unitRepository;
        private readonly ILogger<SearchUnitsQueryHandler> _logger;
        private readonly ISearchLogRepository _searchLogRepository;

        /// <summary>
        /// ينشئ مثيلاً جديداً من SearchUnitsQueryHandler.
        /// Initializes a new instance of SearchUnitsQueryHandler.
        /// </summary>
        /// <param name="unitSearchEngine">قيمة الوحدة البحث engine / unit Search Engine value.</param>
        /// <param name="currentUserService">خدمة المستخدم الحالي / Current user service.</param>
        /// <param name="logger">مسجل الأحداث / Logger.</param>
        /// <param name="searchLogRepository">مستودع البحث عن log / Search Log repository.</param>
        public SearchUnitsQueryHandler(
            IUnitSearchEngine unitSearchEngine,
            ICurrentUserService currentUserService,
            IUnitRepository unitRepository,
            ILogger<SearchUnitsQueryHandler> logger,
            ISearchLogRepository searchLogRepository)
        {
            _unitSearchEngine = unitSearchEngine ?? throw new ArgumentNullException(nameof(unitSearchEngine));
            _currentUserService = currentUserService ?? throw new ArgumentNullException(nameof(currentUserService));
            _unitRepository = unitRepository ?? throw new ArgumentNullException(nameof(unitRepository));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            _searchLogRepository = searchLogRepository ?? throw new ArgumentNullException(nameof(searchLogRepository));
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
        public async Task<PaginatedResult<UnitDto>> Handle(SearchUnitsQuery request, CancellationToken cancellationToken)
        {
            var startTime = DateTime.UtcNow;
            
            _logger.LogInformation(
                "🔍 بدء البحث عن الوحدات - الموقع: {Location}, السعر: {MinPrice}-{MaxPrice}, الصفحة: {PageNumber}/{PageSize}",
                request.Location, request.MinPrice, request.MaxPrice, request.PageNumber, request.PageSize);

            try
            {
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // المرحلة 1: بناء طلب البحث
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                var searchRequest = BuildSearchRequest(request);
                
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // المرحلة 2: تنفيذ البحث باستخدام محرك البحث (PostgreSQL أو Redis)
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                var searchResult = await _unitSearchEngine.SearchUnitsAsync(searchRequest, cancellationToken);
                
                _logger.LogInformation(
                    "✅ اكتمل البحث: وجد {TotalCount} وحدة، الوقت: {ElapsedMs}ms",
                    searchResult.TotalCount, searchResult.SearchTimeMs);
                
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // المرحلة 3: تطبيق فلاتر الأمان حسب الدور
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                var filteredUnits = await ApplySecurityFilters(searchResult.Units, cancellationToken);
                
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // المرحلة 4: تحويل النتائج إلى DTOs
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                var dtos = await ConvertToUnitDtosAsync(filteredUnits, cancellationToken);
                
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // المرحلة 5: إعادة حساب التصفح بعد فلاتر الأمان
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                var totalCount = filteredUnits.Count;
                var totalPages = (int)Math.Ceiling(totalCount / (double)request.PageSize);
                
                var pagedDtos = dtos
                    .Skip((request.PageNumber - 1) * request.PageSize)
                    .Take(request.PageSize)
                    .ToList();
                
                _logger.LogInformation(
                    "📄 تم إرجاع {ReturnedCount} وحدة من إجمالي {TotalCount}",
                    pagedDtos.Count, totalCount);
                
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // المرحلة 6: تسجيل عملية البحث
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                await LogSearchOperation(request, totalCount, cancellationToken);
                
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // المرحلة 7: بناء النتيجة النهائية
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                var result = new PaginatedResult<UnitDto>
                {
                    Items = pagedDtos,
                    PageNumber = request.PageNumber,
                    PageSize = request.PageSize,
                    TotalCount = totalCount,
                    Metadata = BuildMetadata(filteredUnits, request, startTime)
                };
                
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "❌ خطأ أثناء البحث عن الوحدات");
                throw;
            }
        }
        
        #region === بناء طلب البحث ===
        
        private UnitSearchRequest BuildSearchRequest(SearchUnitsQuery query)
        {
            // Resolve total guests from adults and children.
            // حساب عدد الضيوف الإجمالي من البالغين والأطفال.
            int? totalGuests = null;
            if (query.Adults.HasValue || query.Children.HasValue)
            {
                var adults = Math.Max(0, query.Adults ?? 0);
                var children = Math.Max(0, query.Children ?? 0);
                totalGuests = adults + children;
            }

            var searchRequest = new UnitSearchRequest
            {
                // Text and location.
                // النص والموقع.
                SearchText = BuildSearchText(query),
                City = ExtractCityFromLocation(query.Location),
                
                // Unit and property type.
                // نوع الوحدة والعقار.
                UnitTypeId = query.UnitTypeId,
                PropertyTypeId = null,
                
                // Dates.
                // التواريخ.
                CheckIn = query.CheckInDate,
                CheckOut = query.CheckOutDate,
                
                // Capacity.
                // السعة.
                GuestsCount = totalGuests,
                AdultsCount = query.Adults,
                ChildrenCount = query.Children,
                
                // Price.
                // السعر.
                MinPrice = query.MinPrice,
                MaxPrice = query.MaxPrice,
                PreferredCurrency = "YER",
                
                // Rating.
                // التقييم.
                MinRating = null,
                MinStarRating = null,
                
                // Availability.
                // التوفر.
                FeaturedOnly = null,
                
                // Amenities and services.
                // المرافق والخدمات.
                RequiredAmenities = new List<Guid>(),
                RequiredServices = new List<Guid>(),
                
                // Dynamic fields.
                // الحقول الديناميكية.
                DynamicFieldFilters = BuildDynamicFieldFilters(query.DynamicFieldFilters),
                
                // Geographic search.
                // البحث الجغرافي.
                Latitude = query.Latitude.HasValue ? (decimal)query.Latitude.Value : null,
                Longitude = query.Longitude.HasValue ? (decimal)query.Longitude.Value : null,
                RadiusKm = query.RadiusKm,
                
                // Sorting and pagination.
                // الترتيب والتصفح.
                SortBy = NormalizeSortBy(query.SortBy),
                PageNumber = query.PageNumber,
                PageSize = query.PageSize
            };
            
            return searchRequest;
        }
        
        private string? BuildSearchText(SearchUnitsQuery query)
        {
            var searchParts = new List<string>();
            
            // Add NameContains to the search text.
            // إضافة NameContains إلى نص البحث.
            if (!string.IsNullOrWhiteSpace(query.NameContains))
            {
                searchParts.Add(query.NameContains.Trim());
            }
            
            // Add Location when it is not already a city name.
            // إضافة Location عندما لا تكون اسم مدينة.
            if (!string.IsNullOrWhiteSpace(query.Location) && !IsCityName(query.Location))
            {
                searchParts.Add(query.Location.Trim());
            }
            
            return searchParts.Any() ? string.Join(" ", searchParts) : null;
        }
        
        private string? ExtractCityFromLocation(string? location)
        {
            if (string.IsNullOrWhiteSpace(location))
                return null;
            
            var term = location.Trim().ToLowerInvariant();
            
            // Main Yemeni cities.
            // قائمة المدن اليمنية الرئيسية.
            var yemeniCities = new[]
            {
                "صنعاء", "عدن", "تعز", "الحديدة", "المكلا", "إب", "ذمار", "عمران",
                "صعدة", "حجة", "مأرب", "لحج", "أبين", "شبوة", "حضرموت", "البيضاء"
            };
            
            foreach (var city in yemeniCities)
            {
                if (term.Contains(city.ToLowerInvariant()))
                {
                    return city;
                }
            }
            
            // If Location is already a city name.
            // إذا كان Location اسم مدينة مباشر.
            if (yemeniCities.Any(c => string.Equals(c, location, StringComparison.OrdinalIgnoreCase)))
            {
                return location;
            }
            
            return null;
        }
        
        private bool IsCityName(string? text)
        {
            return !string.IsNullOrWhiteSpace(ExtractCityFromLocation(text));
        }
        
        private Dictionary<string, string>? BuildDynamicFieldFilters(
            IEnumerable<YemenBooking.Application.Features.Units.DTOs.UnitDynamicFieldFilterDto>? filters)
        {
            if (filters == null || !filters.Any())
                return null;
            
            var result = new Dictionary<string, string>();
            
            foreach (var filter in filters)
            {
                // Use FieldId as the key for simplicity.
                // نستخدم FieldId كمفتاح لتبسيط الربط.
                var key = filter.FieldId.ToString();
                var value = filter.FieldValue ?? string.Empty;
                
                result[key] = value;
            }
            
            return result.Any() ? result : null;
        }
        
        private string? NormalizeSortBy(string? sortBy)
        {
            if (string.IsNullOrWhiteSpace(sortBy))
                return "relevance";
            
            var normalized = sortBy.Trim().ToLowerInvariant();
            
            return normalized switch
            {
                "popularity" => "popular",
                "price_asc" => "price_asc",
                "price_desc" => "price_desc",
                "name_asc" => "newest", // تحويل name_asc إلى newest
                "name_desc" => "newest",
                "rating" => "rating",
                "distance" => "distance",
                _ => "relevance"
            };
        }
        
        #endregion
        
        #region === فلاتر الأمان ===
        
        private async Task<List<UnitSearchItem>> ApplySecurityFilters(
            List<UnitSearchItem> units,
            CancellationToken cancellationToken)
        {
            var userRole = _currentUserService.Role;
            var userId = _currentUserService.UserId;
            
            // Admin: no restrictions.
            // Admin: لا قيود.
            if (string.Equals(userRole, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                _logger.LogDebug("🔓 Admin - لا توجد فلاتر أمان");
                return units;
            }
            
            // Owner: only their own units.
            // Owner: فقط وحدات عقاراته.
            if (string.Equals(userRole, "Owner", StringComparison.OrdinalIgnoreCase))
            {
                _logger.LogDebug("👤 Owner - فلترة حسب المالك {UserId}", userId);
                
                var filtered = units.Where(u => u.OwnerId == userId).ToList();
                
                _logger.LogInformation(
                    "🔒 تم تطبيق فلتر المالك: {Filtered}/{Total} وحدة",
                    filtered.Count, units.Count);
                
                return filtered;
            }
            
            // Guest/User: approved units only.
            // Guest/User: فقط الوحدات المعتمدة.
            _logger.LogDebug("👥 Guest/User - فلترة العقارات المعتمدة فقط");
            
            var approvedUnits = units.Where(u => u.IsApproved).ToList();
            
            _logger.LogInformation(
                "🔒 تم تطبيق فلتر الاعتماد: {Approved}/{Total} وحدة",
                approvedUnits.Count, units.Count);
            
            return approvedUnits;
        }
        
        #endregion
        
        #region === تحويل إلى DTOs ===
        
        private async Task<List<UnitDto>> ConvertToUnitDtosAsync(
            List<UnitSearchItem> items,
            CancellationToken cancellationToken)
        {
            var dtos = new List<UnitDto>(items.Count);

            foreach (var item in items)
            {
                var unit = await _unitRepository.GetUnitByIdAsync(item.UnitId, cancellationToken);

                dtos.Add(new UnitDto
                {
                // Basic info.
                // البيانات الأساسية.
                Id = item.UnitId,
                PropertyId = item.PropertyId,
                UnitTypeId = unit?.UnitTypeId ?? Guid.Empty,
                Name = item.UnitName,
                NameEn = unit?.NameEn ?? item.UnitName,
                
                // Capacity and availability.
                // السعة والتوفر.
                CustomFeatures = unit?.CustomFeatures ?? string.Empty,
                CustomFeaturesEn = unit?.CustomFeaturesEn ?? unit?.CustomFeatures,
                
                // Property info.
                // معلومات العقار.
                PropertyName = item.PropertyName,
                PropertyNameEn = unit?.Property?.NameEn ?? item.PropertyName,
                UnitTypeName = item.UnitTypeName,
                UnitTypeNameEn = unit?.UnitType?.NameEn ?? item.UnitTypeName,
                
                // Pricing method.
                // طريقة التسعير.
                PricingMethod = ParsePricingMethod(item.PricingMethod),
                
                // Images.
                // الصور.
                Images = ConvertImages(item.ImageUrls, item.MainImageUrl),
                
                // Dynamic fields.
                // الحقول الديناميكية.
                FieldValues = ConvertFieldValues(item.DisplayFields),
                
                // Distance.
                // المسافة.
                DistanceKm = item.DistanceKm,
                
                });
            }

            return dtos;
        }
        
        private Core.Enums.PricingMethod ParsePricingMethod(string? pricingMethod)
        {
            if (string.IsNullOrWhiteSpace(pricingMethod))
                return Core.Enums.PricingMethod.Daily;
            
            return pricingMethod.ToLowerInvariant() switch
            {
                "hourly" => Core.Enums.PricingMethod.Hourly,
                "daily" => Core.Enums.PricingMethod.Daily,
                "weekly" => Core.Enums.PricingMethod.Weekly,
                "monthly" => Core.Enums.PricingMethod.Monthly,
                _ => Core.Enums.PricingMethod.Daily
            };
        }
        
        private List<PropertyImageDto> ConvertImages(List<string> imageUrls, string? mainImageUrl)
        {
            var images = new List<PropertyImageDto>();
            
            if (!string.IsNullOrWhiteSpace(mainImageUrl))
            {
                images.Add(new PropertyImageDto
                {
                    Id = Guid.NewGuid(),
                    Url = mainImageUrl,
                    IsMain = true,
                    DisplayOrder = 0,
                    Category = Core.Enums.ImageCategory.Interior,
                    Type = "image/jpeg",
                    SizeBytes = 0
                });
            }
            
            var order = 1;
            foreach (var url in imageUrls)
            {
                if (url == mainImageUrl)
                    continue;
                
                images.Add(new PropertyImageDto
                {
                    Id = Guid.NewGuid(),
                    Url = url,
                    IsMain = false,
                    DisplayOrder = order++,
                    Category = Core.Enums.ImageCategory.Interior,
                    Type = "image/jpeg",
                    SizeBytes = 0
                });
            }
            
            return images;
        }
        
        private List<UnitFieldValueDto> ConvertFieldValues(Dictionary<string, string> displayFields)
        {
            var fieldValues = new List<UnitFieldValueDto>();
            
            foreach (var field in displayFields)
            {
                fieldValues.Add(new UnitFieldValueDto
                {
                    ValueId = Guid.NewGuid(),
                    UnitId = Guid.Empty,
                    FieldId = Guid.Empty,
                    FieldName = field.Key,
                    DisplayName = field.Key,
                    DisplayNameEn = field.Key,
                    FieldType = "text",
                    FieldValue = field.Value,
                    IsPrimaryFilter = false,
                    Field = null,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                });
            }
            
            return fieldValues;
        }
        
        #endregion
        
        #region === بناء البيانات الوصفية ===
        
        private object BuildMetadata(
            List<UnitSearchItem> units,
            SearchUnitsQuery request,
            DateTime startTime)
        {
            var metadata = new
            {
                totalUnits = units.Count,
                searchTimeMs = (long)(DateTime.UtcNow - startTime).TotalMilliseconds,
                appliedFilters = BuildAppliedFilters(request),
                priceRange = (object?)null
            };
            
            return metadata;
        }
        
        private Dictionary<string, string> BuildAppliedFilters(SearchUnitsQuery request)
        {
            var filters = new Dictionary<string, string>();
            
            if (!string.IsNullOrWhiteSpace(request.Location))
                filters["location"] = request.Location;
            
            if (request.UnitTypeId.HasValue)
                filters["unitTypeId"] = request.UnitTypeId.Value.ToString();
            
            if (request.PropertyId.HasValue)
                filters["propertyId"] = request.PropertyId.Value.ToString();
            
            if (request.MinPrice.HasValue)
                filters["minPrice"] = request.MinPrice.Value.ToString("N0");
            
            if (request.MaxPrice.HasValue)
                filters["maxPrice"] = request.MaxPrice.Value.ToString("N0");
            
            if (request.CheckInDate.HasValue)
                filters["checkIn"] = request.CheckInDate.Value.ToString("yyyy-MM-dd");
            
            if (request.CheckOutDate.HasValue)
                filters["checkOut"] = request.CheckOutDate.Value.ToString("yyyy-MM-dd");
            
            if (request.Adults.HasValue)
                filters["adults"] = request.Adults.Value.ToString();
            
            if (request.Children.HasValue)
                filters["children"] = request.Children.Value.ToString();
            
            if (!string.IsNullOrWhiteSpace(request.SortBy))
                filters["sortBy"] = request.SortBy;
            
            return filters;
        }
        
        #endregion
        
        #region === تسجيل العملية ===
        
        private async Task LogSearchOperation(
            SearchUnitsQuery request,
            int resultCount,
            CancellationToken cancellationToken)
        {
            try
            {
                await _searchLogRepository.AddAsync(new SearchLog
                {
                    UserId = _currentUserService.UserId,
                    SearchType = "Unit",
                    CriteriaJson = JsonSerializer.Serialize(request),
                    ResultCount = resultCount,
                    PageNumber = request.PageNumber,
                    PageSize = request.PageSize
                }, cancellationToken);
                await _searchLogRepository.SaveChangesAsync(cancellationToken);
                
                _logger.LogDebug("📝 تم تسجيل عملية البحث");
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "⚠️ فشل تسجيل عملية البحث");
            }
        }
        
        #endregion
    }
}
