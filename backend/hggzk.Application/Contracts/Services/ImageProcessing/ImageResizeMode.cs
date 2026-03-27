namespace YemenBooking.Application.Contracts.Services.ImageProcessing;

/// <summary>
/// أنماط تغيير أبعاد الصورة.
/// Supported image resize modes.
/// </summary>
public enum ImageResizeMode
{
    /// <summary>
    /// قيمة تعداد Fit.
    /// Fit enum value.
    /// </summary>
    Fit,
    /// <summary>
    /// قيمة تعداد Fill.
    /// Fill enum value.
    /// </summary>
    Fill,
    /// <summary>
    /// قيمة تعداد Stretch.
    /// Stretch enum value.
    /// </summary>
    Stretch,
    /// <summary>
    /// قيمة تعداد Crop.
    /// Crop enum value.
    /// </summary>
    Crop,
}
