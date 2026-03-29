using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.SearchAndFilters.DTOs;
using YemenBooking.Application.Features.SearchAndFilters.Services;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Indexing.Models;
using YemenBooking.Application.Contracts.Services.Scheduling;
using YemenBooking.Core.Enums;

namespace YemenBooking.Application.Features.Properties.Queries.SearchProperties
{
    /// <summary>
    /// يعالج أمر البحث عن العقارات.
    /// Handles the search properties command.
    /// </summary>
    public class SearchPropertiesQueryHandler : IRequestHandler<SearchPropertiesQuery, ResultDto<SearchPropertiesResponse>>
    {
        private readonly IUnitIndexingService _indexingService;
        private readonly ICurrentUserService _currentUserService;
        private readonly ILogger<SearchPropertiesQueryHandler> _logger;
        private readonly IUnitRepository _unitRepository;
        private readonly IPropertyRepository _propertyRepository;
        private readonly IPropertyTypeRepository _propertyTypeRepository;
        private readonly IAvailabilityService _availabilityService;
        private readonly IDailyUnitScheduleRepository _scheduleRepository;
        private readonly ICurrencyExchangeRepository _currencyExchangeRepository;
        private readonly ISearchFacetService _searchFacetService;

        /// <summary>
        /// يهيّئ مثيلاً جديداً من [SearchPropertiesQueryHandler].
        /// Initializes a new instance of [SearchPropertiesQueryHandler].
        /// </summary>
        public SearchPropertiesQueryHandler(
            IUnitIndexingService indexingService,
            ICurrentUserService currentUserService,
            ILogger<SearchPropertiesQueryHandler> logger,
            IUnitRepository unitRepository,
            IPropertyRepository propertyRepository,
            IPropertyTypeRepository propertyTypeRepository,
            IAvailabilityService availabilityService,
            IDailyUnitScheduleRepository scheduleRepository,
            ICurrencyExchangeRepository currencyExchangeRepository,
            ISearchFacetService searchFacetService)
        {
            _indexingService = indexingService ?? throw new ArgumentNullException(nameof(indexingService));
            _currentUserService = currentUserService ?? throw new ArgumentNullException(nameof(currentUserService));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            _unitRepository = unitRepository ?? throw new ArgumentNullException(nameof(unitRepository));
            _propertyRepository = propertyRepository ?? throw new ArgumentNullException(nameof(propertyRepository));
            _propertyTypeRepository = propertyTypeRepository ?? throw new ArgumentNullException(nameof(propertyTypeRepository));
            _availabilityService = availabilityService ?? throw new ArgumentNullException(nameof(availabilityService));
            _scheduleRepository = scheduleRepository ?? throw new ArgumentNullException(nameof(scheduleRepository));
            _currencyExchangeRepository = currencyExchangeRepository ?? throw new ArgumentNullException(nameof(currencyExchangeRepository));
            _searchFacetService = searchFacetService ?? throw new ArgumentNullException(nameof(searchFacetService));
        }
        /// <summary>
        /// يعالج استعلام البحث النصي والمتقدم في العقارات.
        /// Handles text and advanced property search queries.
        /// </summary>
        public async Task<ResultDto<SearchPropertiesResponse>> Handle(
            SearchPropertiesQuery request,
            CancellationToken cancellationToken)
        {
            var startTime = DateTime.UtcNow;

            _logger.LogInformation(
                "🔍 بدء البحث عن العقارات - المدينة: {City}, السعر: {MinPrice}-{MaxPrice}, الصفحة: {PageNumber}/{PageSize}",
                request.City, request.MinPrice, request.MaxPrice, request.PageNumber, request.PageSize);
            _logger.LogInformation(
                "🧾 Search request snapshot: {@SearchRequestSnapshot}",
                CreateRequestSnapshot(request));
            
            // Log received dynamic fields.
            // تسجيل الحقول الديناميكية المستلمة / Log the received dynamic fields.
            if (request.DynamicFieldFilters != null && request.DynamicFieldFilters.Any())
            {
                _logger.LogInformation(
                    "📋 الحقول الديناميكية المستقبلة: {Count} حقل",
                    request.DynamicFieldFilters.Count);
                
                foreach (var filter in request.DynamicFieldFilters)
                {
                    _logger.LogInformation(
                        "   • {Key} = {Value} ({Type})",
                        filter.Key,
                        filter.Value,
                        filter.Value?.GetType().Name ?? "null");
                }
            }
            else
            {
                _logger.LogInformation("📋 لا توجد حقول ديناميكية في الطلب");
            }

            try
            {
                // Stage 1: validate the request.
                // المرحلة 1: التحقق من صحة الطلب / Validate the request.
                var validationResult = ValidateRequest(request);
                if (!validationResult.IsSuccess)
                {
                    _logger.LogWarning("⚠️ طلب البحث غير صالح: {Error}", validationResult.Message);
                    return validationResult;
                }

                // Stage 2: build the indexed search request.
                // المرحلة 2: بناء طلب البحث المفهرس / Build the indexed search request.
                var searchRequest = await BuildRedisSearchRequest(request, cancellationToken);
                _logger.LogInformation(
                    "🧭 Indexed search request snapshot: {@IndexedSearchRequestSnapshot}",
                    CreateIndexedRequestSnapshot(searchRequest));

                // Stage 3: execute the indexed search.
                // المرحلة 3: تنفيذ البحث المفهرس / Execute the indexed search.
                var searchResult = await _indexingService.SearchPropertiesWithUnitsAsync(searchRequest, cancellationToken);
                var liveFacets = await _searchFacetService.BuildFacetsAsync(searchRequest, cancellationToken);

                _logger.LogInformation(
                    "✅ اكتمل البحث: وجد {TotalPropertiesCount} عقار و {TotalUnitsCount} وحدة - المستوى: {RelaxationLevel}",
                    searchResult.TotalPropertiesCount,
                    searchResult.TotalUnitsCount,
                    searchResult.RelaxationLevel);

                // Stage 4: apply role-based security filters.
                // المرحلة 4: تطبيق فلاتر الأمان حسب الدور / Apply role-based security filters.
                var filteredProperties = await ApplySecurityFilters(searchResult.Properties, cancellationToken);

                // Stage 5: convert the results to DTOs.
                // المرحلة 5: تحويل النتائج إلى DTOs / Convert the results to DTOs.
                var propertyDtos = request.PreviewOnly
                    ? new List<PropertySearchResultDto>()
                    : await ConvertToPropertyDtos(filteredProperties, request, cancellationToken);

                // Stage 6: recompute pagination after security filtering.
                // المرحلة 6: إعادة حساب التصفح بعد فلاتر الأمان / Recompute pagination after security filtering.
                var totalCount = searchResult.TotalPropertiesCount;
                var totalPages = (int)Math.Ceiling(totalCount / (double)Math.Max(1, request.PageSize));

                var pagedDtos = request.PreviewOnly
                    ? new List<PropertySearchResultDto>()
                    : propertyDtos;

                _logger.LogInformation(
                    "📄 تم إرجاع {ReturnedCount} عقار من إجمالي {TotalCount}",
                    pagedDtos.Count, totalCount);

                // Stage 7: build the final response.
                // المرحلة 7: بناء النتيجة النهائية / Build the final response.
                var response = new SearchPropertiesResponse
                {
                    Properties = pagedDtos,
                    TotalCount = totalCount,
                    CurrentPage = request.PageNumber,
                    PageSize = request.PageSize,
                    TotalPages = totalPages,
                    HasPreviousPage = request.PageNumber > 1,
                    HasNextPage = request.PageNumber < totalPages,
                    AppliedFilters = BuildAppliedFilters(request),
                    SearchTimeMs = (long)(DateTime.UtcNow - startTime).TotalMilliseconds,
                    Statistics = BuildStatistics(propertyDtos, totalCount, startTime),
                    Facets = liveFacets,
                    
                    // Carry over fallback-search metadata.
                    // نقل بيانات استراتيجية Fallback Search / Carry over fallback-search metadata.
                    RelaxationLevel = searchResult.RelaxationLevel,
                    RelaxedFilters = searchResult.RelaxedFilters,
                    UserMessage = searchResult.UserMessage,
                    SuggestedActions = searchResult.SuggestedActions
                };

                _logger.LogInformation(
                    "🎯 اكتمل البحث بنجاح في {ElapsedMs}ms - WasRelaxed: {WasRelaxed}",
                    response.SearchTimeMs,
                    response.WasRelaxed);
                _logger.LogInformation(
                    "📦 Search response snapshot: {@SearchResponseSnapshot}",
                    CreateResponseSnapshot(response));

                return ResultDto<SearchPropertiesResponse>.Ok(response, "تم البحث بنجاح");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "❌ خطأ أثناء البحث عن العقارات");
                return ResultDto<SearchPropertiesResponse>.Failed(
                    $"حدث خطأ أثناء البحث: {ex.Message}",
                    "SEARCH_ERROR");
            }
        }

        #region === Request Validation ===

        private ResultDto<SearchPropertiesResponse> ValidateRequest(SearchPropertiesQuery request)
        {
            // Validate page number.
            if (request.PageNumber < 1)
            {
                return ResultDto<SearchPropertiesResponse>.Failed(
                    "رقم الصفحة يجب أن يكون أكبر من صفر",
                    "INVALID_PAGE_NUMBER");
            }

            // Validate page size.
            if (request.PageSize < 1 || request.PageSize > 100)
            {
                return ResultDto<SearchPropertiesResponse>.Failed(
                    "حجم الصفحة يجب أن يكون بين 1 و 100",
                    "INVALID_PAGE_SIZE");
            }

            // Validate date range.
            if (request.CheckIn.HasValue && request.CheckOut.HasValue)
            {
                // Ensure CheckOut is after CheckIn.
                if (request.CheckIn.Value.Date >= request.CheckOut.Value.Date)
                {
                    return ResultDto<SearchPropertiesResponse>.Failed(
                        "تاريخ الوصول يجب أن يكون قبل تاريخ المغادرة",
                        "INVALID_DATE_RANGE");
                }
            }

            // Validate price range.
            if (request.MinPrice.HasValue && request.MaxPrice.HasValue)
            {
                if (request.MinPrice > request.MaxPrice)
                {
                    return ResultDto<SearchPropertiesResponse>.Failed(
                        "السعر الأدنى يجب أن يكون أقل من السعر الأقصى",
                        "INVALID_PRICE_RANGE");
                }
            }

            // Validate radius.
            if (request.RadiusKm.HasValue && request.RadiusKm <= 0)
            {
                return ResultDto<SearchPropertiesResponse>.Failed(
                    "نصف القطر يجب أن يكون أكبر من صفر",
                    "INVALID_RADIUS");
            }

            return ResultDto<SearchPropertiesResponse>.Ok(null);
        }

        #endregion

        #region === Search Request Building ===

        private async Task<PropertyWithUnitsSearchRequest> BuildRedisSearchRequest(
            SearchPropertiesQuery query,
            CancellationToken cancellationToken)
        {
            // Convert request dates to UTC for database-facing queries while also preserving
            // the raw local calendar dates for Redis day-based availability filtering.
            var checkInUtc = query.CheckIn.HasValue
                ? await _currentUserService.ConvertFromUserLocalToUtcAsync(query.CheckIn.Value).ConfigureAwait(false)
                : (DateTime?)null;

            var checkOutUtc = query.CheckOut.HasValue
                ? await _currentUserService.ConvertFromUserLocalToUtcAsync(query.CheckOut.Value).ConfigureAwait(false)
                : (DateTime?)null;

            // Resolve the effective guest count.
            // حساب عدد الضيوف الفعلي / Resolve the effective guest count.
            int? effectiveGuests = null;
            if (query.Adults.HasValue || query.Children.HasValue)
            {
                var adults = Math.Max(0, query.Adults ?? 0);
                var children = Math.Max(0, query.Children ?? 0);
                effectiveGuests = adults + children;
            }
            else if (query.GuestsCount.HasValue)
            {
                effectiveGuests = query.GuestsCount;
            }

            // Build the search request.
            // بناء طلب البحث / Build the search request.
            var searchRequest = new PropertyWithUnitsSearchRequest
            {
                // Text and location.
                // النص والموقع / Text and location.
                SearchText = NormalizeSearchText(query.SearchTerm),
                City = NormalizeCity(query.City),

                // Dates.
                // التواريخ / Dates.
                CheckIn = checkInUtc,
                CheckOut = checkOutUtc,
                CheckInLocalDate = query.CheckIn?.Date,
                CheckOutLocalDate = query.CheckOut?.Date,

                // Capacity.
                // السعة / Capacity.
                GuestsCount = effectiveGuests,
                AdultsCount = query.Adults,
                ChildrenCount = query.Children,

                // Price.
                // السعر / Price.
                MinPrice = query.MinPrice,
                MaxPrice = query.MaxPrice,
                PreferredCurrency = NormalizeCurrency(query.PreferredCurrency),

                // Rating.
                // التقييم / Rating.
                MinRating = null,
                MinStarRating = query.MinStarRating,

                // Property type.
                // نوع العقار / Property type.
                PropertyTypeId = query.PropertyTypeId,

                // Unit type.
                // نوع الوحدة / Unit type.
                UnitTypeId = query.UnitTypeId,

                // Amenities and services.
                // المرافق والخدمات / Amenities and services.
                RequiredAmenities = query.RequiredAmenities?.ToList(),
                RequiredServices = query.ServiceIds?.ToList(),

                // Dynamic fields.
                // الحقول الديناميكية / Dynamic fields.
                DynamicFieldFilters = BuildDynamicFieldFilters(query.DynamicFieldFilters),

                // Geographic search.
                // البحث الجغرافي / Geographic search.
                Latitude = query.Latitude,
                Longitude = query.Longitude,
                RadiusKm = query.RadiusKm.HasValue ? (double)query.RadiusKm.Value : null,

                // Sorting and pagination.
                // الترتيب والتصفح / Sorting and pagination.
                SortBy = NormalizeSortBy(query.SortBy, query.Latitude, query.Longitude),
                PageNumber = query.PageNumber,
                PageSize = query.PageSize,
                
                // Grouping settings.
                // إعدادات التجميع / Grouping settings.
                GroupByProperty = true, // Group results by property. / تجميع النتائج حسب العقار.
                MaxUnitsPerProperty = null // Return all matching units. / عرض جميع الوحدات المطابقة.
            };

            return searchRequest;
        }

        private string? NormalizeSearchText(string? searchText)
        {
            if (string.IsNullOrWhiteSpace(searchText))
                return null;

            return searchText.Trim();
        }

        private string? NormalizeCity(string? city)
        {
            if (string.IsNullOrWhiteSpace(city))
                return null;

            return city.Trim();
        }

        private string NormalizeCurrency(string? currency)
        {
            if (string.IsNullOrWhiteSpace(currency))
                return "YER";

            return currency.ToUpperInvariant();
        }

        private Dictionary<string, string>? BuildDynamicFieldFilters(
            Dictionary<string, string>? filters)
        {
            if (filters == null || !filters.Any())
                return null;

            // Filter empty values only.
            // فلترة القيم الفارغة فقط / Filter empty values only.
            var result = filters
                .Where(f => !string.IsNullOrWhiteSpace(f.Value))
                .ToDictionary(f => f.Key, f => f.Value);

            return result.Any() ? result : null;
        }

        private string? NormalizeSortBy(string? sortBy, decimal? latitude, decimal? longitude)
        {
            if (string.IsNullOrWhiteSpace(sortBy))
                return null;

            var normalized = sortBy.Trim().ToLowerInvariant();

            return normalized switch
            {
                "distance" => (latitude.HasValue && longitude.HasValue) ? "distance" : null,
                "price_asc" => "price_asc",
                "price_desc" => "price_desc",
                "rating" => "rating",
                "newest" => "newest",
                "popularity" => "popular",
                "recommended" => null,
                _ => normalized
            };
        }

        #endregion

        #region === Security Filters / فلاتر الأمان ===

        private async Task<List<PropertyGroupSearchItem>> ApplySecurityFilters(
            List<PropertyGroupSearchItem> properties,
            CancellationToken cancellationToken)
        {
            var userRole = _currentUserService.Role;
            var userId = _currentUserService.UserId;

            // ━━━ Admin: no restrictions / لا قيود ━━━
            if (string.Equals(userRole, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                _logger.LogDebug("🔓 Admin - لا توجد فلاتر أمان");
                return properties;
            }

            // ━━━ Owner: only owned properties / فقط عقاراته ━━━
            if (string.Equals(userRole, "Owner", StringComparison.OrdinalIgnoreCase))
            {
                _logger.LogDebug("👤 Owner - فلترة حسب المالك {UserId}", userId);

                // TODO: PropertySearchItem must include OwnerId.
                // مؤقتاً نُرجع جميع العقارات / Temporarily return all properties.
                return properties;
            }

            // ━━━ Guest/User: approved properties only / فقط العقارات المعتمدة ━━━
            _logger.LogDebug("👥 Guest/User - فلترة العقارات المعتمدة فقط");

            // TODO: PropertySearchItem must include IsApproved.
            // مؤقتاً نُرجع جميع العقارات / Temporarily return all properties.
            return properties;
        }

        #endregion

        #region === تحويل إلى DTOs ===

        private async Task<List<PropertySearchResultDto>> ConvertToPropertyDtos(
            List<PropertyGroupSearchItem> items,
            SearchPropertiesQuery query,
            CancellationToken cancellationToken)
        {
            var dtos = new List<PropertySearchResultDto>();

            foreach (var item in items)
            {
                try
                {
                    var dto = await ConvertToPropertyDto(item, query, cancellationToken);
                    
                    // Copy mismatches from the search result into the DTO.
                    // نسخ الفروقات من نتيجة البحث إلى DTO.
                    dto.FilterMismatches = item.FilterMismatches;
                    
                    dtos.Add(dto);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "⚠️ خطأ في تحويل العقار {PropertyId}", item.PropertyId);
                }
            }

            return dtos;
        }

        private async Task<PropertySearchResultDto> ConvertToPropertyDto(
            PropertyGroupSearchItem item,
            SearchPropertiesQuery query,
            CancellationToken cancellationToken)
        {
            var propertyId = item.PropertyId;
            var property = await _propertyRepository.GetByIdAsync(propertyId, cancellationToken);
            var propertyType = property != null && property.TypeId != Guid.Empty
                ? await _propertyTypeRepository.GetByIdAsync(property.TypeId, cancellationToken)
                : null;

            // ━━━ Build the base DTO / بناء DTO أساسي ━━━
            var dto = new PropertySearchResultDto
            {
                Id = propertyId,
                Name = item.PropertyName,
                NameEn = property?.NameEn ?? item.PropertyName,
                Description = property?.Description ?? string.Empty,
                DescriptionEn = property?.DescriptionEn ?? property?.Description ?? string.Empty,
                PropertyType = item.PropertyTypeName ?? string.Empty,
                PropertyTypeEn = propertyType?.NameEn ?? item.PropertyTypeName ?? string.Empty,
                Address = item.Address,
                AddressEn = property?.AddressEn ?? item.Address,
                City = item.City,
                CityEn = property?.CityEn ?? item.City,
                MinPrice = item.PriceRange?.Min ?? 0,
                DiscountedPrice = item.PriceRange?.Min ?? 0,
                Currency = NormalizeCurrency(item.Currency),
                StarRating = item.StarRating,
                AverageRating = item.AverageRating,
                ReviewsCount = 0,
                MainImageUrl = item.MainImageUrl ?? item.ImageUrls?.FirstOrDefault() ?? string.Empty,
                ImageUrls = item.ImageUrls ?? new List<string>(),
                IsAvailable = true,
                IsFavorite = false,
                IsFeatured = item.IsFeatured,
                Latitude = item.Latitude,
                Longitude = item.Longitude,
                MaxCapacity = item.MatchedUnits?.Max(u => u.MaxCapacity) ?? 0,
                AvailableUnitsCount = item.MatchedUnitsCount,
                DynamicFieldValues = new Dictionary<string, object>(),
                MainAmenities = item.AvailableAmenities ?? new List<string>(),
                MainAmenitiesEn = property?.Amenities?
                    .Select(a => a.PropertyTypeAmenity.Amenity.NameEn ?? a.PropertyTypeAmenity.Amenity.Name)
                    .Take(5)
                    .ToList() ?? new List<string>(),
                LastUpdated = await _currentUserService.ConvertFromUtcToUserLocalAsync(DateTime.UtcNow)
            };

            // ━━━ Calculate availability and price when dates are present / حساب الإتاحة والسعر إذا كانت هناك تواريخ ━━━
            if (query.CheckIn.HasValue && query.CheckOut.HasValue)
            {
                await CalculateAvailabilityAndPricing(dto, query, cancellationToken);
            }
            else if (query.UnitTypeId.HasValue || query.GuestsCount.HasValue || dto.MinPrice <= 0)
            {
                await SelectBestUnit(dto, query, cancellationToken);
            }

            // ━━━ Convert currency if requested / تحويل العملة إذا طُلب ━━━
            if (!string.IsNullOrWhiteSpace(query.PreferredCurrency) &&
                !string.Equals(dto.Currency, query.PreferredCurrency, StringComparison.OrdinalIgnoreCase))
            {
                await ConvertCurrency(dto, query.PreferredCurrency, cancellationToken);
            }

            // ━━━ Calculate distance when using geographic search / حساب المسافة إذا كان بحث جغرافي ━━━
            if (query.Latitude.HasValue && query.Longitude.HasValue)
            {
                dto.DistanceKm = CalculateDistance(
                    (double)query.Latitude.Value,
                    (double)query.Longitude.Value,
                    (double)dto.Latitude,
                    (double)dto.Longitude);
            }

            return dto;
        }

        private async Task CalculateAvailabilityAndPricing(
            PropertySearchResultDto dto,
            SearchPropertiesQuery query,
            CancellationToken cancellationToken)
        {
            try
            {
                var checkIn = query.CheckIn!.Value;
                var checkOut = query.CheckOut!.Value;
                var guestCount = ResolveEffectiveGuestCount(query);

                // ━━━ Get available units / الحصول على الوحدات المتاحة ━━━
                var availableUnitIds = await _availabilityService
                    .GetAvailableUnitsInPropertyAsync(dto.Id, checkIn, checkOut, guestCount, cancellationToken);

                // ━━━ Apply extra filters (unit type, capacity) / تطبيق فلاتر إضافية (نوع الوحدة، السعة) ━━━
                var filteredAvailable = new List<Guid>();
                foreach (var unitId in availableUnitIds)
                {
                    var unit = await _unitRepository.GetUnitByIdAsync(unitId, cancellationToken);
                    if (unit != null &&
                        (!query.UnitTypeId.HasValue || unit.UnitTypeId == query.UnitTypeId.Value) &&
                        unit.MaxCapacity >= guestCount)
                    {
                        filteredAvailable.Add(unitId);
                    }
                }

                if (!filteredAvailable.Any())
                {
                    dto.AvailableUnitsCount = 0;
                    dto.IsAvailable = false;
                    dto.MinPrice = 0;
                    dto.DiscountedPrice = 0;
                    dto.UnitId = null;
                    dto.UnitName = null;
                    dto.UnitNameEn = null;
                    dto.MaxCapacity = 0;
                    _logger.LogDebug("⚠️ لا توجد وحدات متاحة للعقار {PropertyId}", dto.Id);
                    return;
                }

                var pricedCandidates = new List<(Guid UnitId, string UnitName, string UnitNameEn, int MaxCapacity, decimal PerNight)>();
                foreach (var unitId in filteredAvailable)
                {
                    var pricedCandidate = await GetPricedUnitCandidate(
                        unitId, checkIn, checkOut, cancellationToken);

                    if (pricedCandidate.HasValue)
                    {
                        pricedCandidates.Add(pricedCandidate.Value);
                    }
                }

                dto.AvailableUnitsCount = pricedCandidates.Count;
                dto.IsAvailable = dto.AvailableUnitsCount > 0;

                if (!pricedCandidates.Any())
                {
                    dto.MinPrice = 0;
                    dto.DiscountedPrice = 0;
                    dto.UnitId = null;
                    dto.UnitName = null;
                    dto.UnitNameEn = null;
                    dto.MaxCapacity = 0;
                    return;
                }

                // Show the cheapest bookable unit so the card matches the unit-fetch flow.
                // نعرض أرخص وحدة قابلة للحجز فعلياً حتى تتطابق البطاقة مع مسار جلب الوحدات.
                var selectedPricedCandidate = pricedCandidates
                    .OrderBy(candidate => candidate.PerNight)
                    .ThenByDescending(candidate => candidate.MaxCapacity)
                    .First();

                dto.UnitId = selectedPricedCandidate.UnitId;
                dto.UnitName = selectedPricedCandidate.UnitName;
                dto.UnitNameEn = selectedPricedCandidate.UnitNameEn;
                dto.MaxCapacity = selectedPricedCandidate.MaxCapacity;
                dto.MinPrice = selectedPricedCandidate.PerNight;
                dto.DiscountedPrice = selectedPricedCandidate.PerNight;
                dto.Currency = NormalizeCurrency(dto.Currency);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "⚠️ خطأ في حساب الإتاحة والتسعير للعقار {PropertyId}", dto.Id);
            }
        }

        private async Task<Guid> SelectBestAvailableUnit(
            List<Guid> availableUnitIds,
            Guid? preferredUnitTypeId,
            int guestCount,
            CancellationToken cancellationToken)
        {
            // ━━━ Search for a unit of the preferred type first / البحث عن وحدة من النوع المفضل أولاً ━━━
            if (preferredUnitTypeId.HasValue)
            {
                foreach (var unitId in availableUnitIds)
                {
                    var unit = await _unitRepository.GetUnitByIdAsync(unitId, cancellationToken);
                    if (unit != null &&
                        unit.UnitTypeId == preferredUnitTypeId.Value &&
                        unit.MaxCapacity >= guestCount)
                    {
                        return unitId;
                    }
                }
            }

            // ━━━ If none exists, pick the first available unit / إذا لم توجد، نختار أول وحدة متاحة ━━━
            return availableUnitIds.FirstOrDefault();
        }

        private async Task<(Guid UnitId, string UnitName, string UnitNameEn, int MaxCapacity, decimal PerNight)?> GetPricedUnitCandidate(
            Guid unitId,
            DateTime checkIn,
            DateTime checkOut,
            CancellationToken cancellationToken)
        {
            var unit = await _unitRepository.GetUnitByIdAsync(unitId, cancellationToken);
            if (unit == null)
                return null;

            var nights = Math.Max(1, (checkOut.Date - checkIn.Date).Days);
            var pricingEndDate = checkOut.Date > checkIn.Date
                ? checkOut.Date.AddDays(-1)
                : checkIn.Date;

            // ━━━ Calculate the total price from daily schedules (final price with no extra discount) / حساب السعر الإجمالي من الجداول اليومية (سعر نهائي بدون خصم إضافي) ━━━
            var schedules = (await _scheduleRepository.GetByUnitAndDateRangeAsync(
                unitId, checkIn.Date, pricingEndDate)).ToList();

            var schedulesByDate = schedules
                .GroupBy(s => s.Date.Date)
                .ToDictionary(g => g.Key, g => g.OrderByDescending(x => x.UpdatedAt).First());

            decimal totalPrice = 0m;
            for (var day = checkIn.Date; day < checkOut.Date; day = day.AddDays(1))
            {
                if (!schedulesByDate.TryGetValue(day, out var schedule))
                {
                    return null;
                }

                if (!IsBookableStatus(schedule.Status))
                {
                    return null;
                }

                if (!schedule.PriceAmount.HasValue || schedule.PriceAmount.Value <= 0)
                {
                    return null;
                }

                totalPrice += schedule.PriceAmount.Value;
            }

            totalPrice = decimal.Round(totalPrice, 2);
            var perNight = nights > 0 ? decimal.Round(totalPrice / nights, 2) : 0m;
            return (unitId, unit.Name, unit.NameEn ?? unit.Name, unit.MaxCapacity, perNight);
        }

        private static bool IsBookableStatus(string? status)
        {
            return string.Equals(status, AvailabilityStatus.Available, StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(status, "Free", StringComparison.OrdinalIgnoreCase);
        }

        private async Task SelectBestUnit(
            PropertySearchResultDto dto,
            SearchPropertiesQuery query,
            CancellationToken cancellationToken)
        {
            try
            {
                var units = await _unitRepository.GetByPropertyIdAsync(dto.Id, cancellationToken);
                var guestCount = ResolveEffectiveGuestCount(query);

                // ━━━ Filter units by criteria / فلترة الوحدات حسب المعايير ━━━
                var filteredUnits = units
                    .Where(u => !query.UnitTypeId.HasValue || u.UnitTypeId == query.UnitTypeId.Value)
                    .Where(u => u.MaxCapacity >= guestCount)
                    .ToList();

                if (!filteredUnits.Any())
                {
                    _logger.LogDebug("⚠️ لا توجد وحدات مناسبة للعقار {PropertyId}", dto.Id);
                    return;
                }

                // ━━━ Fetch price from DailyUnitSchedule for each unit / جلب السعر من DailyUnitSchedule لكل وحدة ━━━
                var fallbackCurrency = string.IsNullOrWhiteSpace(dto.Currency)
                    ? "YER"
                    : dto.Currency;
                var unitsWithPrices = new List<(Core.Entities.Unit Unit, decimal Price, string Currency)>();

                foreach (var unit in filteredUnits)
                {
                    var (displayPrice, displayCurrency) = await GetUnitDisplayPriceAsync(
                        unit.Id,
                        fallbackCurrency,
                        cancellationToken);

                    if (displayPrice > 0)
                    {
                        unitsWithPrices.Add((unit, displayPrice, displayCurrency));
                    }
                }

                if (!unitsWithPrices.Any())
                {
                    _logger.LogDebug("⚠️ لا توجد أسعار متاحة في DailyUnitSchedule للعقار {PropertyId}", dto.Id);
                    return;
                }

                // ━━━ Pick the cheapest unit / اختيار الوحدة الأرخص ━━━
                var chosenUnitWithPrice = unitsWithPrices.OrderBy(u => u.Price).First();

                dto.UnitId = chosenUnitWithPrice.Unit.Id;
                dto.UnitName = chosenUnitWithPrice.Unit.Name;
                dto.UnitNameEn = chosenUnitWithPrice.Unit.NameEn ?? chosenUnitWithPrice.Unit.Name;
                dto.MinPrice = chosenUnitWithPrice.Price;
                dto.DiscountedPrice = chosenUnitWithPrice.Price;
                dto.Currency = chosenUnitWithPrice.Currency;
                dto.MaxCapacity = chosenUnitWithPrice.Unit.MaxCapacity;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "⚠️ خطأ في اختيار وحدة للعقار {PropertyId}", dto.Id);
            }
        }

        private async Task<(decimal Price, string Currency)> GetUnitDisplayPriceAsync(
            Guid unitId,
            string fallbackCurrency,
            CancellationToken cancellationToken)
        {
            var today = DateTime.UtcNow.Date;
            var searchEnd = today.AddDays(90);

            var schedules = (await _scheduleRepository.GetPricingForPeriodAsync(
                    unitId,
                    today,
                    searchEnd))
                .Where(IsDisplayEligibleSchedule)
                .ToList();

            if (!schedules.Any())
            {
                return (0m, NormalizeCurrency(fallbackCurrency));
            }

            var manuallyManagedSchedules = schedules
                .Where(IsManuallyManagedDisplaySchedule)
                .ToList();

            var effectiveSchedules = manuallyManagedSchedules.Any()
                ? manuallyManagedSchedules
                : schedules;

            var effectiveDate = effectiveSchedules.Min(s => s.Date.Date);
            var sameDaySchedules = effectiveSchedules
                .Where(s => s.Date.Date == effectiveDate)
                .ToList();

            var displayPrice = sameDaySchedules.Min(s => s.PriceAmount!.Value);
            var displayCurrency = sameDaySchedules
                                      .Select(s => s.Currency)
                                      .FirstOrDefault(c => !string.IsNullOrWhiteSpace(c))
                                  ?? fallbackCurrency;

            return (displayPrice, NormalizeCurrency(displayCurrency));
        }

        private static bool IsDisplayEligibleSchedule(Core.Entities.DailyUnitSchedule schedule)
        {
            return schedule.PriceAmount.HasValue &&
                   schedule.PriceAmount.Value > 0 &&
                   (schedule.Status == "Available" || schedule.Status == "Free");
        }

        private static bool IsManuallyManagedDisplaySchedule(Core.Entities.DailyUnitSchedule schedule)
        {
            return !string.IsNullOrWhiteSpace(schedule.CreatedBy) &&
                   !string.Equals(schedule.CreatedBy, "System", StringComparison.OrdinalIgnoreCase);
        }

        private async Task ConvertCurrency(
            PropertySearchResultDto dto,
            string targetCurrency,
            CancellationToken cancellationToken)
        {
            try
            {
                var target = targetCurrency.ToUpperInvariant();
                if (string.Equals(dto.Currency, target, StringComparison.OrdinalIgnoreCase))
                    return;

                var rate = await _currencyExchangeRepository.GetExchangeRateAsync(
                    dto.Currency, target);

                if (rate != null && rate.Rate > 0)
                {
                    var sourceCurrency = dto.Currency;
                    dto.MinPrice = Math.Round(dto.MinPrice * rate.Rate, 2);
                    dto.DiscountedPrice = Math.Round(dto.DiscountedPrice * rate.Rate, 2);
                    dto.Currency = target;

                    _logger.LogDebug("💱 تم تحويل العملة من {From} إلى {To}", sourceCurrency, target);
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "⚠️ خطأ في تحويل العملة للعقار {PropertyId}", dto.Id);
            }
        }

        private double CalculateDistance(double lat1, double lon1, double lat2, double lon2)
        {
            const double R = 6371; // Earth's radius in kilometers / نصف قطر الأرض بالكيلومتر.

            var dLat = ToRadians(lat2 - lat1);
            var dLon = ToRadians(lon2 - lon1);

            var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                    Math.Cos(ToRadians(lat1)) * Math.Cos(ToRadians(lat2)) *
                    Math.Sin(dLon / 2) * Math.Sin(dLon / 2);

            var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));

            return R * c;
        }

        private double ToRadians(double degrees) => degrees * Math.PI / 180;

        #endregion

        #region === بناء البيانات الوصفية ===

        private SearchFiltersDto BuildAppliedFilters(SearchPropertiesQuery request)
        {
            var filters = new SearchFiltersDto();

            // TODO: populate applied filters.
            // يمكن إضافة الحقول المطلوبة حسب SearchFiltersDto / Add the required fields based on SearchFiltersDto.

            return filters;
        }

        private SearchStatisticsDto BuildStatistics(
            List<PropertySearchResultDto> properties,
            int totalCount,
            DateTime startTime)
        {
            var duration = (long)(DateTime.UtcNow - startTime).TotalMilliseconds;

            var priceRange = properties.Any() ? new PriceRangeDto
            {
                MinPrice = properties.Min(p => p.MinPrice),
                MaxPrice = properties.Max(p => p.MinPrice),
                AveragePrice = properties.Average(p => p.MinPrice)
            } : null;

            var propertiesByType = properties
                .GroupBy(p => string.IsNullOrWhiteSpace(p.PropertyType) ? "غير محدد" : p.PropertyType)
                .ToDictionary(g => g.Key, g => g.Count());

            return new SearchStatisticsDto
            {
                SearchDurationMs = duration,
                AppliedFiltersCount = CountAppliedFilters(),
                TotalResultsBeforePaging = totalCount,
                PriceRange = priceRange,
                PropertiesByType = propertiesByType,
                AverageRating = properties.Any() ? (double)properties.Average(p => p.AverageRating) : 0
            };
        }

        private int CountAppliedFilters()
        {
            // TODO: calculate the number of applied filters.
            return 0;
        }

        private static int ResolveEffectiveGuestCount(SearchPropertiesQuery query)
        {
            if (query.Adults.HasValue || query.Children.HasValue)
            {
                return Math.Max(1, Math.Max(0, query.Adults ?? 0) + Math.Max(0, query.Children ?? 0));
            }

            return Math.Max(1, query.GuestsCount ?? 1);
        }

        #endregion

        #region === Diagnostics Logging ===

        private static object CreateRequestSnapshot(SearchPropertiesQuery request) => new
        {
            request.SearchTerm,
            request.City,
            request.PropertyTypeId,
            request.UnitTypeId,
            request.CheckIn,
            request.CheckOut,
            request.Adults,
            request.Children,
            request.GuestsCount,
            request.MinPrice,
            request.MaxPrice,
            request.MinStarRating,
            request.ServiceIds,
            request.RequiredAmenities,
            request.DynamicFieldFilters,
            request.Latitude,
            request.Longitude,
            request.RadiusKm,
            request.SortBy,
            request.PreferredCurrency,
            request.PreviewOnly,
            request.PageNumber,
            request.PageSize
        };

        private static object CreateIndexedRequestSnapshot(PropertyWithUnitsSearchRequest request) => new
        {
            request.SearchText,
            request.City,
            request.PropertyTypeId,
            request.UnitTypeId,
            request.CheckIn,
            request.CheckInLocalDate,
            request.CheckOut,
            request.CheckOutLocalDate,
            request.GuestsCount,
            request.AdultsCount,
            request.ChildrenCount,
            request.MinimumAmenityMatches,
            request.MinPrice,
            request.MaxPrice,
            request.MinRating,
            request.MinStarRating,
            request.RequiredServices,
            request.RequiredAmenities,
            request.DynamicFieldFilters,
            request.Latitude,
            request.Longitude,
            request.RadiusKm,
            request.SortBy,
            request.FeaturedOnly,
            request.GroupByProperty,
            request.MaxUnitsPerProperty,
            request.PageNumber,
            request.PageSize,
            request.PreferredCurrency
        };

        private static object CreateResponseSnapshot(SearchPropertiesResponse response) => new
        {
            response.TotalCount,
            response.CurrentPage,
            response.PageSize,
            response.TotalPages,
            response.SearchTimeMs,
            response.RelaxationLevel,
            response.WasRelaxed,
            response.RelaxedFilters,
            Facets = new
            {
                Cities = response.Facets?.Cities.Count ?? 0,
                PropertyTypes = response.Facets?.PropertyTypes.Count ?? 0,
                UnitTypes = response.Facets?.UnitTypes.Count ?? 0,
                Services = response.Facets?.Services.Count ?? 0,
                DynamicFieldValues = response.Facets?.DynamicFieldValues.Count ?? 0
            }
        };

        #endregion
    }
}
