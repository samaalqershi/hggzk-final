namespace YemenBooking.Application.Contracts.Services.Storage;

/// <summary>
/// نتيجة تحميل ملف من التخزين.
/// Result of downloading a file from storage.
/// </summary>
public class FileDownloadResult
{
    /// <summary>
    /// يحدد ما إذا نجحت عملية التنزيل.
    /// Indicates whether the download operation succeeded.
    /// </summary>
    public bool IsSuccess { get; set; }

    /// <summary>
    /// تدفق الملف الناتج عند الحاجة للقراءة المباشرة.
    /// File stream result when direct streaming is needed.
    /// </summary>
    public Stream? FileStream { get; set; }

    /// <summary>
    /// محتوى الملف كمصفوفة بايتات عند الحاجة.
    /// File contents as a byte array when needed.
    /// </summary>
    public byte[]? FileBytes { get; set; }

    /// <summary>
    /// اسم الملف الذي تم تنزيله.
    /// Name of the downloaded file.
    /// </summary>
    public string? FileName { get; set; }

    /// <summary>
    /// نوع المحتوى الخاص بالملف.
    /// Content type of the file.
    /// </summary>
    public string? ContentType { get; set; }

    /// <summary>
    /// حجم الملف بالبايت.
    /// File size in bytes.
    /// </summary>
    public long FileSizeBytes { get; set; }

    /// <summary>
    /// رسالة الخطأ عند فشل العملية.
    /// Error message when the operation fails.
    /// </summary>
    public string? ErrorMessage { get; set; }
}
