namespace YemenBooking.Application.Contracts.Services.ImageProcessing;

/// <summary>
/// واجهة خدمة معالجة الصور
/// Image processing service interface
/// </summary>
public interface IImageProcessingService
{
    /// <summary>
    /// تغيير حجم الصورة
    /// Resize image
    /// </summary>
    Task<ImageProcessingResult> ResizeImageAsync(
        Stream imageStream,
        int width,
        int height,
        ImageResizeMode mode = ImageResizeMode.Fit,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// قص الصورة
    /// Crop image
    /// </summary>
    Task<ImageProcessingResult> CropImageAsync(
        Stream imageStream,
        int x,
        int y,
        int width,
        int height,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// ضغط الصورة
    /// Compress image
    /// </summary>
    Task<ImageProcessingResult> CompressImageAsync(
        Stream imageStream,
        int quality = 85,
        ImageFormat? outputFormat = null,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// إنشاء صورة مصغرة
    /// Generate thumbnail
    /// </summary>
    Task<ImageProcessingResult> GenerateThumbnailAsync(
        Stream imageStream,
        int maxWidth = 150,
        int maxHeight = 150,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// تحويل صيغة الصورة
    /// Convert image format
    /// </summary>
    Task<ImageProcessingResult> ConvertFormatAsync(
        Stream imageStream,
        ImageFormat outputFormat,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// إضافة علامة مائية
    /// Add watermark
    /// </summary>
    Task<ImageProcessingResult> AddWatermarkAsync(
        Stream imageStream,
        Stream watermarkStream,
        WatermarkPosition position = WatermarkPosition.BottomRight,
        float opacity = 0.5f,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// إضافة نص كعلامة مائية
    /// Add text watermark
    /// </summary>
    Task<ImageProcessingResult> AddTextWatermarkAsync(
        Stream imageStream,
        string text,
        WatermarkPosition position = WatermarkPosition.BottomRight,
        string fontName = "Arial",
        int fontSize = 12,
        string color = "#FFFFFF",
        float opacity = 0.5f,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// الحصول على معلومات الصورة
    /// Get image info
    /// </summary>
    Task<ImageInfo> GetImageInfoAsync(
        Stream imageStream,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// التحقق من صحة الصورة
    /// Validate image
    /// </summary>
    Task<ImageValidationResult> ValidateImageAsync(
        Stream imageStream,
        ImageValidationOptions? options = null,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// إنشاء عدة أحجام للصورة
    /// Generate multiple sizes
    /// </summary>
    Task<MultipleSizeResult> GenerateMultipleSizesAsync(
        Stream imageStream,
        ImageSize[] sizes,
        CancellationToken cancellationToken = default);
}
