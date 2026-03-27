using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using YemenBooking.Infrastructure.Data.Context;
using System.Reflection;
using Npgsql;

namespace YemenBooking.Infrastructure.Data.Initialization;

/// <summary>
/// Applies database migrations and bundled SQL scripts during startup.
/// يطبق ترحيلات قاعدة البيانات ونصوص SQL المضمنة أثناء بدء التشغيل.
/// </summary>
public class DatabaseInitializer
{
    /// <summary>
    /// حقل _context.
    /// _context field.
    /// </summary>
    private readonly YemenBookingDbContext _context;
    /// <summary>
    /// حقل _logger.
    /// _logger field.
    /// </summary>
    private readonly ILogger<DatabaseInitializer> _logger;

    /// <summary>
    /// Initializes the database initializer with the DbContext and logger.
    /// يهيئ أداة تهيئة قاعدة البيانات باستخدام DbContext والمسجل.
    /// </summary>
    /// <param name="context">The application DbContext. سياق قاعدة البيانات الخاص بالتطبيق.</param>
    /// <param name="logger">The logger used for startup diagnostics. المسجل المستخدم لتشخيص بدء التشغيل.</param>
    public DatabaseInitializer(
        YemenBookingDbContext context,
        ILogger<DatabaseInitializer> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Applies migrations and then runs the embedded SQL scripts.
    /// يطبق المهاجرات ثم يشغل نصوص SQL المضمنة.
    /// </summary>
    public async Task InitializeAsync()
    {
        try
        {
            _logger.LogInformation("Starting database initialization.");

            await _context.Database.MigrateAsync();
            _logger.LogInformation("Database migrations applied successfully.");

            await ExecuteEmbeddedSqlScriptsAsync();
            
            _logger.LogInformation("Database initialization completed successfully.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error while initializing the database.");
            throw;
        }
    }

    /// <summary>
    /// دالة ExecuteEmbeddedSqlScriptsAsync.
    /// ExecuteEmbeddedSqlScriptsAsync method.
    /// </summary>
    private async Task ExecuteEmbeddedSqlScriptsAsync()
    {
        try
        {
            var assembly = typeof(DatabaseInitializer).Assembly;

            // The execution order is intentional because later assets depend on earlier database objects.
            var orderedFolders = new[]
            {
                "Functions",
                "Views",
                "Indexes",
                "Fixes"
            };

            var totalFilesExecuted = 0;

            foreach (var folder in orderedFolders)
            {
                var resourceNames = assembly.GetManifestResourceNames()
                    .Where(r => r.Contains($".SQL.{folder}.") && r.EndsWith(".sql"))
                    .OrderBy(r => r)
                    .ToList();

                if (!resourceNames.Any())
                {
                    _logger.LogDebug("⏭️ لا توجد ملفات SQL في مجلد: {Folder}", folder);
                    continue;
                }

                _logger.LogInformation("📁 معالجة مجلد: {Folder} ({Count} ملفات)", folder, resourceNames.Count);

                foreach (var resourceName in resourceNames)
                {
                    await ExecuteEmbeddedResourceAsync(assembly, resourceName);
                    totalFilesExecuted++;
                }
            }

            _logger.LogInformation("✅ تم تنفيذ {Count} ملف SQL من الموارد المضمنة", totalFilesExecuted);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "❌ خطأ أثناء تنفيذ SQL Scripts من الموارد المضمنة");
            throw;
        }
    }

    /// <summary>
    /// دالة ExecuteEmbeddedResourceAsync.
    /// ExecuteEmbeddedResourceAsync method.
    /// </summary>
    private async Task ExecuteEmbeddedResourceAsync(Assembly assembly, string resourceName)
    {
        try
        {
            var fileName = resourceName.Split('.').TakeLast(2).First();
            _logger.LogInformation("  📄 تنفيذ: {FileName}.sql", fileName);

            using var stream = assembly.GetManifestResourceStream(resourceName);
            if (stream == null)
            {
                _logger.LogWarning("  ⚠️ لا يمكن قراءة المورد: {ResourceName}", resourceName);
                return;
            }

            using var reader = new StreamReader(stream);
            var sqlContent = await reader.ReadToEndAsync();

            if (string.IsNullOrWhiteSpace(sqlContent))
            {
                _logger.LogWarning("  ⚠️ المورد فارغ: {FileName}", fileName);
                return;
            }

            var connectionString = _context.Database.GetConnectionString();
            await using var connection = new NpgsqlConnection(connectionString);
            await connection.OpenAsync();

            await using var command = new NpgsqlCommand(sqlContent, connection);
            command.CommandTimeout = 60;
            await command.ExecuteNonQueryAsync();
            
            _logger.LogInformation("  ✅ تم تنفيذ {FileName}.sql بنجاح", fileName);
        }
        catch (Exception ex)
        {
            var fileName = resourceName.Split('.').TakeLast(2).First();
            _logger.LogError(ex, "  ❌ خطأ أثناء تنفيذ {FileName}.sql", fileName);
        }
    }
}
