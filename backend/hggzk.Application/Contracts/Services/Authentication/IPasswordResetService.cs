using System;
using System.Threading.Tasks;

namespace YemenBooking.Application.Contracts.Services.Authentication;

/// <summary>
/// واجهة خدمة إعادة تعيين كلمة المرور.
/// Contract for issuing password reset tokens.
/// </summary>
public interface IPasswordResetService
{
    /// <summary>
    /// ينشئ رمز إعادة تعيين كلمة المرور للمستخدم.
    /// Generates a password reset token for the specified user.
    /// </summary>
    /// <param name="userId">معرف المستخدم. User identifier.</param>
    /// <returns>رمز إعادة التعيين. Reset token.</returns>
    Task<string> GenerateResetTokenAsync(Guid userId);
}
