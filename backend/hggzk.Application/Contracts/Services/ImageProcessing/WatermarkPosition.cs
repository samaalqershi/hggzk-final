namespace YemenBooking.Application.Contracts.Services.ImageProcessing;

/// <summary>
/// المواضع الممكنة للعلامة المائية داخل الصورة.
/// Available watermark positions within an image.
/// </summary>
public enum WatermarkPosition
{
    /// <summary>
    /// قيمة تعداد TopLeft.
    /// TopLeft enum value.
    /// </summary>
    TopLeft,
    /// <summary>
    /// قيمة تعداد TopCenter.
    /// TopCenter enum value.
    /// </summary>
    TopCenter,
    /// <summary>
    /// قيمة تعداد TopRight.
    /// TopRight enum value.
    /// </summary>
    TopRight,
    /// <summary>
    /// قيمة تعداد MiddleLeft.
    /// MiddleLeft enum value.
    /// </summary>
    MiddleLeft,
    /// <summary>
    /// قيمة تعداد MiddleCenter.
    /// MiddleCenter enum value.
    /// </summary>
    MiddleCenter,
    /// <summary>
    /// قيمة تعداد MiddleRight.
    /// MiddleRight enum value.
    /// </summary>
    MiddleRight,
    /// <summary>
    /// قيمة تعداد BottomLeft.
    /// BottomLeft enum value.
    /// </summary>
    BottomLeft,
    /// <summary>
    /// قيمة تعداد BottomCenter.
    /// BottomCenter enum value.
    /// </summary>
    BottomCenter,
    /// <summary>
    /// قيمة تعداد BottomRight.
    /// BottomRight enum value.
    /// </summary>
    BottomRight,
}
