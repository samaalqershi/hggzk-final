using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Contracts.Services.Location;

/// <summary>
/// واجهة خدمة تحديد الموقع الجغرافي والمنطقة الزمنية
/// Geolocation and timezone service interface
/// </summary>
public interface IGeolocationService
{
    /// <summary>
    /// الحصول على معلومات المنطقة الزمنية من الـ Headers أو IP
    /// Get timezone info from headers or IP fallback
    /// </summary>
    /// <param name="ipAddress">عنوان IP اختياري. Optional IP address.</param>
    /// <returns>معلومات الموقع الجغرافي. Geolocation details.</returns>
    Task<GeolocationInfo> GetLocationInfoAsync(string? ipAddress = null);

    /// <summary>
    /// الحصول على المنطقة الزمنية من HttpContext Headers
    /// Get timezone from HttpContext headers
    /// </summary>
    /// <returns>معرف المنطقة الزمنية أو قيمة فارغة. Timezone identifier or null.</returns>
    string? GetTimezoneFromHeaders();

    /// <summary>
    /// الحصول على offset المنطقة الزمنية من Headers
    /// Get timezone offset from headers
    /// </summary>
    int? GetTimezoneOffsetFromHeaders();

    /// <summary>
    /// تحويل التوقيت من UTC إلى توقيت المستخدم
    /// Convert from UTC to user timezone
    /// </summary>
    /// <param name="utcDateTime">القيمة بتوقيت UTC. UTC date and time.</param>
    /// <param name="timezoneId">معرف المنطقة الزمنية الاختياري. Optional timezone identifier.</param>
    /// <returns>التوقيت بعد تحويله للمنطقة المطلوبة. Converted local date and time.</returns>
    DateTime ConvertFromUtc(DateTime utcDateTime, string? timezoneId = null);

    /// <summary>
    /// تحويل التوقيت من توقيت المستخدم إلى UTC
    /// Convert from user timezone to UTC
    /// </summary>
    /// <param name="localDateTime">التوقيت المحلي. Local date and time.</param>
    /// <param name="timezoneId">معرف المنطقة الزمنية الاختياري. Optional timezone identifier.</param>
    /// <returns>التوقيت بعد تحويله إلى UTC. UTC date and time.</returns>
    DateTime ConvertToUtc(DateTime localDateTime, string? timezoneId = null);

}
