using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Authentication.Commands.Login;
using YemenBooking.Application.Features.Authentication.Commands.RefreshToken;
using YemenBooking.Application.Features.Authentication.Commands.PasswordReset;
using YemenBooking.Application.Features.Authentication.Commands.ChangePassword;
using YemenBooking.Application.Features.Authentication.Commands.VerifyEmail;
using YemenBooking.Application.Features.Authentication.Commands.Account;
using YemenBooking.Application.Features.Authentication.Commands.RegisterOwner;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Authentication.DTOs;
using YemenBooking.Application.Features.Users.Commands.ResendPasswordResetLink;

namespace YemenBooking.Api.Controllers.Common
{
    /// <summary>
    /// نقاط المصادقة واستعادة الحساب والتحقق من البريد.
    /// Authentication, recovery, and email verification endpoints.
    /// </summary>
    public class AuthController : BaseCommonController
    {
        /// <summary>
        /// ينشئ متحكم المصادقة مع المرسل الوسيط.
        /// Creates the authentication controller with the mediator.
        /// </summary>
        public AuthController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// يسجل دخول المستخدم ويعيد بيانات المصادقة.
        /// Logs the user in and returns authentication data.
        /// </summary>
        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يسجل دخول البوابة عبر مزود اجتماعي.
        /// Performs portal social login.
        /// </summary>
        [AllowAnonymous]
        [HttpPost("portal-social-login")]
        public async Task<ActionResult<ResultDto<AuthResultDto>>> PortalSocialLogin([FromBody] PortalSocialLoginCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يكمل ملف المالك بعد التسجيل.
        /// Completes the owner profile after registration.
        /// </summary>
        [Authorize(Roles = "Owner")]
        [HttpPost("complete-owner-profile")]
        public async Task<ActionResult<ResultDto<AuthResultDto>>> CompleteOwnerProfile([FromBody] CompleteOwnerProfileCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يجدد رمز المصادقة باستخدام رمز التحديث.
        /// Refreshes the authentication token using a refresh token.
        /// </summary>
        [AllowAnonymous]
        [HttpPost("refresh-token")]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يرسل رابط إعادة تعيين كلمة المرور.
        /// Sends a password reset link.
        /// </summary>
        [AllowAnonymous]
        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعيد تعيين كلمة المرور باستخدام الرمز المرسل.
        /// Resets the password using the provided token.
        /// </summary>
        [AllowAnonymous]
        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعيد إرسال رابط التحقق من البريد الإلكتروني.
        /// Resends the email verification link.
        /// </summary>
        [AllowAnonymous]
        [HttpPost("resend-email-verification")]
        public async Task<IActionResult> ResendEmailVerification([FromBody] ResendEmailVerificationLinkCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعيد إرسال رابط استعادة كلمة المرور.
        /// Resends the password reset link.
        /// </summary>
        [AllowAnonymous]
        [HttpPost("resend-password-reset")]
        public async Task<IActionResult> ResendPasswordReset([FromBody] ResendPasswordResetLinkCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يتحقق من عنوان البريد الإلكتروني للمستخدم.
        /// Verifies the user's email address.
        /// </summary>
        [AllowAnonymous]
        [HttpPost("verify-email")]
        public async Task<IActionResult> VerifyEmail([FromBody] VerifyEmailCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يغيّر كلمة مرور المستخدم الحالي.
        /// Changes the current user's password.
        /// </summary>
        [HttpPost("change-password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحذف حساب المالك.
        /// Deletes the owner account.
        /// </summary>
        [Authorize(Roles = "Owner")]
        [HttpPost("account/delete")]
        public async Task<ActionResult<ResultDto<DeleteAccountResponse>>> DeleteOwnerAccount([FromBody] DeleteOwnerAccountCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }
    }
} 
