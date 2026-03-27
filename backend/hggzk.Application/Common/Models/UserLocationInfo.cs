namespace YemenBooking.Application.Common.Models;

/// <summary>
/// معلومات الموقع الجغرافي والمنطقة الزمنية للمستخدم الحالي.
/// Represents geolocation and timezone details for the current user.
/// </summary>
public class UserLocationInfo
{
    /// <summary>
    /// اسم الدولة.
    /// Country name.
    /// </summary>
    public string Country { get; set; } = string.Empty;

    /// <summary>
    /// رمز الدولة القياسي.
    /// ISO country code.
    /// </summary>
    public string CountryCode { get; set; } = string.Empty;

    /// <summary>
    /// اسم المدينة.
    /// City name.
    /// </summary>
    public string City { get; set; } = string.Empty;

    /// <summary>
    /// معرف المنطقة الزمنية.
    /// Timezone identifier.
    /// </summary>
    public string TimeZoneId { get; set; } = string.Empty;

    /// <summary>
    /// الإزاحة الزمنية الحالية عن UTC.
    /// Current UTC offset.
    /// </summary>
    public TimeSpan UtcOffset { get; set; }

    /// <summary>
    /// الاسم المقروء للمنطقة الزمنية.
    /// Human-readable timezone name.
    /// </summary>
    public string TimeZoneName { get; set; } = string.Empty;

    /// <summary>
    /// يحدد ما إذا كان التوقيت الصيفي مفعلاً.
    /// Indicates whether daylight saving is currently active.
    /// </summary>
    public bool IsDaylightSaving { get; set; }

    /// <summary>
    /// مصدر بيانات الموقع.
    /// Source of the location data.
    /// </summary>
    public string Source { get; set; } = string.Empty;
}
