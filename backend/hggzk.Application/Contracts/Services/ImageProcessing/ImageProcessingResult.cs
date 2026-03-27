namespace YemenBooking.Application.Contracts.Services.ImageProcessing;

/// <summary>
/// نتيجة عملية معالجة الصورة.
/// Result of an image-processing operation.
/// </summary>
public class ImageProcessingResult
{
    /// <summary>
    /// يحدد ما إذا نجحت عملية المعالجة.
    /// Indicates whether the processing operation succeeded.
    /// </summary>
    public bool IsSuccess { get; set; }

    /// <summary>
    /// تدفق الصورة المعالجة عند الحاجة للتعامل معها مباشرة.
    /// Processed image stream when direct stream handling is needed.
    /// </summary>
    public Stream? ProcessedImageStream { get; set; }

    /// <summary>
    /// الصورة المعالجة كمصفوفة بايتات.
    /// Processed image as a byte array.
    /// </summary>
    public byte[]? ProcessedImageBytes { get; set; }

    /// <summary>
    /// معلومات الصورة الناتجة بعد المعالجة.
    /// Output image metadata after processing.
    /// </summary>
    public ImageInfo? ImageInfo { get; set; }

    /// <summary>
    /// رسالة الخطأ عند فشل المعالجة.
    /// Error message when processing fails.
    /// </summary>
    public string? ErrorMessage { get; set; }
}
