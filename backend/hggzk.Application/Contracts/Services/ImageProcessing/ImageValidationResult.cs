namespace YemenBooking.Application.Contracts.Services.ImageProcessing;

/// <summary>
/// نتيجة التحقق من صلاحية الصورة.
/// Result of validating an image input.
/// </summary>
public class ImageValidationResult
{
    /// <summary>
    /// يحدد ما إذا كانت الصورة صالحة وفق الخيارات المحددة.
    /// Indicates whether the image is valid for the configured options.
    /// </summary>
    public bool IsValid { get; set; }

    /// <summary>
    /// قائمة الأخطاء الناتجة عن التحقق.
    /// Validation errors produced by the check.
    /// </summary>
    public List<string> ValidationErrors { get; set; } = new();

    /// <summary>
    /// معلومات الصورة التي تم تحليلها أثناء التحقق.
    /// Image metadata gathered during validation.
    /// </summary>
    public ImageInfo? ImageInfo { get; set; }
}
