namespace YemenBooking.Application.Contracts.Services.ImageProcessing;

/// <summary>
/// خيارات التحقق المطبقة على الصورة.
/// Validation options applied to an image.
/// </summary>
public class ImageValidationOptions
{
    /// <summary>
    /// الحد الأقصى المسموح لعرض الصورة.
    /// Maximum allowed image width.
    /// </summary>
    public int? MaxWidth { get; set; }

    /// <summary>
    /// الحد الأقصى المسموح لارتفاع الصورة.
    /// Maximum allowed image height.
    /// </summary>
    public int? MaxHeight { get; set; }

    /// <summary>
    /// الحد الأدنى المطلوب لعرض الصورة.
    /// Minimum required image width.
    /// </summary>
    public int? MinWidth { get; set; }

    /// <summary>
    /// الحد الأدنى المطلوب لارتفاع الصورة.
    /// Minimum required image height.
    /// </summary>
    public int? MinHeight { get; set; }

    /// <summary>
    /// الحد الأقصى المسموح لحجم الملف بالبايت.
    /// Maximum allowed file size in bytes.
    /// </summary>
    public long? MaxFileSizeBytes { get; set; }

    /// <summary>
    /// الصيغ المسموح بها أثناء التحقق.
    /// Allowed formats during validation.
    /// </summary>
    public HashSet<ImageFormat>? AllowedFormats { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت الشفافية مطلوبة.
    /// Indicates whether transparency is required.
    /// </summary>
    public bool RequireTransparency { get; set; }
}
