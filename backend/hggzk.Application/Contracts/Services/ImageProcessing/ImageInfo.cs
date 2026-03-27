namespace YemenBooking.Application.Contracts.Services.ImageProcessing;

/// <summary>
/// معلومات وصفية عن الصورة.
/// Descriptive metadata for an image.
/// </summary>
public class ImageInfo
{
    /// <summary>
    /// عرض الصورة بالبكسل.
    /// Image width in pixels.
    /// </summary>
    public int Width { get; set; }

    /// <summary>
    /// ارتفاع الصورة بالبكسل.
    /// Image height in pixels.
    /// </summary>
    public int Height { get; set; }

    /// <summary>
    /// صيغة الصورة المكتشفة.
    /// Detected image format.
    /// </summary>
    public ImageFormat Format { get; set; }

    /// <summary>
    /// حجم الملف الأصلي أو المعالج بالبايت.
    /// Original or processed file size in bytes.
    /// </summary>
    public long FileSizeBytes { get; set; }

    /// <summary>
    /// مساحة الألوان إن كانت معروفة.
    /// Color space when known.
    /// </summary>
    public string? ColorSpace { get; set; }

    /// <summary>
    /// عدد البتات لكل بكسل.
    /// Bits per pixel.
    /// </summary>
    public int BitsPerPixel { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت الصورة تحتوي على شفافية.
    /// Indicates whether the image contains transparency.
    /// </summary>
    public bool HasTransparency { get; set; }

    /// <summary>
    /// نوع MIME المناسب للصورة.
    /// MIME type associated with the image.
    /// </summary>
    public string? MimeType { get; set; }
}
