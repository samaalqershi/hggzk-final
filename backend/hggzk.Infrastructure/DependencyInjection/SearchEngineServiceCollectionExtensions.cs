using System;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using YemenBooking.Infrastructure.Postgres.Configuration;
using YemenBooking.Infrastructure.Redis.Configuration;

namespace YemenBooking.Infrastructure.DependencyInjection;

/// <summary>
/// Registers the search subsystem with PostgreSQL as the primary engine and Redis as optional cache infrastructure.
/// يسجل منظومة البحث بحيث يكون PostgreSQL هو المحرك الأساسي وRedis بنية كاش اختيارية.
/// </summary>
public static class SearchEngineServiceCollectionExtensions
{
    public static IServiceCollection AddSearchEngine(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var options = configuration
            .GetSection("SearchEngine")
            .Get<SearchEngineOptions>() ?? new SearchEngineOptions();

        services.AddSingleton(options);

        var configuredProvider = options.Provider?.Trim();
        var normalizedProvider = configuredProvider?.ToLowerInvariant();

        switch (normalizedProvider)
        {
            case "redis":
            case "redisearch":
                services.AddRedisServices(configuration);
                services.AddPostgresFacetServices();
                Console.WriteLine("✅ تم تفعيل محرك البحث: Redis/RediSearch مع Facets من PostgreSQL");
                break;

            case null:
            case "":
            case "postgres":
            case "postgresql":
                services.AddRedisCachingServicesIfConfigured(configuration);
                services.AddPostgresSearchServices(configuration);
                Console.WriteLine("✅ تم تفعيل محرك البحث الرسمي: PostgreSQL (Full-Text + Faceting)");
                break;

            default:
                services.AddRedisCachingServicesIfConfigured(configuration);
                services.AddPostgresSearchServices(configuration);
                Console.WriteLine(
                    $"⚠️ قيمة SearchEngine:Provider غير معروفة: {configuredProvider}. " +
                    "سيتم استخدام PostgreSQL كمحرك افتراضي وRedis للكاش فقط.");
                Console.WriteLine("✅ تم تفعيل محرك البحث الرسمي: PostgreSQL (Full-Text + Faceting)");
                break;
        }

        return services;
    }
}

/// <summary>
/// Runtime options kept for backward-compatible configuration binding.
/// خيارات التشغيل المحتفظ بها للتوافق مع الإعدادات الحالية.
/// </summary>
public class SearchEngineOptions
{
    /// <summary>
    /// Legacy provider value. PostgreSQL remains the effective engine.
    /// قيمة مزود قديمة؛ يبقى PostgreSQL هو المحرك الفعلي.
    /// </summary>
    public string Provider { get; set; } = "Postgres";

    /// <summary>
    /// Retained for compatibility with existing configuration.
    /// محفوظة للتوافق مع الإعدادات الحالية.
    /// </summary>
    public bool AutoFallback { get; set; } = true;

    /// <summary>
    /// Enables detailed diagnostic logs where supported.
    /// يفعّل السجلات التشخيصية التفصيلية حيثما أمكن.
    /// </summary>
    public bool EnableDetailedLogging { get; set; }
}
