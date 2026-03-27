using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using YemenBooking.Application.Features.SearchAndFilters.Services;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Indexing.Enums;
using YemenBooking.Core.Indexing.Models;
using YemenBooking.Core.Indexing.Options;
using YemenBooking.Infrastructure.Data.Context;
using YemenBooking.Infrastructure.Postgres.Configuration;
using YemenBooking.Infrastructure.Services;

namespace YemenBooking.Infrastructure.Postgres.Indexing;

/// <summary>
/// محرك البحث المحسّن لـ PostgreSQL
/// تنفيذ IUnitSearchEngine للعمل مباشرة مع قاعدة البيانات الأساسية
/// 
/// المبادئ الرئيسية:
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// ✅ جميع العمليات تتم في SQL فقط - لا جلب للبيانات إلا النتائج النهائية
/// ✅ الإتاحة تعتمد على DailyUnitSchedule حسب التواريخ
/// ✅ التسعير يعتمد على DailyUnitSchedule حسب التواريخ
/// ✅ استخدام فهارس PostgreSQL المحسّنة (B-Tree, GIN, GiST, Range)
/// </summary>
public sealed class PostgresUnitSearchEngine : IUnitSearchEngine
{
    #region === الحقول الخاصة ===
    
    private readonly YemenBookingDbContext _context;
    private readonly ILogger<PostgresUnitSearchEngine> _logger;
    private readonly IMemoryCache _cache;
    private readonly ISearchRelaxationService _relaxationService;
    private readonly SearchMessageGenerator _messageGenerator;
    private readonly PropertyFilterComparisonService _comparisonService;
    private readonly FallbackSearchOptions _fallbackOptions;
    private readonly SearchSafeGuardOptions _safeGuardOptions;
    
    #endregion
    
    #region === البناء والتهيئة ===
    
    public PostgresUnitSearchEngine(
        YemenBookingDbContext context,
        ILogger<PostgresUnitSearchEngine> logger,
        IMemoryCache cache,
        ISearchRelaxationService relaxationService,
        SearchMessageGenerator messageGenerator,
        PropertyFilterComparisonService comparisonService,
        IOptions<FallbackSearchOptions> fallbackOptions,
        IOptions<SearchSafeGuardOptions> safeGuardOptions)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        _cache = cache ?? throw new ArgumentNullException(nameof(cache));
        _relaxationService = relaxationService ?? throw new ArgumentNullException(nameof(relaxationService));
        _messageGenerator = messageGenerator ?? throw new ArgumentNullException(nameof(messageGenerator));
        _comparisonService = comparisonService ?? throw new ArgumentNullException(nameof(comparisonService));
        _fallbackOptions = fallbackOptions?.Value ?? new FallbackSearchOptions();
        _safeGuardOptions = safeGuardOptions?.Value ?? new SearchSafeGuardOptions();
        
        // التحقق من صحة الخيارات
        _fallbackOptions.Validate();
        _safeGuardOptions.Validate();
    }
    
    public Task PreloadScriptsAsync()
    {
        _logger.LogInformation("PostgresUnitSearchEngine: لا حاجة لتحميل Scripts");
        return Task.CompletedTask;
    }
    
    #endregion
    
    #region === البحث الرئيسي ===
    
    /// <summary>
    /// البحث عن الوحدات بناءً على المعايير المحددة مع تطبيق استراتيجية Fallback Search
    /// ⚠️ جميع العمليات في SQL - الإتاحة والتسعير من الجداول الخاصة بهما
    /// 
    /// استراتيجية البحث متعددة المراحل:
    /// المرحلة 1: بحث دقيق (Exact Match)
    /// المرحلة 2: تخفيف بسيط (Minor Relaxation - 15-20%)
    /// المرحلة 3: تخفيف متوسط (Moderate Relaxation - 30-40%)
    /// المرحلة 4: تخفيف كبير (Major Relaxation - 50%+)
    /// المرحلة 5: اقتراحات بديلة (Alternative Suggestions)
    /// </summary>
    public async Task<UnitSearchResult> SearchUnitsAsync(
        UnitSearchRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request == null)
            throw new ArgumentNullException(nameof(request));
        
        var stopwatch = Stopwatch.StartNew();
        
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Validation 1: رفض الطلبات الفارغة تماماً
        // Reject completely empty requests
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        if (_safeGuardOptions.RejectEmptyRequests && !HasAnySearchCriteria(request))
        {
            _logger.LogWarning("⚠️ طلب بحث بدون أي معايير - إرجاع نتيجة فارغة");
            
            return new UnitSearchResult
            {
                Units = new List<UnitSearchItem>(),
                TotalCount = 0,
                PageNumber = request.PageNumber,
                PageSize = request.PageSize,
                SearchTimeMs = 0,
                UserMessage = "يرجى تحديد معيار بحث واحد على الأقل (مدينة، نوع عقار، تواريخ، إلخ)",
                SuggestedActions = new List<string> 
                { 
                    "حدد المدينة المطلوبة",
                    "اختر نوع العقار",
                    "حدد تواريخ الإقامة",
                    "حدد نطاق السعر"
                }
            };
        }
        
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Validation 2: تقليل PageSize الكبير عند عدم وجود فلاتر كافية
        // Reduce large PageSize when insufficient filters exist
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        if (request.PageSize > 100 && !HasSignificantFilters(request))
        {
            var originalPageSize = request.PageSize;
            request.PageSize = _safeGuardOptions.MaxPageSizeWithoutFilters;
            
            _logger.LogWarning(
                "⚠️ تقليل PageSize من {OriginalSize} إلى {NewSize} (لا توجد فلاتر كافية)",
                originalPageSize, request.PageSize);
        }
        
        try
        {
            _logger.LogInformation(
                "🔍 بدء البحث PostgreSQL: المدينة={City}, CheckIn={CheckIn}, CheckOut={CheckOut}, العملة={Currency}",
                request.City, request.CheckIn, request.CheckOut, request.PreferredCurrency ?? "افتراضية");
            
            // جلب أسعار الصرف إذا كان هناك فلتر سعر (يُنفذ مرة واحدة فقط - 3-5 سجلات)
            Dictionary<string, decimal>? exchangeRates = null;
            if (request.MinPrice.HasValue || request.MaxPrice.HasValue)
            {
                exchangeRates = await GetExchangeRatesAsync(request.PreferredCurrency);
            }
            
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            // استراتيجية Fallback Search متعددة المراحل
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            
            // حفظ نسخة من الطلب الأصلي
            var originalRequest = _relaxationService.CloneRequest(request);
            var originalCriteria = _relaxationService.ExtractCriteria(originalRequest);
            
            // إذا كانت استراتيجية Fallback معطلة، نفذ البحث العادي مباشرة
            if (!_fallbackOptions.EnableFallback)
            {
                if (_fallbackOptions.LogRelaxationSteps)
                {
                    _logger.LogInformation("ℹ️ استراتيجية Fallback معطلة - تنفيذ بحث عادي");
                }
                
                var directResult = await ExecuteSearchQueryAsync(
                    request, exchangeRates, cancellationToken);
                
                directResult.SearchTimeMs = stopwatch.ElapsedMilliseconds;
                return directResult;
            }
            
            // بدء استراتيجية Fallback متعددة المراحل
            SearchRelaxationLevel currentLevel = SearchRelaxationLevel.Exact;
            UnitSearchResult? result = null;
            List<string> relaxedFilters = new();
            var currentRequest = request;
            
            while (currentLevel <= SearchRelaxationLevel.AlternativeSuggestions)
            {
                try
                {
                    // تطبيق التخفيف إذا لم نكن في المرحلة الأولى
                    if (currentLevel > SearchRelaxationLevel.Exact)
                    {
                        if (_fallbackOptions.LogRelaxationSteps)
                        {
                            _logger.LogInformation(
                                "🔄 تطبيق التخفيف: المستوى {Level}",
                                currentLevel);
                        }
                        
                        currentRequest = _relaxationService.RelaxSearchCriteria(
                            originalRequest, 
                            currentLevel, 
                            _fallbackOptions, 
                            out relaxedFilters);
                        
                        // تحديث أسعار الصرف إذا تغير السعر
                        if (currentRequest.MinPrice != originalRequest.MinPrice || 
                            currentRequest.MaxPrice != originalRequest.MaxPrice)
                        {
                            exchangeRates = await GetExchangeRatesAsync(currentRequest.PreferredCurrency);
                        }
                    }
                    
                    // بناء الاستعلام
                    var query = BuildCompleteQuery(_context, currentRequest, exchangeRates);
                    
                    // الحصول على العدد الكلي (في SQL)
                    var totalCount = await query.CountAsync(cancellationToken);
                    
                    if (_fallbackOptions.LogRelaxationSteps)
                    {
                        _logger.LogInformation(
                            "📊 المستوى {Level}: عدد النتائج = {Count}",
                            currentLevel, totalCount);
                    }
                    
                    // إذا وجدنا نتائج كافية، نتوقف
                    if (totalCount >= _fallbackOptions.MinResultsThreshold)
                    {
                        result = await ExecuteSearchQueryAsync(
                            currentRequest, exchangeRates, cancellationToken);
                        
                        // ملء معلومات التخفيف
                        result.RelaxationLevel = currentLevel;
                        result.RelaxedFilters = relaxedFilters;
                        result.SearchStrategy = Application.Features.SearchAndFilters.DTOs.SearchStrategyDto
                            .FromLevel(currentLevel).StrategyName;
                        result.OriginalCriteria = originalCriteria;
                        result.ActualCriteria = _relaxationService.ExtractCriteria(currentRequest);
                        
                        // إضافة رسالة للمستخدم إذا كانت مفعلة
                        if (_fallbackOptions.ShowRelaxationInfo && currentLevel > SearchRelaxationLevel.Exact)
                        {
                            result.UserMessage = _messageGenerator.GenerateUserMessage(
                                currentLevel, result.TotalCount, relaxedFilters);
                        }
                        
                        // إضافة اقتراحات
                        result.SuggestedActions = _messageGenerator.GenerateSuggestedActions(originalRequest);
                        
                        if (_fallbackOptions.LogRelaxationSteps)
                        {
                            _logger.LogInformation(
                                "✅ نجح البحث في المستوى {Level} مع {Count} نتيجة",
                                currentLevel, result.TotalCount);
                        }
                        
                        break;
                    }
                    
                    // ✅ إضافة: إذا كنا في آخر مستوى ووجدنا نتائج (حتى لو قليلة)، نُرجعها
                    if (currentLevel == SearchRelaxationLevel.AlternativeSuggestions && totalCount > 0)
                    {
                        result = await ExecuteSearchQueryAsync(
                            currentRequest, exchangeRates, cancellationToken);
                        
                        // ملء معلومات التخفيف
                        result.RelaxationLevel = currentLevel;
                        result.RelaxedFilters = relaxedFilters;
                        result.SearchStrategy = Application.Features.SearchAndFilters.DTOs.SearchStrategyDto
                            .FromLevel(currentLevel).StrategyName;
                        result.OriginalCriteria = originalCriteria;
                        result.ActualCriteria = _relaxationService.ExtractCriteria(currentRequest);
                        
                        // رسالة خاصة للمستخدم
                        result.UserMessage = $"عُثر على {totalCount} وحدة مطابقة بعد توسيع معايير البحث. " +
                                             "قد ترغب في تعديل المعايير للحصول على المزيد من الخيارات.";
                        
                        result.SuggestedActions = _messageGenerator.GenerateSuggestedActions(originalRequest);
                        
                        _logger.LogInformation(
                            "✅ نجح البحث في المستوى الأخير {Level} مع {Count} وحدة (أقل من الحد الأدنى)",
                            currentLevel, result.TotalCount);
                        
                        break;
                    }
                    
                    // الانتقال للمرحلة التالية
                    var nextLevel = GetNextLevel(currentLevel);
                    
                    if (nextLevel == currentLevel)
                    {
                        // لا يوجد مستوى تالٍ متاح
                        break;
                    }
                    
                    currentLevel = nextLevel;
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, 
                        "⚠️ خطأ في المستوى {Level} - الانتقال للمستوى التالي", 
                        currentLevel);
                    
                    // الانتقال للمرحلة التالية عند حدوث خطأ
                    var nextLevel = GetNextLevel(currentLevel);
                    if (nextLevel == currentLevel) break;
                    currentLevel = nextLevel;
                }
            }
            
            // إذا لم نجد نتائج في أي مرحلة، نرجع نتيجة فارغة مع اقتراحات
            if (result == null || result.TotalCount == 0)
            {
                result = CreateEmptyResult(originalRequest, originalCriteria);
                
                if (_fallbackOptions.LogRelaxationSteps)
                {
                    _logger.LogWarning(
                        "⚠️ لم يتم العثور على نتائج في أي مستوى - إرجاع نتيجة فارغة مع اقتراحات");
                }
            }
            
            result.SearchTimeMs = stopwatch.ElapsedMilliseconds;
            
            _logger.LogInformation(
                "✅ اكتمل البحث PostgreSQL: {Count} وحدة من {Total} في {Ms}ms (المستوى: {Level})",
                result.Units.Count, result.TotalCount, result.SearchTimeMs, result.RelaxationLevel);
            
            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "❌ خطأ أثناء البحث عن الوحدات في PostgreSQL");
            
            var errorResult = new UnitSearchResult
            {
                Units = new List<UnitSearchItem>(),
                TotalCount = 0,
                PageNumber = request.PageNumber,
                PageSize = request.PageSize,
                SearchTimeMs = stopwatch.ElapsedMilliseconds,
                UserMessage = "حدث خطأ أثناء البحث. يرجى المحاولة مرة أخرى.",
                SuggestedActions = new List<string> 
                { 
                    "تبسيط معايير البحث",
                    "المحاولة مرة أخرى"
                }
            };
            
            return errorResult;
        }
    }
    
    #region === Helper Methods لاستراتيجية Fallback Search ===
    
    /// <summary>
    /// تنفيذ استعلام البحث الكامل مع إرجاع النتائج
    /// Execute full search query and return results
    /// </summary>
    private async Task<UnitSearchResult> ExecuteSearchQueryAsync(
        UnitSearchRequest request,
        Dictionary<string, decimal>? exchangeRates,
        CancellationToken cancellationToken)
    {
        // بناء الاستعلام الأساسي مع جميع الفلاتر
        var query = BuildCompleteQuery(_context, request, exchangeRates);
        
        // الحصول على العدد الكلي (في SQL)
        var totalCount = await query.CountAsync(cancellationToken);
        
        // تطبيق الترتيب والـ Pagination (في SQL)
        query = ApplySorting(query, request);
        query = query
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize);
        
        // جلب البيانات من قاعدة البيانات
        var searchItems = await query
            .Select(u => new 
            {
                // ━━━ معلومات الوحدة ━━━
                UnitId = u.Id,
                UnitName = u.Name,
                UnitTypeName = u.UnitType.Name,
                MaxCapacity = u.MaxCapacity,
                PricingMethod = u.PricingMethod.ToString(),
                
                // ━━━ معلومات العقار ━━━
                PropertyId = u.PropertyId,
                PropertyName = u.Property.Name,
                PropertyTypeName = u.Property.PropertyType.Name,
                City = u.Property.City,
                Address = u.Property.Address,
                StarRating = u.Property.StarRating,
                IsFeatured = u.Property.IsFeatured,
                IsApproved = u.Property.IsApproved,
                OwnerId = u.Property.OwnerId,
                
                // ━━━ الموقع (حساب المسافة في SQL) ━━━
                Latitude = u.Property.Latitude,
                Longitude = u.Property.Longitude,
                DistanceKm = request.Latitude.HasValue && request.Longitude.HasValue
                    ? (double?)(6371 * 2 * Math.Asin(Math.Sqrt(
                        Math.Pow(Math.Sin((Math.PI / 180.0 * ((double)u.Property.Latitude - (double)request.Latitude.Value)) / 2), 2) +
                        Math.Cos(Math.PI / 180.0 * (double)request.Latitude.Value) *
                        Math.Cos(Math.PI / 180.0 * (double)u.Property.Latitude) *
                        Math.Pow(Math.Sin((Math.PI / 180.0 * ((double)u.Property.Longitude - (double)request.Longitude.Value)) / 2), 2)
                    )))
                    : (double?)null,
                
                // ━━━ التقييمات (حساب في SQL) ━━━
                AverageRating = _context.Reviews
                    .Where(r => r.PropertyId == u.PropertyId)
                    .Average(r => (decimal?)r.AverageRating) ?? 0,
                
                // ━━━ الصور (في SQL) ━━━
                MainImageUrl = _context.PropertyImages
                    .Where(i => i.PropertyId == u.PropertyId)
                    .OrderBy(i => i.DisplayOrder)
                    .Select(i => i.Url)
                    .FirstOrDefault(),
                ImageUrls = _context.PropertyImages
                    .Where(i => i.PropertyId == u.PropertyId)
                    .OrderBy(i => i.DisplayOrder)
                    .Take(5)
                    .Select(i => i.Url)
                    .ToList(),
                
                // ━━━ السعر (حساب في SQL من DailyUnitSchedule) ━━━
                BasePrice = request.CheckIn.HasValue && request.CheckOut.HasValue
                    ? _context.DailyUnitSchedules
                        .Where(ds => ds.UnitId == u.Id &&
                                    ds.Date >= request.CheckIn.Value &&
                                    ds.Date < request.CheckOut.Value &&
                                    ds.PriceAmount.HasValue &&
                                    ds.Status == "Available")
                        .Average(ds => (decimal?)ds.PriceAmount) ?? 0
                    : _context.DailyUnitSchedules
                        .Where(ds => ds.UnitId == u.Id &&
                                    ds.PriceAmount.HasValue &&
                                    ds.Status == "Available" &&
                                    ds.Date >= DateTime.UtcNow.Date)
                        .OrderBy(ds => ds.PriceAmount)
                        .Select(ds => (decimal?)ds.PriceAmount)
                        .FirstOrDefault() ?? 0,
                
                TotalPrice = request.CheckIn.HasValue && request.CheckOut.HasValue
                    ? _context.DailyUnitSchedules
                        .Where(ds => ds.UnitId == u.Id &&
                                    ds.Date >= request.CheckIn.Value &&
                                    ds.Date < request.CheckOut.Value &&
                                    ds.PriceAmount.HasValue)
                        .Sum(ds => (decimal?)ds.PriceAmount)
                    : (decimal?)null,
                
                NumberOfNights = request.CheckIn.HasValue && request.CheckOut.HasValue
                    ? (int?)(request.CheckOut.Value - request.CheckIn.Value).Days
                    : (int?)null,
                
                Currency = _context.DailyUnitSchedules
                    .Where(ds => ds.UnitId == u.Id && ds.PriceAmount.HasValue)
                    .OrderBy(ds => ds.Date)
                    .Select(ds => ds.Currency)
                    .FirstOrDefault() ?? "YER",
                
                // ━━━ المرافق (في SQL) ━━━
                MainAmenities = _context.PropertyAmenities
                    .Where(pa => pa.PropertyId == u.PropertyId)
                    .Select(pa => pa.PropertyTypeAmenity.Amenity.Name)
                    .Take(5)
                    .ToList(),
                
                // ━━━ الحقول الديناميكية (في SQL باستخدام PostgreSQL function) ━━━
                DisplayFieldsJson = PostgreSqlFunctionsConfiguration.GetUnitDisplayFieldsJson(u.Id),
                
                // ━━━ نقاط الملاءمة (حساب بسيط في SQL) ━━━
                RelevanceScore = 50 + 
                    (u.Property.IsFeatured ? 15 : 0) +
                    (_context.Reviews.Where(r => r.PropertyId == u.PropertyId).Average(r => (decimal?)r.AverageRating) ?? 0) * 10,
                
                // ━━━ التواريخ ━━━
                NextAvailableDate = _context.DailyUnitSchedules
                    .Where(ds => ds.UnitId == u.Id && 
                                 ds.Status == "Available" && 
                                 ds.Date >= DateTime.UtcNow.Date)
                    .OrderBy(ds => ds.Date)
                    .Select(ds => (DateTime?)ds.Date)
                    .FirstOrDefault()
            })
            .ToListAsync(cancellationToken);
        
        // تحويل DisplayFieldsJson من JSONB string إلى Dictionary (في الذاكرة)
        var finalResults = searchItems.Select(s => new UnitSearchItem
        {
            UnitId = s.UnitId,
            UnitName = s.UnitName,
            UnitTypeName = s.UnitTypeName,
            MaxCapacity = s.MaxCapacity,
            PricingMethod = s.PricingMethod,
            PropertyId = s.PropertyId,
            PropertyName = s.PropertyName,
            PropertyTypeName = s.PropertyTypeName,
            City = s.City,
            Address = s.Address,
            StarRating = s.StarRating,
            IsFeatured = s.IsFeatured,
            IsApproved = s.IsApproved,
            OwnerId = s.OwnerId,
            Latitude = s.Latitude,
            Longitude = s.Longitude,
            DistanceKm = s.DistanceKm,
            AverageRating = s.AverageRating,
            MainImageUrl = s.MainImageUrl,
            ImageUrls = s.ImageUrls,
            BasePrice = s.BasePrice,
            TotalPrice = s.TotalPrice,
            NumberOfNights = s.NumberOfNights,
            Currency = s.Currency,
            MainAmenities = s.MainAmenities,
            DisplayFields = ParseJsonToDictionary(s.DisplayFieldsJson),
            RelevanceScore = s.RelevanceScore,
            NextAvailableDate = s.NextAvailableDate
        }).ToList();
        
        var result = new UnitSearchResult
        {
            Units = finalResults,
            TotalCount = totalCount,
            PageNumber = request.PageNumber,
            PageSize = request.PageSize,
            TotalPages = (int)Math.Ceiling(totalCount / (double)request.PageSize),
            AppliedFilters = BuildAppliedFilters(request)
        };
        
        return result;
    }
    
    /// <summary>
    /// الحصول على المستوى التالي في استراتيجية Fallback
    /// Get next level in Fallback strategy
    /// </summary>
    private SearchRelaxationLevel GetNextLevel(SearchRelaxationLevel current)
    {
        return current switch
        {
            SearchRelaxationLevel.Exact when _fallbackOptions.EnableMinorRelaxation
                => SearchRelaxationLevel.MinorRelaxation,
            
            SearchRelaxationLevel.Exact when !_fallbackOptions.EnableMinorRelaxation 
                                           && _fallbackOptions.EnableModerateRelaxation
                => SearchRelaxationLevel.ModerateRelaxation,
            
            SearchRelaxationLevel.Exact when !_fallbackOptions.EnableMinorRelaxation 
                                           && !_fallbackOptions.EnableModerateRelaxation
                                           && _fallbackOptions.EnableMajorRelaxation
                => SearchRelaxationLevel.MajorRelaxation,
            
            SearchRelaxationLevel.Exact when !_fallbackOptions.EnableMinorRelaxation 
                                           && !_fallbackOptions.EnableModerateRelaxation
                                           && !_fallbackOptions.EnableMajorRelaxation
                                           && _fallbackOptions.EnableAlternativeSuggestions
                => SearchRelaxationLevel.AlternativeSuggestions,
            
            SearchRelaxationLevel.MinorRelaxation when _fallbackOptions.EnableModerateRelaxation
                => SearchRelaxationLevel.ModerateRelaxation,
            
            SearchRelaxationLevel.MinorRelaxation when !_fallbackOptions.EnableModerateRelaxation
                                                     && _fallbackOptions.EnableMajorRelaxation
                => SearchRelaxationLevel.MajorRelaxation,
            
            SearchRelaxationLevel.MinorRelaxation when !_fallbackOptions.EnableModerateRelaxation
                                                     && !_fallbackOptions.EnableMajorRelaxation
                                                     && _fallbackOptions.EnableAlternativeSuggestions
                => SearchRelaxationLevel.AlternativeSuggestions,
            
            SearchRelaxationLevel.ModerateRelaxation when _fallbackOptions.EnableMajorRelaxation
                => SearchRelaxationLevel.MajorRelaxation,
            
            SearchRelaxationLevel.ModerateRelaxation when !_fallbackOptions.EnableMajorRelaxation
                                                        && _fallbackOptions.EnableAlternativeSuggestions
                => SearchRelaxationLevel.AlternativeSuggestions,
            
            SearchRelaxationLevel.MajorRelaxation when _fallbackOptions.EnableAlternativeSuggestions
                => SearchRelaxationLevel.AlternativeSuggestions,
            
            // لا يوجد مستوى تالٍ - البقاء في المستوى الحالي
            _ => current
        };
    }
    
    /// <summary>
    /// إنشاء نتيجة فارغة مع اقتراحات مفيدة
    /// Create empty result with helpful suggestions
    /// </summary>
    private UnitSearchResult CreateEmptyResult(
        UnitSearchRequest request, 
        Dictionary<string, object> originalCriteria)
    {
        var result = new UnitSearchResult
        {
            Units = new List<UnitSearchItem>(),
            TotalCount = 0,
            PageNumber = request.PageNumber,
            PageSize = request.PageSize,
            TotalPages = 0,
            AppliedFilters = BuildAppliedFilters(request),
            RelaxationLevel = SearchRelaxationLevel.AlternativeSuggestions,
            RelaxedFilters = new List<string> { "لم يتم العثور على نتائج في جميع المستويات" },
            SearchStrategy = "لا توجد نتائج",
            OriginalCriteria = originalCriteria,
            ActualCriteria = _relaxationService.ExtractCriteria(request),
            UserMessage = "لم نتمكن من العثور على نتائج مطابقة حتى بعد توسيع معايير البحث.\n\n" +
                          "يُرجى التأكد من:\n" +
                          "• أن المدينة أو المنطقة المطلوبة متوفرة في قاعدة البيانات\n" +
                          "• تعديل نطاق السعر أو التواريخ\n" +
                          "• تقليل عدد المعايير المحددة",
            SuggestedActions = _messageGenerator.GenerateSuggestedActions(request)
        };
        
        return result;
    }
    
    #endregion
    
    #endregion
    
    #region === البحث المجمّع حسب العقار ===
    
    public async Task<PropertyWithUnitsSearchResult> SearchPropertiesWithUnitsAsync(
        PropertyWithUnitsSearchRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request == null)
            throw new ArgumentNullException(nameof(request));
        
        var stopwatch = Stopwatch.StartNew();
        
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Validation 1: رفض الطلبات الفارغة تماماً
        // Reject completely empty requests
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        if (_safeGuardOptions.RejectEmptyRequests && !HasAnySearchCriteria(request))
        {
            _logger.LogWarning("⚠️ طلب بحث مجمّع بدون أي معايير - إرجاع نتيجة فارغة");
            
            return new PropertyWithUnitsSearchResult
            {
                Properties = new List<PropertyGroupSearchItem>(),
                TotalPropertiesCount = 0,
                TotalUnitsCount = 0,
                PageNumber = request.PageNumber,
                PageSize = request.PageSize,
                SearchTimeMs = 0,
                UserMessage = "يرجى تحديد معيار بحث واحد على الأقل (مدينة، نوع عقار، تواريخ، إلخ)",
                SuggestedActions = new List<string> 
                { 
                    "حدد المدينة المطلوبة",
                    "اختر نوع العقار",
                    "حدد تواريخ الإقامة",
                    "حدد نطاق السعر"
                }
            };
        }
        
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Validation 2: تقليل PageSize الكبير عند عدم وجود فلاتر كافية
        // Reduce large PageSize when insufficient filters exist
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        if (request.PageSize > 100 && !HasSignificantFilters(request))
        {
            var originalPageSize = request.PageSize;
            request.PageSize = _safeGuardOptions.MaxPageSizeWithoutFilters;
            
            _logger.LogWarning(
                "⚠️ تقليل PageSize من {OriginalSize} إلى {NewSize} (لا توجد فلاتر كافية)",
                originalPageSize, request.PageSize);
        }
        
        try
        {
            _logger.LogInformation(
                "🔍 بدء البحث المجمّع PostgreSQL: المدينة={City}, CheckIn={CheckIn}, CheckOut={CheckOut}",
                request.City, request.CheckIn, request.CheckOut);
            
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            // استراتيجية Fallback Search متعددة المراحل
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            // حفظ نسخة من الطلب الأصلي
            // ✅ بعد إصلاح CloneRequest، يجب أن يحافظ على النوع PropertyWithUnitsSearchRequest
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            var originalRequest = _relaxationService.CloneRequest(request) as PropertyWithUnitsSearchRequest;
            
            // ✅ Safe Guard: إذا فشل النسخ (حالة استثنائية جداً)، ننسخ يدوياً
            if (originalRequest == null)
            {
                _logger.LogWarning("⚠️ فشل cast للطلب الأصلي - نسخ يدوي");
                originalRequest = CopyToPropertyWithUnitsRequest(request);
            }
            
            var originalCriteria = _relaxationService.ExtractCriteria(originalRequest);
            
            // إذا كانت استراتيجية Fallback معطلة، نفذ البحث العادي مباشرة
            if (!_fallbackOptions.EnableFallback)
            {
                if (_fallbackOptions.LogRelaxationSteps)
                {
                    _logger.LogInformation("ℹ️ استراتيجية Fallback معطلة - تنفيذ بحث مجمّع عادي");
                }
                
                var directResult = await ExecutePropertySearchQueryAsync(
                    request, request, cancellationToken, SearchRelaxationLevel.Exact);
                
                directResult.SearchTimeMs = stopwatch.ElapsedMilliseconds;
                return directResult;
            }
            
            // بدء استراتيجية Fallback متعددة المراحل
            SearchRelaxationLevel currentLevel = SearchRelaxationLevel.Exact;
            PropertyWithUnitsSearchResult? result = null;
            List<string> relaxedFilters = new();
            PropertyWithUnitsSearchRequest currentRequest = request;
            
            while (currentLevel <= SearchRelaxationLevel.AlternativeSuggestions)
            {
                try
                {
                    // تطبيق التخفيف إذا لم نكن في المرحلة الأولى
                    if (currentLevel > SearchRelaxationLevel.Exact)
                    {
                        if (_fallbackOptions.LogRelaxationSteps)
                        {
                            _logger.LogInformation(
                                "🔄 تطبيق التخفيف على البحث المجمّع: المستوى {Level}",
                                currentLevel);
                        }
                        
                        // ✅ تطبيق التخفيف ثم نسخ النتيجة بشكل آمن
                        var relaxedBase = _relaxationService.RelaxSearchCriteria(
                            originalRequest, 
                            currentLevel, 
                            _fallbackOptions, 
                            out relaxedFilters);
                        
                        // ✅ نسخ النتيجة إلى PropertyWithUnitsSearchRequest مع الاحتفاظ بالخصائص الخاصة
                        currentRequest = CopyToPropertyWithUnitsRequest(relaxedBase);
                        currentRequest.GroupByProperty = originalRequest.GroupByProperty;
                        currentRequest.MaxUnitsPerProperty = originalRequest.MaxUnitsPerProperty;
                    }
                    
                    // جلب أسعار الصرف إذا كان هناك فلتر سعر
                    Dictionary<string, decimal>? exchangeRates = null;
                    if (currentRequest.MinPrice.HasValue || currentRequest.MaxPrice.HasValue)
                    {
                        exchangeRates = await GetExchangeRatesAsync(currentRequest.PreferredCurrency);
                    }
                    
                    // بناء الاستعلام الأساسي
                    var unitsQuery = BuildCompleteQuery(_context, currentRequest, exchangeRates);
                    
                    // التجميع حسب العقار في SQL
                    var propertyGroupsQuery = unitsQuery
                        .GroupBy(u => new
                        {
                            u.PropertyId,
                            PropertyName = u.Property.Name,
                            PropertyTypeName = u.Property.PropertyType.Name,
                            u.Property.City,
                            u.Property.Address,
                            u.Property.StarRating,
                            u.Property.AverageRating,
                            u.Property.IsFeatured,
                            u.Property.OwnerId,
                            u.Property.IsApproved,
                            u.Property.Latitude,
                            u.Property.Longitude
                        })
                        .Select(g => new
                        {
                            PropertyInfo = g.Key,
                            UnitCount = g.Count(),
                            MinPrice = 0m,
                            MaxPrice = 0m,
                            Currency = "YER"
                        });
                    
                    // الحصول على العدد الكلي
                    var totalPropertiesCount = await propertyGroupsQuery.CountAsync(cancellationToken);
                    var totalUnitsCount = await unitsQuery.CountAsync(cancellationToken);
                    
                    if (_fallbackOptions.LogRelaxationSteps)
                    {
                        _logger.LogInformation(
                            "📊 المستوى {Level}: عدد العقارات = {PropertiesCount}, عدد الوحدات = {UnitsCount}",
                            currentLevel, totalPropertiesCount, totalUnitsCount);
                    }
                    
                    // إذا وجدنا نتائج كافية، نتوقف
                    if (totalPropertiesCount >= _fallbackOptions.MinResultsThreshold)
                    {
                        result = await ExecutePropertySearchQueryAsync(
                            currentRequest, originalRequest, cancellationToken, currentLevel);
                        
                        // ملء معلومات التخفيف
                        result.RelaxationLevel = currentLevel;
                        result.RelaxedFilters = relaxedFilters;
                        result.SearchStrategy = Application.Features.SearchAndFilters.DTOs.SearchStrategyDto
                            .FromLevel(currentLevel).StrategyName;
                        result.OriginalCriteria = originalCriteria;
                        result.ActualCriteria = _relaxationService.ExtractCriteria(currentRequest);
                        
                        // إضافة رسالة للمستخدم إذا كانت مفعلة
                        if (_fallbackOptions.ShowRelaxationInfo && currentLevel > SearchRelaxationLevel.Exact)
                        {
                            result.UserMessage = _messageGenerator.GenerateUserMessage(
                                currentLevel, result.TotalPropertiesCount, relaxedFilters);
                        }
                        
                        // إضافة اقتراحات
                        result.SuggestedActions = _messageGenerator.GenerateSuggestedActions(originalRequest);
                        
                        if (_fallbackOptions.LogRelaxationSteps)
                        {
                            _logger.LogInformation(
                                "✅ نجح البحث المجمّع في المستوى {Level} مع {PropertiesCount} عقار و {UnitsCount} وحدة",
                                currentLevel, result.TotalPropertiesCount, result.TotalUnitsCount);
                        }
                        
                        break;
                    }
                    
                    // ✅ إضافة: إذا كنا في آخر مستوى ووجدنا نتائج (حتى لو قليلة)، نُرجعها
                    if (currentLevel == SearchRelaxationLevel.AlternativeSuggestions && totalPropertiesCount > 0)
                    {
                        result = await ExecutePropertySearchQueryAsync(
                            currentRequest, originalRequest, cancellationToken, currentLevel);
                        
                        // ملء معلومات التخفيف
                        result.RelaxationLevel = currentLevel;
                        result.RelaxedFilters = relaxedFilters;
                        result.SearchStrategy = Application.Features.SearchAndFilters.DTOs.SearchStrategyDto
                            .FromLevel(currentLevel).StrategyName;
                        result.OriginalCriteria = originalCriteria;
                        result.ActualCriteria = _relaxationService.ExtractCriteria(currentRequest);
                        
                        // رسالة خاصة للمستخدم
                        result.UserMessage = $"عُثر على {totalPropertiesCount} نتيجة مطابقة بعد توسيع معايير البحث. " +
                                             "قد ترغب في تعديل المعايير للحصول على المزيد من الخيارات.";
                        
                        result.SuggestedActions = _messageGenerator.GenerateSuggestedActions(originalRequest);
                        
                        _logger.LogInformation(
                            "✅ نجح البحث المجمّع في المستوى الأخير {Level} مع {PropertiesCount} عقار (أقل من الحد الأدنى)",
                            currentLevel, result.TotalPropertiesCount);
                        
                        break;
                    }
                    
                    // الانتقال للمرحلة التالية
                    var nextLevel = GetNextLevel(currentLevel);
                    
                    if (nextLevel == currentLevel)
                    {
                        // لا يوجد مستوى تالٍ متاح
                        break;
                    }
                    
                    currentLevel = nextLevel;
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, 
                        "⚠️ خطأ في المستوى {Level} في البحث المجمّع - الانتقال للمستوى التالي", 
                        currentLevel);
                    
                    // الانتقال للمرحلة التالية عند حدوث خطأ
                    var nextLevel = GetNextLevel(currentLevel);
                    if (nextLevel == currentLevel) break;
                    currentLevel = nextLevel;
                }
            }
            
            // إذا لم نجد نتائج في أي مرحلة، نرجع نتيجة فارغة مع اقتراحات
            if (result == null || result.TotalPropertiesCount == 0)
            {
                result = CreateEmptyPropertyResult(originalRequest, originalCriteria);
                
                if (_fallbackOptions.LogRelaxationSteps)
                {
                    _logger.LogWarning(
                        "⚠️ لم يتم العثور على عقارات في أي مستوى - إرجاع نتيجة فارغة مع اقتراحات");
                }
            }
            
            result.SearchTimeMs = stopwatch.ElapsedMilliseconds;
            
            _logger.LogInformation(
                "✅ اكتمل البحث المجمّع: {PropertiesCount} عقار، {UnitsCount} وحدة في {Ms}ms (المستوى: {Level})",
                result.Properties.Count, result.TotalUnitsCount, result.SearchTimeMs, result.RelaxationLevel);
            
            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "❌ خطأ أثناء البحث المجمّع PostgreSQL");
            
            return new PropertyWithUnitsSearchResult
            {
                Properties = new List<PropertyGroupSearchItem>(),
                TotalPropertiesCount = 0,
                TotalUnitsCount = 0,
                PageNumber = request.PageNumber,
                PageSize = request.PageSize,
                SearchTimeMs = stopwatch.ElapsedMilliseconds,
                UserMessage = "حدث خطأ أثناء البحث. يرجى المحاولة مرة أخرى.",
                SuggestedActions = new List<string> 
                { 
                    "تبسيط معايير البحث",
                    "المحاولة مرة أخرى"
                }
            };
        }
    }
    
    #region === Helper Methods للبحث المجمّع مع Fallback ===
    
    /// <summary>
    /// تنفيذ استعلام البحث المجمّع الكامل مع إرجاع النتائج
    /// Execute full property search query and return results
    /// </summary>
    private async Task<PropertyWithUnitsSearchResult> ExecutePropertySearchQueryAsync(
        PropertyWithUnitsSearchRequest request,
        PropertyWithUnitsSearchRequest? originalRequest,
        CancellationToken cancellationToken,
        SearchRelaxationLevel relaxationLevel = SearchRelaxationLevel.Exact)
    {
        try
        {
            // جلب أسعار الصرف إذا كان هناك فلتر سعر
            Dictionary<string, decimal>? exchangeRates = null;
            if (request.MinPrice.HasValue || request.MaxPrice.HasValue)
            {
                exchangeRates = await GetExchangeRatesAsync(request.PreferredCurrency);
            }
            
            // بناء الاستعلام الأساسي (مع دعم العملات)
            var unitsQuery = BuildCompleteQuery(_context, request, exchangeRates);
            
            // التجميع حسب العقار في SQL
            var propertyGroupsQuery = unitsQuery
                .GroupBy(u => new
                {
                    u.PropertyId,
                    PropertyTypeId = u.Property.TypeId,
                    PropertyName = u.Property.Name,
                    PropertyTypeName = u.Property.PropertyType.Name,
                    u.Property.City,
                    u.Property.Address,
                    u.Property.StarRating,
                    u.Property.AverageRating,
                    u.Property.IsFeatured,
                    u.Property.OwnerId,
                    u.Property.IsApproved,
                    u.Property.Latitude,
                    u.Property.Longitude
                })
                .Select(g => new
                {
                    PropertyInfo = g.Key,
                    UnitCount = g.Count(),
                    MinPrice = 0m,
                    MaxPrice = 0m,
                    Currency = "YER"
                });
            
            var totalPropertiesCount = await propertyGroupsQuery.CountAsync(cancellationToken);
            var totalUnitsCount = await unitsQuery.CountAsync(cancellationToken);
            
            // Pagination على العقارات
            var orderedPropertyGroupsQuery = propertyGroupsQuery
                .OrderByDescending(pg => pg.PropertyInfo.IsFeatured)
                .ThenByDescending(pg => pg.PropertyInfo.AverageRating);

            var pagedPropertyGroups = request.IncludeAllMatchesForFacets
                ? await orderedPropertyGroupsQuery.ToListAsync(cancellationToken)
                : await orderedPropertyGroupsQuery
                    .Skip((request.PageNumber - 1) * request.PageSize)
                    .Take(request.PageSize)
                    .ToListAsync(cancellationToken);
            
            // ✅ جلب البيانات المطلوبة فقط باستخدام Projection (في SQL)
            var displayedPropertyIds = pagedPropertyGroups.Select(g => g.PropertyInfo.PropertyId).Distinct().ToList();
            
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            // ✅ تحسين: استخدام Projection مباشرة بدلاً من جلب Entities كاملة
            // بدلاً من ToListAsync() ثم Select في الذاكرة، نُسقط البيانات في SQL
            // ✅ استخدام PostgreSQL function للحقول الديناميكية
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            var unitsProjection = await unitsQuery
                .Where(u => displayedPropertyIds.Contains(u.PropertyId))
                .Select(u => new
                {
                    u.Id,
                    u.Name,
                    u.UnitTypeId,
                    UnitTypeName = u.UnitType.Name ?? "",
                    u.PropertyId,
                    u.MaxCapacity,
                    PricingMethod = u.PricingMethod.ToString(),
                    // حساب السعر في SQL
                    BasePrice = request.CheckIn.HasValue && request.CheckOut.HasValue
                        ? _context.DailyUnitSchedules
                            .Where(ds => ds.UnitId == u.Id &&
                                        ds.Date >= request.CheckIn.Value &&
                                        ds.Date < request.CheckOut.Value &&
                                        ds.PriceAmount.HasValue)
                            .Average(ds => (decimal?)ds.PriceAmount) ?? 0
                        : 0m,
                    Currency = _context.DailyUnitSchedules
                        .Where(ds => ds.UnitId == u.Id && ds.PriceAmount.HasValue)
                        .OrderBy(ds => ds.Date)
                        .Select(ds => ds.Currency)
                        .FirstOrDefault() ?? "YER",
                    SearchableFields = u.FieldValues
                        .Where(fv => fv.UnitTypeField != null &&
                                     fv.UnitTypeField.IsSearchable &&
                                     fv.UnitTypeField.IsPublic)
                        .Select(fv => new
                        {
                            FieldName = fv.UnitTypeField.FieldName,
                            DisplayName = fv.UnitTypeField.DisplayName,
                            FieldType = fv.UnitTypeField.FieldTypeId,
                            fv.FieldValue,
                            fv.UnitTypeField.IsPrimaryFilter,
                            fv.UnitTypeField.Priority
                        })
                        .ToList()
                })
                .ToListAsync(cancellationToken);
            
            var properties = await _context.Properties
                .AsNoTracking()
                .Where(p => displayedPropertyIds.Contains(p.Id))
                .Select(p => new
                {
                    p.Id,
                    p.Name,
                    MainImageUrl = p.Images.OrderBy(i => i.DisplayOrder).Select(i => i.Url).FirstOrDefault() ?? "",
                    ImageUrls = p.Images.OrderBy(i => i.DisplayOrder).Take(5).Select(i => i.Url).ToList(),
                    Amenities = p.Amenities.Select(a => a.PropertyTypeAmenity.Amenity.Name).Take(5).ToList()
                })
                .ToDictionaryAsync(p => p.Id, cancellationToken);
            
            var propertyItems = new List<PropertyGroupSearchItem>();
            
            foreach (var propertyGroup in pagedPropertyGroups)
            {
                var propertyInfo = propertyGroup.PropertyInfo;
                
                // جلب الوحدات الخاصة بهذا العقار من البيانات المُسقطة
                var propertyUnits = unitsProjection
                    .Where(u => u.PropertyId == propertyInfo.PropertyId)
                    .ToList();
                
                var displayUnits = request.MaxUnitsPerProperty.HasValue
                    ? propertyUnits.Take(request.MaxUnitsPerProperty.Value).ToList()
                    : propertyUnits;
                
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // ✅ حساب المسافة مرة واحدة (تم تبسيطه)
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                double? distanceKm = null;
                if (request.Latitude.HasValue && request.Longitude.HasValue)
                {
                    var lat1 = (double)request.Latitude.Value;
                    var lng1 = (double)request.Longitude.Value;
                    var lat2 = (double)propertyInfo.Latitude;
                    var lng2 = (double)propertyInfo.Longitude;
                    
                    distanceKm = 6371 * 2 * Math.Asin(Math.Sqrt(
                        Math.Pow(Math.Sin((Math.PI / 180.0 * (lat2 - lat1)) / 2), 2) +
                        Math.Cos(Math.PI / 180.0 * lat1) *
                        Math.Cos(Math.PI / 180.0 * lat2) *
                        Math.Pow(Math.Sin((Math.PI / 180.0 * (lng2 - lng1)) / 2), 2)
                    ));
                }
                
                // جلب بيانات العقار من Dictionary
                var property = properties.GetValueOrDefault(propertyInfo.PropertyId);
                
                // ✅ تحويل البيانات المُسقطة إلى UnitSearchItem (بسيط وسريع)
                var unitSearchItems = displayUnits.Select(u => new UnitSearchItem
                {
                    UnitId = u.Id,
                    UnitName = u.Name,
                    UnitTypeId = u.UnitTypeId,
                    UnitTypeName = u.UnitTypeName,
                    PropertyId = u.PropertyId,
                    PropertyName = property?.Name ?? propertyInfo.PropertyName,
                    PropertyTypeId = propertyInfo.PropertyTypeId,
                    PropertyTypeName = propertyInfo.PropertyTypeName,
                    City = propertyInfo.City,
                    Address = propertyInfo.Address,
                    MaxCapacity = u.MaxCapacity,
                    PricingMethod = u.PricingMethod,
                    BasePrice = u.BasePrice,
                    Currency = request.PreferredCurrency ?? u.Currency,
                    StarRating = propertyInfo.StarRating,
                    AverageRating = propertyInfo.AverageRating,
                    IsFeatured = propertyInfo.IsFeatured,
                    IsApproved = propertyInfo.IsApproved,
                    OwnerId = propertyInfo.OwnerId,
                    Latitude = propertyInfo.Latitude,
                    Longitude = propertyInfo.Longitude,
                    DistanceKm = distanceKm,
                    MainImageUrl = property?.MainImageUrl ?? "",
                    ImageUrls = property?.ImageUrls ?? new List<string>(),
                    MainAmenities = property?.Amenities ?? new List<string>(),
                    SearchableFields = u.SearchableFields
                        .Select(f => new SearchableFieldValue
                        {
                            FieldName = f.FieldName ?? string.Empty,
                            DisplayName = f.DisplayName ?? f.FieldName ?? string.Empty,
                            FieldType = f.FieldType ?? "text",
                            Value = f.FieldValue ?? string.Empty,
                            IsPrimaryFilter = f.IsPrimaryFilter,
                            Priority = f.Priority
                        })
                        .ToList(),
                    DisplayFields = BuildDisplayFields(
                        u.SearchableFields.Select(f => new SearchableFieldValue
                        {
                            FieldName = f.FieldName ?? string.Empty,
                            DisplayName = f.DisplayName ?? f.FieldName ?? string.Empty,
                            FieldType = f.FieldType ?? "text",
                            Value = f.FieldValue ?? string.Empty,
                            IsPrimaryFilter = f.IsPrimaryFilter,
                            Priority = f.Priority
                        })),
                    RelevanceScore = 50 + (propertyInfo.IsFeatured ? 15 : 0) + (propertyInfo.AverageRating * 10)
                }).ToList();
                
                // حساب MinPrice و MaxPrice من الوحدات المُسقطة
                var prices = displayUnits.Select(u => u.BasePrice).Where(p => p > 0).ToList();
                var minPrice = prices.Any() ? prices.Min() : 0m;
                var maxPrice = prices.Any() ? prices.Max() : 0m;
                
                propertyItems.Add(new PropertyGroupSearchItem
                {
                    PropertyId = propertyInfo.PropertyId,
                    PropertyName = propertyInfo.PropertyName,
                    PropertyTypeId = propertyInfo.PropertyTypeId,
                    PropertyTypeName = propertyInfo.PropertyTypeName,
                    City = propertyInfo.City,
                    Address = propertyInfo.Address,
                    StarRating = propertyInfo.StarRating,
                    AverageRating = propertyInfo.AverageRating,
                    IsFeatured = propertyInfo.IsFeatured,
                    OwnerId = propertyInfo.OwnerId,
                    IsApproved = propertyInfo.IsApproved,
                    Latitude = propertyInfo.Latitude,
                    Longitude = propertyInfo.Longitude,
                    DistanceKm = distanceKm,
                    MinPrice = minPrice,
                    MaxPrice = maxPrice,
                    MatchedUnits = unitSearchItems,
                    MatchedUnitsCount = propertyGroup.UnitCount,
                    MainImageUrl = property?.MainImageUrl,
                    ImageUrls = property?.ImageUrls ?? new List<string>(),
                    AvailableAmenities = property?.Amenities ?? new List<string>(),
                    PriceRange = new PriceRange
                    {
                        Min = minPrice,
                        Max = maxPrice
                    }
                });
            }
            
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            // 🆕 حساب الفروقات لكل عقار
            // Calculate mismatches for each property
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            
            // استخدام originalRequest للمقارنة (إذا كان متاحاً)
            var requestForComparison = originalRequest ?? request;
            
            foreach (var property in propertyItems)
            {
                property.FilterMismatches = _comparisonService.ComparePropertyWithOriginalRequest(
                    property,
                    requestForComparison
                );
                
                _logger.LogDebug(
                    "🔍 العقار {PropertyName}: {MismatchCount} فرق",
                    property.PropertyName,
                    property.MismatchesCount
                );
            }
            
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            
            return new PropertyWithUnitsSearchResult
            {
                Properties = propertyItems,
                TotalPropertiesCount = totalPropertiesCount,
                TotalUnitsCount = totalUnitsCount,
                PageNumber = request.PageNumber,
                PageSize = request.PageSize,
                TotalPages = (int)Math.Ceiling(totalPropertiesCount / (double)request.PageSize),
                
                // ✅ تعيين مستوى التخفيف المُمرر من الدالة المُستدعية
                RelaxationLevel = relaxationLevel
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "❌ خطأ أثناء تنفيذ استعلام البحث المجمّع");
            
            return new PropertyWithUnitsSearchResult
            {
                Properties = new List<PropertyGroupSearchItem>(),
                TotalPropertiesCount = 0,
                TotalUnitsCount = 0,
                PageNumber = request.PageNumber,
                PageSize = request.PageSize
            };
        }
    }
    
    /// <summary>
    /// إنشاء نتيجة فارغة مع اقتراحات مفيدة (للبحث المجمّع)
    /// Create empty property result with helpful suggestions
    /// </summary>
    private PropertyWithUnitsSearchResult CreateEmptyPropertyResult(
        PropertyWithUnitsSearchRequest request,
        Dictionary<string, object> originalCriteria)
    {
        return new PropertyWithUnitsSearchResult
        {
            Properties = new List<PropertyGroupSearchItem>(),
            TotalPropertiesCount = 0,
            TotalUnitsCount = 0,
            PageNumber = request.PageNumber,
            PageSize = request.PageSize,
            TotalPages = 0,
            RelaxationLevel = SearchRelaxationLevel.AlternativeSuggestions,
            RelaxedFilters = new List<string> { "لم يتم العثور على نتائج في جميع المستويات" },
            SearchStrategy = "لا توجد نتائج",
            OriginalCriteria = originalCriteria,
            ActualCriteria = _relaxationService.ExtractCriteria(request),
            UserMessage = "عذراً، لم نتمكن من العثور على عقارات تطابق معايير البحث الخاصة بك حتى مع توسيع البحث.\n\nنقترح عليك تعديل معايير البحث وفقاً للاقتراحات أدناه.",
            SuggestedActions = _messageGenerator.GenerateSuggestedActions(request)
        };
    }
    
    #endregion
    
    #endregion
    
    #region === بناء الاستعلام الكامل ===
    
    /// <summary>
    /// بناء الاستعلام الكامل مع جميع الفلاتر
    /// ⚠️ الإتاحة تُفحص من DailyUnitSchedule حسب التواريخ
    /// ✅ دعم العملات المتعددة - الفلترة في SQL بالكامل
    /// </summary>
    private IQueryable<Unit> BuildCompleteQuery(
        YemenBookingDbContext context, 
        UnitSearchRequest request,
        Dictionary<string, decimal>? exchangeRates = null)
    {
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // الاستعلام الأساسي - بدون Includes (يتم جلب البيانات عبر Projection في ExecuteSearchQueryAsync)
        // Base query - without Includes (data fetched via Projection in ExecuteSearchQueryAsync)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        var query = context.Units
            .AsNoTracking()
            .Where(u => u.Property.IsApproved); // فقط العقارات المعتمدة
        
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Safe Guard: فرض قيود عند عدم وجود فلاتر كافية
        // Apply safety constraints when insufficient filters exist
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        if (!HasSignificantFilters(request))
        {
            if (_safeGuardOptions.RequireFeaturedWhenNoFilters)
            {
                query = query.Where(u => u.Property.IsFeatured);
                _logger.LogWarning("⚠️ لا توجد فلاتر كافية - تطبيق فلتر IsFeatured");
            }
            
            query = query.Take(_safeGuardOptions.MaxResultsWithoutFilters);
            
            _logger.LogWarning(
                "⚠️ لا توجد فلاتر كافية - تطبيق حد أقصى {MaxResults} نتيجة",
                _safeGuardOptions.MaxResultsWithoutFilters);
        }
        
        // تطبيق جميع الفلاتر (بما فيها العملات)
        query = ApplyAllFilters(query, request, context, exchangeRates);
        
        return query;
    }
    
    /// <summary>
    /// تطبيق جميع الفلاتر على الاستعلام
    /// ⚠️ الإتاحة والتسعير من الجداول الخاصة بهما
    /// ✅ دعم العملات المتعددة - جميع الفلترة في SQL
    /// </summary>
    private IQueryable<Unit> ApplyAllFilters(
        IQueryable<Unit> query, 
        UnitSearchRequest request, 
        YemenBookingDbContext context,
        Dictionary<string, decimal>? exchangeRates = null)
    {
        // 1. فلتر المدينة (Case-insensitive + تجاهل المسافات)
        if (!string.IsNullOrWhiteSpace(request.City))
        {
            var normalizedCity = request.City.Trim();
            query = query.Where(u => EF.Functions.ILike(u.Property.City.Trim(), normalizedCity));
        }
        
        // 2. فلتر نوع الوحدة
        if (request.UnitTypeId.HasValue)
        {
            query = query.Where(u => u.UnitTypeId == request.UnitTypeId.Value);
        }
        
        // 3. فلتر نوع العقار
        if (request.PropertyTypeId.HasValue)
        {
            query = query.Where(u => u.Property.TypeId == request.PropertyTypeId.Value);
        }
        
        // 4. فلتر السعر (دعم العملات المتعددة)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // ✅ يُنفذ بالكامل في SQL - لا جلب للبيانات
        // ✅ يدعم البحث بأي عملة مع مصارفة تلقائية
        // ✅ الفلترة بناءً على متوسط السعر (ليس كل يوم على حدة)
        // ملاحظة: إذا كانت هناك فترة بحث (CheckIn/CheckOut)، نفلتر بناءً على متوسط أسعار تلك الفترة
        //         وإلا نفلتر بناءً على وجود أي سعر في DailySchedules ضمن النطاق
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        if (request.MinPrice.HasValue || request.MaxPrice.HasValue)
        {
            // ✅ التحقق من وجود أسعار صرف - إذا لم توجد، نستخدم العملة الافتراضية فقط
            if (exchangeRates == null || !exchangeRates.Any())
            {
                _logger.LogWarning(
                    "⚠️ لم يتم جلب أسعار الصرف - سيتم تطبيق فلتر السعر على العملة الافتراضية (YER) فقط! " +
                    "MinPrice={MinPrice}, MaxPrice={MaxPrice}, Currency={Currency}",
                    request.MinPrice, request.MaxPrice, request.PreferredCurrency ?? "null");
                
                // ✅ استخدام YER كعملة افتراضية
                exchangeRates = new Dictionary<string, decimal> { ["YER"] = 1m };
            }
            
            var minPrice = request.MinPrice ?? 0;
            var maxPrice = request.MaxPrice ?? decimal.MaxValue;
            
            _logger.LogDebug(
                "💰 فلتر السعر: Min={MinPrice}, Max={MaxPrice}, العملة={Currency}, عدد أسعار الصرف={RateCount}",
                minPrice, maxPrice, request.PreferredCurrency ?? "افتراضية", exchangeRates.Count);
            
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            // إصلاح: تخزين نطاقات الأسعار لكل عملة في متغيرات محلية
            // بدلاً من استخدام anonymous type الذي لا يمكن لـ EF Core ترجمته
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            
            // تخزين نطاقات السعر لكل عملة شائعة
            decimal? yerMin = null, yerMax = null;
            decimal? usdMin = null, usdMax = null;
            decimal? eurMin = null, eurMax = null;
            decimal? sarMin = null, sarMax = null;
            decimal? gbpMin = null, gbpMax = null;
            
            foreach (var rate in exchangeRates)
            {
                var currencyMin = minPrice * rate.Value;
                var currencyMax = maxPrice * rate.Value;
                
                _logger.LogDebug(
                    "  └─ {Currency}: معدل={Rate}, نطاق={Min:N2}-{Max:N2}",
                    rate.Key, rate.Value, currencyMin, currencyMax);
                
                switch (rate.Key.ToUpper())
                {
                    case "YER":
                        yerMin = currencyMin;
                        yerMax = currencyMax;
                        break;
                    case "USD":
                        usdMin = currencyMin;
                        usdMax = currencyMax;
                        break;
                    case "EUR":
                        eurMin = currencyMin;
                        eurMax = currencyMax;
                        break;
                    case "SAR":
                        sarMin = currencyMin;
                        sarMax = currencyMax;
                        break;
                    case "GBP":
                        gbpMin = currencyMin;
                        gbpMax = currencyMax;
                        break;
                }
            }
            
            // إذا كانت هناك فترة بحث، نفلتر بناءً على أسعار تلك الفترة
            if (request.CheckIn.HasValue && request.CheckOut.HasValue)
            {
                var checkIn = request.CheckIn.Value.Date;
                var checkOut = request.CheckOut.Value.Date;
                
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // ✅ استخدام SQL Function المحسّنة: check_unit_price_in_range
                // بدلاً من 15 استعلام فرعي، نستخدم استعلام واحد يحسب المتوسط
                // الأداء: من O(15n) إلى O(n) حيث n = عدد الوحدات
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                query = query.Where(u => 
                    PostgreSqlFunctionsConfiguration.CheckUnitPriceInRange(
                        u.Id,
                        checkIn,
                        checkOut,
                        yerMin,
                        yerMax,
                        usdMin,
                        usdMax,
                        eurMin,
                        eurMax,
                        sarMin,
                        sarMax,
                        gbpMin,
                        gbpMax
                    )
                );
            }
            else
            {
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // ✅ استخدام SQL Function المبسطة: check_unit_any_price_in_range
                // للبحث بدون تحديد فترة (CheckIn/CheckOut)
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                query = query.Where(u => 
                    PostgreSqlFunctionsConfiguration.CheckUnitAnyPriceInRange(
                        u.Id,
                        yerMin,
                        yerMax,
                        usdMin,
                        usdMax,
                        eurMin,
                        eurMax,
                        sarMin,
                        sarMax,
                        gbpMin,
                        gbpMax
                    )
                );
            }
        }
        
        // 5. فلتر التقييم
        if (request.MinRating.HasValue)
        {
            query = query.Where(u => u.Property.AverageRating >= request.MinRating.Value);
        }
        
        // 6. فلتر تصنيف النجوم
        if (request.MinStarRating.HasValue)
        {
            query = query.Where(u => u.Property.StarRating >= request.MinStarRating.Value);
        }
        
        // 7. فلتر المميزة فقط
        if (request.FeaturedOnly == true)
        {
            query = query.Where(u => u.Property.IsFeatured);
        }
        
        // 8. فلتر السعة (Capacity Filter)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // استراتيجية التحقق:
        // 1. إذا كان GuestsCount موجودًا → استخدمه مباشرة
        // 2. وإلا، احسب من Adults + Children
        // 3. التحقق الرئيسي: MaxCapacity يجب أن يكون >= إجمالي الضيوف
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        if (request.GuestsCount.HasValue && request.GuestsCount.Value > 0)
        {
            // التحقق البسيط: MaxCapacity >= GuestsCount
            query = query.Where(u => u.MaxCapacity >= request.GuestsCount.Value);
        }
        else if (request.AdultsCount.HasValue || request.ChildrenCount.HasValue)
        {
            // حساب إجمالي الضيوف من البالغين والأطفال
            var adults = request.AdultsCount ?? 0;
            var children = request.ChildrenCount ?? 0;
            var totalGuests = adults + children;
            
            if (totalGuests > 0)
            {
                query = query.Where(u => u.MaxCapacity >= totalGuests);
            }
        }
        
        // 9. فلتر المرافق
        if (request.RequiredAmenities != null && request.RequiredAmenities.Any())
        {
            foreach (var amenityId in request.RequiredAmenities)
            {
                var currentAmenityId = amenityId;
                query = query.Where(u => u.Property.Amenities.Any(a => a.PropertyTypeAmenity.AmenityId == currentAmenityId));
            }
        }
        
        // 10. فلتر الخدمات
        if (request.RequiredServices != null && request.RequiredServices.Any())
        {
            foreach (var serviceId in request.RequiredServices)
            {
                var currentServiceId = serviceId;
                query = query.Where(u => u.Property.Services.Any(s => s.Id == currentServiceId));
            }
        }
        
        // 11. فلتر الحقول الديناميكية مع حماية
        if (request.DynamicFieldFilters != null && request.DynamicFieldFilters.Any())
        {
            var originalCount = request.DynamicFieldFilters.Count;
            
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            // Safe Guard: تقليل تلقائي إذا تجاوز الحد الأقصى
            // Automatically reduce if exceeds maximum limit
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            if (originalCount > _safeGuardOptions.MaxDynamicFieldFilters)
            {
                _logger.LogWarning(
                    "⚠️ عدد كبير من الحقول الديناميكية ({Count}) - تقليل للحد الأقصى {MaxAllowed}",
                    originalCount, _safeGuardOptions.MaxDynamicFieldFilters);
                
                request.DynamicFieldFilters = request.DynamicFieldFilters
                    .Take(_safeGuardOptions.MaxDynamicFieldFilters)
                    .ToDictionary(kvp => kvp.Key, kvp => kvp.Value);
            }
            
            _logger.LogInformation(
                "🔧 تطبيق فلاتر الحقول الديناميكية: {Count} فلتر",
                request.DynamicFieldFilters.Count);
            
            foreach (var filter in request.DynamicFieldFilters)
            {
                var fieldName = filter.Key;
                var fieldValue = filter.Value;
                
                _logger.LogInformation(
                    "   • فلترة {FieldName} = {FieldValue}",
                    fieldName,
                    fieldValue);
                
                if (fieldValue.StartsWith("~"))
                {
                    var searchValue = fieldValue.Substring(1);
                    _logger.LogInformation("     → بحث نصي جزئي: {SearchValue}", searchValue);
                    query = query.Where(u => u.FieldValues.Any(fv => 
                        fv.UnitTypeField.FieldName != null && fv.UnitTypeField.FieldName == fieldName && 
                        EF.Functions.ILike(fv.FieldValue, $"%{searchValue}%")));
                }
                else if (fieldValue.Contains(".."))
                {
                    var parts = fieldValue.Split("..");
                    if (parts.Length == 2 && 
                        decimal.TryParse(parts[0], out var min) && 
                        decimal.TryParse(parts[1], out var max))
                    {
                        _logger.LogInformation("     → نطاق رقمي: {Min} إلى {Max}", min, max);
                        // ✅ FIX: تطبيق فلترة النطاق الرقمي بالكامل في SQL
                        // استخدام PostgreSQL function: is_numeric_in_range()
                        var fieldName2 = fieldName;
                        
                        query = query.Where(u => 
                            context.UnitFieldValues.Any(fv => 
                                fv.UnitId == u.Id &&
                                fv.UnitTypeField.FieldName == fieldName2 &&
                                PostgreSqlFunctionsConfiguration.IsNumericInRange(fv.FieldValue, min, max)
                            )
                        );
                    }
                }
                else
                {
                    _logger.LogInformation("     → تطابق تام: {FieldValue}", fieldValue);
                    query = query.Where(u => u.FieldValues.Any(fv => 
                        fv.UnitTypeField.FieldName != null && fv.UnitTypeField.FieldName == fieldName && 
                        fv.FieldValue == fieldValue));
                }
            }
        }
        else
        {
            _logger.LogInformation("🔧 لا توجد فلاتر للحقول الديناميكية");
        }
        
        // 12. البحث النصي
        if (!string.IsNullOrWhiteSpace(request.SearchText))
        {
            var searchText = request.SearchText.Trim();
            var loweredSearchText = searchText.ToLowerInvariant();
            var arabicTsQuery = EF.Functions.WebSearchToTsQuery("arabic", searchText);
            var simpleTsQuery = EF.Functions.WebSearchToTsQuery("simple", searchText);
            
            query = query.Where(u =>
                EF.Functions.ToTsVector(
                    "arabic",
                    (u.Name ?? string.Empty) + " " +
                    (u.Property.Name ?? string.Empty) + " " +
                    (u.Property.Description ?? string.Empty) + " " +
                    (u.Property.Address ?? string.Empty) + " " +
                    (u.Property.City ?? string.Empty) + " " +
                    (u.UnitType.Name ?? string.Empty))
                    .Matches(arabicTsQuery) ||
                EF.Functions.ToTsVector(
                    "simple",
                    (u.Name ?? string.Empty) + " " +
                    (u.Property.Name ?? string.Empty) + " " +
                    (u.Property.Description ?? string.Empty) + " " +
                    (u.Property.Address ?? string.Empty) + " " +
                    (u.Property.City ?? string.Empty) + " " +
                    (u.UnitType.Name ?? string.Empty))
                    .Matches(simpleTsQuery) ||
                EF.Functions.ILike(u.Name, $"%{loweredSearchText}%") ||
                EF.Functions.ILike(u.Property.Name, $"%{loweredSearchText}%") ||
                EF.Functions.ILike(u.Property.Description ?? string.Empty, $"%{loweredSearchText}%") ||
                EF.Functions.ILike(u.Property.Address ?? string.Empty, $"%{loweredSearchText}%") ||
                EF.Functions.ILike(u.Property.City ?? string.Empty, $"%{loweredSearchText}%") ||
                EF.Functions.ILike(u.UnitType.Name ?? string.Empty, $"%{loweredSearchText}%"));
        }
        
        // 13. البحث الجغرافي
        if (request.Latitude.HasValue && request.Longitude.HasValue && request.RadiusKm.HasValue)
        {
            var userLat = (double)request.Latitude.Value;
            var userLng = (double)request.Longitude.Value;
            var radiusKm = request.RadiusKm.Value;
            
            query = query.Where(u =>
                (6371 * 2 * Math.Asin(Math.Sqrt(
                    Math.Pow(Math.Sin((Math.PI / 180.0 * ((double)u.Property.Latitude - userLat)) / 2), 2) +
                    Math.Cos(Math.PI / 180.0 * userLat) *
                    Math.Cos(Math.PI / 180.0 * (double)u.Property.Latitude) *
                    Math.Pow(Math.Sin((Math.PI / 180.0 * ((double)u.Property.Longitude - userLng)) / 2), 2)
                ))) <= radiusKm);
        }
        
        // 14. ⚠️ فلتر الإتاحة من UnitAvailabilities (ليس IsAvailable)
        if (request.CheckIn.HasValue && request.CheckOut.HasValue)
        {
            // ✅ FIX: توحيد Timezone - التأكد من استخدام UTC
            var checkIn = request.CheckIn.Value.ToUniversalTime();
            var checkOut = request.CheckOut.Value.ToUniversalTime();
            var rangeEndExclusive = checkOut.Date > checkIn.Date
                ? checkOut.Date
                : checkIn.Date.AddDays(1);
            
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            // منطق الإتاحة:
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            // ✅ إذا لم يوجد أي سجل في DailyUnitSchedules → الوحدة متاحة
            // ✅ إذا وُجد سجل بحالة "Available" → الوحدة متاحة
            // ✅ إذا وُجد سجل بحالة "Booked/Blocked" في أي يوم من الفترة → الوحدة غير متاحة
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            
            // استبعاد الوحدات التي لديها سجلات غير متاحة في أي يوم من الفترة المطلوبة
            query = query.Where(u => !context.DailyUnitSchedules
                .Any(ds =>
                    ds.UnitId == u.Id &&
                    ds.Status != "Available" &&  // فقط الحالات غير المتاحة
                    ds.Date >= checkIn.Date &&   // التحقق من التقاطع
                    ds.Date < rangeEndExclusive &&
                    // تجاهل السجلات القديمة غير المتسقة: يوم خارج فترة الحجز المرتبط
                    (ds.BookingId == null ||
                     ds.Booking == null ||
                     (ds.Date >= ds.Booking.CheckIn.Date && ds.Date < ds.Booking.CheckOut.Date))));
        }
        
        return query;
    }
    
    private IQueryable<Unit> ApplySorting(IQueryable<Unit> query, UnitSearchRequest request)
    {
        if (request.SortBy?.ToLower() == "distance" && 
            request.Latitude.HasValue && 
            request.Longitude.HasValue)
        {
            var userLat = (double)request.Latitude.Value;
            var userLng = (double)request.Longitude.Value;
            
            return query.OrderBy(u =>
                (6371 * 2 * Math.Asin(Math.Sqrt(
                    Math.Pow(Math.Sin((Math.PI / 180.0 * ((double)u.Property.Latitude - userLat)) / 2), 2) +
                    Math.Cos(Math.PI / 180.0 * userLat) *
                    Math.Cos(Math.PI / 180.0 * (double)u.Property.Latitude) *
                    Math.Pow(Math.Sin((Math.PI / 180.0 * ((double)u.Property.Longitude - userLng)) / 2), 2)
                ))));
        }
        
        // ترتيب حسب السعر من DailySchedules
        // ملاحظة: نحسب متوسط السعر من DailySchedules للفترة المطلوبة (أو آخر 30 يوم إذا لم تحدد فترة)
        var sortBy = request.SortBy?.ToLower();
        if (sortBy == "price_asc" || sortBy == "price_desc")
        {
            DateTime fromDate;
            DateTime toDate;
            
            if (request.CheckIn.HasValue && request.CheckOut.HasValue)
            {
                fromDate = request.CheckIn.Value.Date;
                toDate = request.CheckOut.Value.Date > request.CheckIn.Value.Date
                    ? request.CheckOut.Value.Date
                    : request.CheckIn.Value.Date.AddDays(1);
            }
            else
            {
                // استخدام آخر 30 يوم كفترة افتراضية
                fromDate = DateTime.UtcNow.Date;
                toDate = fromDate.AddDays(30);
            }
            
            // الترتيب بناءً على متوسط السعر في الفترة
            if (sortBy == "price_asc")
            {
                return query.OrderBy(u => _context.DailyUnitSchedules
                    .Where(ds => ds.UnitId == u.Id && 
                                 ds.Date >= fromDate && 
                                 ds.Date < toDate &&
                                 ds.PriceAmount.HasValue)
                    .Average(ds => ds.PriceAmount) ?? 0);
            }
            else
            {
                return query.OrderByDescending(u => _context.DailyUnitSchedules
                    .Where(ds => ds.UnitId == u.Id && 
                                 ds.Date >= fromDate && 
                                 ds.Date < toDate &&
                                 ds.PriceAmount.HasValue)
                    .Average(ds => ds.PriceAmount) ?? 0);
            }
        }
        
        return sortBy switch
        {
            "rating" => query.OrderByDescending(u => u.Property.AverageRating)
                            .ThenBy(u => u.Id),
            "newest" => query.OrderByDescending(u => u.CreatedAt)
                            .ThenBy(u => u.Id),
            "popular" => query.OrderByDescending(u => u.BookingCount)
                             .ThenByDescending(u => u.ViewCount)
                             .ThenBy(u => u.Id),
            _ => query.OrderByDescending(u => u.Property.IsFeatured)
                      .ThenByDescending(u => u.Property.AverageRating)
                      .ThenBy(u => u.Id)
        };
    }
    
    #endregion
    
    #region === المساعدة (Helper Methods) ===
    
    private Dictionary<string, string> BuildAppliedFilters(UnitSearchRequest request)
    {
        var filters = new Dictionary<string, string>();
        
        if (!string.IsNullOrWhiteSpace(request.City))
            filters["City"] = request.City;
        
        if (request.UnitTypeId.HasValue)
            filters["UnitType"] = request.UnitTypeId.ToString()!;
        
        if (request.PropertyTypeId.HasValue)
            filters["PropertyType"] = request.PropertyTypeId.ToString()!;
        
        if (request.CheckIn.HasValue && request.CheckOut.HasValue)
            filters["Dates"] = $"{request.CheckIn:yyyy-MM-dd} → {request.CheckOut:yyyy-MM-dd}";
        
        if (request.MinPrice.HasValue || request.MaxPrice.HasValue)
            filters["Price"] = $"{request.MinPrice ?? 0} - {request.MaxPrice ?? decimal.MaxValue}";
        
        if (request.GuestsCount.HasValue)
            filters["Guests"] = request.GuestsCount.ToString()!;
        
        return filters;
    }
    
    /// <summary>
    /// التحقق من وجود أي معايير بحث في الطلب
    /// Check if request has any search criteria
    /// </summary>
    private bool HasAnySearchCriteria(UnitSearchRequest request)
    {
        return !string.IsNullOrWhiteSpace(request.SearchText) ||
               !string.IsNullOrWhiteSpace(request.City) ||
               request.UnitTypeId.HasValue ||
               request.PropertyTypeId.HasValue ||
               request.CheckIn.HasValue ||
               request.CheckOut.HasValue ||
               request.MinPrice.HasValue ||
               request.MaxPrice.HasValue ||
               request.GuestsCount.HasValue ||
               request.AdultsCount.HasValue ||
               request.ChildrenCount.HasValue ||
               request.MinRating.HasValue ||
               request.MinStarRating.HasValue ||
               request.FeaturedOnly == true ||
               request.RequiredAmenities?.Any() == true ||
               request.RequiredServices?.Any() == true ||
               request.DynamicFieldFilters?.Any() == true ||
               (request.Latitude.HasValue && request.Longitude.HasValue && request.RadiusKm.HasValue);
    }
    
    /// <summary>
    /// التحقق من وجود فلاتر "مهمة" كافية في الطلب
    /// Check if request has significant filters
    /// 
    /// الفلاتر المهمة: المدينة، نوع العقار، نوع الوحدة، التواريخ، السعر، الموقع الجغرافي
    /// Significant filters: City, PropertyType, UnitType, Dates, Price, Geographic location
    /// </summary>
    private bool HasSignificantFilters(UnitSearchRequest request)
    {
        return !string.IsNullOrWhiteSpace(request.City) ||
               request.UnitTypeId.HasValue ||
               request.PropertyTypeId.HasValue ||
               (request.CheckIn.HasValue && request.CheckOut.HasValue) ||
               (request.MinPrice.HasValue || request.MaxPrice.HasValue) ||
               (request.Latitude.HasValue && request.Longitude.HasValue && request.RadiusKm.HasValue);
    }
    
    #endregion
    
    #region === دعم العملات المتعددة (Multi-Currency Support) ===
    
    /// <summary>
    /// جلب أسعار الصرف من جدول العملات مع Memory Cache
    /// ✅ يُخزن في الذاكرة لمدة 30 دقيقة لتحسين الأداء
    /// ✅ يُرجع العملة الافتراضية على الأقل في حالة الفشل
    /// </summary>
    private async Task<Dictionary<string, decimal>> GetExchangeRatesAsync(string? searchCurrency = null)
    {
        try
        {
            // تحديد العملة المطلوبة
            if (string.IsNullOrWhiteSpace(searchCurrency))
            {
                var defaultCurrency = await _context.Set<Currency>()
                    .AsNoTracking()
                    .Where(c => c.IsDefault)
                    .Select(c => c.Code)
                    .FirstOrDefaultAsync();
                
                searchCurrency = defaultCurrency ?? "YER";
            }
            
            // ✅ FIX: استخدام Memory Cache للأسعار
            var cacheKey = $"ExchangeRates_{searchCurrency}";
            
            if (_cache.TryGetValue(cacheKey, out Dictionary<string, decimal>? cachedRates) && cachedRates != null && cachedRates.Any())
            {
                _logger.LogDebug("✅ تم جلب أسعار الصرف من Cache لـ {Currency}", searchCurrency);
                return cachedRates;
            }
            
            // جلب جميع العملات النشطة مع أسعار الصرف
            var currencies = await _context.Set<Currency>()
                .AsNoTracking()
                .Where(c => c.ExchangeRate.HasValue || c.IsDefault)
                .Select(c => new { c.Code, c.ExchangeRate, c.IsDefault })
                .ToListAsync();
            
            // بناء قاموس أسعار الصرف بالنسبة للعملة المطلوبة
            var rates = new Dictionary<string, decimal>();
            
            // العملة الافتراضية لها سعر صرف = 1
            var defaultCurrencyItem = currencies.FirstOrDefault(c => c.IsDefault);
            if (defaultCurrencyItem == null)
            {
                _logger.LogWarning("⚠️ لا توجد عملة افتراضية محددة في النظام - استخدام YER كعملة افتراضية");
                // ✅ إرجاع YER كعملة افتراضية على الأقل
                rates["YER"] = 1m;
                return rates;
            }
            
            // إذا كانت عملة البحث هي العملة الافتراضية
            if (searchCurrency == defaultCurrencyItem.Code)
            {
                // جميع العملات الأخرى بأسعارها المحولة
                foreach (var currency in currencies)
                {
                    if (currency.IsDefault)
                    {
                        rates[currency.Code] = 1m;  // العملة الافتراضية = 1
                    }
                    else if (currency.ExchangeRate.HasValue)
                    {
                        rates[currency.Code] = 1m / currency.ExchangeRate.Value;
                    }
                }
            }
            else
            {
                // إذا كانت عملة البحث ليست العملة الافتراضية
                var searchCurrencyItem = currencies.FirstOrDefault(c => c.Code == searchCurrency);
                if (searchCurrencyItem == null || !searchCurrencyItem.ExchangeRate.HasValue)
                {
                    _logger.LogWarning("⚠️ عملة البحث {Currency} غير موجودة أو ليس لها سعر صرف - استخدام العملة الافتراضية {Default}",
                        searchCurrency, defaultCurrencyItem.Code);
                    
                    // ✅ إرجاع العملة الافتراضية على الأقل
                    rates[defaultCurrencyItem.Code] = 1m;
                    
                    // إضافة باقي العملات إن أمكن
                    foreach (var currency in currencies.Where(c => c.ExchangeRate.HasValue))
                    {
                        rates[currency.Code] = 1m / currency.ExchangeRate.Value;
                    }
                    
                    return rates;
                }
                
                var searchCurrencyRate = searchCurrencyItem.ExchangeRate.Value;
                
                // تحويل جميع العملات بالنسبة لعملة البحث
                foreach (var currency in currencies)
                {
                    if (currency.Code == searchCurrency)
                    {
                        rates[currency.Code] = 1m;  // العملة نفسها = 1
                    }
                    else if (currency.IsDefault)
                    {
                        // العملة الافتراضية بالنسبة لعملة البحث
                        rates[currency.Code] = searchCurrencyRate;
                    }
                    else if (currency.ExchangeRate.HasValue)
                    {
                        // العملات الأخرى: تحويل عبر العملة الافتراضية
                        rates[currency.Code] = searchCurrencyRate / currency.ExchangeRate.Value;
                    }
                }
            }
            
            // ✅ التأكد من أن لدينا عملة واحدة على الأقل
            if (!rates.Any())
            {
                _logger.LogWarning("⚠️ لم يتم جلب أي أسعار صرف - استخدام YER كعملة افتراضية");
                rates["YER"] = 1m;
            }
            
            _logger.LogDebug("✅ تم جلب {Count} سعر صرف بالنسبة لـ {Currency} وتخزينه في Cache", rates.Count, searchCurrency);
            
            // ✅ تخزين في Cache لمدة 30 دقيقة
            var cacheOptions = new MemoryCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(30),
                SlidingExpiration = TimeSpan.FromMinutes(15)
            };
            _cache.Set(cacheKey, rates, cacheOptions);
            
            return rates;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "❌ خطأ أثناء جلب أسعار الصرف - استخدام YER كعملة افتراضية");
            // ✅ في حالة الخطأ، إرجاع YER كعملة افتراضية
            return new Dictionary<string, decimal> { ["YER"] = 1m };
        }
    }
    
    /// <summary>
    /// تحويل JSONB string إلى Dictionary
    /// </summary>
    private static Dictionary<string, string> ParseJsonToDictionary(string? json)
    {
        if (string.IsNullOrWhiteSpace(json) || json == "{}")
            return new Dictionary<string, string>();
        
        try
        {
            var dict = JsonSerializer.Deserialize<Dictionary<string, string>>(json);
            return dict ?? new Dictionary<string, string>();
        }
        catch
        {
            return new Dictionary<string, string>();
        }
    }

    private static Dictionary<string, string> BuildDisplayFields(IEnumerable<SearchableFieldValue> fields)
    {
        return fields
            .Where(field => !string.IsNullOrWhiteSpace(field.Value))
            .OrderByDescending(field => field.IsPrimaryFilter)
            .ThenByDescending(field => field.Priority)
            .GroupBy(field => string.IsNullOrWhiteSpace(field.DisplayName) ? field.FieldName : field.DisplayName)
            .ToDictionary(group => group.Key, group => group.First().Value);
    }
    
    /// <summary>
    /// نسخ UnitSearchRequest إلى PropertyWithUnitsSearchRequest
    /// Copy UnitSearchRequest to PropertyWithUnitsSearchRequest
    /// 
    /// ✅ يحافظ على جميع الخصائص من النوع الأساسي
    /// ✅ Preserves all properties from base type
    /// </summary>
    private PropertyWithUnitsSearchRequest CopyToPropertyWithUnitsRequest(UnitSearchRequest source)
    {
        try
        {
            var json = JsonSerializer.Serialize(source, source.GetType());
            return JsonSerializer.Deserialize<PropertyWithUnitsSearchRequest>(json)
                   ?? new PropertyWithUnitsSearchRequest();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "❌ فشل نسخ UnitSearchRequest إلى PropertyWithUnitsSearchRequest");
            return new PropertyWithUnitsSearchRequest();
        }
    }
    
    #endregion
}
