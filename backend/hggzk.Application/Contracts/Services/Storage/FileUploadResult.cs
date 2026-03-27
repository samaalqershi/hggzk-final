namespace YemenBooking.Application.Contracts.Services.Storage;

/// <summary>
/// نتيجة رفع ملف إلى التخزين.
/// Result of uploading a file to storage.
/// </summary>
public class FileUploadResult
{
    /// <summary>
    /// يحدد ما إذا نجحت عملية الرفع.
    /// Indicates whether the upload operation succeeded.
    /// </summary>
    public bool IsSuccess { get; set; }

    /// <summary>
    /// المسار النهائي للملف بعد الرفع.
    /// Final file path after upload.
    /// </summary>
    public string? FilePath { get; set; }

    /// <summary>
    /// الرابط العام أو المؤقت للوصول إلى الملف.
    /// Public or temporary URL used to access the file.
    /// </summary>
    public string? FileUrl { get; set; }

    /// <summary>
    /// اسم الملف بعد الحفظ.
    /// Stored file name.
    /// </summary>
    public string? FileName { get; set; }

    /// <summary>
    /// حجم الملف بالبايت.
    /// File size in bytes.
    /// </summary>
    public long FileSizeBytes { get; set; }

    /// <summary>
    /// نوع المحتوى الخاص بالملف.
    /// Content type of the file.
    /// </summary>
    public string? ContentType { get; set; }

    /// <summary>
    /// رسالة الخطأ عند فشل عملية الرفع.
    /// Error message when upload fails.
    /// </summary>
    public string? ErrorMessage { get; set; }

    /// <summary>
    /// وقت إتمام الرفع.
    /// Timestamp when the upload completed.
    /// </summary>
    public DateTime UploadedAt { get; set; } = DateTime.UtcNow;
}
