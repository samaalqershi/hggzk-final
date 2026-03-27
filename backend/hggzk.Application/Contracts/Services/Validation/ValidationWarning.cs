namespace YemenBooking.Application.Contracts.Services.Validation;

/// <summary>
/// يمثل تحذيراً غير مانع ضمن نتيجة التحقق.
/// Represents a non-blocking validation warning entry.
/// </summary>
public class ValidationWarning
{
    /// <summary>
    /// رمز التحذير.
    /// Warning code.
    /// </summary>
    public string Code { get; set; } = null!;

    /// <summary>
    /// الرسالة المقروءة للتحذير.
    /// Human-readable warning message.
    /// </summary>
    public string Message { get; set; } = null!;

    /// <summary>
    /// اسم الحقل المرتبط بالتحذير إن وجد.
    /// Field name associated with the warning when available.
    /// </summary>
    public string? Field { get; set; }

    /// <summary>
    /// القيمة ذات الصلة بالتحذير إن توفرت.
    /// Related value when available.
    /// </summary>
    public object? Value { get; set; }
}
