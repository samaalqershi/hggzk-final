namespace YemenBooking.Application.Common.Models;

/// <summary>
/// معلومات الموقع الجغرافي العامة المستخدمة في خدمات التحديد الجغرافي.
/// Represents general geolocation details returned by geolocation services.
/// </summary>
public class GeolocationInfo
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
    /// إزاحة المنطقة الزمنية بالدقائق.
    /// Timezone offset in minutes.
    /// </summary>
    public int? TimeZoneOffset { get; set; }

    /// <summary>
    /// خط العرض.
    /// Latitude.
    /// </summary>
    public double? Latitude { get; set; }

    /// <summary>
    /// خط الطول.
    /// Longitude.
    /// </summary>
    public double? Longitude { get; set; }

    /// <summary>
    /// اسم الإقليم أو المحافظة.
    /// Region or state name.
    /// </summary>
    public string Region { get; set; } = string.Empty;

    /// <summary>
    /// مصدر بيانات الموقع.
    /// Source of the location data.
    /// </summary>
    public string Source { get; set; } = string.Empty;
}
