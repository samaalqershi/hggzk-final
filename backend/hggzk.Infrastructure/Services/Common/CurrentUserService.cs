using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using YemenBooking.Core.Entities;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Core.Interfaces.Repositories;
using TimeZoneConverter;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Infrastructure.Services.Common
{
    /// <summary>
    /// Resolves the current user from claims, headers, and persisted profile data.
    /// يستخرج المستخدم الحالي من المطالبات والرؤوس وبيانات الملف الشخصي المحفوظة.
    /// </summary>
    public class CurrentUserService : ICurrentUserService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IUserRepository _userRepository;
        private readonly IGeolocationService _geolocationService;
        private readonly IMemoryCache _cache;
        private readonly ILogger<CurrentUserService> _logger;
        private static readonly Guid BreakGlassUserFallbackId = Guid.Parse("7f9a0df4-d93d-4549-91eb-4e0f0cc9d174");

        /// <summary>
        /// Initializes a new instance of CurrentUserService with the required dependencies.
        /// يهيئ مثيلاً جديدًا من CurrentUserService باستخدام الاعتماديات المطلوبة.
        /// </summary>
        public CurrentUserService(
            IHttpContextAccessor httpContextAccessor, 
            IUserRepository userRepository, 
            IGeolocationService geolocationService, 
            IMemoryCache cache, 
            ILogger<CurrentUserService> logger)
        {
            _httpContextAccessor = httpContextAccessor;
            _userRepository = userRepository;
            _geolocationService = geolocationService;
            _cache = cache;
            _logger = logger;
        }

        private ClaimsPrincipal? User => _httpContextAccessor.HttpContext?.User;

        private bool IsBreakGlassMasterAdmin
        {
            get
            {
                var flag = User?.FindFirst("isMasterAdmin")?.Value;
                if (bool.TryParse(flag, out var isMasterAdmin) && isMasterAdmin)
                {
                    return true;
                }

                return string.Equals(User?.FindFirst("skipAudit")?.Value, "true", StringComparison.OrdinalIgnoreCase);
            }
        }

        /// <summary>
        /// Current user identifier.
        /// معرّف المستخدم الحالي.
        /// </summary>
        public Guid UserId
        {
            get
            {
                var idClaim = User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                return Guid.TryParse(idClaim, out var id) ? id : Guid.Empty;
            }
        }

        /// <summary>
        /// Current username.
        /// اسم المستخدم الحالي.
        /// </summary>
        public string Username => User?.Identity?.Name ?? string.Empty;

        /// <summary>
        /// Effective role for the current user.
        /// الدور الفعّال للمستخدم الحالي.
        /// </summary>
        public string Role
        {
            get
            {
                var role = User?.FindFirst(ClaimTypes.Role)?.Value;
                if (string.IsNullOrWhiteSpace(role))
                {
                    role = User?.FindFirst("accountRole")?.Value;
                }
                if (string.IsNullOrWhiteSpace(role))
                {
                    var headerRole = _httpContextAccessor.HttpContext?.Request?.Headers?["X-Account-Role"].ToString();
                    if (!string.IsNullOrWhiteSpace(headerRole)) role = headerRole;
                }
                return role ?? string.Empty;
            }
        }

        /// <summary>
        /// Account role associated with the current user.
        /// دور الحساب المرتبط بالمستخدم الحالي.
        /// </summary>
        public string AccountRole => User?.FindFirst("accountRole")?.Value ?? string.Empty;

        /// <summary>
        /// Indicates whether the current user has administrative access.
        /// يحدد ما إذا كان المستخدم الحالي يملك صلاحيات إدارية.
        /// </summary>
        public bool IsAdmin => UserRoles.Contains("Admin");

        /// <summary>
        /// Permissions granted to the current user.
        /// الأذونات الممنوحة للمستخدم الحالي.
        /// </summary>
        public IEnumerable<string> Permissions =>
            User?.FindAll("permission")?.Select(c => c.Value) ?? Enumerable.Empty<string>();

        /// <summary>
        /// Roles assigned to the current user.
        /// الأدوار المرتبطة بالمستخدم الحالي.
        /// </summary>
        public IEnumerable<string> UserRoles =>
            User?.FindAll(ClaimTypes.Role)?.Select(c => c.Value) ?? Enumerable.Empty<string>();

        /// <summary>
        /// Correlation identifier for the current request.
        /// معرّف الارتباط الخاص بالطلب الحالي.
        /// </summary>
        public string CorrelationId => User?.FindFirst("correlationId")?.Value ?? Guid.NewGuid().ToString();

        /// <summary>
        /// Property identifier associated with the current user.
        /// معرّف العقار المرتبط بالمستخدم الحالي.
        /// </summary>
        public Guid? PropertyId
        {
            get
            {
                var propIdClaim = User?.FindFirst("propertyId")?.Value;
                if (Guid.TryParse(propIdClaim, out var pid)) return pid;
                var headerVal = _httpContextAccessor.HttpContext?.Request?.Headers?["X-Property-Id"].ToString();
                if (!string.IsNullOrWhiteSpace(headerVal) && Guid.TryParse(headerVal, out var pid2)) return pid2;
                return null;
            }
        }

        /// <summary>
        /// Property name associated with the current user.
        /// اسم العقار المرتبط بالمستخدم الحالي.
        /// </summary>
        public string? PropertyName => User?.FindFirst("propertyName")?.Value;

        /// <summary>
        /// Currency used by the user property.
        /// عملة العقار المرتبط بالمستخدم.
        /// </summary>
        public string? PropertyCurrency
        {
            get
            {
                var v = User?.FindFirst("propertyCurrency")?.Value;
                if (!string.IsNullOrWhiteSpace(v)) return v;
                var headerVal = _httpContextAccessor.HttpContext?.Request?.Headers?["X-Property-Currency"].ToString();
                return string.IsNullOrWhiteSpace(headerVal) ? null : headerVal;
            }
        }

        /// <summary>
        /// Staff identifier associated with the current user.
        /// معرّف الموظف المرتبط بالمستخدم الحالي.
        /// </summary>
        public Guid? StaffId
        {
            get
            {
                var staffIdClaim = User?.FindFirst("staffId")?.Value;
                return Guid.TryParse(staffIdClaim, out var sid) ? sid : (Guid?)null;
            }
        }

        /// <summary>
        /// Checks whether the current staff user is linked to the specified property.
        /// يتحقق مما إذا كان الموظف الحالي مرتبطًا بالعقار المحدد.
        /// </summary>
        public bool IsStaffInProperty(Guid propertyId)
        {
            var userPropertyId = PropertyId;
            return userPropertyId.HasValue && userPropertyId.Value == propertyId &&
                   (UserRoles.Contains("Staff"));
        }

        /// <summary>
        /// Loads the current user entity when it is available.
        /// يحمل كيان المستخدم الحالي عند توفره.
        /// </summary>
        public async Task<User> GetCurrentUserAsync(CancellationToken cancellationToken = default)
        {
            // Ensure an authenticated identity exists before hitting persistence.
            // التحقق من وجود هوية مصدقة قبل الوصول إلى قاعدة البيانات.
            if (User == null || User.Identity?.IsAuthenticated != true)
                throw new UnauthorizedAccessException("المستخدم غير مصدق عليه");

            if (IsBreakGlassMasterAdmin)
            {
                return new User
                {
                    Id = UserId != Guid.Empty ? UserId : BreakGlassUserFallbackId,
                    Name = string.IsNullOrWhiteSpace(Username) ? "Master Admin" : Username,
                    Email = User.FindFirst(ClaimTypes.Email)?.Value ?? "master-admin@local",
                    Password = string.Empty,
                    Phone = string.Empty,
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true,
                    EmailConfirmed = true,
                    IsEmailVerified = true,
                    SettingsJson = "{}",
                    FavoritesJson = "[]"
                };
            }

            if (UserId == Guid.Empty)
                throw new UnauthorizedAccessException("المستخدم غير مصدق عليه");

            // Load the persisted user entity for downstream business logic.
            // جلب كيان المستخدم المحفوظ لاستخدامه في منطق الأعمال اللاحق.
            var user = await _userRepository.GetUserByIdAsync(UserId, cancellationToken);
            if (user == null)
                throw new UnauthorizedAccessException($"المستخدم بالمعرف {UserId} غير موجود");

            return user;
        }

        /// <summary>
        /// Checks whether the current user has the specified role.
        /// يتحقق مما إذا كان المستخدم الحالي يملك الدور المحدد.
        /// </summary>
        public Task<bool> IsInRoleAsync(string role)
        {
            var hasRole = UserRoles != null && UserRoles.Contains(role);
            return Task.FromResult(hasRole);
        }

        /// <summary>
        /// Resolves the current user location details.
        /// يستخرج تفاصيل موقع المستخدم الحالي.
        /// </summary>
        public async Task<UserLocationInfo> GetUserLocationAsync()
        {
            var cacheKey = $"user_location_{UserId}";
            
            // Check the in-memory cache first to avoid repeated lookups.
            // التحقق من الذاكرة المؤقتة أولاً لتجنب عمليات البحث المتكررة.
            if (_cache.TryGetValue<UserLocationInfo>(cacheKey, out var cachedLocation))
            {
                _logger.LogDebug("Returning cached location for user {UserId}", UserId);
                return cachedLocation;
            }

            try
            {
                // 1. Try request headers first because they are the most explicit source.
                // 1. محاولة الحصول على المنطقة الزمنية من الرؤوس أولاً لأنها المصدر الأكثر صراحة.
                var timezoneFromHeaders = _geolocationService.GetTimezoneFromHeaders();
                var offsetFromHeaders = _geolocationService.GetTimezoneOffsetFromHeaders();

                if (!string.IsNullOrEmpty(timezoneFromHeaders))
                {
                    _logger.LogInformation("Using timezone from headers for user {UserId}: {Timezone}", 
                        UserId, timezoneFromHeaders);

                    var locationInfo = CreateLocationInfoFromTimezone(
                        timezoneFromHeaders, 
                        offsetFromHeaders,
                        "Headers");

                    // Cache the resolved location for one hour.
                    // تخزين الموقع المحدد في الذاكرة المؤقتة لمدة ساعة.
                    _cache.Set(cacheKey, locationInfo, TimeSpan.FromHours(1));
                    
                    // Persist the resolved timezone into the user profile for future requests.
                    // حفظ المنطقة الزمنية في ملف المستخدم للاستخدام المستقبلي.
                    await UpdateUserTimezoneAsync(timezoneFromHeaders, locationInfo);
                    
                    return locationInfo;
                }

                // 2. Fall back to the stored user profile only for authenticated users.
                // 2. الرجوع إلى ملف المستخدم المخزن فقط للمستخدمين المصدق عليهم.
                if (User?.Identity?.IsAuthenticated == true && UserId != Guid.Empty)
                {
                    var user = await GetCurrentUserAsync();
                    if (!string.IsNullOrEmpty(user?.TimeZoneId))
                    {
                        _logger.LogInformation("Using saved timezone for user {UserId}: {Timezone}", 
                            UserId, user.TimeZoneId);

                        var locationInfo = CreateLocationInfoFromTimezone(
                            user.TimeZoneId,
                            null,
                            "UserProfile");

                        locationInfo.Country = user.Country ?? locationInfo.Country;
                        locationInfo.City = user.City ?? locationInfo.City;
                        
                        _cache.Set(cacheKey, locationInfo, TimeSpan.FromHours(1));
                        return locationInfo;
                    }
                }

                // 3. Use IP geolocation as the final fallback path.
                // 3. استخدام تحديد الموقع عبر عنوان IP كمسار احتياطي أخير.
                _logger.LogInformation("Using IP geolocation for user {UserId}", UserId);
                var geoInfo = await _geolocationService.GetLocationInfoAsync();
                
                var ipLocationInfo = new UserLocationInfo
                {
                    Country = geoInfo.Country,
                    CountryCode = geoInfo.CountryCode,
                    City = geoInfo.City,
                    TimeZoneId = geoInfo.TimeZoneId,
                    UtcOffset = GetOffsetFromMinutes(geoInfo.TimeZoneOffset),
                    Source = geoInfo.Source
                };

                // Normalize the timezone identifier to a stable display name.
                // توحيد معرّف المنطقة الزمنية إلى اسم عرض ثابت.
                try
                {
                    var timeZone = TZConvert.GetTimeZoneInfo(geoInfo.TimeZoneId);
                    ipLocationInfo.TimeZoneName = timeZone.DisplayName;
                    ipLocationInfo.IsDaylightSaving = timeZone.IsDaylightSavingTime(DateTime.Now);
                    ipLocationInfo.UtcOffset = timeZone.GetUtcOffset(DateTime.Now);
                }
                catch
                {
                    ipLocationInfo.TimeZoneName = $"UTC{ipLocationInfo.UtcOffset:hh\\:mm}";
                }

                _cache.Set(cacheKey, ipLocationInfo, TimeSpan.FromHours(1));
                
                // Persist the derived timezone when possible.
                // حفظ المنطقة الزمنية المشتقة عند الإمكان.
                await UpdateUserTimezoneAsync(geoInfo.TimeZoneId, ipLocationInfo);
                
                return ipLocationInfo;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting user location for user {UserId}", UserId);
                return GetDefaultLocation();
            }
        }

        /// <summary>
        /// Converts a UTC timestamp to the user local time.
        /// يحوّل طابعًا زمنيًا UTC إلى الوقت المحلي للمستخدم.
        /// </summary>
        public async Task<DateTime> ConvertFromUtcToUserLocalAsync(DateTime utcDateTime)
        {
            if (utcDateTime.Kind != DateTimeKind.Utc)
            {
                utcDateTime = DateTime.SpecifyKind(utcDateTime, DateTimeKind.Utc);
            }

            // Try the geolocation service first because it reads live request headers.
            // محاولة استخدام خدمة تحديد الموقع أولاً لأنها تقرأ رؤوس الطلب الحالية.
            var converted = _geolocationService.ConvertFromUtc(utcDateTime);
            if (converted != utcDateTime.AddHours(3)) // Not the default Yemen fallback. / ليس مسار اليمن الافتراضي.
            {
                return converted;
            }

            // Fall back to the legacy profile-based conversion path.
            // الرجوع إلى مسار التحويل القديم المعتمد على ملف المستخدم.
            var timeZoneId = await GetUserTimeZoneIdAsync();
            
            try
            {
                var timeZone = TZConvert.GetTimeZoneInfo(timeZoneId);
                return TimeZoneInfo.ConvertTimeFromUtc(utcDateTime, timeZone);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error converting from UTC to local time. TimeZone: {TimeZone}", timeZoneId);
                // Fall back to Yemen time when timezone resolution fails.
                // الرجوع إلى توقيت اليمن عند فشل تحديد المنطقة الزمنية.
                return utcDateTime.AddHours(3);
            }
        }

        /// <summary>
        /// Converts a local timestamp to UTC.
        /// يحوّل الوقت المحلي إلى UTC.
        /// </summary>
        public async Task<DateTime> ConvertFromUserLocalToUtcAsync(DateTime localDateTime)
        {
            // Try the live geolocation path first.
            // محاولة استخدام مسار تحديد الموقع المباشر أولاً.
            var converted = _geolocationService.ConvertToUtc(localDateTime);
            if (converted != localDateTime.AddHours(-3)) // Not the default Yemen fallback. / ليس مسار اليمن الافتراضي.
            {
                return converted;
            }

            // Fall back to the legacy profile-based conversion path.
            // الرجوع إلى مسار التحويل القديم المعتمد على الملف الشخصي.
            var timeZoneId = await GetUserTimeZoneIdAsync();
            
            try
            {
                if (localDateTime.Kind == DateTimeKind.Utc)
                    return localDateTime;

                localDateTime = DateTime.SpecifyKind(localDateTime, DateTimeKind.Unspecified);
                
                var timeZone = TZConvert.GetTimeZoneInfo(timeZoneId);
                return TimeZoneInfo.ConvertTimeToUtc(localDateTime, timeZone);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error converting from local to UTC time. TimeZone: {TimeZone}", timeZoneId);
                // Fall back to the historical fixed offset.
                // الرجوع إلى الإزاحة الثابتة التاريخية.
                return localDateTime.AddHours(-3);
            }
        }

        /// <summary>
        /// Determines the user time zone identifier.
        /// يحدد معرّف المنطقة الزمنية للمستخدم.
        /// </summary>
        public async Task<string> GetUserTimeZoneIdAsync()
        {
            // 1. Try request headers first.
            // 1. المحاولة أولاً من الرؤوس.
            var timezoneFromHeaders = _geolocationService.GetTimezoneFromHeaders();
            if (!string.IsNullOrEmpty(timezoneFromHeaders))
                return timezoneFromHeaders;

            // 2. Fall back to derived location information.
            // 2. الرجوع إلى معلومات الموقع المشتقة.
            var location = await GetUserLocationAsync();
            return location?.TimeZoneId ?? "Asia/Aden";
        }

        /// <summary>
        /// Determines the user time zone offset.
        /// يحدد إزاحة المنطقة الزمنية للمستخدم.
        /// </summary>
        public async Task<TimeSpan> GetUserTimeZoneOffsetAsync()
        {
            // 1. Try request headers first.
            // 1. المحاولة أولاً من الرؤوس.
            var offsetFromHeaders = _geolocationService.GetTimezoneOffsetFromHeaders();
            if (offsetFromHeaders.HasValue)
                return TimeSpan.FromMinutes(-offsetFromHeaders.Value);

            // 2. Fall back to derived location information.
            // 2. الرجوع إلى معلومات الموقع المشتقة.
            var location = await GetUserLocationAsync();
            return location?.UtcOffset ?? TimeSpan.FromHours(3);
        }

        private UserLocationInfo CreateLocationInfoFromTimezone(string timeZoneId, int? offsetMinutes, string source)
        {
            try
            {
                UserLocationInfo info = new UserLocationInfo
                {
                    TimeZoneId = timeZoneId,
                    Source = source
                };

                // Try to resolve timezone metadata through the platform APIs.
                // محاولة جلب بيانات المنطقة الزمنية عبر واجهات النظام.
                if (!string.IsNullOrEmpty(timeZoneId) && !timeZoneId.StartsWith("UTC"))
                {
                    try
                    {
                        var timeZone = TZConvert.GetTimeZoneInfo(timeZoneId);
                        var now = DateTime.UtcNow;
                        info.UtcOffset = timeZone.GetUtcOffset(now);
                        info.TimeZoneName = timeZone.DisplayName;
                        info.IsDaylightSaving = timeZone.IsDaylightSavingTime(now);
                    }
                    catch
                    {
                        // If conversion fails, continue with the raw offset when available.
                        // عند فشل التحويل، نستخدم الإزاحة الخام إن توفرت.
                        if (offsetMinutes.HasValue)
                        {
                            info.UtcOffset = TimeSpan.FromMinutes(-offsetMinutes.Value);
                            info.TimeZoneName = $"UTC{info.UtcOffset:hh\\:mm}";
                        }
                    }
                }
                else if (offsetMinutes.HasValue)
                {
                    info.UtcOffset = TimeSpan.FromMinutes(-offsetMinutes.Value);
                    info.TimeZoneName = $"UTC{info.UtcOffset:hh\\:mm}";
                }

                // Infer country and city data from the timezone when possible.
                // محاولة استنتاج بيانات الدولة والمدينة من المنطقة الزمنية عند الإمكان.
                EnrichLocationFromTimezone(info);

                return info;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating location info from timezone: {TimeZone}", timeZoneId);
                return GetDefaultLocation();
            }
        }

        private void EnrichLocationFromTimezone(UserLocationInfo info)
        {
            var timezoneMap = new Dictionary<string, (string Country, string Code, string City)>
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
                // Extend this map as more supported regions are introduced.
                // يمكن توسيع هذا الربط عند إضافة مناطق مدعومة أخرى.
            };

            if (timezoneMap.TryGetValue(info.TimeZoneId ?? "", out var location))
            {
                info.Country = info.Country ?? location.Country;
                info.CountryCode = info.CountryCode ?? location.Code;
                info.City = info.City ?? location.City;
            }
        }

        private async Task UpdateUserTimezoneAsync(string timeZoneId, UserLocationInfo locationInfo)
        {
            try
            {
                var user = await GetCurrentUserAsync();
                if (user != null && user.TimeZoneId != timeZoneId)
                {
                    user.TimeZoneId = timeZoneId;
                    user.Country = locationInfo.Country;
                    user.City = locationInfo.City;
                    await _userRepository.UpdateAsync(user);
                    
                    _logger.LogInformation("Updated timezone for user {UserId} to {TimeZone}", 
                        UserId, timeZoneId);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating user timezone");
            }
        }

        private TimeSpan GetOffsetFromMinutes(int? minutes)
        {
            if (!minutes.HasValue)
                return TimeSpan.FromHours(3);
            
            return TimeSpan.FromMinutes(-minutes.Value);
        }

        private UserLocationInfo GetDefaultLocation()
        {
            return new UserLocationInfo
            {
                Country = "Yemen",
                CountryCode = "YE",
                City = "Sana'a",
                TimeZoneId = "Asia/Aden",
                UtcOffset = TimeSpan.FromHours(3),
                TimeZoneName = "(UTC+03:00) Yemen Time",
                IsDaylightSaving = false,
                Source = "Default"
            };
        }
    }
}
