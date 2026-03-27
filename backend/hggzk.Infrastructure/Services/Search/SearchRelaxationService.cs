using System.Text.Json;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.SearchAndFilters.Services;
using YemenBooking.Core.Indexing.Enums;
using YemenBooking.Core.Indexing.Models;
using YemenBooking.Core.Indexing.Options;

namespace YemenBooking.Infrastructure.Services.Search;

/// <summary>
/// يمثل خدمة تخفيف معايير البحث التدريجية.
/// Represents the progressive search relaxation service.
/// 
/// يخفف معايير البحث بشكل تدريجي عندما لا توجد نتائج مطابقة كافية.
/// Relaxes search criteria progressively when no sufficient matches are found.
/// </summary>
public class SearchRelaxationService : ISearchRelaxationService
{
    private readonly ILogger<SearchRelaxationService> _logger;

    /// <summary>
    /// ينشئ مثيلًا جديدًا من خدمة تخفيف البحث.
    /// Creates a new instance of the search relaxation service.
    /// </summary>
    /// <param name="logger">The logger used for diagnostics. المسجل المستخدم للتشخيص.</param>
    public SearchRelaxationService(ILogger<SearchRelaxationService> logger)
    {
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    #region === Main Methods ===

    /// <summary>
    /// Applies relaxation to the provided search criteria.
    /// يطبّق التخفيف على معايير البحث المقدمة.
    /// </summary>
    /// <param name="originalRequest">The original request. الطلب الأصلي.</param>
    /// <param name="level">The relaxation level. مستوى التخفيف.</param>
    /// <param name="options">The fallback search options. خيارات البحث البديلة.</param>
    /// <param name="relaxedFilters">Outputs the filters that were relaxed. يعيد الفلاتر التي تم تخفيفها.</param>
    /// <returns>The relaxed request. الطلب بعد التخفيف.</returns>
    public UnitSearchRequest RelaxSearchCriteria(
        UnitSearchRequest originalRequest,
        SearchRelaxationLevel level,
        FallbackSearchOptions options,
        out List<string> relaxedFilters)
    {
        relaxedFilters = new List<string>();

        // نسخ الطلب الأصلي. / Clone the original request.
        var relaxedRequest = CloneRequest(originalRequest);

        // تطبيق التخفيف حسب المستوى. / Apply relaxation based on the selected level.
        switch (level)
        {
            case SearchRelaxationLevel.MinorRelaxation:
                if (options.EnableMinorRelaxation)
                    ApplyMinorRelaxation(relaxedRequest, options, relaxedFilters);
                break;

            case SearchRelaxationLevel.ModerateRelaxation:
                if (options.EnableModerateRelaxation)
                    ApplyModerateRelaxation(relaxedRequest, options, relaxedFilters);
                break;

            case SearchRelaxationLevel.MajorRelaxation:
                if (options.EnableMajorRelaxation)
                    ApplyMajorRelaxation(relaxedRequest, options, relaxedFilters);
                break;

            case SearchRelaxationLevel.AlternativeSuggestions:
                // Validation: ensure minimum criteria exist before applying an alternative strategy.
                // التحقق من وجود معايير أساسية قبل تطبيق استراتيجية بديلة. / Ensure minimum criteria exist before applying the alternative strategy.
                if (!HasMinimumCriteria(originalRequest))
                {
                    _logger.LogWarning(
                        "⚠️ No sufficient criteria for Alternative relaxation - returning the original request.");
                    return originalRequest; // بدون تعديل / No change.
                }
                
                if (options.EnableAlternativeSuggestions)
                    ApplyAlternativeStrategy(relaxedRequest, originalRequest, relaxedFilters);
                break;

            default:
                // Exact - لا تعديلات. / Exact - no changes.
                break;
        }

        if (options.LogRelaxationSteps && relaxedFilters.Any())
        {
            _logger.LogInformation(
                "📊 Relaxed {Count} filters at level {Level}: {Filters}",
                relaxedFilters.Count, level, string.Join(", ", relaxedFilters));
        }

        return relaxedRequest;
    }

    /// <summary>
    /// Extracts search criteria from the request.
    /// يستخرج معايير البحث من الطلب.
    /// </summary>
    /// <param name="request">The search request. طلب البحث.</param>
    /// <returns>The extracted criteria. المعايير المستخرجة.</returns>
    public Dictionary<string, object> ExtractCriteria(UnitSearchRequest request)
    {
        var criteria = new Dictionary<string, object>();

        if (!string.IsNullOrWhiteSpace(request.SearchText))
            criteria["نص البحث"] = request.SearchText;

        if (!string.IsNullOrWhiteSpace(request.City))
            criteria["المدينة"] = request.City;

        if (request.UnitTypeId.HasValue)
            criteria["نوع الوحدة"] = request.UnitTypeId.Value;

        if (request.PropertyTypeId.HasValue)
            criteria["نوع العقار"] = request.PropertyTypeId.Value;

        if (request.CheckIn.HasValue)
            criteria["تاريخ الوصول"] = request.CheckIn.Value.ToString("yyyy-MM-dd");

        if (request.CheckOut.HasValue)
            criteria["تاريخ المغادرة"] = request.CheckOut.Value.ToString("yyyy-MM-dd");

        if (request.MinPrice.HasValue)
            criteria["الحد الأدنى للسعر"] = $"{request.MinPrice:N0} {request.PreferredCurrency ?? "YER"}";

        if (request.MaxPrice.HasValue)
            criteria["الحد الأقصى للسعر"] = $"{request.MaxPrice:N0} {request.PreferredCurrency ?? "YER"}";

        if (request.GuestsCount.HasValue)
            criteria["عدد الضيوف"] = request.GuestsCount.Value;

        if (request.MinRating.HasValue)
            criteria["الحد الأدنى للتقييم"] = $"{request.MinRating:F1} نجمة";

        if (request.MinStarRating.HasValue)
            criteria["تصنيف النجوم"] = $"{request.MinStarRating} نجوم";

        if (request.RequiredAmenities?.Any() == true)
            criteria["المرافق المطلوبة"] = $"{request.RequiredAmenities.Count} مرفق";

        if (request.RadiusKm.HasValue && request.Latitude.HasValue && request.Longitude.HasValue)
            criteria["النطاق الجغرافي"] = $"{request.RadiusKm:F1} كم";

        if (request.DynamicFieldFilters?.Any() == true)
            criteria["حقول إضافية"] = $"{request.DynamicFieldFilters.Count} حقل";

        return criteria;
    }

    /// <summary>
    /// Creates a deep clone of the search request using JSON serialization.
    /// ينشئ نسخة عميقة من طلب البحث باستخدام JSON.
    /// 
    /// ✅ يدعم الأنواع المشتقة (PropertyWithUnitsSearchRequest)
    /// ✅ Supports derived types (PropertyWithUnitsSearchRequest)
    /// </summary>
    /// <param name="original">The original request. الطلب الأصلي.</param>
    /// <returns>The cloned request when possible, otherwise the original. الطلب المستنسخ عند الإمكان، وإلا الطلب الأصلي.</returns>
    public UnitSearchRequest CloneRequest(UnitSearchRequest original)
    {
        try
        {
            // ✅ Use the runtime type instead of the base type only.
            // استخدام النوع الفعلي بدلاً من النوع الأساسي فقط.
            var originalType = original.GetType();
            var json = JsonSerializer.Serialize(original, originalType);
            var clonedRequest = JsonSerializer.Deserialize(json, originalType);

            if (clonedRequest is not UnitSearchRequest typedClone)
            {
                throw new InvalidOperationException("Failed to clone request");
            }

            return typedClone;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "❌ فشل نسخ طلب البحث، إرجاع الأصلي");
            return original;
        }
    }

    #endregion

    #region === Minor Relaxation (15-20%) ===

    private void ApplyMinorRelaxation(
        UnitSearchRequest request,
        FallbackSearchOptions options,
        List<string> relaxedFilters)
    {
        // 1. Expand price range (+/- 15%).
        // 1. توسيع نطاق السعر (+/- 15%). / 1. Expand the price range (+/- 15%).
        RelaxPrice(request, options.PriceRelaxationMinor, relaxedFilters);

        // 2. Reduce required amenities by half.
        // 2. تقليل المرافق المطلوبة إلى النصف. / 2. Reduce required amenities by half.
        RelaxAmenities(request, options.AmenitiesRetentionRatio, relaxedFilters);

        // 3. Relax the rating filter.
        // 3. تخفيف فلتر التقييم. / 3. Relax the rating filter.
        RelaxRating(request, options.RatingReduction, relaxedFilters);

        // 4. Remove non-critical dynamic fields.
        // 4. إزالة الحقول الديناميكية غير الحرجة. / 4. Remove non-critical dynamic fields.
        RelaxDynamicFields(request, keepCriticalOnly: true, relaxedFilters);
    }

    #endregion

    #region === Moderate Relaxation (30-40%) ===

    private void ApplyModerateRelaxation(
        UnitSearchRequest request,
        FallbackSearchOptions options,
        List<string> relaxedFilters)
    {
        // Apply minor relaxation first.
        // تطبيق التخفيف البسيط أولاً. / Apply minor relaxation first.
        ApplyMinorRelaxation(request, options, relaxedFilters);

        // 5. Expand price range further (+/- 30%).
        // 5. توسيع نطاق السعر أكثر (+/- 30%). / 5. Expand the price range further (+/- 30%).
        RelaxPrice(request, options.PriceRelaxationModerate, relaxedFilters, forceUpdate: true);

        // 6. Expand the geographic radius.
        // 6. توسيع النطاق الجغرافي. / 6. Expand the geographic radius.
        RelaxGeographicRadius(request, options.RadiusMultiplierModerate, relaxedFilters);

        // 7. Relax the guest capacity requirement.
        // 7. تخفيف شرط السعة. / 7. Relax the guest capacity requirement.
        RelaxGuestsCount(request, options.GuestsCountReduction, relaxedFilters);

        // 8. Remove the star rating filter.
        // 8. إلغاء فلتر تصنيف النجوم. / 8. Remove the star rating filter.
        if (request.MinStarRating.HasValue)
        {
            request.MinStarRating = null;
            relaxedFilters.Add("إلغاء شرط تصنيف النجوم");
        }
    }

    #endregion

    #region === Major Relaxation (50%+) ===

    private void ApplyMajorRelaxation(
        UnitSearchRequest request,
        FallbackSearchOptions options,
        List<string> relaxedFilters)
    {
        // Apply moderate relaxation first.
        // تطبيق التخفيف المتوسط أولاً. / Apply moderate relaxation first.
        ApplyModerateRelaxation(request, options, relaxedFilters);

        // 10. Expand price range significantly (+/- 50%).
        // 10. توسيع نطاق السعر بشكل كبير (+/- 50%). / 10. Expand the price range significantly (+/- 50%).
        RelaxPrice(request, options.PriceRelaxationMajor, relaxedFilters, forceUpdate: true);

        // 11. Expand the geographic radius significantly.
        // 11. توسيع كبير في النطاق الجغرافي. / 11. Expand the geographic radius significantly.
        RelaxGeographicRadius(request, options.RadiusMultiplierMajor, relaxedFilters, forceUpdate: true);

        // 12. Add date flexibility (±3 days).
        // 12. مرونة في التواريخ (±3 أيام). / 12. Add date flexibility (±3 days).
        RelaxDates(request, options.DateFlexibilityDays, relaxedFilters);

        // 13. Remove all amenities.
        // 13. إلغاء جميع المرافق. / 13. Remove all amenities.
        if (request.RequiredAmenities?.Any() == true)
        {
            request.RequiredAmenities = null;
            request.MinimumAmenityMatches = null;
            relaxedFilters.Add("إلغاء جميع شروط المرافق");
        }

        // 14. Remove all dynamic fields.
        // 14. إلغاء جميع الحقول الديناميكية. / 14. Remove all dynamic fields.
        if (request.DynamicFieldFilters?.Any() == true)
        {
            request.DynamicFieldFilters = null;
            relaxedFilters.Add("إلغاء جميع الحقول الإضافية");
        }
    }

    #endregion

    #region === Alternative Strategy ===

    private void ApplyAlternativeStrategy(
        UnitSearchRequest request,
        UnitSearchRequest original,
        List<string> relaxedFilters)
    {
        // ✅ Keep the criteria that should never be removed:
        // ✅ الاحتفاظ بالمعايير الأساسية التي لا يجب إلغاؤها أبداً. / ✅ Keep the criteria that should never be removed.
        // - المدينة (City). / - City.
        // - نوع العقار (PropertyTypeId). / - Property type (PropertyTypeId).
        // - نوع الوحدة (UnitTypeId). / - Unit type (UnitTypeId).
        // - التواريخ (CheckIn, CheckOut). / - Dates (CheckIn, CheckOut).
        
        var city = original.City;
        var propertyTypeId = original.PropertyTypeId;
        var unitTypeId = original.UnitTypeId;
        var checkIn = original.CheckIn;
        var checkOut = original.CheckOut;

        // Copy the core properties.
        // نسخ الخصائص الأساسية. / Copy the core properties.
        request.City = city;
        request.PropertyTypeId = propertyTypeId;  // ✅ Keep the property type.
        request.UnitTypeId = unitTypeId;          // ✅ Keep the unit type.
        request.CheckIn = checkIn;
        request.CheckOut = checkOut;
        request.SortBy = "relevance";

        // Validation: ensure core criteria still exist after copying.
        // التحقق من وجود معايير أساسية بعد النسخ. / Ensure core criteria still exist after copying.
        if (string.IsNullOrWhiteSpace(request.City) && 
            !request.PropertyTypeId.HasValue && 
            !request.UnitTypeId.HasValue)
        {
            // Apply fallback constraints to reduce result volume.
            // فرض معايير افتراضية للحد من النتائج. / Apply fallback constraints to reduce result volume.
            request.FeaturedOnly = true;
            request.PageSize = Math.Min(request.PageSize, 20);
            
            relaxedFilters.Add("عرض العقارات المميزة فقط (لا توجد معايير بحث محددة)");
            
            _logger.LogWarning(
                "⚠️ Alternative strategy without core criteria - forcing FeaturedOnly=true and PageSize=20.");
        }

        // Remove only the secondary criteria.
        // إلغاء باقي المعايير الثانوية فقط. / Remove only the secondary criteria.
        request.SearchText = null;
        request.MinPrice = null;
        request.MaxPrice = null;
        request.MinRating = null;
        request.MinStarRating = null;
        request.GuestsCount = null;
        request.RequiredAmenities = null;
        request.RequiredServices = null;
        request.DynamicFieldFilters = null;
        request.Latitude = null;
        request.Longitude = null;
        request.RadiusKm = null;

        var keptFilters = new List<string>();
        if (!string.IsNullOrWhiteSpace(city)) keptFilters.Add("المدينة");
        if (checkIn.HasValue || checkOut.HasValue) keptFilters.Add("التواريخ");
        if (propertyTypeId.HasValue) keptFilters.Add("نوع العقار");
        if (unitTypeId.HasValue) keptFilters.Add("نوع الوحدة");
        
        relaxedFilters.Add($"بحث بديل: الاحتفاظ بـ {string.Join("، ", keptFilters)} فقط");
    }

    #endregion

    #region === Helper Methods ===

    private void RelaxPrice(
        UnitSearchRequest request,
        decimal relaxationPercentage,
        List<string> relaxedFilters,
        bool forceUpdate = false)
    {
        var hasChanges = false;

        if (request.MinPrice.HasValue)
        {
            var newMin = request.MinPrice.Value * (1 - relaxationPercentage);
            if (forceUpdate || newMin != request.MinPrice.Value)
            {
                request.MinPrice = newMin;
                hasChanges = true;
            }
        }

        if (request.MaxPrice.HasValue)
        {
            var newMax = request.MaxPrice.Value * (1 + relaxationPercentage);
            if (forceUpdate || newMax != request.MaxPrice.Value)
            {
                request.MaxPrice = newMax;
                hasChanges = true;
            }
        }

        if (hasChanges)
        {
            var percentage = (int)(relaxationPercentage * 100);
            relaxedFilters.Add($"توسيع نطاق السعر {percentage}%");
        }
    }

    private void RelaxAmenities(
        UnitSearchRequest request,
        decimal retentionRatio,
        List<string> relaxedFilters)
    {
        if (request.RequiredAmenities?.Any() != true)
            return;

        var originalCount = request.RequiredAmenities.Count;
        var keepCount = Math.Max(1, (int)(originalCount * retentionRatio));

        if (keepCount < originalCount)
        {
            request.MinimumAmenityMatches = keepCount;
            relaxedFilters.Add($"الاكتفاء بمطابقة {keepCount} من أصل {originalCount} مرافق");
        }
    }

    private void RelaxRating(
        UnitSearchRequest request,
        decimal reduction,
        List<string> relaxedFilters)
    {
        if (request.MinRating.HasValue && request.MinRating > 0)
        {
            var newRating = Math.Max(0, request.MinRating.Value - reduction);
            if (newRating != request.MinRating.Value)
            {
                request.MinRating = newRating;
                relaxedFilters.Add($"تخفيض الحد الأدنى للتقييم إلى {newRating:F1}");
            }
        }
    }

    private void RelaxDynamicFields(
        UnitSearchRequest request,
        bool keepCriticalOnly,
        List<string> relaxedFilters)
    {
        if (request.DynamicFieldFilters?.Any() != true)
            return;

        var criticalFields = new[] { "room_count", "bedrooms", "bathroom_count" };
        var originalCount = request.DynamicFieldFilters.Count;

        if (keepCriticalOnly)
        {
            var filtered = request.DynamicFieldFilters
                .Where(f => criticalFields.Contains(f.Key.ToLower()))
                .ToDictionary(f => f.Key, f => f.Value);

            if (filtered.Count < originalCount)
            {
                request.DynamicFieldFilters = filtered.Any() ? filtered : null;
                relaxedFilters.Add($"إزالة {originalCount - filtered.Count} حقل إضافي");
            }
        }
        else
        {
            request.DynamicFieldFilters = null;
            relaxedFilters.Add($"إلغاء جميع الحقول الإضافية ({originalCount})");
        }
    }

    private void RelaxGeographicRadius(
        UnitSearchRequest request,
        double multiplier,
        List<string> relaxedFilters,
        bool forceUpdate = false)
    {
        if (request.RadiusKm.HasValue && request.RadiusKm.Value > 0)
        {
            var newRadius = request.RadiusKm.Value * multiplier;
            if (forceUpdate || newRadius != request.RadiusKm.Value)
            {
                request.RadiusKm = newRadius;
                relaxedFilters.Add($"توسيع نطاق البحث إلى {newRadius:F1} كم");
            }
        }
    }

    private void RelaxGuestsCount(
        UnitSearchRequest request,
        int reduction,
        List<string> relaxedFilters)
    {
        if (request.GuestsCount.HasValue && request.GuestsCount > reduction)
        {
            var newCount = request.GuestsCount.Value - reduction;
            request.GuestsCount = newCount;
            relaxedFilters.Add($"تقليل عدد الضيوف إلى {newCount}");
        }
    }

    private void RelaxDates(
        UnitSearchRequest request,
        int flexibilityDays,
        List<string> relaxedFilters)
    {
        if (request.CheckIn.HasValue && request.CheckOut.HasValue)
        {
            // We do not change dates here; only record a relaxation note.
            // لا نغير التواريخ فعلياً، لكن نضيف ملاحظة. / We do not change dates here; only record a note.
            relaxedFilters.Add($"مرونة في التواريخ ±{flexibilityDays} أيام");
            // Additional logic can be added here later.
            // يمكن إضافة منطق إضافي هنا لاحقاً. / Additional logic can be added here later.
        }
    }

    private bool HasMinimumCriteria(UnitSearchRequest request)
    {
        return !string.IsNullOrWhiteSpace(request.City) ||
               request.PropertyTypeId.HasValue ||
               request.UnitTypeId.HasValue ||
               (request.CheckIn.HasValue && request.CheckOut.HasValue);
    }

    #endregion
}
