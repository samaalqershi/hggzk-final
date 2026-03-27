namespace YemenBooking.Application.Contracts.Services.Validation;

/// <summary>
/// يحدد مستوى قوة كلمة المرور.
/// Defines the strength tier of a password.
/// </summary>
public enum PasswordStrength
{
    /// <summary>
    /// ضعيف جداً.
    /// Very weak.
    /// </summary>
    VERY_WEAK,

    /// <summary>
    /// ضعيف.
    /// Weak.
    /// </summary>
    WEAK,

    /// <summary>
    /// متوسط.
    /// Fair.
    /// </summary>
    FAIR,

    /// <summary>
    /// جيد.
    /// Good.
    /// </summary>
    GOOD,

    /// <summary>
    /// ممتاز.
    /// Excellent.
    /// </summary>
    EXCELLENT
}
