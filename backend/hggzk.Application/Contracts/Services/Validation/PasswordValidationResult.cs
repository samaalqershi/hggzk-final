namespace YemenBooking.Application.Contracts.Services.Validation;

/// <summary>
/// نتيجة تقييم قوة كلمة المرور ومتطلباتها.
/// Result of password strength evaluation and requirement checks.
/// </summary>
public class PasswordValidationResult
{
    /// <summary>
    /// يحدد ما إذا كانت كلمة المرور مستوفية للحد الأدنى.
    /// Indicates whether the password satisfies the minimum policy.
    /// </summary>
    public bool IsValid { get; set; }

    /// <summary>
    /// درجة كلمة المرور من 0 إلى 100.
    /// Password score from 0 to 100.
    /// </summary>
    public int Score { get; set; }

    /// <summary>
    /// مستوى قوة كلمة المرور.
    /// Password strength level.
    /// </summary>
    public PasswordStrength Strength { get; set; }

    /// <summary>
    /// المتطلبات غير المستوفاة أو المفروضة على كلمة المرور.
    /// Requirements enforced or still missing for the password.
    /// </summary>
    public List<string> Requirements { get; set; } = new();

    /// <summary>
    /// اقتراحات تحسين كلمة المرور.
    /// Suggestions for improving the password.
    /// </summary>
    public List<string> Suggestions { get; set; } = new();
}
