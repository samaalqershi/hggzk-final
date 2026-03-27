using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using YemenBooking.Application.Contracts.Services.Location;
using YemenBooking.Application.Contracts.Services.Wallets;
using YemenBooking.Application.Features.Payments.Services;
using YemenBooking.Application.Features.SearchAndFilters.Services;
using YemenBooking.Infrastructure.Data.Configurations.Indexes;
using YemenBooking.Infrastructure.Services.Location;
using YemenBooking.Infrastructure.Services.Notifications;
using YemenBooking.Infrastructure.Services.Search;
using YemenBooking.Infrastructure.Services.Wallets;
using YemenBooking.Infrastructure.Settings;

namespace YemenBooking.Infrastructure.DependencyInjection;

/// <summary>
/// يوفّر نقطة الدخول المركزية لتسجيل جميع تبعيات طبقة البنية التحتية.
/// Provides the centralized entry point for registering all infrastructure-layer dependencies.
/// </summary>
public static class InfrastructureServiceCollectionExtensions
{
    /// <summary>
    /// يسجل مستودعات وخدمات وعمليات الخلفية الخاصة بطبقة البنية التحتية من نقطة واحدة.
    /// Registers the infrastructure repositories, services, and hosted workflows from a single entry point.
    /// </summary>
    /// <param name="services">حاوية الخدمات الحالية. The current service collection.</param>
    /// <param name="configuration">مصدر الإعدادات اللازم لربط الخيارات وتكاملات البنية التحتية. The configuration source used to bind options and infrastructure integrations.</param>
    /// <returns>حاوية الخدمات بعد اكتمال تسجيل طبقة البنية التحتية. The updated service collection after infrastructure registration completes.</returns>
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(services);
        ArgumentNullException.ThrowIfNull(configuration);

        services.Configure<GeolocationSettings>(configuration.GetSection("GeolocationSettings"));
        services.Configure<PaymentGatewaySettings>(configuration.GetSection("PaymentGatewaySettings"));

        services.AddRepositories();
        services.AddApplicationInfrastructureServices();

        // Services without dedicated contracts still live inside infrastructure.
        services.AddScoped<PropertyFilterComparisonService>();
        services.AddScoped<ISearchRelaxationService, SearchRelaxationService>();
        services.AddScoped<SearchMessageGenerator>();

        // Typed clients are registered centrally so HttpClient-dependent services resolve correctly.
        services.AddHttpClient<IPaymentGatewayService, PaymentGatewayService>();
        services.AddHttpClient<IGeolocationService, GeolocationService>();
        services.AddHttpClient<ISabaCashWalletService, SabaCashWalletService>();
        services.AddHttpClient<IJwaliWalletService, JwaliWalletService>();
        services.AddHttpClient<IFloskWalletService, FloskWalletService>();

        services.AddHostedService<ScheduledNotificationsDispatcher>();
        services.AddSearchEngine(configuration);
        services.AddDatabaseIndexInitialization();

        return services;
    }
}
