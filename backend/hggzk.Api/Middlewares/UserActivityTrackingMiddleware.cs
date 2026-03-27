using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Concurrent;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Api.Middlewares
{
    /// <summary>
    /// Tracks the user's last-seen activity.
    /// يتتبع وقت آخر ظهور للمستخدم.
    /// </summary>
    public class UserActivityTrackingMiddleware
    {
        /// <summary>
        /// حقل _next.
        /// _next field.
        /// </summary>
        private readonly RequestDelegate _next;
        /// <summary>
        /// حقل _logger.
        /// _logger field.
        /// </summary>
        private readonly ILogger<UserActivityTrackingMiddleware> _logger;
        /// <summary>
        /// حقل _cache.
        /// _cache field.
        /// </summary>
        private readonly IMemoryCache _cache;
        /// <summary>
        /// حقل _serviceScopeFactory.
        /// _serviceScopeFactory field.
        /// </summary>
        private readonly IServiceScopeFactory _serviceScopeFactory;
        
        // Tracks the last update time for each user.
        // يتتبع آخر وقت تحديث لكل مستخدم.
        /// <summary>
        /// حقل _lastUpdateTimes.
        /// _lastUpdateTimes field.
        /// </summary>
        private static readonly ConcurrentDictionary<Guid, DateTime> _lastUpdateTimes = new();
        
        // Minimum interval between updates in seconds.
        // الحد الأدنى للفترة الزمنية بين التحديثات بالثواني.
        /// <summary>
        /// حقل MinUpdateIntervalSeconds.
        /// MinUpdateIntervalSeconds field.
        /// </summary>
        private const int MinUpdateIntervalSeconds = 60; // Minimum interval is one minute. الحد الأدنى للتحديث دقيقة واحدة.
        
        // Semaphore used to limit concurrent operations.
        // يستخدم Semaphore للحد من عدد العمليات المتزامنة.
        /// <summary>
        /// حقل _updateSemaphore.
        /// _updateSemaphore field.
        /// </summary>
        private static readonly SemaphoreSlim _updateSemaphore = new(10); // Up to 10 concurrent operations. حد أقصى 10 عمليات متزامنة.

        /// <summary>
        /// Creates the middleware that tracks user activity.
        /// ينشئ الـ middleware المسؤول عن تتبع نشاط المستخدم.
        /// </summary>
        public UserActivityTrackingMiddleware(
            RequestDelegate next,
            ILogger<UserActivityTrackingMiddleware> logger,
            IMemoryCache cache,
            IServiceScopeFactory serviceScopeFactory)
        {
            _next = next;
            _logger = logger;
            _cache = cache;
            _serviceScopeFactory = serviceScopeFactory;
        }

        /// <summary>
        /// Executes the middleware and queues a background last-seen update when needed.
        /// ينفذ الـ middleware ويجدول تحديث آخر ظهور في الخلفية عند الحاجة.
        /// </summary>
        public async Task InvokeAsync(HttpContext context)
        {
            Guid? userId = null;
            if (context.User?.Identity?.IsAuthenticated == true)
            {
                if (IsBreakGlassMasterAdmin(context))
                {
                    await _next(context);
                    return;
                }

                userId = GetUserIdFromContext(context);
            }

            if (userId.HasValue)
            {
                // Fire-and-forget: do not wait for the update to complete.
                // تنفيذ بالخلفية دون انتظار اكتمال التحديث.
                _ = Task.Run(async () =>
                {
                    try
                    {
                        await UpdateUserLastSeenInBackgroundAsync(userId.Value);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Error occurred while tracking user activity in background");
                    }
                });
            }

            // Continue the pipeline immediately without waiting.
            // متابعة بقية خط الأنابيب مباشرة دون انتظار.
            await _next(context);
        }

        /// <summary>
        /// دالة IsBreakGlassMasterAdmin.
        /// IsBreakGlassMasterAdmin method.
        /// </summary>
        private static bool IsBreakGlassMasterAdmin(HttpContext context)
        {
            var flag = context.User.FindFirst("isMasterAdmin")?.Value;
            if (bool.TryParse(flag, out var isMasterAdmin) && isMasterAdmin)
            {
                return true;
            }

            return string.Equals(context.User.FindFirst("skipAudit")?.Value, "true", StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// دالة UpdateUserLastSeenInBackgroundAsync.
        /// UpdateUserLastSeenInBackgroundAsync method.
        /// </summary>
        private async Task UpdateUserLastSeenInBackgroundAsync(Guid userId)
        {
            // Skip updates that happen too soon after the previous one.
            // تخطّي التحديث إذا كان آخر تحديث قريبًا جدًا.
            if (ShouldSkipUpdate(userId))
            {
                _logger.LogTrace($"Skipping LastSeen update for user {userId} (too soon)");
                return;
            }

            // Try to acquire the semaphore to limit concurrency.
            // محاولة الحصول على الـ Semaphore للحد من التزامن.
            var acquired = await _updateSemaphore.WaitAsync(TimeSpan.FromSeconds(1));
            if (!acquired)
            {
                _logger.LogTrace($"Skipping LastSeen update for user {userId} (semaphore busy)");
                return;
            }

            try
            {
                // Create a new scope to resolve an isolated DbContext.
                // إنشاء نطاق جديد للحصول على DbContext معزول.
                using var scope = _serviceScopeFactory.CreateScope();
                var dbContext = scope.ServiceProvider.GetRequiredService<YemenBookingDbContext>();

                // Update the user's last-seen timestamp.
                // تحديث وقت آخر ظهور للمستخدم.
                var currentTime = DateTime.UtcNow;
                
                // Use ExecuteUpdateAsync for better performance (EF Core 7+).
                // استخدام ExecuteUpdateAsync لتحسين الأداء (EF Core 7+).
                var updateResult = await dbContext.Users
                    .Where(u => u.Id == userId)
                    .ExecuteUpdateAsync(setters => setters
                        .SetProperty(u => u.LastSeen, currentTime));

                if (updateResult > 0)
                {
                    // Refresh the cached update time in the dictionary.
                    // تحديث وقت آخر تعديل مخزن في القاموس.
                    _lastUpdateTimes.AddOrUpdate(userId, currentTime, (key, old) => currentTime);
                    _logger.LogDebug($"Updated LastSeen for user {userId} at {currentTime}");
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Error updating LastSeen for user {userId}", userId);
            }
            finally
            {
                _updateSemaphore.Release();
            }
        }

        /// <summary>
        /// Resolves the user ID from <see cref="HttpContext"/> with caching.
        /// يستخرج معرف المستخدم من <see cref="HttpContext"/> مع الاستفادة من التخزين المؤقت.
        /// </summary>
        private Guid? GetUserIdFromContext(HttpContext context)
        {
            // Cache key.
            // مفتاح التخزين المؤقت.
            var cacheKey = $"user_id_{context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? context.User.FindFirst("id")?.Value ?? context.User.FindFirst("sub")?.Value ?? context.User.FindFirst("userId")?.Value ?? context.User.FindFirst("user_id")?.Value ?? context.User.Identity?.Name}";
            
            // Try cache first.
            // محاولة القراءة من التخزين المؤقت أولًا.
            if (_cache.TryGetValue<Guid>(cacheKey, out var cachedUserId))
            {
                return cachedUserId;
            }

            // Search claims for the user identifier.
            // البحث عن معرف المستخدم داخل الـ Claims.
            var userIdClaim = context.User.FindFirst(ClaimTypes.NameIdentifier) 
                              ?? context.User.FindFirst("id")
                              ?? context.User.FindFirst("sub")
                              ?? context.User.FindFirst("userId")
                              ?? context.User.FindFirst("user_id");

            if (userIdClaim == null || string.IsNullOrEmpty(userIdClaim.Value))
            {
                return null;
            }

            // Try to parse the user identifier as a Guid.
            // محاولة تحويل معرف المستخدم إلى Guid.
            if (!Guid.TryParse(userIdClaim.Value, out var userId))
            {
                _logger.LogWarning($"Unable to parse user ID: {userIdClaim.Value}");
                return null;
            }

            // Cache the value for 5 minutes.
            // حفظ القيمة في التخزين المؤقت لمدة 5 دقائق.
            _cache.Set(cacheKey, userId, TimeSpan.FromMinutes(5));
            return userId;
        }

        /// <summary>
        /// Determines whether the update should be skipped based on the last update time.
        /// يحدد ما إذا كان يجب تخطي التحديث اعتمادًا على وقت آخر تحديث.
        /// </summary>
        private bool ShouldSkipUpdate(Guid userId)
        {
            if (!_lastUpdateTimes.TryGetValue(userId, out var lastUpdate))
            {
                // No previous update exists, so the update should run.
                // لا يوجد تحديث سابق، لذلك يجب تنفيذ التحديث.
                return false;
            }

            var timeSinceLastUpdate = DateTime.UtcNow - lastUpdate;
            return timeSinceLastUpdate.TotalSeconds < MinUpdateIntervalSeconds;
        }
    }

    /// <summary>
    /// Extension methods for registering the middleware.
    /// أساليب امتداد لتسجيل الـ middleware.
    /// </summary>
    public static class UserActivityTrackingMiddlewareExtensions
    {
        /// <summary>
        /// Registers the user activity tracking middleware.
        /// يسجل middleware تتبع نشاط المستخدم.
        /// </summary>
        public static IApplicationBuilder UseUserActivityTracking(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<UserActivityTrackingMiddleware>();
        }
    }
}
