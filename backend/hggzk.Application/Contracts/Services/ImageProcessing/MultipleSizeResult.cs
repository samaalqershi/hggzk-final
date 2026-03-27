namespace YemenBooking.Application.Contracts.Services.ImageProcessing;

/// <summary>
/// نتيجة إنشاء عدة نسخ بأحجام مختلفة للصورة.
/// Result of generating multiple image sizes.
/// </summary>
public class MultipleSizeResult
{
    /// <summary>
    /// يحدد ما إذا نجحت العملية الكلية لإنشاء الأحجام المتعددة.
    /// Indicates whether the overall multiple-size generation succeeded.
    /// </summary>
    public bool IsSuccess { get; set; }

    /// <summary>
    /// النتائج الناتجة لكل حجم باسم منطقي.
    /// Results produced for each named size.
    /// </summary>
    public Dictionary<string, ImageProcessingResult> Results { get; set; } = new();

    /// <summary>
    /// رسالة الخطأ عند فشل العملية.
    /// Error message when the operation fails.
    /// </summary>
    public string? ErrorMessage { get; set; }
}
