using System;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using StackExchange.Redis;
using YemenBooking.Application.Features.SearchAndFilters.Services;
using YemenBooking.Infrastructure.Redis.Core;
using YemenBooking.Infrastructure.Redis.Core.Interfaces;
using YemenBooking.Infrastructure.Redis.Cache;
using YemenBooking.Infrastructure.Redis.Indexing;
using YemenBooking.Infrastructure.Redis.Monitoring;
using YemenBooking.Infrastructure.Redis.HealthChecks;

namespace YemenBooking.Infrastructure.Redis.Configuration
{
    /// <summary>
    /// Registers Redis infrastructure services.
    /// تسجيل خدمات البنية التحتية الخاصة بـ Redis.
    /// </summary>
    public static class RedisServiceConfiguration
    {
        /// <summary>
        /// Adds Redis services to the DI container.
        /// يضيف خدمات Redis إلى حاوية الحقن المعتمد.
        /// </summary>
        /// <param name="services">The service collection. مجموعة الخدمات.</param>
        /// <param name="configuration">The application configuration. إعدادات التطبيق.</param>
        /// <returns>The same service collection for chaining. نفس مجموعة الخدمات للسلسلة.</returns>
        /// <exception cref="InvalidOperationException">Thrown when the Redis connection string is missing. يُرمى عند غياب سلسلة اتصال Redis.</exception>
        public static IServiceCollection AddRedisServices(
            this IServiceCollection services,
            IConfiguration configuration)
        {
            var redisConnectionString = configuration.GetConnectionString("Redis");
            if (string.IsNullOrWhiteSpace(redisConnectionString))
            {
                throw new InvalidOperationException("Redis connection string is not configured");
            }

            // Register singleton infrastructure services.
            // تسجيل خدمات البنية التحتية بنمط Singleton.
            services.AddSingleton<IRedisConnectionManager, RedisConnectionManager>();
            services.AddSingleton<IRedisCache, RedisCache>();
            // Health check wiring is kept separate for the current DI setup.
            // تم فصل فحص الصحة مؤقتاً لملاءمة إعدادات الـ DI الحالية.
            // services.AddSingleton<IHealthCheckService, Monitoring.HealthCheckService>();
            
            // Register the optimized search and indexing stack.
            // تسجيل طبقة البحث والفهرسة المحسنة.
            services.AddSingleton<IUnitSearchEngine, UltraOptimizedSearchEngine>();
            services.AddSingleton<UltraOptimizedSearchEngine>();
            
            // OptimizedUnitIndexingService: indexing facade backed by the optimized engine.
            // OptimizedUnitIndexingService: واجهة الفهرسة المعتمدة على المحرك المحسّن.
            services.AddSingleton<OptimizedUnitIndexingService>();
            
            // Expose the indexing facade with the same singleton lifetime as the
            // underlying service to avoid disposing the shared instance per scope.
            // إتاحة واجهة الفهرسة بنفس عمر الـ singleton لتجنب التخلص من
            // النسخة المشتركة مع نهاية كل scope.
            services.AddSingleton<IUnitIndexingService>(sp => 
                sp.GetRequiredService<OptimizedUnitIndexingService>());

            // Validate RediSearch prerequisites and preload scripts during startup.
            // التحقق من متطلبات RediSearch وتحميل السكربتات أثناء بدء التشغيل.
            services.AddHostedService<RedisSearchStartupValidationService>();
            
            // Add health checks for the Redis-backed indexing subsystem.
            // إضافة فحوصات الصحة لمنظومة الفهرسة المعتمدة على Redis.
            services.AddHealthChecks()
                .AddCheck<IndexingHealthCheck>(
                    "indexing", // Check name. اسم الفحص.
                    failureStatus: Microsoft.Extensions.Diagnostics.HealthChecks.HealthStatus.Unhealthy, // Failure status. الحالة عند الفشل.
                    tags: new[] { "redis", "indexing" } // Tags for grouping. علامات للتصنيف.
                );

            // Bind Redis options from configuration.
            // ربط خيارات Redis من الإعدادات.
            services.Configure<RedisOptions>(configuration.GetSection("Redis"));

            return services;
        }

        /// <summary>
        /// Adds Redis caching and health services only, without binding the search/indexing engine to Redis.
        /// يضيف خدمات Redis الخاصة بالكاش والصحة فقط دون ربط محرك البحث أو الفهرسة بـ Redis.
        /// </summary>
        public static IServiceCollection AddRedisCachingServicesIfConfigured(
            this IServiceCollection services,
            IConfiguration configuration)
        {
            var redisConnectionString = configuration.GetConnectionString("Redis");
            if (string.IsNullOrWhiteSpace(redisConnectionString))
            {
                return services;
            }

            services.AddSingleton<IRedisConnectionManager, RedisConnectionManager>();
            services.AddSingleton<IRedisCache, RedisCache>();

            services.AddHealthChecks()
                .AddCheck<IndexingHealthCheck>(
                    "indexing",
                    failureStatus: Microsoft.Extensions.Diagnostics.HealthChecks.HealthStatus.Unhealthy,
                    tags: new[] { "redis", "cache" });

            services.Configure<RedisOptions>(configuration.GetSection("Redis"));

            return services;
        }

        /// <summary>
        /// Verifies Redis services after the container is built.
        /// يتحقق من خدمات Redis بعد بناء الحاوية.
        /// </summary>
        /// <param name="serviceProvider">The built service provider. مزود الخدمات المبني.</param>
        /// <returns>The same service provider for chaining. نفس مزود الخدمات للسلسلة.</returns>
        /// <exception cref="InvalidOperationException">Thrown when Redis connectivity fails. يُرمى عند فشل الاتصال بـ Redis.</exception>
        public static IServiceProvider InitializeRedisServices(this IServiceProvider serviceProvider)
        {
            var redisManager = serviceProvider.GetRequiredService<IRedisConnectionManager>();
            
            // Check connectivity synchronously during startup validation.
            // التحقق من الاتصال بشكل متزامن أثناء التهيئة.
            var isConnected = redisManager.IsConnectedAsync().GetAwaiter().GetResult();
            
            if (!isConnected)
            {
                throw new InvalidOperationException("Failed to connect to Redis");
            }

            return serviceProvider;
        }
    }

    /// <summary>
    /// Validates that the configured Redis instance supports RediSearch and
    /// preloads the Lua scripts used by the Redis search engine.
    /// يتحقق من أن مثيل Redis يدعم RediSearch ويحمّل سكربتات Lua اللازمة.
    /// </summary>
    public sealed class RedisSearchStartupValidationService : IHostedService
    {
        private readonly IRedisConnectionManager _redisConnectionManager;
        private readonly UltraOptimizedSearchEngine _searchEngine;
        private readonly ILogger<RedisSearchStartupValidationService> _logger;
        private readonly IConfiguration _configuration;

        public RedisSearchStartupValidationService(
            IRedisConnectionManager redisConnectionManager,
            UltraOptimizedSearchEngine searchEngine,
            ILogger<RedisSearchStartupValidationService> logger,
            IConfiguration configuration)
        {
            _redisConnectionManager = redisConnectionManager;
            _searchEngine = searchEngine;
            _logger = logger;
            _configuration = configuration;
        }

        public async Task StartAsync(CancellationToken cancellationToken)
        {
            var configuredProvider = _configuration["SearchEngine:Provider"]?.Trim();
            if (!string.Equals(configuredProvider, "redis", StringComparison.OrdinalIgnoreCase) &&
                !string.Equals(configuredProvider, "redisearch", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            var db = await _redisConnectionManager.GetDatabaseAsync().ConfigureAwait(false);

            try
            {
                // FT._LIST succeeds only when RediSearch is available.
                // نجاح FT._LIST يعني أن RediSearch متاح فعلاً.
                await db.ExecuteAsync("FT._LIST").ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                var endpoint = _configuration.GetSection("Redis")["EndPoint"] ??
                               _configuration.GetConnectionString("Redis") ??
                               "127.0.0.1:6380";

                throw new InvalidOperationException(
                    "SearchEngine:Provider=Redis requires RediSearch/Redis Stack, but the configured Redis endpoint " +
                    $"({endpoint}) does not expose the search module. " +
                    "Start `backend/docker-compose.redis-stack.yml` or point the configuration to a Redis Stack instance.",
                    ex);
            }

            await _searchEngine.PreloadScriptsAsync().ConfigureAwait(false);
            _logger.LogInformation("Redis/RediSearch startup validation completed successfully.");
        }

        public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
    }

    /// <summary>
    /// Redis configuration options.
    /// خيارات تكوين Redis.
    /// </summary>
    public class RedisOptions
    {
        /// <summary>Connection string (host:port or host:port,password=xyz). سلسلة الاتصال.</summary>
        public string ConnectionString { get; set; }
        
        /// <summary>Database number (0-15 in default Redis). رقم قاعدة البيانات.</summary>
        public int DatabaseNumber { get; set; } = 0;
        
        /// <summary>Connection timeout in milliseconds. مهلة الاتصال بالمللي ثانية.</summary>
        public int ConnectTimeout { get; set; } = 5000;
        
        /// <summary>Synchronous operation timeout in milliseconds. مهلة العمليات المتزامنة.</summary>
        public int SyncTimeout { get; set; } = 5000;
        
        /// <summary>Asynchronous operation timeout in milliseconds. مهلة العمليات غير المتزامنة.</summary>
        public int AsyncTimeout { get; set; } = 5000;
        
        /// <summary>Keep-alive interval in seconds. فترة keep-alive بالثواني.</summary>
        public int KeepAlive { get; set; } = 60;
        
        /// <summary>Number of reconnect attempts. عدد محاولات إعادة الاتصال.</summary>
        public int ConnectRetry { get; set; } = 3;
        
        /// <summary>Whether to abort startup when the first connection fails. إيقاف التطبيق عند فشل الاتصال الأولي.</summary>
        public bool AbortOnConnectFail { get; set; } = false;
        
        /// <summary>Allow admin commands such as KEYS and FLUSHALL. السماح بأوامر الإدارة.</summary>
        public bool AllowAdmin { get; set; } = false;
        
        /// <summary>Password, when configured. كلمة المرور عند توفرها.</summary>
        public string Password { get; set; }
        
        /// <summary>Use SSL/TLS for secure connections. استخدام SSL/TLS.</summary>
        public bool Ssl { get; set; } = false;
        
        /// <summary>SSL certificate host name. اسم مضيف شهادة SSL.</summary>
        public string SslHost { get; set; }
        
        /// <summary>Default key expiry in minutes. مدة انتهاء الصلاحية الافتراضية للمفاتيح.</summary>
        public int DefaultExpiryMinutes { get; set; } = 60;
        
        /// <summary>Enable detailed logging. تفعيل التسجيل التفصيلي.</summary>
        public bool EnableLogging { get; set; } = true;
        
        /// <summary>Enable metrics collection. تفعيل جمع المقاييس.</summary>
        public bool EnableMetrics { get; set; } = true;
    }
}
