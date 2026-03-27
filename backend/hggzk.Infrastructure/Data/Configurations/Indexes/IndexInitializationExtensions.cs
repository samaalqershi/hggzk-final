using Microsoft.Extensions.DependencyInjection;
using YemenBooking.Infrastructure.Data.Initialization;

namespace YemenBooking.Infrastructure.Data.Configurations.Indexes;

/// <summary>
/// Extensions for registering index initialization services.
/// امتدادات لتسجيل خدمات تهيئة الفهارس.
/// </summary>
public static class IndexInitializationExtensions
{
    /// <summary>
    /// Registers the automatic index initializer service.
    /// يسجل خدمة تهيئة الفهارس التلقائية.
    /// </summary>
    public static IServiceCollection AddDatabaseIndexInitialization(this IServiceCollection services)
    {
        services.AddHostedService<DatabaseIndexInitializerService>();
        return services;
    }
}
