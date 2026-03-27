using System.IO;
using System.Text.Json;
using Microsoft.Extensions.Logging;

namespace YemenBooking.Infrastructure.Services.Exports;

/// <summary>
/// Provides lightweight export support for report payloads.
/// يوفر دعمًا خفيفًا لتصدير بيانات التقارير.
/// </summary>
public class ExportService : IExportService
{
    private readonly ILogger<ExportService> _logger;
    private readonly string _exportFolder = Path.Combine(Directory.GetCurrentDirectory(), "Exports");

    /// <summary>
    /// Initializes the export service and ensures the output folder exists.
    /// يهيئ خدمة التصدير ويتأكد من وجود مجلد المخرجات.
    /// </summary>
    public ExportService(ILogger<ExportService> logger)
    {
        _logger = logger;

        if (!Directory.Exists(_exportFolder))
        {
            Directory.CreateDirectory(_exportFolder);
        }
    }

    /// <summary>
    /// Exports report data to a file in the local export folder.
    /// يصدر بيانات التقرير إلى ملف داخل مجلد التصدير المحلي.
    /// </summary>
    public async Task<ExportResult> ExportReportAsync(
        object reportData,
        string reportType,
        string fileName,
        ExportFormat format,
        ExportOptions? options = null,
        CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("تصدير تقرير {ReportType} بصيغة {Format}: {FileName}", reportType, format, fileName);

        try
        {
            var path = Path.Combine(_exportFolder, fileName);
            var content = JsonSerializer.Serialize(reportData, new JsonSerializerOptions { WriteIndented = true });
            await File.WriteAllTextAsync(path, content, cancellationToken);

            var info = new FileInfo(path);

            return new ExportResult
            {
                IsSuccess = true,
                FilePath = path,
                FileName = fileName,
                FileSizeBytes = info.Length,
                ContentType = "application/json",
                ExportedAt = info.CreationTimeUtc
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء تصدير التقرير");
            return new ExportResult
            {
                IsSuccess = false,
                ErrorMessage = ex.Message
            };
        }
    }
}
