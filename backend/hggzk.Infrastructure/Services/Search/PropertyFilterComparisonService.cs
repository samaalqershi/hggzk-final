using YemenBooking.Core.Indexing.Models;

namespace YemenBooking.Infrastructure.Services.Search;

/// <summary>
/// خدمة مقارنة معايير البحث الأصلية مع خصائص العقارات المُرجعة
/// Service for comparing original search criteria with returned property attributes
/// </summary>
public class PropertyFilterComparisonService
{
    /// <summary>
    /// مقارنة معايير الطلب الأصلي مع خصائص العقار وإرجاع الفروقات
    /// Compare original request criteria with property attributes and return mismatches
    /// </summary>
    /// <param name="property">العقار المُرجع / Returned property</param>
    /// <param name="request">الطلب الأصلي (قبل التخفيف) / Original request (before relaxation)</param>
    /// <returns>قائمة الفروقات / List of mismatches</returns>
    public List<PropertyFilterMismatch> ComparePropertyWithOriginalRequest(
        PropertyGroupSearchItem property,
        UnitSearchRequest request)
    {
        var mismatches = new List<PropertyFilterMismatch>();
        
        Console.WriteLine($"🔍 [ComparisonService] Comparing property '{property.PropertyName}'");
        Console.WriteLine($"   - Request GuestsCount: {request.GuestsCount}");
        Console.WriteLine($"   - Matched Units: {property.MatchedUnits.Count()}");
        
        // 1. مقارنة عدد الضيوف
        if (request.GuestsCount.HasValue)
        {
            var guestMismatch = CompareGuestsCount(property, request.GuestsCount.Value);
            if (guestMismatch != null)
            {
                Console.WriteLine($"   ✓ Guest count mismatch found");
                mismatches.Add(guestMismatch);
            }
        }
        
        // 2. مقارنة السعر (إذا كان خارج النطاق المطلوب)
        if (request.MinPrice.HasValue || request.MaxPrice.HasValue)
        {
            var priceMismatch = ComparePriceRange(
                property, 
                request.MinPrice, 
                request.MaxPrice,
                request.PreferredCurrency ?? "YER");
            
            if (priceMismatch != null)
            {
                Console.WriteLine($"   ✓ Price mismatch found");
                mismatches.Add(priceMismatch);
            }
        }
        
        Console.WriteLine($"   → Total mismatches: {mismatches.Count}");
        return mismatches;
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // دوال المقارنة التفصيلية
    // Detailed comparison methods
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// <summary>
    /// مقارنة عدد الضيوف المطلوب مع سعة الوحدات المطابقة
    /// Compare requested guest count with matched units capacity
    /// </summary>
    private PropertyFilterMismatch? CompareGuestsCount(
        PropertyGroupSearchItem property, 
        int requestedGuests)
    {
        // الحصول على أكبر سعة من الوحدات المطابقة
        var maxCapacity = property.MatchedUnits.Max(u => u.MaxCapacity);
        
        if (maxCapacity < requestedGuests)
        {
            var diff = requestedGuests - maxCapacity;
            
            return new PropertyFilterMismatch
            {
                FilterType = "GuestsCount",
                FilterDisplayName = "السعة",
                RequestedValue = $"{requestedGuests} ضيوف",
                ActualValue = $"{maxCapacity} ضيوف",
                DisplayMessage = $"يستوعب {maxCapacity} ضيوف (طلبت {requestedGuests})",
                Severity = diff == 1 ? MismatchSeverity.Minor : MismatchSeverity.Moderate
            };
        }
        
        return null;
    }
    
    /// <summary>
    /// مقارنة نطاق السعر
    /// Compare price range
    /// </summary>
    private PropertyFilterMismatch? ComparePriceRange(
        PropertyGroupSearchItem property,
        decimal? minPrice,
        decimal? maxPrice,
        string currency)
    {
        // التحقق إذا كان سعر العقار خارج النطاق المطلوب
        var propertyMin = property.MinPrice;
        var propertyMax = property.MaxPrice;
        
        var isOutOfRange = false;
        string reason = "";
        
        if (minPrice.HasValue && propertyMax < minPrice.Value)
        {
            isOutOfRange = true;
            reason = "أقل من الحد الأدنى";
        }
        else if (maxPrice.HasValue && propertyMin > maxPrice.Value)
        {
            isOutOfRange = true;
            reason = "أعلى من الحد الأقصى";
        }
        
        if (isOutOfRange)
        {
            return new PropertyFilterMismatch
            {
                FilterType = "Price",
                FilterDisplayName = "السعر",
                RequestedValue = FormatPriceRange(minPrice, maxPrice, currency),
                ActualValue = FormatPriceRange(propertyMin, propertyMax, currency),
                DisplayMessage = $"السعر {reason}",
                Severity = MismatchSeverity.Moderate
            };
        }
        
        return null;
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // دوال مساعدة
    // Helper methods
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// <summary>
    /// توليد رسالة العرض
    /// Generate display message
    /// </summary>
    private string GenerateDisplayMessage(
        string displayName, 
        string requested, 
        string actual)
    {
        // إذا كانت القيمة المطلوبة "نعم" والفعلية "لا"
        if (requested == "نعم" && actual == "لا")
            return $"بدون {displayName}";
        
        // إذا كانت القيمة المطلوبة "لا" والفعلية "نعم"
        if (requested == "لا" && actual == "نعم")
            return $"يحتوي على {displayName}";
        
        // باقي الحالات
        return $"{displayName}: {actual} (طلبت {requested})";
    }
    
    /// <summary>
    /// تنسيق نطاق السعر
    /// Format price range
    /// </summary>
    private string FormatPriceRange(decimal? min, decimal? max, string currency)
    {
        if (min.HasValue && max.HasValue)
            return $"{min:N0}-{max:N0} {currency}";
        if (min.HasValue)
            return $"من {min:N0} {currency}";
        if (max.HasValue)
            return $"حتى {max:N0} {currency}";
        return "غير محدد";
    }
}
