using Microsoft.Extensions.DependencyInjection;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Contracts.Services.Authentication;
using YemenBooking.Application.Features.Analytics.Services;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Application.Features.Accounting.Services;
using YemenBooking.Application.Features.Notifications.Services;
using YemenBooking.Application.Features.Payments.Services;
using YemenBooking.Application.Features.SearchAndFilters.Services;
using YemenBooking.Application.Contracts.Services.Scheduling;
using YemenBooking.Infrastructure.Services.Common;
using YemenBooking.Infrastructure.Services.Events;
using YemenBooking.Infrastructure.Services.Analytics;
using YemenBooking.Infrastructure.Services.Audit;
using YemenBooking.Infrastructure.Services.Exports;
using YemenBooking.Infrastructure.Services.Media;
using YemenBooking.Infrastructure.Services.Notifications;
using YemenBooking.Infrastructure.Services.Notifications.Channels;
using YemenBooking.Infrastructure.Services.Payments;
using YemenBooking.Infrastructure.Services.Reporting;
using YemenBooking.Infrastructure.Services.Scheduling;
using YemenBooking.Infrastructure.Services.Settings;
using YemenBooking.Infrastructure.Services.Authentication;

namespace YemenBooking.Infrastructure.DependencyInjection;

/// <summary>
/// تسجيل جميع Application Services في DI Container
/// Registration of all application services in the Dependency Injection Container
/// </summary>
public static class ApplicationServiceCollectionExtensions
{
    /// <summary>
    /// يسجل الخدمات التنفيذية التي تحقق عقود طبقة التطبيق داخل طبقة البنية التحتية.
    /// Registers the infrastructure implementations that fulfill application-layer contracts.
    /// </summary>
    /// <param name="services">حاوية الخدمات الحالية. The current service collection.</param>
    /// <returns>حاوية الخدمات بعد تسجيل الخدمات التنفيذية. The updated service collection with infrastructure implementations.</returns>
    public static IServiceCollection AddApplicationInfrastructureServices(this IServiceCollection services)
    {
        // Authentication & Authorization
        services.AddScoped<IAuthenticationService, AuthenticationService>();
        services.AddScoped<IPasswordHashingService, PasswordHashingService>();
        services.AddScoped<IPasswordResetService, PasswordResetService>();
        services.AddScoped<ISocialAuthService, SocialAuthService>();
        services.AddScoped<IEmailVerificationService, EmailVerificationService>();
        
        // User Services
        services.AddScoped<ICurrentUserService, CurrentUserService>();
        
        // Communication
        services.AddScoped<IEmailService, EmailService>();
        services.AddScoped<ISmsService, SmsService>();
        services.AddScoped<INotificationService, NotificationService>();
        services.AddScoped<INotificationChannelService, NotificationChannelService>();
        
        // Payment & Financial
        services.AddScoped<IDailyUnitScheduleService, DailyUnitScheduleService>();
        services.AddScoped<IFinancialAccountingService, FinancialAccountingService>();
        
        // Currency & Location
        services.AddScoped<ICurrencyExchangeService, CurrencyExchangeService>();
        services.AddScoped<ICurrencyEnsureService, CurrencyEnsureService>();
        services.AddScoped<ICurrencySettingsService, CurrencySettingsService>();
        services.AddScoped<ICitySettingsService, CitySettingsService>();
        
        // Search & Filter
        services.AddScoped<ISearchService, SearchService>();
        // ملاحظة: IUnitSearchEngine و IUnitIndexingService يتم تسجيلهم في Program.cs
        // حسب نوع المحرك المستخدم (Redis أو PostgreSQL)
        
        // Availability & Booking
        services.AddScoped<IAvailabilityService, AvailabilityService>();
        
        // Analytics & Dashboard
        services.AddScoped<IDashboardService, DashboardService>();
        services.AddScoped<IAnalyticsTrackerService, AnalyticsTrackerService>();
        
        // Reporting & Export
        services.AddScoped<IReportingService, ReportingService>();
        services.AddScoped<IExportService, ExportService>();
        
        // File & Media
        services.AddScoped<IFileStorageService, FileStorageService>();
        services.AddScoped<IFileUploadService, FileUploadService>();
        services.AddScoped<IImageProcessingService, ImageProcessingService>();
        services.AddScoped<IMediaMetadataService, MediaMetadataService>();
        
        // Firebase
        services.AddSingleton<IFirebaseService, FirebaseService>();
        
        // Validation & System
        services.AddScoped<IValidationService, ValidationService>();
        services.AddScoped<ISystemSettingsService, SystemSettingsService>();
        
        // Audit
        services.AddScoped<IAuditService, AuditService>();
        
        // Helper
        services.AddSingleton<IUrlHelper, UrlHelper>();
        
        // Background Services
        services.AddSingleton<IEventPublisher, EventPublisherService>();
        
        return services;
    }
}
