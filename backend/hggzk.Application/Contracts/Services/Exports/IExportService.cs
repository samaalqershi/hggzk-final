namespace YemenBooking.Application.Contracts.Services.Exports;

/// <summary>
/// واجهة خدمة التصدير
/// Export service interface
/// </summary>
public interface IExportService
{
    /// <summary>
    /// تصدير التقارير
    /// Export reports
    /// </summary>
    Task<ExportResult> ExportReportAsync(
        object reportData,
        string reportType,
        string fileName,
        ExportFormat format,
        ExportOptions? options = null,
        CancellationToken cancellationToken = default);
}
