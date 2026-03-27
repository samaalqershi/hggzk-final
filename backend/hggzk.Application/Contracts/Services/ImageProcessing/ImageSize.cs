namespace YemenBooking.Application.Contracts.Services.ImageProcessing;

/// <summary>
/// تعريف حجم صورة مطلوب إنشاؤه أو استخدامه.
/// Defines an image size to generate or process.
/// </summary>
public class ImageSize
{
    /// <summary>
    /// الاسم المنطقي للحجم المطلوب.
    /// Logical name of the requested size.
    /// </summary>
    public string Name { get; set; } = null!;

    /// <summary>
    /// العرض المطلوب بالبكسل.
    /// Requested width in pixels.
    /// </summary>
    public int Width { get; set; }

    /// <summary>
    /// الارتفاع المطلوب بالبكسل.
    /// Requested height in pixels.
    /// </summary>
    public int Height { get; set; }

    /// <summary>
    /// نمط إعادة التحجيم المطبق على هذا الحجم.
    /// Resize mode applied to this size.
    /// </summary>
    public ImageResizeMode Mode { get; set; } = ImageResizeMode.Fit;
}
