namespace YemenBooking.Application.Contracts.Services.Exports;

/// <summary>
/// نتيجة عملية التصدير إلى ملف.
/// Result of exporting data to a file.
/// </summary>
public class ExportResult
{
    /// <summary>
    /// يحدد ما إذا نجحت عملية التصدير.
    /// Indicates whether the export operation succeeded.
    /// </summary>
    public bool IsSuccess { get; set; }

    /// <summary>
    /// المسار المحلي أو التخزيني للملف الناتج.
    /// Local or storage path of the generated file.
    /// </summary>
    public string? FilePath { get; set; }

    /// <summary>
    /// اسم الملف الناتج.
    /// Generated file name.
    /// </summary>
    public string? FileName { get; set; }

    /// <summary>
    /// حجم الملف الناتج بالبايت.
    /// Generated file size in bytes.
    /// </summary>
    public long FileSizeBytes { get; set; }

    /// <summary>
    /// نوع المحتوى الخاص بالملف الناتج.
    /// Content type of the generated file.
    /// </summary>
    public string? ContentType { get; set; }

    /// <summary>
    /// رسالة الخطأ في حال فشل التصدير.
    /// Error message when export fails.
    /// </summary>
    public string? ErrorMessage { get; set; }

    /// <summary>
    /// وقت إتمام التصدير.
    /// Timestamp when the export completed.
    /// </summary>
    public DateTime ExportedAt { get; set; } = DateTime.UtcNow;
}
