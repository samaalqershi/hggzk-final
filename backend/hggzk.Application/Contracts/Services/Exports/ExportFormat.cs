namespace YemenBooking.Application.Contracts.Services.Exports;

/// <summary>
/// صيغ الملفات المدعومة في التصدير.
/// Supported output formats for exports.
/// </summary>
public enum ExportFormat
{
    /// <summary>
    /// قيمة تعداد EXCEL.
    /// EXCEL enum value.
    /// </summary>
    EXCEL,
    /// <summary>
    /// قيمة تعداد PDF.
    /// PDF enum value.
    /// </summary>
    PDF,
    /// <summary>
    /// قيمة تعداد CSV.
    /// CSV enum value.
    /// </summary>
    CSV,
    /// <summary>
    /// قيمة تعداد JSON.
    /// JSON enum value.
    /// </summary>
    JSON,
    /// <summary>
    /// قيمة تعداد XML.
    /// XML enum value.
    /// </summary>
    XML,
    /// <summary>
    /// قيمة تعداد HTML.
    /// HTML enum value.
    /// </summary>
    HTML,
}
