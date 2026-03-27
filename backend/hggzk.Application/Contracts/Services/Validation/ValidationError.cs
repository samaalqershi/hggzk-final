namespace YemenBooking.Application.Contracts.Services.Validation;

/// <summary>
/// يمثل خطأً واحداً في نتيجة التحقق.
/// Represents a single validation error entry.
/// </summary>
public class ValidationError
{
    /// <summary>
    /// رمز الخطأ القياسي.
    /// Canonical error code.
    /// </summary>
    public string Code { get; set; } = null!;

    /// <summary>
    /// الرسالة المقروءة للخطأ.
    /// Human-readable error message.
    /// </summary>
    public string Message { get; set; } = null!;

    /// <summary>
    /// اسم الحقل المرتبط بالخطأ إن وجد.
    /// Field name associated with the error when available.
    /// </summary>
    public string? Field { get; set; }

    /// <summary>
    /// القيمة التي تسببت في الخطأ إن توفرت.
    /// Offending value when available.
    /// </summary>
    public object? Value { get; set; }
}
