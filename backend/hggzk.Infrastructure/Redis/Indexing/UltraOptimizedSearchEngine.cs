using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using StackExchange.Redis;
using YemenBooking.Application.Features.SearchAndFilters.Services;
using YemenBooking.Core.Indexing.Models;
using YemenBooking.Core.Indexing.RediSearch;
using YemenBooking.Infrastructure.Redis.Core.Interfaces;
using YemenBooking.Infrastructure.Redis.Scripts;

namespace YemenBooking.Infrastructure.Redis.Indexing;

/// <summary>
/// Highly optimized Redis search engine backed by Lua scripts.
/// محرك بحث Redis عالي التحسين يعتمد على Lua Scripts.
/// </summary>
public sealed class UltraOptimizedSearchEngine : IUnitSearchEngine
{
    #region === Private Fields / الحقول الخاصة ===
    
    /// <summary>
    /// حقل _redisManager.
    /// _redisManager field.
    /// </summary>
    private readonly IRedisConnectionManager _redisManager;
    /// <summary>
    /// حقل _logger.
    /// _logger field.
    /// </summary>
    private readonly ILogger<UltraOptimizedSearchEngine> _logger;
    /// <summary>
    /// حقل _jsonOptions.
    /// _jsonOptions field.
    /// </summary>
    private readonly JsonSerializerOptions _jsonOptions;
    
    // Cached compiled Lua scripts.
    // Cached compiled Lua scripts. / تخزين سكربتات Lua المترجمة.
    /// <summary>
    /// حقل _comprehensiveSearchScript.
    /// _comprehensiveSearchScript field.
    /// </summary>
    private string? _comprehensiveSearchScript;
    /// <summary>
    /// حقل _batchPriceCalculationScript.
    /// _batchPriceCalculationScript field.
    /// </summary>
    private string? _batchPriceCalculationScript;
    /// <summary>
    /// حقل _availableUnitsSearchScript.
    /// _availableUnitsSearchScript field.
    /// </summary>
    private string? _availableUnitsSearchScript;
    
    #endregion
    
    #region === Construction / البناء والتهيئة ===
    
    /// <summary>
    /// منشئ UltraOptimizedSearchEngine.
    /// UltraOptimizedSearchEngine constructor.
    /// </summary>
    public UltraOptimizedSearchEngine(
        IRedisConnectionManager redisManager,
        ILogger<UltraOptimizedSearchEngine> logger)
    {
        _redisManager = redisManager ?? throw new ArgumentNullException(nameof(redisManager));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        
        _jsonOptions = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true,
            WriteIndented = false
        };
    }
    
    /// <summary>
    /// Preloads the Lua scripts used by the search engine.
    /// يحمّل سكربتات Lua المستخدمة في محرك البحث.
    /// </summary>
    public async Task PreloadScriptsAsync()
    {
        const int maxRetries = 3;
        var retryCount = 0;
        
        while (retryCount < maxRetries)
        {
            try
            {
                await _redisManager.GetDatabaseAsync().ConfigureAwait(false);

                // Do not use LuaScript.Prepare here because the embedded RediSearch
                // queries contain literal tokens such as @unitId and @startDateTs.
                // StackExchange.Redis treats those as script parameters and then
                // fails at runtime while binding anonymous objects.
                _comprehensiveSearchScript = LuaScripts.ComprehensiveSearchScript;
                _batchPriceCalculationScript = LuaScripts.BatchCalculatePricesScript;
                _availableUnitsSearchScript = LuaScripts.SearchAvailableUnitsScript;
                
                _logger.LogInformation("Loaded Lua scripts successfully. / تم تحميل Lua Scripts بنجاح");
                return;
            }
            catch (Exception ex)
            {
                retryCount++;
                
                if (retryCount >= maxRetries)
                {
                    _logger.LogError(ex, "فشل تحميل Lua Scripts بعد {RetryCount} محاولات", maxRetries);
                    throw;
                }
                
                var delayMs = (int)Math.Pow(2, retryCount) * 1000; // Exponential backoff. / تأخير تصاعدي.
                _logger.LogWarning(ex, "خطأ أثناء تحميل Lua Scripts. إعادة المحاولة {RetryCount}/{MaxRetries} بعد {DelayMs}ms", 
                    retryCount, maxRetries, delayMs);
                
                await Task.Delay(delayMs).ConfigureAwait(false);
            }
        }
    }
    
    #endregion
    
    #region === Search / البحث الرئيسي ===
    
    /// <summary>
    /// Searches for units using the optimized Redis flow.
    /// يبحث عن الوحدات باستخدام مسار Redis المحسّن.
    /// </summary>
    public async Task<UnitSearchResult> SearchUnitsAsync(
        UnitSearchRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request == null)
            throw new ArgumentNullException(nameof(request));
        
        var stopwatch = Stopwatch.StartNew();
        
        try
        {
            _logger.LogInformation(
                "🔍 بدء البحث المحسّن: المدينة={City}, CheckIn={CheckIn}, CheckOut={CheckOut}",
                request.City, request.CheckIn, request.CheckOut);
            
            UnitSearchResult result;
            
            // Select the search strategy based on date filters.
            // Choose the search strategy based on whether dates are provided. / اختيار استراتيجية البحث بناءً على وجود التواريخ.
            if (request.CheckIn.HasValue && request.CheckOut.HasValue)
            {
                // Search with dates and prices.
                // Search with dates and prices. / البحث مع التواريخ والأسعار.
                result = await SearchWithDatesAndPricesAsync(request, cancellationToken).ConfigureAwait(false);
            }
            else
            {
                // Search without dates.
                // Search without dates. / البحث بدون تواريخ.
                result = await SearchWithoutDatesAsync(request, cancellationToken).ConfigureAwait(false);
            }
            
            result.SearchTimeMs = stopwatch.ElapsedMilliseconds;
            
            _logger.LogInformation(
                "✅ اكتمل البحث المحسّن: {Count} وحدة من {Total} في {Ms}ms",
                result.Units.Count, result.TotalCount, result.SearchTimeMs);
            
            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "❌ خطأ أثناء البحث عن الوحدات");
            
            return new UnitSearchResult
            {
                Units = new List<UnitSearchItem>(),
                TotalCount = 0,
                PageNumber = request.PageNumber,
                PageSize = request.PageSize,
                SearchTimeMs = stopwatch.ElapsedMilliseconds
            };
        }
    }
    
    #endregion
    
    #region === Search Strategies / استراتيجيات البحث ===
    
    /// <summary>
    /// Searches with dates and prices using the comprehensive Lua script.
    /// يبحث مع التواريخ والأسعار باستخدام سكربت Lua الشامل.
    /// </summary>
    private async Task<UnitSearchResult> SearchWithDatesAndPricesAsync(
        UnitSearchRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var db = await _redisManager.GetDatabaseAsync().ConfigureAwait(false);
            
            // Build Redis queries. / بناء استعلامات Redis.
            var queryBuilder = new PeriodBasedQueryBuilder(request);
            var unitsQuery = queryBuilder.BuildUnitsSearchQuery(null);
            var availQuery = queryBuilder.BuildBlockedPeriodsQuery(request.CheckIn!.Value, request.CheckOut!.Value);

            var effectiveCheckIn = request.CheckInLocalDate ?? request.CheckIn.Value.Date;
            var effectiveCheckOut = request.CheckOutLocalDate ?? request.CheckOut.Value.Date;
            
            var checkInTs = new DateTimeOffset(effectiveCheckIn).ToUnixTimeSeconds();
            var checkOutTs = new DateTimeOffset(effectiveCheckOut).ToUnixTimeSeconds();
            
            // Ensure the script is loaded. / التأكد من تحميل السكربت.
            if (_comprehensiveSearchScript == null)
            {
                await PreloadScriptsAsync().ConfigureAwait(false);
            }
            
            // Execute the comprehensive script. / تنفيذ السكربت الشامل.
            var keys = new RedisKey[]
            {
                PeriodBasedSearchSchema.UNITS_INDEX,
                PeriodBasedSearchSchema.SCHEDULE_INDEX,
                PeriodBasedSearchSchema.SCHEDULE_INDEX
            };
            
            var unitsQueryStr = unitsQuery.Length > 1 ? unitsQuery[1] : "*";
            var availQueryStr = availQuery.Length > 1 ? availQuery[1] : "*";

            _logger.LogInformation(
                "Redis dated search diagnostics. UnitsQuery={UnitsQuery}, AvailabilityQuery={AvailabilityQuery}, CheckInUtc={CheckInUtc}, CheckOutUtc={CheckOutUtc}, CheckInLocalDate={CheckInLocalDate}, CheckOutLocalDate={CheckOutLocalDate}, EffectiveCheckIn={EffectiveCheckIn}, EffectiveCheckOut={EffectiveCheckOut}, CheckInTs={CheckInTs}, CheckOutTs={CheckOutTs}, RequestedPageSize={PageSize}",
                unitsQueryStr,
                availQueryStr,
                request.CheckIn,
                request.CheckOut,
                request.CheckInLocalDate,
                request.CheckOutLocalDate,
                effectiveCheckIn,
                effectiveCheckOut,
                checkInTs,
                checkOutTs,
                request.PageSize);
            
            var values = new RedisValue[]
            {
                unitsQueryStr,
                availQueryStr,
                checkInTs,
                checkOutTs,
                request.PageSize * 2 // Fetch extra rows to offset filtering. / جلب صفوف إضافية لتعويض الفلترة.
            };
            
            var scriptResult = await db.ScriptEvaluateAsync(
                _comprehensiveSearchScript!,
                keys,
                values).ConfigureAwait(false);
            
            // Parse the script results. / تحليل نتائج السكربت.
            var results = await ParseComprehensiveSearchResultsAsync(scriptResult, request).ConfigureAwait(false);
            _logger.LogInformation(
                "Redis dated search raw result count before price filter: {Count}",
                results.Count);
            
            // Apply the price filter when present. / تطبيق فلتر السعر عند وجوده.
            if (request.MinPrice.HasValue || request.MaxPrice.HasValue)
            {
                results = ApplyPriceFilter(results, request.MinPrice, request.MaxPrice);
                _logger.LogInformation(
                    "Redis dated search result count after price filter: {Count}, MinPrice={MinPrice}, MaxPrice={MaxPrice}",
                    results.Count,
                    request.MinPrice,
                    request.MaxPrice);
            }
            
            // Sort the results. / ترتيب النتائج.
            results = ApplySorting(results, request.SortBy);
            
            // Apply pagination. / تطبيق التصفح.
            var totalCount = results.Count;
            var offset = (request.PageNumber - 1) * request.PageSize;
            var pagedResults = results.Skip(offset).Take(request.PageSize).ToList();
            
            return new UnitSearchResult
            {
                Units = pagedResults,
                TotalCount = totalCount,
                PageNumber = request.PageNumber,
                PageSize = request.PageSize,
                TotalPages = (int)Math.Ceiling((double)totalCount / request.PageSize)
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء البحث مع التواريخ");
            throw;
        }
    }
    
    /// <summary>
    /// Searches without dates directly through RediSearch.
    /// يبحث بدون تواريخ مباشرة عبر RediSearch.
    /// </summary>
    private async Task<UnitSearchResult> SearchWithoutDatesAsync(
        UnitSearchRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var db = await _redisManager.GetDatabaseAsync().ConfigureAwait(false);
            var queryBuilder = new PeriodBasedQueryBuilder(request);
            
            var query = queryBuilder.BuildUnitsSearchQuery(null);
            _logger.LogInformation(
                "Redis non-dated search diagnostics. Query={Query}, PageNumber={PageNumber}, PageSize={PageSize}",
                string.Join(" ", query.Skip(1)),
                request.PageNumber,
                request.PageSize);
            
            // Build the Redis command. / بناء أمر Redis.
            var searchCmd = new List<object> { "FT.SEARCH" };
            searchCmd.AddRange(query);
            
            // Execute the search. / تنفيذ البحث.
            var result = await db.ExecuteAsync(searchCmd[0].ToString(), searchCmd.Skip(1).ToArray()).ConfigureAwait(false);
            
            var units = new List<UnitSearchItem>();
            int totalCount = 0;
            
            if (!result.IsNull)
            {
                var resultArray = (RedisResult[])result;
                
                if (resultArray.Length > 0)
                {
                    // First element is the total count. / العنصر الأول هو العدد الإجمالي.
                    totalCount = (int)resultArray[0];
                    
                    // Parse the results. / تحليل النتائج.
                    for (int i = 1; i < resultArray.Length; i += 2)
                    {
                        if (i + 1 < resultArray.Length)
                        {
                            var fields = (RedisResult[])resultArray[i + 1];
                            var unit = ParseUnitSearchItem(fields, null);
                            if (unit != null)
                            {
                                units.Add(unit);
                            }
                        }
                    }
                }
            }
            
            return new UnitSearchResult
            {
                Units = units,
                TotalCount = totalCount,
                PageNumber = request.PageNumber,
                PageSize = request.PageSize,
                TotalPages = (int)Math.Ceiling((double)totalCount / request.PageSize)
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء البحث بدون تواريخ");
            throw;
        }
    }
    
    #endregion
    
    #region === Result Handling / معالجة النتائج ===
    
    /// <summary>
    /// Parses the comprehensive Lua-script result payload.
    /// يحلل ناتج سكربت Lua الشامل.
    /// </summary>
    private async Task<List<UnitSearchItem>> ParseComprehensiveSearchResultsAsync(
        RedisResult scriptResult,
        UnitSearchRequest request)
    {
        var results = new List<UnitSearchItem>();
        
        try
        {
            if (scriptResult.IsNull)
                return results;
            
            var resultArray = (RedisResult[])scriptResult;
            
            // Result format: [unitId, totalPrice, key, ...] / التنسيق: [unitId, totalPrice, key, ...]
            for (int i = 0; i < resultArray.Length; i += 3)
            {
                if (i + 2 < resultArray.Length)
                {
                    var unitIdStr = resultArray[i].ToString();
                    var totalPriceStr = resultArray[i + 1].ToString();
                    var unitKey = resultArray[i + 2].ToString();
                    
                    if (Guid.TryParse(unitIdStr, out var unitId) &&
                        decimal.TryParse(totalPriceStr, NumberStyles.Any, CultureInfo.InvariantCulture, out var totalPrice))
                    {
                        // Fetch minimal unit details. / جلب تفاصيل الوحدة الأساسية.
                        var item = new UnitSearchItem
                        {
                            UnitId = unitId,
                            TotalPrice = totalPrice
                        };
                        
                        results.Add(item);
                    }
                }
            }
            
            // Enrich the items in a batch. / إثراء العناصر دفعة واحدة.
            if (results.Any())
            {
                await EnrichUnitDetailsInBatchAsync(results).ConfigureAwait(false);
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "خطأ أثناء تحليل نتائج البحث الشامل");
        }
        
        return results;
    }
    
    /// <summary>
    /// Enriches unit details in batch using Redis pipeline.
    /// يثري تفاصيل الوحدات دفعة واحدة باستخدام Redis pipeline.
    /// </summary>
    private async Task EnrichUnitDetailsInBatchAsync(List<UnitSearchItem> items)
    {
        try
        {
            var db = await _redisManager.GetDatabaseAsync().ConfigureAwait(false);
            var batch = db.CreateBatch();
            
            var tasks = new List<Task<HashEntry[]>>();
            
            foreach (var item in items)
            {
                var unitKey = PeriodBasedSearchSchema.GetUnitKey(item.UnitId);
                tasks.Add(batch.HashGetAllAsync(unitKey));
            }
            
            batch.Execute();
            
            var results = await Task.WhenAll(tasks).ConfigureAwait(false);
            
            for (int i = 0; i < items.Count && i < results.Length; i++)
            {
                var fields = results[i];
                EnrichUnitItem(items[i], fields);
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "خطأ أثناء إثراء تفاصيل الوحدات");
        }
    }
    
    /// <summary>
    /// Enriches a single unit item with Redis fields.
    /// يثري عنصر وحدة واحداً بحقول Redis.
    /// </summary>
    private void EnrichUnitItem(UnitSearchItem item, HashEntry[] fields)
    {
        foreach (var field in fields)
        {
            var fieldName = field.Name.ToString();
            var fieldValue = field.Value.ToString();
            
            switch (fieldName)
            {
                case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.PROPERTY_ID:
                    if (Guid.TryParse(fieldValue, out var propertyId))
                        item.PropertyId = propertyId;
                    break;
                
                case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.UNIT_NAME:
                    item.UnitName = fieldValue;
                    break;
                
                case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.PROPERTY_NAME:
                    item.PropertyName = fieldValue;
                    break;
                
                case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.CITY:
                    item.City = fieldValue;
                    break;
                
                case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.BASE_PRICE:
                    if (decimal.TryParse(fieldValue, NumberStyles.Any, CultureInfo.InvariantCulture, out var basePrice))
                        item.BasePrice = basePrice;
                    break;

                case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.CURRENCY:
                    item.Currency = fieldValue;
                    break;
                
                case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.UNIT_TYPE_NAME:
                    item.UnitTypeName = fieldValue;
                    break;
                
                case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.PROPERTY_TYPE_NAME:
                    item.PropertyTypeName = fieldValue;
                    break;
                
                case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.AVERAGE_RATING:
                    if (decimal.TryParse(fieldValue, NumberStyles.Any, CultureInfo.InvariantCulture, out var rating))
                        item.AverageRating = rating;
                    break;
                
                case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.STAR_RATING:
                    if (int.TryParse(fieldValue, out var starRating))
                        item.StarRating = starRating;
                    break;

                case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.LATITUDE:
                    if (decimal.TryParse(fieldValue, NumberStyles.Any, CultureInfo.InvariantCulture, out var latitude))
                        item.Latitude = latitude;
                    break;

                case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.LONGITUDE:
                    if (decimal.TryParse(fieldValue, NumberStyles.Any, CultureInfo.InvariantCulture, out var longitude))
                        item.Longitude = longitude;
                    break;

                case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.MAX_CAPACITY:
                    if (int.TryParse(fieldValue, out var maxCapacity))
                        item.MaxCapacity = maxCapacity;
                    break;

                case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.ADDRESS:
                    item.Address = fieldValue;
                    break;

                case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.IS_FEATURED:
                    item.IsFeatured = string.Equals(fieldValue, "1", StringComparison.OrdinalIgnoreCase) ||
                                      string.Equals(fieldValue, "true", StringComparison.OrdinalIgnoreCase);
                    break;
            }
        }
    }
    
    /// <summary>
    /// Parses a unit item from Redis fields.
    /// يحلل عنصر وحدة من حقول Redis.
    /// </summary>
    private UnitSearchItem? ParseUnitSearchItem(RedisResult[] fields, decimal? totalPrice)
    {
        try
        {
            var item = new UnitSearchItem();
            
            for (int i = 0; i < fields.Length; i += 2)
            {
                if (i + 1 >= fields.Length) break;
                
                var fieldName = fields[i].ToString();
                var fieldValue = fields[i + 1].ToString();
                
                switch (fieldName)
                {
                    case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.UNIT_ID:
                        if (Guid.TryParse(fieldValue, out var unitId))
                            item.UnitId = unitId;
                        break;
                    
                    case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.PROPERTY_ID:
                        if (Guid.TryParse(fieldValue, out var propertyId))
                            item.PropertyId = propertyId;
                        break;
                    
                    case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.UNIT_NAME:
                        item.UnitName = fieldValue;
                        break;
                    
                    case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.PROPERTY_NAME:
                        item.PropertyName = fieldValue;
                        break;
                    
                    case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.CITY:
                        item.City = fieldValue;
                        break;
                    
                    case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.BASE_PRICE:
                        if (decimal.TryParse(fieldValue, NumberStyles.Any, CultureInfo.InvariantCulture, out var basePrice))
                            item.BasePrice = basePrice;
                        break;

                    case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.CURRENCY:
                        item.Currency = fieldValue;
                        break;

                    case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.UNIT_TYPE_NAME:
                        item.UnitTypeName = fieldValue;
                        break;

                    case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.PROPERTY_TYPE_NAME:
                        item.PropertyTypeName = fieldValue;
                        break;

                    case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.AVERAGE_RATING:
                        if (decimal.TryParse(fieldValue, NumberStyles.Any, CultureInfo.InvariantCulture, out var averageRating))
                            item.AverageRating = averageRating;
                        break;

                    case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.STAR_RATING:
                        if (int.TryParse(fieldValue, out var starRating))
                            item.StarRating = starRating;
                        break;

                    case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.LATITUDE:
                        if (decimal.TryParse(fieldValue, NumberStyles.Any, CultureInfo.InvariantCulture, out var latitude))
                            item.Latitude = latitude;
                        break;

                    case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.LONGITUDE:
                        if (decimal.TryParse(fieldValue, NumberStyles.Any, CultureInfo.InvariantCulture, out var longitude))
                            item.Longitude = longitude;
                        break;

                    case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.MAX_CAPACITY:
                        if (int.TryParse(fieldValue, out var maxCapacity))
                            item.MaxCapacity = maxCapacity;
                        break;

                    case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.ADDRESS:
                        item.Address = fieldValue;
                        break;

                    case var _ when fieldName == PeriodBasedSearchSchema.UnitFields.IS_FEATURED:
                        item.IsFeatured = string.Equals(fieldValue, "1", StringComparison.OrdinalIgnoreCase) ||
                                          string.Equals(fieldValue, "true", StringComparison.OrdinalIgnoreCase);
                        break;
                }
            }
            
            if (totalPrice.HasValue)
            {
                item.TotalPrice = totalPrice.Value;
            }
            
            return item.UnitId != Guid.Empty ? item : null;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "خطأ أثناء تحليل عنصر الوحدة");
            return null;
        }
    }
    
    #endregion
    
    #region === Filtering and Sorting / الفلترة والترتيب ===
    
    /// <summary>
    /// Applies the price filter.
    /// يطبق فلتر السعر.
    /// </summary>
    private List<UnitSearchItem> ApplyPriceFilter(
        List<UnitSearchItem> units,
        decimal? minPrice,
        decimal? maxPrice)
    {
        var filtered = units.AsEnumerable();
        
        if (minPrice.HasValue)
        {
            filtered = filtered.Where(u => (u.TotalPrice ?? u.BasePrice) >= minPrice.Value);
        }
        
        if (maxPrice.HasValue)
        {
            filtered = filtered.Where(u => (u.TotalPrice ?? u.BasePrice) <= maxPrice.Value);
        }
        
        return filtered.ToList();
    }
    
    /// <summary>
    /// Applies result sorting.
    /// يطبق ترتيب النتائج.
    /// </summary>
    private List<UnitSearchItem> ApplySorting(List<UnitSearchItem> units, string? sortBy)
    {
        if (string.IsNullOrWhiteSpace(sortBy))
            return units;
        
        return sortBy.ToLowerInvariant() switch
        {
            "price_asc" => units.OrderBy(u => u.TotalPrice ?? u.BasePrice).ToList(),
            "price_desc" => units.OrderByDescending(u => u.TotalPrice ?? u.BasePrice).ToList(),
            "rating" => units.OrderByDescending(u => u.AverageRating).ToList(),
            "name" => units.OrderBy(u => u.UnitName).ToList(),
            _ => units
        };
    }
    
    #endregion
    
    #region === Property Search / البحث عن العقارات ===
    
    /// <summary>
    /// Searches for properties with their matched units.
    /// يبحث عن العقارات مع الوحدات المطابقة لها.
    /// </summary>
    public async Task<PropertyWithUnitsSearchResult> SearchPropertiesWithUnitsAsync(
        PropertyWithUnitsSearchRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request == null)
            throw new ArgumentNullException(nameof(request));
        
        try
        {
            // Search units first. / البحث عن الوحدات أولاً.
            var unitSearchRequest = new UnitSearchRequest
            {
                SearchText = request.SearchText,
                City = request.City,
                UnitTypeId = request.UnitTypeId,
                PropertyTypeId = request.PropertyTypeId,
                CheckIn = request.CheckIn,
                CheckInLocalDate = request.CheckInLocalDate,
                CheckOut = request.CheckOut,
                CheckOutLocalDate = request.CheckOutLocalDate,
                GuestsCount = request.GuestsCount,
                AdultsCount = request.AdultsCount,
                ChildrenCount = request.ChildrenCount,
                MinPrice = request.MinPrice,
                MaxPrice = request.MaxPrice,
                PreferredCurrency = request.PreferredCurrency,
                MinRating = request.MinRating,
                MinStarRating = request.MinStarRating,
                RequiredAmenities = request.RequiredAmenities,
                RequiredServices = request.RequiredServices,
                DynamicFieldFilters = request.DynamicFieldFilters,
                Latitude = request.Latitude,
                Longitude = request.Longitude,
                RadiusKm = request.RadiusKm,
                SortBy = request.SortBy,
                PageNumber = 1,
                PageSize = request.PageSize * 10 // Fetch more units for grouping. / جلب وحدات أكثر للتجميع.
            };
            
            var unitsResult = await SearchUnitsAsync(unitSearchRequest, cancellationToken).ConfigureAwait(false);
            
            if (!unitsResult.Units.Any())
            {
                return new PropertyWithUnitsSearchResult
                {
                    Properties = new List<PropertyGroupSearchItem>(),
                    TotalPropertiesCount = 0,
                    TotalUnitsCount = 0,
                    PageNumber = request.PageNumber,
                    PageSize = request.PageSize
                };
            }
            
            // Group units by property. / تجميع الوحدات حسب العقار.
            var propertiesDict = new Dictionary<Guid, PropertyGroupSearchItem>();
            
            foreach (var unit in unitsResult.Units)
            {
                if (!propertiesDict.ContainsKey(unit.PropertyId))
                {
                    propertiesDict[unit.PropertyId] = new PropertyGroupSearchItem
                    {
                        PropertyId = unit.PropertyId,
                        PropertyName = unit.PropertyName ?? "",
                        City = unit.City ?? "",
                        PropertyTypeName = unit.PropertyTypeName ?? "",
                        StarRating = unit.StarRating,
                        AverageRating = unit.AverageRating,
                        MatchedUnits = new List<UnitSearchItem>()
                    };
                }
                
                propertiesDict[unit.PropertyId].MatchedUnits.Add(unit);
                
                // Apply MaxUnitsPerProperty when configured.
                // تطبيق MaxUnitsPerProperty عند ضبطه.
                if (request.MaxUnitsPerProperty.HasValue &&
                    propertiesDict[unit.PropertyId].MatchedUnits.Count >= request.MaxUnitsPerProperty.Value)
                {
                    continue;
                }
            }
            
            // Convert to a list. / تحويل إلى قائمة.
            var properties = propertiesDict.Values.ToList();
            
            // Calculate the price range per property.
            // حساب نطاق الأسعار لكل عقار.
            foreach (var property in properties)
            {
                var prices = property.MatchedUnits
                    .Select(u => u.TotalPrice ?? u.BasePrice)
                    .Where(p => p > 0)
                    .ToList();
                
                if (prices.Any())
                {
                    property.MinPrice = prices.Min();
                    property.MaxPrice = prices.Max();
                }
            }
            
            // Sort the grouped properties. / ترتيب العقارات المجمعة.
            if (!string.IsNullOrWhiteSpace(request.SortBy))
            {
                properties = request.SortBy.ToLowerInvariant() switch
                {
                    "price_asc" => properties.OrderBy(p => p.MinPrice).ToList(),
                    "price_desc" => properties.OrderByDescending(p => p.MaxPrice).ToList(),
                    "rating" => properties.OrderByDescending(p => p.AverageRating).ToList(),
                    "name" => properties.OrderBy(p => p.PropertyName).ToList(),
                    _ => properties
                };
            }
            
            // Paginate the grouped properties. / تطبيق التصفح على العقارات.
            var totalPropertiesCount = properties.Count;
            var offset = (request.PageNumber - 1) * request.PageSize;
            var pagedProperties = properties.Skip(offset).Take(request.PageSize).ToList();
            
            return new PropertyWithUnitsSearchResult
            {
                Properties = pagedProperties,
                TotalPropertiesCount = totalPropertiesCount,
                TotalUnitsCount = unitsResult.TotalCount,
                PageNumber = request.PageNumber,
                PageSize = request.PageSize,
                TotalPages = (int)Math.Ceiling((double)totalPropertiesCount / request.PageSize)
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء البحث عن العقارات مع الوحدات");
            
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
    
    #endregion
}
