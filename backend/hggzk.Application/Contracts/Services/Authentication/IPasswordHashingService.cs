using System.Threading;
using System.Threading.Tasks;

namespace YemenBooking.Application.Contracts.Services.Authentication;

/// <summary>
/// واجهة خدمة تشفير كلمات المرور.
/// Contract for password hashing and validation operations.
/// </summary>
public interface IPasswordHashingService
{
    /// <summary>
    /// ينشئ تجزئة آمنة لكلمة المرور.
    /// Creates a secure hash for the supplied password.
    /// </summary>
    Task<string> HashPasswordAsync(string password, CancellationToken cancellationToken = default);

    /// <summary>
    /// يتحقق من تطابق كلمة المرور مع القيمة المجزأة المخزنة.
    /// Verifies a plaintext password against a stored hash.
    /// </summary>
    Task<bool> VerifyPasswordAsync(string password, string hashedPassword, CancellationToken cancellationToken = default);

    /// <summary>
    /// يولد كلمة مرور عشوائية وفق الطول المحدد.
    /// Generates a random password with the requested length.
    /// </summary>
    Task<string> GenerateRandomPasswordAsync(int length = 12, CancellationToken cancellationToken = default);

    /// <summary>
    /// يتحقق من قوة كلمة المرور ويعيد ملاحظات الإخفاق إن وجدت.
    /// Validates password strength and returns any detected issues.
    /// </summary>
    Task<(bool IsValid, string[] Issues)> ValidatePasswordStrengthAsync(string password, CancellationToken cancellationToken = default);
}
