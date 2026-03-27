using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using YemenBooking.Application.Features.SearchAndFilters.Services;
using YemenBooking.Infrastructure.Postgres.Indexing;

namespace YemenBooking.Infrastructure.Postgres.Configuration;

/// <summary>
/// يوفر طرق تسجيل خدمات البحث والفهرسة المعتمدة على PostgreSQL.
/// Provides registration helpers for PostgreSQL-based search and indexing services.
/// </summary>
public static class PostgresServiceConfiguration
{
    /// <summary>
    /// يسجل خدمات البحث والفهرسة الأساسية المعتمدة على PostgreSQL.
    /// Registers the core PostgreSQL-backed search and indexing services.
    /// </summary>
    /// <param name="services">حاوية الخدمات التي ستستقبل التسجيلات. The service collection to update.</param>
    /// <param name="configuration">إعدادات التطبيق الحالية. The active application configuration.</param>
    /// <returns>حاوية الخدمات بعد إضافة التسجيلات. The updated service collection.</returns>
    public static IServiceCollection AddPostgresSearchServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // Register the PostgreSQL implementations used by search and indexing flows.
        
        // Scoped lifetime keeps the services aligned with the DbContext scope.
        services.AddScoped<IUnitSearchEngine, PostgresUnitSearchEngine>();
        
        services.AddScoped<IUnitIndexingService, PostgresUnitIndexingService>();
        services.AddScoped<ISearchFacetService, PostgresSearchFacetService>();
        
        // Register concrete types for direct resolution when needed.
        services.AddScoped<PostgresUnitSearchEngine>();
        services.AddScoped<PostgresUnitIndexingService>();
        services.AddScoped<PostgresSearchFacetService>();
        
        return services;
    }

    /// <summary>
    /// Registers only the PostgreSQL facet service so other engines can still use
    /// the live filters/counts pipeline backed by the relational database.
    /// يسجل خدمة الـ facets فقط حتى تتمكن المحركات الأخرى من استخدام العدادات
    /// والفلاتر الحية المعتمدة على قاعدة البيانات العلائقية.
    /// </summary>
    public static IServiceCollection AddPostgresFacetServices(this IServiceCollection services)
    {
        services.AddScoped<ISearchFacetService, PostgresSearchFacetService>();
        services.AddScoped<PostgresSearchFacetService>();

        return services;
    }
    
    /// <summary>
    /// يسجل خدمات PostgreSQL مع خيارات إضافية اختيارية.
    /// Registers PostgreSQL services with optional advanced configuration.
    /// </summary>
    /// <param name="services">حاوية الخدمات التي ستستقبل التسجيلات. The service collection to update.</param>
    /// <param name="configuration">إعدادات التطبيق الحالية. The active application configuration.</param>
    /// <param name="configureOptions">إجراء اختياري لتخصيص الخيارات. Optional delegate used to customize options.</param>
    /// <returns>حاوية الخدمات بعد إضافة التسجيلات. The updated service collection.</returns>
    public static IServiceCollection AddPostgresSearchServices(
        this IServiceCollection services,
        IConfiguration configuration,
        Action<PostgresSearchOptions>? configureOptions = null)
    {
        // Register the optional search options singleton. / تسجيل خيارات البحث الاختيارية كمفرد.
        var options = new PostgresSearchOptions();
        configureOptions?.Invoke(options);
        services.AddSingleton(options);
        
        // Register the baseline PostgreSQL services. / تسجيل خدمات PostgreSQL الأساسية.
        services.AddPostgresSearchServices(configuration);
        
        return services;
    }
}

/// <summary>
/// يمثل خيارات تخصيص البحث المعتمد على PostgreSQL.
/// Represents configuration options for PostgreSQL-based search behavior.
/// </summary>
public class PostgresSearchOptions
{
    /// <summary>
    /// يحدد ما إذا كان تخزين النتائج مؤقتاً مفعلاً.
    /// Gets or sets whether result caching is enabled.
    /// </summary>
    public bool EnableCaching { get; set; } = false;
    
    /// <summary>
    /// يحدد مدة الاحتفاظ بالنتائج في الذاكرة بالدقائق.
    /// Gets or sets the cache lifetime, in minutes.
    /// </summary>
    public int CacheDurationMinutes { get; set; } = 5;
    
    /// <summary>
    /// يحدد ما إذا كان التسجيل التفصيلي مفعلاً.
    /// Gets or sets whether detailed logging is enabled.
    /// </summary>
    public bool EnableDetailedLogging { get; set; } = false;
    
    /// <summary>
    /// يحدد أكبر حجم صفحة مسموح به للاستعلامات.
    /// Gets or sets the maximum allowed page size.
    /// </summary>
    public int MaxPageSize { get; set; } = 100;
    
    /// <summary>
    /// يحدد أقصى عدد للنتائج التي يمكن إرجاعها عبر الاستعلام.
    /// Gets or sets the maximum total number of results that can be returned.
    /// </summary>
    public int MaxTotalResults { get; set; } = 10000;
    
    /// <summary>
    /// يحدد ما إذا كان البحث النصي الكامل مفعلاً.
    /// Gets or sets whether full-text search is enabled.
    /// </summary>
    public bool EnableFullTextSearch { get; set; } = true;
    
    /// <summary>
    /// يحدد ما إذا كان البحث الجغرافي مفعلاً.
    /// Gets or sets whether geographic search is enabled.
    /// </summary>
    public bool EnableGeographicSearch { get; set; } = true;
    
    /// <summary>
    /// يحدد لغة البحث النصي الكامل مثل <c>english</c> أو <c>arabic</c>.
    /// Gets or sets the full-text search language, such as <c>english</c> or <c>arabic</c>.
    /// </summary>
    public string FullTextSearchLanguage { get; set; } = "english";
}
