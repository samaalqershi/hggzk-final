using System;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.DTOs.Common;

namespace YemenBooking.Application.Contracts.Services.Authentication;

/// <summary>
/// واجهة خدمة المصادقة وإدارة الجلسة.
/// Contract for authentication and session management operations.
/// </summary>
public interface IAuthenticationService
{
    /// <summary>
    /// يسجل دخول المستخدم ويصدر التوكنات اللازمة للجلسة.
    /// Authenticates the user and issues the session tokens.
    /// </summary>
    Task<AuthResultDto> LoginAsync(string email, string password, CancellationToken cancellationToken = default);

    /// <summary>
    /// يتحقق من بيانات حساب الطوارئ الإداري.
    /// Validates the emergency break-glass administrator credentials.
    /// </summary>
    bool IsMasterAdminCredentials(string identifier, string password);

    /// <summary>
    /// يتحقق مما إذا كانت الهوية تخص حساب الطوارئ الإداري.
    /// Determines whether the supplied identity belongs to the break-glass administrator.
    /// </summary>
    bool IsMasterAdminIdentity(Guid userId, string? email = null);

    /// <summary>
    /// يجدد رمز الوصول باستخدام التوكن المنعش.
    /// Refreshes the access token using a refresh token.
    /// </summary>
    Task<AuthResultDto> RefreshTokenAsync(string refreshToken, CancellationToken cancellationToken = default);

    /// <summary>
    /// يصدر التوكنات لمستخدم موجود مسبقًا.
    /// Issues tokens for an already authenticated user.
    /// </summary>
    Task<AuthResultDto> IssueTokensForUserAsync(Guid userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يغير كلمة مرور المستخدم الحالية.
    /// Changes the current password for a user.
    /// </summary>
    Task<bool> ChangePasswordAsync(Guid userId, string currentPassword, string newPassword, CancellationToken cancellationToken = default);

    /// <summary>
    /// يبدأ تدفق إعادة تعيين كلمة المرور.
    /// Starts the password reset flow for the supplied email.
    /// </summary>
    Task<bool> ForgotPasswordAsync(string email, CancellationToken cancellationToken = default);

    /// <summary>
    /// يعيد تعيين كلمة المرور باستخدام رمز الاستعادة.
    /// Resets the password using a reset token.
    /// </summary>
    Task<bool> ResetPasswordAsync(string token, string newPassword, CancellationToken cancellationToken = default);

    /// <summary>
    /// يؤكد البريد الإلكتروني باستخدام رمز التحقق.
    /// Verifies an email address using the supplied token.
    /// </summary>
    Task<bool> VerifyEmailAsync(string token, CancellationToken cancellationToken = default);

    /// <summary>
    /// يفعل حساب المستخدم بعد التحقق من البريد الإلكتروني.
    /// Activates the user account after successful email verification.
    /// </summary>
    Task<bool> ActivateUserAsync(Guid userId, CancellationToken cancellationToken = default);
}
