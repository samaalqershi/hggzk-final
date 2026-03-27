using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;
using System.IO;

namespace YemenBooking.Infrastructure.Data.Context;

/// <summary>
/// Design-time DbContext factory used by EF Core tooling.
/// مولد DbContext المخصص لوقت التصميم والمستخدم من أدوات EF Core.
/// </summary>
public class YemenBookingDbContextFactory : IDesignTimeDbContextFactory<YemenBookingDbContext>
{
    /// <summary>
    /// Creates a DbContext instance for migrations and other design-time operations.
    /// ينشئ DbContext لعمليات المهاجرات وباقي مهام وقت التصميم.
    /// </summary>
    /// <param name="args">Command-line arguments passed by EF tools. معاملات سطر الأوامر الصادرة من أدوات EF.</param>
    /// <returns>A configured DbContext instance. مثيل DbContext جاهز ومهيأ.</returns>
    public YemenBookingDbContext CreateDbContext(string[] args)
    {
        // Resolve the API project path used to load configuration files.
        // تحديد مسار مشروع الـ API المستخدم لقراءة ملفات الإعدادات.
        var apiProjectPath = Path.Combine(
            Directory.GetCurrentDirectory(),
            "..",
            "YemenBooking.Api"
        );

        // Fall back to the current directory if the API path is unavailable.
        // الرجوع إلى المجلد الحالي إذا كان مسار مشروع API غير متاح.
        if (!Directory.Exists(apiProjectPath))
        {
            apiProjectPath = Directory.GetCurrentDirectory();
        }

        // Build configuration from appsettings.json and appsettings.Development.json.
        // بناء الإعدادات من appsettings.json و appsettings.Development.json.
        var configuration = new ConfigurationBuilder()
            .SetBasePath(apiProjectPath)
            .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
            .AddJsonFile("appsettings.Development.json", optional: true, reloadOnChange: true)
            .AddEnvironmentVariables()
            .Build();

        // Read the connection string from configuration.
        // قراءة Connection String من الإعدادات.
        var connectionString = configuration.GetConnectionString("DefaultConnection");

        // Validate the connection string before creating the context.
        // التحقق من وجود Connection String قبل إنشاء الـ DbContext.
        if (string.IsNullOrEmpty(connectionString))
        {
            throw new InvalidOperationException(
                "Connection string not found in appsettings.json.\n" +
                "تأكد من وجود 'ConnectionStrings:DefaultConnection' في ملف الإعدادات.");
        }

        // Create the DbContext options used by EF tooling.
        // إنشاء إعدادات DbContext التي تستخدمها أدوات EF.
        var optionsBuilder = new DbContextOptionsBuilder<YemenBookingDbContext>();

        optionsBuilder.UseNpgsql(
            connectionString,
            npgsqlOptions =>
            {
                // Enable retry support for migrations.
                // تفعيل إعادة المحاولة للمهاجرات.
                npgsqlOptions.EnableRetryOnFailure(
                    maxRetryCount: 3,
                    maxRetryDelay: TimeSpan.FromSeconds(5),
                    errorCodesToAdd: null);

                // Set the migrations assembly explicitly.
                // تحديد assembly الخاص بالمهاجرات بشكل صريح.
                npgsqlOptions.MigrationsAssembly("YemenBooking.Infrastructure");
            });

        // Create the DbContext without IHttpContextAccessor, which is unavailable at design time.
        // إنشاء DbContext بدون IHttpContextAccessor لأنه غير متاح في وقت التصميم.
        return new YemenBookingDbContext(optionsBuilder.Options);
    }
} 
