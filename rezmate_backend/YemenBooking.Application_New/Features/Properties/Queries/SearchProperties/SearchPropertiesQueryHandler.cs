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
using YemenBooking.Application.Features.Units.Services;
using YemenBooking.Core.Enums;

namespace YemenBooking.Application.Features.Properties.Queries.SearchProperties
{
    /// <summary>
    /// معالج استعلام البحث عن العقارات المتقدم - مبني على Redis Indexing
    /// Handler for SearchPropertiesQuery using Redis Indexing System
    /// </summary>
    public class SearchPropertiesQueryHandler : IRequestHandler<SearchPropertiesQuery, ResultDto<SearchPropertiesResponse>>
    {
    private readonly IUnitIndexingService _indexingService;
        private readonly ICurrentUserService _currentUserService;
        private readonly ILogger<SearchPropertiesQueryHandler> _logger;
        private readonly IUnitRepository _unitRepository;
        private readonly IAvailabilityService _availabilityService;
        private readonly IDailyUnitScheduleRepository _scheduleRepository;
        private readonly ICurrencyExchangeRepository _currencyExchangeRepository;
        private readonly IAmenityRepository _amenityRepository;
        private readonly IPropertyServiceRepository _propertyServiceRepository;

        public SearchPropertiesQueryHandler(
            IUnitIndexingService indexingService,
            ICurrentUserService currentUserService,
            ILogger<SearchPropertiesQueryHandler> logger,
            IUnitRepository unitRepository,
            IAvailabilityService availabilityService,
            IDailyUnitScheduleRepository scheduleRepository,
            ICurrencyExchangeRepository currencyExchangeRepository,
            IAmenityRepository amenityRepository,
            IPropertyServiceRepository propertyServiceRepository)
        {
            _indexingService = indexingService ?? throw new ArgumentNullException(nameof(indexingService));
            _currentUserService = currentUserService ?? throw new ArgumentNullException(nameof(currentUserService));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            _unitRepository = unitRepository ?? throw new ArgumentNullException(nameof(unitRepository));
            _availabilityService = availabilityService ?? throw new ArgumentNullException(nameof(availabilityService));
            _scheduleRepository = scheduleRepository ?? throw new ArgumentNullException(nameof(scheduleRepository));
            _currencyExchangeRepository = currencyExchangeRepository ?? throw new ArgumentNullException(nameof(currencyExchangeRepository));
            _amenityRepository = amenityRepository ?? throw new ArgumentNullException(nameof(amenityRepository));
            _propertyServiceRepository = propertyServiceRepository ?? throw new ArgumentNullException(nameof(propertyServiceRepository));
        }

        public async Task<ResultDto<SearchPropertiesResponse>> Handle(
            SearchPropertiesQuery request,
            CancellationToken cancellationToken)
        {
            var startTime = DateTime.UtcNow;

            _logger.LogInformation(
                "🔍 بدء البحث عن العقارات - المدينة: {City}, السعر: {MinPrice}-{MaxPrice}, الصفحة: {PageNumber}/{PageSize}",
                request.City, request.MinPrice, request.MaxPrice, request.PageNumber, request.PageSize);
            
            // ━━━ تسجيل الحقول الديناميكية ━━━
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
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // المرحلة 1: التحقق من صحة الطلب
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                var validationResult = ValidateRequest(request);
                if (!validationResult.IsSuccess)
                {
                    _logger.LogWarning("⚠️ طلب البحث غير صالح: {Error}", validationResult.Message);
                    return validationResult;
                }

                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // المرحلة 2: بناء طلب البحث الداخلي
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                var searchRequest = await BuildSearchRequest(request, cancellationToken);
                searchRequest.IncludeAllMatchesForFacets = true;
                searchRequest.PageNumber = 1;

                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // المرحلة 3: تنفيذ البحث عبر محرك البحث الفعلي
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                var searchResult = await _indexingService.SearchPropertiesWithUnitsAsync(searchRequest, cancellationToken);

                _logger.LogInformation(
                    "✅ اكتمل البحث: وجد {TotalPropertiesCount} عقار و {TotalUnitsCount} وحدة - المستوى: {RelaxationLevel}",
                    searchResult.TotalPropertiesCount,
                    searchResult.TotalUnitsCount,
                    searchResult.RelaxationLevel);

                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // المرحلة 4: تطبيق فلاتر الأمان حسب الدور
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                var filteredProperties = await ApplySecurityFilters(searchResult.Properties, cancellationToken);

                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // المرحلة 5: تحويل النتائج إلى DTOs
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                var propertyDtos = await ConvertToPropertyDtos(filteredProperties, request, cancellationToken);
                propertyDtos = ApplyPropertySorting(propertyDtos, request).ToList();

                var liveFacets = await BuildLiveFacetsAsync(filteredProperties, request, cancellationToken);

                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // المرحلة 6: إعادة حساب التصفح بعد فلاتر الأمان
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                var totalCount = propertyDtos.Count;
                var totalPages = (int)Math.Ceiling(totalCount / (double)request.PageSize);

                var pagedDtos = propertyDtos
                    .Skip((request.PageNumber - 1) * request.PageSize)
                    .Take(request.PageSize)
                    .ToList();

                _logger.LogInformation(
                    "📄 تم إرجاع {ReturnedCount} عقار من إجمالي {TotalCount}",
                    pagedDtos.Count, totalCount);

                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // المرحلة 7: بناء النتيجة النهائية
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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
                    Facets = liveFacets,
                    SearchTimeMs = (long)(DateTime.UtcNow - startTime).TotalMilliseconds,
                    Statistics = BuildStatistics(propertyDtos, totalCount, startTime, request),
                    
                    // ✅ استخراج معلومات استراتيجية Fallback Search
                    RelaxationLevel = searchResult.RelaxationLevel,
                    RelaxedFilters = searchResult.RelaxedFilters,
                    UserMessage = searchResult.UserMessage,
                    SuggestedActions = searchResult.SuggestedActions
                };

                _logger.LogInformation(
                    "🎯 اكتمل البحث بنجاح في {ElapsedMs}ms - WasRelaxed: {WasRelaxed}",
                    response.SearchTimeMs,
                    response.WasRelaxed);

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

        #region === التحقق من صحة الطلب ===

        /// <summary>
        /// التحقق من صحة طلب البحث
        /// Validate search request
        /// </summary>
        private ResultDto<SearchPropertiesResponse> ValidateRequest(SearchPropertiesQuery request)
        {
            // التحقق من رقم الصفحة
            if (request.PageNumber < 1)
            {
                return ResultDto<SearchPropertiesResponse>.Failed(
                    "رقم الصفحة يجب أن يكون أكبر من صفر",
                    "INVALID_PAGE_NUMBER");
            }

            // التحقق من حجم الصفحة
            if (request.PageSize < 1 || request.PageSize > 100)
            {
                return ResultDto<SearchPropertiesResponse>.Failed(
                    "حجم الصفحة يجب أن يكون بين 1 و 100",
                    "INVALID_PAGE_SIZE");
            }

            // التحقق من نطاق التواريخ
            if (request.CheckIn.HasValue && request.CheckOut.HasValue)
            {
                // التحقق من أن CheckOut بعد CheckIn (مقارنة بسيطة بدون timezone)
                if (request.CheckIn.Value.Date >= request.CheckOut.Value.Date)
                {
                    return ResultDto<SearchPropertiesResponse>.Failed(
                        "تاريخ الوصول يجب أن يكون قبل تاريخ المغادرة",
                        "INVALID_DATE_RANGE");
                }
            }

            // التحقق من نطاق السعر
            if (request.MinPrice.HasValue && request.MaxPrice.HasValue)
            {
                if (request.MinPrice > request.MaxPrice)
                {
                    return ResultDto<SearchPropertiesResponse>.Failed(
                        "السعر الأدنى يجب أن يكون أقل من السعر الأقصى",
                        "INVALID_PRICE_RANGE");
                }
            }

            // التحقق من نصف القطر
            if (request.RadiusKm.HasValue && request.RadiusKm <= 0)
            {
                return ResultDto<SearchPropertiesResponse>.Failed(
                    "نصف القطر يجب أن يكون أكبر من صفر",
                    "INVALID_RADIUS");
            }

            return ResultDto<SearchPropertiesResponse>.Ok(null);
        }

        #endregion

        #region === بناء طلب البحث الداخلي ===

        /// <summary>
        /// بناء طلب البحث الداخلي من طلب البحث الأصلي
        /// Building the internal search request from the original search query
        /// </summary>
        private async Task<PropertyWithUnitsSearchRequest> BuildSearchRequest(
            SearchPropertiesQuery query,
            CancellationToken cancellationToken)
        {
            // ━━━ تحويل التواريخ إلى UTC ━━━
            var checkInUtc = query.CheckIn.HasValue
                ? await _currentUserService.ConvertFromUserLocalToUtcAsync(query.CheckIn.Value)
                : (DateTime?)null;

            var checkOutUtc = query.CheckOut.HasValue
                ? await _currentUserService.ConvertFromUserLocalToUtcAsync(query.CheckOut.Value)
                : (DateTime?)null;

            // ━━━ حساب عدد الضيوف الفعلي ━━━
            // إعطاء الأولوية لـ Adults + Children إذا كانا موجودين
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

            // ━━━ بناء طلب البحث ━━━
            var searchRequest = new PropertyWithUnitsSearchRequest
            {
                // ━━━ النص والموقع (Text & Location) ━━━
                SearchText = NormalizeSearchText(query.SearchTerm),
                City = NormalizeCity(query.City),

                // ━━━ التواريخ (Dates) ━━━
                CheckIn = checkInUtc,
                CheckOut = checkOutUtc,

                // ━━━ السعة (Capacity) ━━━
                GuestsCount = effectiveGuests,
                AdultsCount = query.Adults,
                ChildrenCount = query.Children,

                // ━━━ السعر (Price) ━━━
                MinPrice = query.MinPrice,
                MaxPrice = query.MaxPrice,
                PreferredCurrency = NormalizeCurrency(query.PreferredCurrency),

                // ━━━ التقييم (Rating) ━━━
                MinRating = query.MinStarRating.HasValue ? (decimal)query.MinStarRating.Value : null,

                // ━━━ نوع العقار (Property Type) ━━━
                PropertyTypeId = query.PropertyTypeId,

                // ━━━ نوع الوحدة (Unit Type) ━━━
                UnitTypeId = query.UnitTypeId,

                // ━━━ المرافق والخدمات (Amenities & Services) ━━━
                RequiredAmenities = query.RequiredAmenities?.ToList(),
                RequiredServices = query.ServiceIds?.ToList(),

                // ━━━ الحقول الديناميكية (Dynamic Fields) ━━━
                DynamicFieldFilters = BuildDynamicFieldFilters(query.DynamicFieldFilters),

                // ━━━ البحث الجغرافي (Geographic Search) ━━━
                Latitude = query.Latitude,
                Longitude = query.Longitude,
                RadiusKm = query.RadiusKm.HasValue ? (double)query.RadiusKm.Value : null,

                // ━━━ الترتيب والتصفح (Sorting & Pagination) ━━━
                SortBy = NormalizeSortBy(query.SortBy, query.Latitude, query.Longitude),
                PageNumber = query.PageNumber,
                PageSize = query.PageSize,
                
                // ━━━ إعدادات تجميع النتائج (Grouping Settings) ━━━
                GroupByProperty = true, // نريد تجميع النتائج حسب العقار
                MaxUnitsPerProperty = null // عرض جميع الوحدات المطابقة
            };

            return searchRequest;
        }

        /// <summary>
        /// تطبيع نص البحث
        /// </summary>
        private string? NormalizeSearchText(string? searchText)
        {
            if (string.IsNullOrWhiteSpace(searchText))
                return null;

            return searchText.Trim();
        }

        /// <summary>
        /// تطبيع اسم المدينة
        /// </summary>
        private string? NormalizeCity(string? city)
        {
            if (string.IsNullOrWhiteSpace(city))
                return null;

            return city.Trim();
        }

        /// <summary>
        /// تطبيع رمز العملة
        /// </summary>
        private string NormalizeCurrency(string? currency)
        {
            if (string.IsNullOrWhiteSpace(currency))
                return "YER";

            return currency.ToUpperInvariant();
        }

        /// <summary>
        /// بناء فلاتر الحقول الديناميكية - إزالة القيم الفارغة فقط
        /// Build dynamic field filters - remove empty values only
        /// </summary>
        private Dictionary<string, string>? BuildDynamicFieldFilters(
            Dictionary<string, string>? filters)
        {
            if (filters == null || !filters.Any())
                return null;

            // فلترة القيم الفارغة فقط
            // Filter empty values only
            var result = filters
                .Where(f => !string.IsNullOrWhiteSpace(f.Value))
                .ToDictionary(f => f.Key, f => f.Value);

            return result.Any() ? result : null;
        }

        /// <summary>
        /// تطبيع قيمة الترتيب
        /// </summary>
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

        #region === فلاتر الأمان ===

        /// <summary>
        /// تطبيق فلاتر الأمان حسب دور المستخدم
        /// Apply security filters based on user role
        /// </summary>
        private async Task<List<PropertyGroupSearchItem>> ApplySecurityFilters(
            List<PropertyGroupSearchItem> properties,
            CancellationToken cancellationToken)
        {
            var userRole = _currentUserService.Role;
            var userId = _currentUserService.UserId;

            // ━━━ Admin: لا قيود ━━━
            if (string.Equals(userRole, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                _logger.LogDebug("🔓 Admin - لا توجد فلاتر أمان");
                return properties;
            }

            // ━━━ Owner: فقط عقاراته ━━━
            if (string.Equals(userRole, "Owner", StringComparison.OrdinalIgnoreCase))
            {
                _logger.LogDebug("👤 Owner - فلترة حسب المالك {UserId}", userId);

                // TODO: PropertySearchItem يجب أن يحتوي على OwnerId
                // مؤقتاً نُرجع جميع العقارات
                return properties;
            }

            // ━━━ Guest/User: فقط العقارات المعتمدة ━━━
            _logger.LogDebug("👥 Guest/User - فلترة العقارات المعتمدة فقط");

            // TODO: PropertySearchItem يجب أن يحتوي على IsApproved
            // مؤقتاً نُرجع جميع العقارات
            return properties;
        }

        #endregion

        #region === تحويل إلى DTOs ===

        /// <summary>
        /// تحويل PropertySearchItem إلى PropertySearchResultDto
        /// </summary>
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
                    
                    // ✅ نسخ الفروقات من نتيجة البحث إلى DTO
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

        /// <summary>
        /// تحويل عنصر واحد من PropertyGroupSearchItem إلى PropertySearchResultDto
        /// </summary>
        private async Task<PropertySearchResultDto> ConvertToPropertyDto(
            PropertyGroupSearchItem item,
            SearchPropertiesQuery query,
            CancellationToken cancellationToken)
        {
            var propertyId = item.PropertyId;

            // ━━━ بناء DTO أساسي ━━━
            var dto = new PropertySearchResultDto
            {
                Id = propertyId,
                Name = item.PropertyName,
                Description = string.Empty,
                PropertyType = item.PropertyTypeName ?? string.Empty,
                Address = item.Address,
                City = item.City,
                MinPrice = item.PriceRange?.Min ?? 0,
                DiscountedPrice = item.PriceRange?.Min ?? 0,
                Currency = "YER",
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
                LastUpdated = await _currentUserService.ConvertFromUtcToUserLocalAsync(DateTime.UtcNow)
            };

            dto.DynamicFieldValues = item.MatchedUnits
                .SelectMany(unit => unit.SearchableFields)
                .Where(field => !string.IsNullOrWhiteSpace(field.FieldName) && !string.IsNullOrWhiteSpace(field.Value))
                .GroupBy(field => field.FieldName, StringComparer.OrdinalIgnoreCase)
                .ToDictionary(
                    group => group.Key,
                    group => (object)group
                        .OrderByDescending(field => field.IsPrimaryFilter)
                        .ThenByDescending(field => field.Priority)
                        .Select(field => field.Value)
                        .First());

            // ━━━ حساب الإتاحة والسعر إذا كانت هناك تواريخ ━━━
            if (query.CheckIn.HasValue && query.CheckOut.HasValue)
            {
                await CalculateAvailabilityAndPricing(dto, query, cancellationToken);
            }
            else if (query.UnitTypeId.HasValue || query.GuestsCount.HasValue)
            {
                await SelectBestUnit(dto, query, cancellationToken);
            }

            // ━━━ تحويل العملة إذا طُلب ━━━
            if (!string.IsNullOrWhiteSpace(query.PreferredCurrency) &&
                !string.Equals(dto.Currency, query.PreferredCurrency, StringComparison.OrdinalIgnoreCase))
            {
                await ConvertCurrency(dto, query.PreferredCurrency, cancellationToken);
            }

            // ━━━ حساب المسافة إذا كان بحث جغرافي ━━━
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

        /// <summary>
        /// حساب الإتاحة والتسعير للعقار بناءً على التواريخ
        /// </summary>
        private async Task CalculateAvailabilityAndPricing(
            PropertySearchResultDto dto,
            SearchPropertiesQuery query,
            CancellationToken cancellationToken)
        {
            try
            {
                var checkIn = query.CheckIn!.Value;
                var checkOut = query.CheckOut!.Value;
                var guestCount = GetEffectiveGuestsCount(query) ?? 1;

                // ━━━ الحصول على الوحدات المتاحة ━━━
                var availableUnitIds = await _availabilityService
                    .GetAvailableUnitsInPropertyAsync(dto.Id, checkIn, checkOut, guestCount, cancellationToken);

                // ━━━ تطبيق فلاتر إضافية (نوع الوحدة، السعة) ━━━
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
                    dto.MaxCapacity = 0;
                    _logger.LogDebug("⚠️ لا توجد وحدات متاحة للعقار {PropertyId}", dto.Id);
                    return;
                }

                var pricedCandidates = new List<(Guid UnitId, string UnitName, int MaxCapacity, decimal PerNight)>();
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
                    dto.MaxCapacity = 0;
                    return;
                }

                // نعرض أرخص وحدة قابلة للحجز فعلياً حتى تتطابق البطاقة مع مسار جلب الوحدات.
                var selectedPricedCandidate = pricedCandidates
                    .OrderBy(candidate => candidate.PerNight)
                    .ThenByDescending(candidate => candidate.MaxCapacity)
                    .First();

                dto.UnitId = selectedPricedCandidate.UnitId;
                dto.UnitName = selectedPricedCandidate.UnitName;
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

        /// <summary>
        /// اختيار أفضل وحدة متاحة
        /// </summary>
        private async Task<Guid> SelectBestAvailableUnit(
            List<Guid> availableUnitIds,
            Guid? preferredUnitTypeId,
            int guestCount,
            CancellationToken cancellationToken)
        {
            // ━━━ البحث عن وحدة من النوع المفضل أولاً ━━━
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

            // ━━━ إذا لم توجد، نختار أول وحدة متاحة ━━━
            return availableUnitIds.FirstOrDefault();
        }

        /// <summary>
        /// تعيين بيانات التسعير من الوحدة المحددة
        /// </summary>
        private async Task<(Guid UnitId, string UnitName, int MaxCapacity, decimal PerNight)?> GetPricedUnitCandidate(
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

            // ━━━ حساب السعر الإجمالي من الجداول اليومية (سعر نهائي بدون خصم إضافي) ━━━
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
            return (unitId, unit.Name, unit.MaxCapacity, perNight);
        }

        private static bool IsBookableStatus(string? status)
        {
            return string.Equals(status, AvailabilityStatus.Available, StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(status, "Free", StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// اختيار أفضل وحدة بدون تواريخ (بناءً على السعر)
        /// </summary>
        private async Task SelectBestUnit(
            PropertySearchResultDto dto,
            SearchPropertiesQuery query,
            CancellationToken cancellationToken)
        {
            try
            {
                var units = await _unitRepository.GetByPropertyIdAsync(dto.Id, cancellationToken);
                var guestCount = GetEffectiveGuestsCount(query) ?? 1;

                // ━━━ فلترة الوحدات حسب المعايير ━━━
                var filteredUnits = units
                    .Where(u => !query.UnitTypeId.HasValue || u.UnitTypeId == query.UnitTypeId.Value)
                    .Where(u => u.MaxCapacity >= guestCount)
                    .ToList();

                if (!filteredUnits.Any())
                {
                    _logger.LogDebug("⚠️ لا توجد وحدات مناسبة للعقار {PropertyId}", dto.Id);
                    return;
                }

                // ━━━ جلب السعر من DailyUnitSchedule لكل وحدة ━━━
                var today = DateTime.UtcNow.Date;
                var unitsWithPrices = new List<(Core.Entities.Unit Unit, decimal Price, string Currency)>();

                foreach (var unit in filteredUnits)
                {
                    var schedule = await _scheduleRepository.GetByUnitAndDateAsync(unit.Id, today);
                    if (schedule != null && schedule.PriceAmount.HasValue)
                    {
                        unitsWithPrices.Add((unit, schedule.PriceAmount.Value, schedule.Currency ?? "YER"));
                    }
                }

                if (!unitsWithPrices.Any())
                {
                    _logger.LogDebug("⚠️ لا توجد أسعار متاحة في DailyUnitSchedule للعقار {PropertyId}", dto.Id);
                    return;
                }

                // ━━━ اختيار الوحدة الأرخص ━━━
                var chosenUnitWithPrice = unitsWithPrices.OrderBy(u => u.Price).First();

                dto.UnitId = chosenUnitWithPrice.Unit.Id;
                dto.UnitName = chosenUnitWithPrice.Unit.Name;
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

        /// <summary>
        /// تحويل العملة
        /// </summary>
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
                    dto.MinPrice = Math.Round(dto.MinPrice * rate.Rate, 2);
                    dto.DiscountedPrice = Math.Round(dto.DiscountedPrice * rate.Rate, 2);
                    dto.Currency = target;

                    _logger.LogDebug("💱 تم تحويل العملة من {From} إلى {To}", dto.Currency, target);
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "⚠️ خطأ في تحويل العملة للعقار {PropertyId}", dto.Id);
            }
        }

        /// <summary>
        /// حساب المسافة بين نقطتين (Haversine formula)
        /// </summary>
        private double CalculateDistance(double lat1, double lon1, double lat2, double lon2)
        {
            const double R = 6371; // نصف قطر الأرض بالكيلومتر

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

        /// <summary>
        /// بناء الفلاتر المطبقة
        /// </summary>
        private SearchFiltersDto BuildAppliedFilters(SearchPropertiesQuery request)
        {
            var filters = new SearchFiltersDto
            {
                AvailableCities = string.IsNullOrWhiteSpace(request.City)
                    ? new List<string>()
                    : new List<string> { request.City.Trim() },
                Cities = string.IsNullOrWhiteSpace(request.City)
                    ? new List<CityFilterDto>()
                    : new List<CityFilterDto>
                    {
                        new() { Name = request.City.Trim(), PropertiesCount = 0 }
                    },
                PropertyTypes = request.PropertyTypeId.HasValue
                    ? new List<PropertyTypeFilterDto>
                    {
                        new() { Id = request.PropertyTypeId.Value, PropertiesCount = 0 }
                    }
                    : new List<PropertyTypeFilterDto>(),
                PriceRange = new PriceRangeDto
                {
                    MinPrice = request.MinPrice ?? 0,
                    MaxPrice = request.MaxPrice ?? 0,
                    AveragePrice = 0
                },
                Amenities = request.RequiredAmenities
                    .Select(id => new AmenityFilterDto { Id = id, PropertiesCount = 0 })
                    .ToList(),
                StarRatings = request.MinStarRating.HasValue
                    ? new List<int> { request.MinStarRating.Value }
                    : new List<int>(),
                MaxGuestCapacity = GetEffectiveGuestsCount(request) ?? 0,
                UnitTypes = request.UnitTypeId.HasValue
                    ? new List<UnitTypeFilterDto>
                    {
                        new() { Id = request.UnitTypeId.Value, UnitsCount = 0 }
                    }
                    : new List<UnitTypeFilterDto>(),
                DistanceRange = new DistanceRangeDto
                {
                    MinDistance = 0,
                    MaxDistance = request.RadiusKm ?? 0
                },
                SupportedCurrencies = string.IsNullOrWhiteSpace(request.PreferredCurrency)
                    ? new List<string>()
                    : new List<string> { request.PreferredCurrency.ToUpperInvariant() },
                Services = request.ServiceIds
                    .Select(id => new ServiceFilterDto { Id = id, PropertiesCount = 0 })
                    .ToList(),
                DynamicFieldValues = request.DynamicFieldFilters
                    .Select(filter => new DynamicFieldValueFilterDto
                    {
                        FieldName = filter.Key,
                        Value = filter.Value,
                        Count = 0
                    })
                    .ToList()
            };

            return filters;
        }

        /// <summary>
        /// بناء إحصائيات البحث
        /// </summary>
        private SearchStatisticsDto BuildStatistics(
            List<PropertySearchResultDto> properties,
            int totalCount,
            DateTime startTime,
            SearchPropertiesQuery request)
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
                AppliedFiltersCount = CountAppliedFilters(request),
                TotalResultsBeforePaging = totalCount,
                PriceRange = priceRange,
                PropertiesByType = propertiesByType,
                AverageRating = properties.Any() ? (double)properties.Average(p => p.AverageRating) : 0
            };
        }

        /// <summary>
        /// عد الفلاتر المطبقة
        /// </summary>
        private int CountAppliedFilters(SearchPropertiesQuery request)
        {
            var count = 0;

            if (!string.IsNullOrWhiteSpace(request.SearchTerm)) count++;
            if (!string.IsNullOrWhiteSpace(request.City)) count++;
            if (request.CheckIn.HasValue && request.CheckOut.HasValue) count++;
            if (request.PropertyTypeId.HasValue) count++;
            if (request.UnitTypeId.HasValue) count++;
            if (request.MinPrice.HasValue || request.MaxPrice.HasValue) count++;
            if (request.MinStarRating.HasValue) count++;
            if (request.RequiredAmenities.Any()) count++;
            if (request.ServiceIds.Any()) count++;
            if (request.DynamicFieldFilters.Any()) count++;
            if (GetEffectiveGuestsCount(request).HasValue) count++;
            if (request.Latitude.HasValue && request.Longitude.HasValue && request.RadiusKm.HasValue) count++;

            return count;
        }

        private int? GetEffectiveGuestsCount(SearchPropertiesQuery request)
        {
            if (request.Adults.HasValue || request.Children.HasValue)
            {
                return Math.Max(0, request.Adults ?? 0) + Math.Max(0, request.Children ?? 0);
            }

            return request.GuestsCount;
        }

        private IEnumerable<PropertySearchResultDto> ApplyPropertySorting(
            IEnumerable<PropertySearchResultDto> properties,
            SearchPropertiesQuery request)
        {
            var sortBy = request.SortBy?.Trim().ToLowerInvariant();

            return sortBy switch
            {
                "price_asc" => properties.OrderBy(property => property.MinPrice).ThenBy(property => property.Name),
                "price_desc" => properties.OrderByDescending(property => property.MinPrice).ThenBy(property => property.Name),
                "distance" => properties.OrderBy(property => property.DistanceKm ?? double.MaxValue).ThenByDescending(property => property.AverageRating),
                "rating" => properties.OrderByDescending(property => property.AverageRating).ThenByDescending(property => property.StarRating),
                "newest" => properties.OrderByDescending(property => property.LastUpdated).ThenByDescending(property => property.IsFeatured),
                "popular" => properties.OrderByDescending(property => property.MatchPercentage).ThenByDescending(property => property.AvailableUnitsCount),
                _ => properties.OrderByDescending(property => property.IsFeatured)
                    .ThenByDescending(property => property.AverageRating)
                    .ThenByDescending(property => property.AvailableUnitsCount)
            };
        }

        private async Task<SearchFiltersDto> BuildLiveFacetsAsync(
            List<PropertyGroupSearchItem> properties,
            SearchPropertiesQuery request,
            CancellationToken cancellationToken)
        {
            var facets = new SearchFiltersDto();

            if (!properties.Any())
            {
                return facets;
            }

            var propertyIds = properties.Select(property => property.PropertyId).ToHashSet();
            var propertyTypeByPropertyId = properties.ToDictionary(
                property => property.PropertyId,
                property => property.PropertyTypeId);

            facets.Cities = properties
                .Where(property => !string.IsNullOrWhiteSpace(property.City))
                .GroupBy(property => property.City.Trim(), StringComparer.OrdinalIgnoreCase)
                .Select(group => new CityFilterDto
                {
                    Name = group.First().City.Trim(),
                    PropertiesCount = group.Select(property => property.PropertyId).Distinct().Count()
                })
                .OrderByDescending(city => city.PropertiesCount)
                .ThenBy(city => city.Name)
                .ToList();
            facets.AvailableCities = facets.Cities.Select(city => city.Name).ToList();

            facets.PropertyTypes = properties
                .GroupBy(property => new { property.PropertyTypeId, property.PropertyTypeName })
                .Select(group => new PropertyTypeFilterDto
                {
                    Id = group.Key.PropertyTypeId,
                    Name = group.Key.PropertyTypeName ?? string.Empty,
                    PropertiesCount = group.Select(property => property.PropertyId).Distinct().Count()
                })
                .OrderByDescending(type => type.PropertiesCount)
                .ThenBy(type => type.Name)
                .ToList();

            facets.UnitTypes = properties
                .SelectMany(property => property.MatchedUnits)
                .GroupBy(unit => new
                {
                    unit.UnitTypeId,
                    unit.UnitTypeName,
                    unit.PricingMethod
                })
                .Select(group => new UnitTypeFilterDto
                {
                    Id = group.Key.UnitTypeId,
                    PropertyTypeId = group.Select(unit => unit.PropertyTypeId).FirstOrDefault(),
                    Name = group.Key.UnitTypeName ?? string.Empty,
                    UnitsCount = group.Select(unit => unit.UnitId).Distinct().Count(),
                    IsHasAdults = group.Any(unit => unit.MaxCapacity > 0),
                    IsHasChildren = group.Any(unit => unit.MaxCapacity > 1),
                    IsMultiDays = group.Any(unit => string.Equals(unit.PricingMethod, "Daily", StringComparison.OrdinalIgnoreCase)),
                    IsRequiredToDetermineTheHour = group.Any(unit => string.Equals(unit.PricingMethod, "Hourly", StringComparison.OrdinalIgnoreCase))
                })
                .OrderByDescending(type => type.UnitsCount)
                .ThenBy(type => type.Name)
                .ToList();

            facets.StarRatings = properties
                .Select(property => property.StarRating)
                .Where(rating => rating > 0)
                .Distinct()
                .OrderByDescending(rating => rating)
                .ToList();

            var prices = properties
                .Where(property => property.MinPrice > 0)
                .Select(property => property.MinPrice)
                .ToList();
            if (prices.Any())
            {
                facets.PriceRange = new PriceRangeDto
                {
                    MinPrice = prices.Min(),
                    MaxPrice = prices.Max(),
                    AveragePrice = prices.Average()
                };
            }

            facets.MaxGuestCapacity = properties
                .SelectMany(property => property.MatchedUnits)
                .Select(unit => unit.MaxCapacity)
                .DefaultIfEmpty(0)
                .Max();

            var distances = properties
                .Where(property => property.DistanceKm.HasValue)
                .Select(property => property.DistanceKm!.Value)
                .ToList();
            if (distances.Any())
            {
                facets.DistanceRange = new DistanceRangeDto
                {
                    MinDistance = distances.Min(),
                    MaxDistance = distances.Max()
                };
            }

            facets.SupportedCurrencies = properties
                .SelectMany(property => property.MatchedUnits)
                .Select(unit => unit.Currency)
                .Where(currency => !string.IsNullOrWhiteSpace(currency))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .OrderBy(currency => currency)
                .ToList();

            facets.DynamicFieldValues = properties
                .SelectMany(property => property.MatchedUnits)
                .SelectMany(unit => unit.SearchableFields)
                .Where(field => !string.IsNullOrWhiteSpace(field.FieldName) && !string.IsNullOrWhiteSpace(field.Value))
                .GroupBy(field => new
                {
                    FieldName = field.FieldName.Trim().ToLowerInvariant(),
                    Value = field.Value.Trim().ToLowerInvariant()
                })
                .Select(group => new DynamicFieldValueFilterDto
                {
                    FieldName = group.First().FieldName.Trim(),
                    Value = group.First().Value.Trim(),
                    Count = group.Count()
                })
                .OrderBy(dynamicField => dynamicField.FieldName)
                .ThenByDescending(dynamicField => dynamicField.Count)
                .ThenBy(dynamicField => dynamicField.Value)
                .ToList();

            var propertyAmenities = (await _amenityRepository.GetAllPropertyAmenitiesAsync(cancellationToken))
                .Where(propertyAmenity => propertyIds.Contains(propertyAmenity.PropertyId))
                .ToList();
            facets.Amenities = propertyAmenities
                .Where(propertyAmenity => propertyAmenity.PropertyTypeAmenity?.Amenity != null)
                .GroupBy(propertyAmenity => propertyAmenity.PropertyTypeAmenity!.AmenityId)
                .Select(group =>
                {
                    var propertyTypeIds = group
                        .Select(propertyAmenity => propertyTypeByPropertyId.GetValueOrDefault(propertyAmenity.PropertyId))
                        .Where(id => id != Guid.Empty)
                        .Distinct()
                        .ToList();

                    var amenity = group.First().PropertyTypeAmenity!.Amenity;
                    return new AmenityFilterDto
                    {
                        Id = amenity.Id,
                        Name = amenity.Name ?? string.Empty,
                        Category = "عام",
                        Icon = amenity.Icon ?? string.Empty,
                        PropertiesCount = group.Select(propertyAmenity => propertyAmenity.PropertyId).Distinct().Count(),
                        PropertyTypeIds = propertyTypeIds
                    };
                })
                .OrderByDescending(amenity => amenity.PropertiesCount)
                .ThenBy(amenity => amenity.Name)
                .ToList();

            var propertyServices = (await _propertyServiceRepository.GetAllAsync(cancellationToken))
                .Where(service => propertyIds.Contains(service.PropertyId))
                .ToList();
            facets.Services = propertyServices
                .GroupBy(service => service.Id)
                .Select(group =>
                {
                    var service = group.First();
                    return new ServiceFilterDto
                    {
                        Id = service.Id,
                        Name = service.Name ?? string.Empty,
                        Icon = service.Icon ?? string.Empty,
                        PropertiesCount = group.Select(item => item.PropertyId).Distinct().Count()
                    };
                })
                .OrderByDescending(service => service.PropertiesCount)
                .ThenBy(service => service.Name)
                .ToList();

            return facets;
        }

        #endregion
    }
}
