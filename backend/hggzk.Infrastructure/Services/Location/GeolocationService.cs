using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using System.Net.Http;
using Microsoft.Extensions.Options;
using YemenBooking.Infrastructure.Settings;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using TimeZoneConverter;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Infrastructure.Services.Location
{
    /// <summary>
    /// Provides geolocation and timezone resolution helpers.
    /// يوفّر أدوات مساعدة لتحديد الموقع الجغرافي والمنطقة الزمنية.
    /// </summary>
    public class GeolocationService : IGeolocationService
    {
        private readonly ILogger<GeolocationService> _logger;
        private readonly HttpClient _httpClient;
        private readonly GeolocationSettings _settings;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IMemoryCache _cache;
        private readonly IConfiguration _configuration;

        /// <summary>
        /// Initializes a new instance of GeolocationService with the required dependencies.
        /// يهيئ مثيلاً جديدًا من GeolocationService باستخدام الاعتماديات المطلوبة.
        /// </summary>
        public GeolocationService(
            IHttpContextAccessor httpContextAccessor,
            IMemoryCache cache,
            IConfiguration configuration,
            ILogger<GeolocationService> logger,
            HttpClient httpClient,
            IOptions<GeolocationSettings> options)
        {
            _httpContextAccessor = httpContextAccessor;
            _cache = cache;
            _configuration = configuration;
            _logger = logger;
            _httpClient = httpClient;
            _settings = options.Value;
        }

        /// <summary>
        /// Reads the user time zone from request headers.
        /// يقرأ المنطقة الزمنية للمستخدم من رؤوس الطلب.
        /// </summary>
        public string GetTimezoneFromHeaders()
        {
            var context = _httpContextAccessor.HttpContext;
            if (context == null) return null;

            // محاولة الحصول على timezone من headers مختلفة
            var timezone = context.Request.Headers["X-TimeZone"].FirstOrDefault() ??
                          context.Request.Headers["X-User-TimeZone"].FirstOrDefault() ??
                          context.Request.Headers["TimeZone"].FirstOrDefault();

            if (!string.IsNullOrEmpty(timezone))
            {
                _logger.LogDebug("Timezone from headers: {Timezone}", timezone);
                return timezone;
            }

            // محاولة استنتاج timezone من offset
            var offset = GetTimezoneOffsetFromHeaders();
            if (offset.HasValue)
            {
                // محاولة إيجاد timezone مطابق للـ offset
                var hours = offset.Value / 60;
                var minutes = Math.Abs(offset.Value % 60);
                var offsetString = $"{(offset.Value >= 0 ? "+" : "-")}{Math.Abs(hours):D2}:{minutes:D2}";
                
                _logger.LogDebug("Timezone offset from headers: {Offset} minutes", offset.Value);
                return $"UTC{offsetString}";
            }

            return null;
        }

        /// <summary>
        /// Reads the time zone offset from request headers.
        /// يقرأ إزاحة المنطقة الزمنية من رؤوس الطلب.
        /// </summary>
        public int? GetTimezoneOffsetFromHeaders()
        {
            var context = _httpContextAccessor.HttpContext;
            if (context == null) return null;

            var offsetHeader = context.Request.Headers["X-TimeZone-Offset"].FirstOrDefault() ??
                              context.Request.Headers["X-User-TimeZone-Offset"].FirstOrDefault();

            if (!string.IsNullOrEmpty(offsetHeader) && int.TryParse(offsetHeader, out var offset))
            {
                return offset;
            }

            return null;
        }

        private string GetClientIpAddress()
        {
            var httpContext = _httpContextAccessor.HttpContext;
            if (httpContext == null) return string.Empty;

            // تحقق من headers مختلفة للحصول على IP الحقيقي
            string ip = httpContext.Request.Headers["CF-Connecting-IP"].FirstOrDefault() ?? // Cloudflare
                       httpContext.Request.Headers["X-Forwarded-For"].FirstOrDefault()?.Split(',')[0].Trim() ??
                       httpContext.Request.Headers["X-Real-IP"].FirstOrDefault() ??
                       httpContext.Connection.RemoteIpAddress?.ToString() ??
                       "127.0.0.1";

            // إزالة IPv6 prefix إذا وجد
            if (ip.Contains("::ffff:"))
                ip = ip.Replace("::ffff:", "");

            return ip;
        }

        /// <summary>
        /// Resolves geolocation details for the supplied IP address.
        /// يحدد بيانات الموقع الجغرافي لعنوان IP المقدم.
        /// </summary>
        public async Task<GeolocationInfo> GetLocationInfoAsync(string? ipAddress = null)
        {
            // 1. محاولة الحصول من Headers أولاً
            var timezoneFromHeaders = GetTimezoneFromHeaders();
            var offsetFromHeaders = GetTimezoneOffsetFromHeaders();

            if (!string.IsNullOrEmpty(timezoneFromHeaders))
            {
                _logger.LogInformation("Using timezone from headers: {Timezone}", timezoneFromHeaders);
                
                // إنشاء GeolocationInfo من headers
                var headerInfo = new GeolocationInfo
                {
                    TimeZoneId = timezoneFromHeaders,
                    TimeZoneOffset = offsetFromHeaders,
                    Source = "Headers"
                };

                // محاولة استنتاج الدولة من timezone
                EnrichLocationFromTimezone(headerInfo);
                
                return headerInfo;
            }

            // 2. إذا لم توجد headers، استخدم IP
            if (string.IsNullOrEmpty(ipAddress))
            {
                ipAddress = GetClientIpAddress();
            }

            // التحقق من الـ cache
            var cacheKey = $"geo_{ipAddress}";
            if (_cache.TryGetValue<GeolocationInfo>(cacheKey, out var cachedInfo))
            {
                _logger.LogDebug("Returning cached location for IP: {IP}", ipAddress);
                return cachedInfo;
            }

            try
            {
                // استخدام خدمات IP للحصول على الموقع
                var info = await GetFromIpApiAsync(ipAddress) ??
                          await GetFromIpGeolocationAsync(ipAddress) ??
                          GetDefaultLocationInfo();

                info.Source = info.Source ?? "IP";

                // حفظ في الـ cache لمدة 24 ساعة
                _cache.Set(cacheKey, info, TimeSpan.FromHours(24));

                return info;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting geolocation for IP: {IpAddress}", ipAddress);
                return GetDefaultLocationInfo();
            }
        }

        /// <summary>
        /// Converts a UTC time to the target time zone.
        /// يحوّل وقت UTC إلى المنطقة الزمنية المستهدفة.
        /// </summary>
        public DateTime ConvertFromUtc(DateTime utcDateTime, string? timezoneId = null)
        {
            if (utcDateTime.Kind != DateTimeKind.Utc)
            {
                utcDateTime = DateTime.SpecifyKind(utcDateTime, DateTimeKind.Utc);
            }

            // استخدام timezone المحدد أو محاولة الحصول عليه من headers
            timezoneId = timezoneId ?? GetTimezoneFromHeaders();

            if (string.IsNullOrEmpty(timezoneId))
            {
                // محاولة استخدام offset
                var offset = GetTimezoneOffsetFromHeaders();
                if (offset.HasValue)
                {
                    return utcDateTime.AddMinutes(-offset.Value); // عكس الـ offset
                }

                // Default to Yemen time
                timezoneId = "Asia/Aden";
            }

            try
            {
                // التعامل مع UTC offset format
                if (timezoneId.StartsWith("UTC"))
                {
                    var offsetPart = timezoneId.Substring(3);
                    if (TimeSpan.TryParse(offsetPart, out var timeOffset))
                    {
                        return utcDateTime.Add(timeOffset);
                    }
                }

                // استخدام TimeZoneConverter للتعامل مع IANA و Windows time zones
                var timeZone = TZConvert.GetTimeZoneInfo(timezoneId);
                return TimeZoneInfo.ConvertTimeFromUtc(utcDateTime, timeZone);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error converting from UTC. TimeZone: {TimeZone}", timezoneId);
                // Fallback to Yemen time
                return utcDateTime.AddHours(3);
            }
        }

        /// <summary>
        /// Converts a local time to UTC.
        /// يحوّل الوقت المحلي إلى UTC.
        /// </summary>
        public DateTime ConvertToUtc(DateTime localDateTime, string? timezoneId = null)
        {
            if (localDateTime.Kind == DateTimeKind.Utc)
                return localDateTime;

            // استخدام timezone المحدد أو محاولة الحصول عليه من headers
            timezoneId = timezoneId ?? GetTimezoneFromHeaders();

            if (string.IsNullOrEmpty(timezoneId))
            {
                // محاولة استخدام offset
                var offset = GetTimezoneOffsetFromHeaders();
                if (offset.HasValue)
                {
                    return localDateTime.AddMinutes(offset.Value);
                }

                // Default to Yemen time
                timezoneId = "Asia/Aden";
            }

            try
            {
                localDateTime = DateTime.SpecifyKind(localDateTime, DateTimeKind.Unspecified);

                // التعامل مع UTC offset format
                if (timezoneId.StartsWith("UTC"))
                {
                    var offsetPart = timezoneId.Substring(3);
                    if (TimeSpan.TryParse(offsetPart, out var timeOffset))
                    {
                        return localDateTime.Subtract(timeOffset);
                    }
                }

                var timeZone = TZConvert.GetTimeZoneInfo(timezoneId);
                return TimeZoneInfo.ConvertTimeToUtc(localDateTime, timeZone);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error converting to UTC. TimeZone: {TimeZone}", timezoneId);
                // Fallback
                return localDateTime.AddHours(-3);
            }
        }

        private void EnrichLocationFromTimezone(GeolocationInfo info)
        {
            if (string.IsNullOrEmpty(info.TimeZoneId))
                return;

            // قائمة بسيطة لربط timezones بالدول
            var timezoneCountryMap = new Dictionary<string, (string Country, string CountryCode, string City)>
            {
                ["Asia/Aden"] = ("Yemen", "YE", "Sana'a"),
                ["Asia/Riyadh"] = ("Saudi Arabia", "SA", "Riyadh"),
                ["Asia/Dubai"] = ("United Arab Emirates", "AE", "Dubai"),
                ["Asia/Kuwait"] = ("Kuwait", "KW", "Kuwait City"),
                ["Asia/Muscat"] = ("Oman", "OM", "Muscat"),
                ["Asia/Qatar"] = ("Qatar", "QA", "Doha"),
                ["Asia/Bahrain"] = ("Bahrain", "BH", "Manama"),
                ["Africa/Cairo"] = ("Egypt", "EG", "Cairo"),
                ["Asia/Amman"] = ("Jordan", "JO", "Amman"),
                ["Asia/Damascus"] = ("Syria", "SY", "Damascus"),
                ["Asia/Baghdad"] = ("Iraq", "IQ", "Baghdad"),
                ["Asia/Beirut"] = ("Lebanon", "LB", "Beirut"),
                // إضافة المزيد حسب الحاجة
            };

            if (timezoneCountryMap.TryGetValue(info.TimeZoneId, out var locationData))
            {
                info.Country = info.Country ?? locationData.Country;
                info.CountryCode = info.CountryCode ?? locationData.CountryCode;
                info.City = info.City ?? locationData.City;
            }
        }

        private async Task<GeolocationInfo> GetFromIpApiAsync(string ipAddress)
        {
            try
            {
                var response = await _httpClient.GetAsync($"http://ip-api.com/json/{ipAddress}");

                if (response.IsSuccessStatusCode)
                {
                    var json = await response.Content.ReadAsStringAsync();
                    dynamic data = JsonConvert.DeserializeObject(json);

                    if (data?.status == "success")
                    {
                        return new GeolocationInfo
                        {
                            Country = data.country,
                            CountryCode = data.countryCode,
                            City = data.city,
                            TimeZoneId = data.timezone,
                            Latitude = data.lat,
                            Longitude = data.lon,
                            Region = data.regionName,
                            Source = "IP-API"
                        };
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to get location from ip-api");
            }

            return null;
        }

        private async Task<GeolocationInfo> GetFromIpGeolocationAsync(string ipAddress)
        {
            try
            {
                var apiKey = _configuration["Geolocation:IpGeolocationApiKey"];
                if (string.IsNullOrEmpty(apiKey))
                    return null;

                var response = await _httpClient.GetAsync(
                    $"https://api.ipgeolocation.io/ipgeo?apiKey={apiKey}&ip={ipAddress}");

                if (response.IsSuccessStatusCode)
                {
                    var json = await response.Content.ReadAsStringAsync();
                    dynamic data = JsonConvert.DeserializeObject(json);

                    return new GeolocationInfo
                    {
                        Country = data.country_name,
                        CountryCode = data.country_code2,
                        City = data.city,
                        TimeZoneId = data.time_zone?.name,
                        TimeZoneOffset = (int?)data.time_zone?.offset * 60, // تحويل من ساعات إلى دقائق
                        Latitude = double.Parse(data.latitude?.ToString() ?? "0"),
                        Longitude = double.Parse(data.longitude?.ToString() ?? "0"),
                        Region = data.state_prov,
                        Source = "IPGeolocation"
                    };
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to get location from ipgeolocation");
            }

            return null;
        }

        private GeolocationInfo GetDefaultLocationInfo()
        {
            return new GeolocationInfo
            {
                Country = "Yemen",
                CountryCode = "YE",
                City = "Sana'a",
                TimeZoneId = "Asia/Aden",
                TimeZoneOffset = 180, // +3 hours in minutes
                Latitude = 15.3694,
                Longitude = 44.1910,
                Region = "Sana'a",
                Source = "Default"
            };
        }
    }
}
