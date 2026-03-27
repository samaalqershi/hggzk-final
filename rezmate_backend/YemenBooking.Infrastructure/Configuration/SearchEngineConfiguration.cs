using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using YemenBooking.Infrastructure.Postgres.Configuration;
using YemenBooking.Infrastructure.Redis.Configuration;

namespace YemenBooking.Infrastructure.Configuration;

/// <summary>
/// تكوين محرك البحث الديناميكي
/// 
/// الاستخدام في Program.cs:
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// builder.Services.AddSearchEngine(builder.Configuration);
/// 
/// التحكم من appsettings.json:
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// {
///   "SearchEngine": {
///     "Provider": "Redis",  // أو "Postgres"
///     "AutoFallback": true  // التبديل التلقائي لـ Postgres إذا فشل Redis
///   }
/// }
/// </summary>
public static class SearchEngineConfiguration
{
    /// <summary>
    /// إضافة محرك البحث حسب التكوين
    /// </summary>
    public static IServiceCollection AddSearchEngine(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddRedisCachingServicesIfConfigured(configuration);

        var searchEngineConfig = configuration
            .GetSection("SearchEngine")
            .Get<SearchEngineOptions>() ?? new SearchEngineOptions();
        
        // تسجيل الخيارات
        services.AddSingleton(searchEngineConfig);
        
        var provider = searchEngineConfig.Provider?.ToLowerInvariant() ?? "postgres";
        
        switch (provider)
        {
            case "redis":
            case "auto":
                Console.WriteLine("⚠️  مزود Redis/Auto لم يعد مستخدماً كمحرك بحث. سيتم استخدام PostgreSQL للبحث وRedis للكاش فقط.");
                return services.AddPostgresSearchEngine(configuration);

            case "postgres":
            case "postgresql":
            default:
                return services.AddPostgresSearchEngine(configuration);
        }
    }
    
    /// <summary>
    /// إضافة محرك بحث PostgreSQL
    /// </summary>
    private static IServiceCollection AddPostgresSearchEngine(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddPostgresSearchServices(configuration);
        
        Console.WriteLine("✅ تم تفعيل محرك البحث: PostgreSQL (PostgresUnitSearchEngine)");
        
        return services;
    }
}

/// <summary>
/// خيارات تكوين محرك البحث
/// </summary>
public class SearchEngineOptions
{
    /// <summary>
    /// المزود المستخدم
    /// القيم المسموحة: Redis, Postgres, Auto
    /// </summary>
    public string Provider { get; set; } = "Postgres";
    
    /// <summary>
    /// التبديل التلقائي إلى PostgreSQL إذا فشل Redis
    /// </summary>
    public bool AutoFallback { get; set; } = true;
    
    /// <summary>
    /// تفعيل التسجيل التفصيلي
    /// </summary>
    public bool EnableDetailedLogging { get; set; } = false;
}
