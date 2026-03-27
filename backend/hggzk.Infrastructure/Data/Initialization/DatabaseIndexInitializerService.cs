using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using YemenBooking.Infrastructure.Data.Configurations.Indexes;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Data.Initialization;

/// <summary>
/// Background service that ensures database indexes are available at startup.
/// خدمة خلفية تضمن توفر فهارس قاعدة البيانات عند بدء التطبيق.
/// </summary>
public class DatabaseIndexInitializerService : IHostedService
{
    /// <summary>
    /// حقل _serviceProvider.
    /// _serviceProvider field.
    /// </summary>
    private readonly IServiceProvider _serviceProvider;
    /// <summary>
    /// حقل _logger.
    /// _logger field.
    /// </summary>
    private readonly ILogger<DatabaseIndexInitializerService> _logger;

    /// <summary>
    /// Initializes the index initializer hosted service.
    /// يهيئ خدمة بدء التشغيل الخاصة بالفهارس.
    /// </summary>
    /// <param name="serviceProvider">The root service provider. موفر الخدمات الجذري.</param>
    /// <param name="logger">The logger used for startup diagnostics. المسجل المستخدم لتشخيص بدء التشغيل.</param>
    public DatabaseIndexInitializerService(
        IServiceProvider serviceProvider,
        ILogger<DatabaseIndexInitializerService> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    /// <summary>
    /// Starts the hosted service and applies database indexes.
    /// يبدأ الخدمة الخلفية ويطبق فهارس قاعدة البيانات.
    /// </summary>
    /// <param name="cancellationToken">The cancellation token. رمز الإلغاء.</param>
    public async Task StartAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Starting database index initialization.");

        try
        {
            using var scope = _serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<YemenBookingDbContext>();
            var indexInitializer = new PostgresIndexInitializer(
                context,
                scope.ServiceProvider.GetRequiredService<ILogger<PostgresIndexInitializer>>());

            // Ensure the database exists before applying indexes.
            // التأكد من وجود قاعدة البيانات قبل تطبيق الفهارس.
            await context.Database.EnsureCreatedAsync(cancellationToken);

            // Apply the database indexes.
            // تطبيق فهارس قاعدة البيانات.
            await indexInitializer.ApplyIndexesAsync();

            _logger.LogInformation("Database index initialization completed successfully.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error while initializing the database indexes.");
            // Do not rethrow to avoid stopping the application.
            // لا نعيد رمي الاستثناء لتجنب إيقاف التطبيق.
        }
    }

    /// <summary>
    /// Stops the hosted service.
    /// يوقف الخدمة الخلفية.
    /// </summary>
    /// <param name="cancellationToken">The cancellation token. رمز الإلغاء.</param>
    public Task StopAsync(CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }
}
