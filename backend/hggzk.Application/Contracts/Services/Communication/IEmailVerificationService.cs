using System;
using System.Threading.Tasks;

namespace YemenBooking.Application.Contracts.Services.Communication
{
    /// <summary>
    /// واجهة خدمة التحقق من البريد الإلكتروني. Email verification service interface.
    /// </summary>
    public interface IEmailVerificationService
    {
        /// <summary>
        /// إرسال رمز التحقق عبر البريد الإلكتروني. Send verification code via email.
        /// </summary>
        /// <param name="email">البريد الإلكتروني. Email address.</param>
        /// <param name="verificationCode">رمز التحقق. Verification code.</param>
        /// <returns>نتيجة العملية. Operation result.</returns>
        Task<bool> SendVerificationEmailAsync(string email, string verificationCode);

        /// <summary>
        /// التحقق من صحة رمز التحقق. Verify the verification code.
        /// </summary>
        /// <param name="email">البريد الإلكتروني. Email address.</param>
        /// <param name="verificationCode">رمز التحقق. Verification code.</param>
        /// <returns>نتيجة التحقق. Verification result.</returns>
        Task<bool> VerifyCodeAsync(string email, string verificationCode);

        /// <summary>
        /// إنشاء رمز تحقق جديد. Generate new verification code.
        /// </summary>
        /// <returns>رمز التحقق. Verification code.</returns>
        string GenerateVerificationCode();

        /// <summary>
        /// التحقق من انتهاء صلاحية رمز التحقق. Check if verification code is expired.
        /// </summary>
        /// <param name="email">البريد الإلكتروني. Email address.</param>
        /// <param name="verificationCode">رمز التحقق. Verification code.</param>
        /// <returns>true إذا كان منتهي الصلاحية. true when the code is expired.</returns>
        Task<bool> IsCodeExpiredAsync(string email, string verificationCode);

    }
}
