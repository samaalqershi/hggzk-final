namespace YemenBooking.Application.Contracts.Services.Validation;

/// <summary>
/// نتيجة التحقق التفصيلية الصادرة عن <see cref="IValidationService"/>.
/// Detailed validation result produced by <see cref="IValidationService"/>.
/// </summary>
public class ValidationServiceResult
{
    /// <summary>
    /// يحدد ما إذا كانت البيانات صالحة.
    /// Indicates whether the payload is valid.
    /// </summary>
    public bool IsValid { get; set; }

    /// <summary>
    /// قائمة الأخطاء التي منعت نجاح التحقق.
    /// Errors that prevented validation from succeeding.
    /// </summary>
    public List<ValidationError> Errors { get; set; } = new();

    /// <summary>
    /// قائمة التحذيرات غير المانعة.
    /// Non-blocking validation warnings.
    /// </summary>
    public List<ValidationWarning> Warnings { get; set; } = new();

    /// <summary>
    /// رسالة عامة مختصرة عن نتيجة التحقق.
    /// Optional summary message for the validation outcome.
    /// </summary>
    public string? Message { get; set; }

    /// <summary>
    /// ينشئ نتيجة تحقق ناجحة.
    /// Creates a successful validation result.
    /// </summary>
    /// <returns>نتيجة نجاح فارغة من الأخطاء. Successful result with no errors.</returns>
    public static ValidationServiceResult Success() => new() { IsValid = true };

    /// <summary>
    /// ينشئ نتيجة تحقق فاشلة بخطأ واحد قياسي.
    /// Creates a failed validation result with a single canonical error.
    /// </summary>
    /// <param name="message">رسالة الخطأ. Error message.</param>
    /// <param name="code">رمز الخطأ. Error code.</param>
    /// <returns>نتيجة تحقق فاشلة. Failed validation result.</returns>
    public static ValidationServiceResult Failure(string message, string code) => new()
    {
        IsValid = false,
        Errors = new() { new ValidationError { Message = message, Code = code } }
    };
}
