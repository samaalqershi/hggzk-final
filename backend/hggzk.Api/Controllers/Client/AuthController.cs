using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Authentication.Commands.Login;
using YemenBooking.Application.Features.Authentication.Commands.Register;
using YemenBooking.Application.Features.Authentication.Commands.RefreshToken;
using YemenBooking.Application.Features.Authentication.Commands.Logout;
using YemenBooking.Application.Features.Authentication.Commands.ChangePassword;
using YemenBooking.Application.Features.Users.Commands.ResendPasswordResetLink;
using YemenBooking.Application.Features.Authentication.Commands.PasswordReset;
using YemenBooking.Application.Features.Authentication.Commands.UpdateUser;
using YemenBooking.Application.Features.Authentication.Commands.UpdateProfile;
using YemenBooking.Application.Features.Authentication.Commands.VerifyEmail;
using YemenBooking.Application.Features.Authentication.Commands.Account;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Authentication.DTOs;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// متحكم المصادقة وإدارة الحسابات الخاصة بالعميل.
    /// Client authentication and account-management controller.
    /// </summary>
    public class AuthController : BaseClientController
    {
        /// <summary>
        /// يهيئ نسخة جديدة من [AuthController].
        /// Initializes a new instance of [AuthController].
        /// </summary>
        /// <param name="mediator">وسيط MediatR المستخدم لمعالجة الأوامر. MediatR mediator used to handle commands.</param>
        public AuthController(IMediator mediator) : base(mediator)
        {
        }

        /// <summary>
        /// يسجّل دخول المستخدم إلى النظام.
        /// Authenticates the user and starts a session.
        /// </summary>
        /// <param name="command">بيانات تسجيل الدخول. Login details.</param>
        /// <returns>بيانات المستخدم ومعلومات الجلسة. User data and session information.</returns>
        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<ClientLoginUserResponse>>> Login([FromBody] ClientLoginUserCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// ينشئ حساب مستخدم جديد.
        /// Registers a new user account.
        /// </summary>
        /// <param name="command">بيانات التسجيل. Registration details.</param>
        /// <returns>نتيجة التسجيل. Registration result.</returns>
        [HttpPost("register")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<RegisterUserResponse>>> Register([FromBody] RegisterUserCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يجدد رمز الوصول.
        /// Refreshes the access token.
        /// </summary>
        /// <param name="command">طلب تجديد الرمز. Refresh token request.</param>
        /// <returns>رمز وصول جديد. A new access token.</returns>
        [HttpPost("refresh-token")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<RefreshTokenResponse>>> RefreshToken([FromBody] RefreshTokenCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// ينهي جلسة المستخدم الحالية.
        /// Ends the current user session.
        /// </summary>
        /// <param name="command">بيانات تسجيل الخروج. Logout details.</param>
        /// <returns>نتيجة تسجيل الخروج. Logout result.</returns>
        [HttpPost("logout")]
        public async Task<ActionResult<ResultDto<LogoutResponse>>> Logout([FromBody] LogoutCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يغيّر كلمة مرور المستخدم.
        /// Changes the user's password.
        /// </summary>
        /// <param name="command">بيانات تغيير كلمة المرور. Password change details.</param>
        /// <returns>نتيجة تغيير كلمة المرور. Password change result.</returns>
        [HttpPost("change-password")]
        public async Task<ActionResult<ResultDto<ChangePasswordResponse>>> ChangePassword([FromBody] ChangePasswordCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يطلب إعادة تعيين كلمة المرور.
        /// Requests a password reset.
        /// </summary>
        /// <param name="command">بيانات الطلب. Reset request details.</param>
        /// <returns>نتيجة الطلب. Request result.</returns>
        [HttpPost("request-password-reset")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<RequestPasswordResetResponse>>> RequestPasswordReset([FromBody] RequestPasswordResetCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحدّث ملف المستخدم الشخصي.
        /// Updates the user profile.
        /// </summary>
        /// <param name="command">بيانات التحديث. Update details.</param>
        /// <returns>نتيجة التحديث. Update result.</returns>
        [HttpPut("profile")]
        public async Task<ActionResult<ResultDto<UpdateUserProfileResponse>>> UpdateProfile([FromBody] UpdateUserProfileCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحدّث ملف المستخدم الشخصي بنسخة العميل.
        /// Updates the user profile using the client-specific flow.
        /// </summary>
        /// <param name="command">بيانات التحديث. Update details.</param>
        /// <returns>نتيجة التحديث. Update result.</returns>
        [HttpPut("client-profile")]
        public async Task<ActionResult<ResultDto<ClientUserProfileResponse>>> UpdateClientProfile([FromBody] ClientUpdateUserProfileCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يرفع صورة الملف الشخصي.
        /// Uploads the user profile image.
        /// </summary>
        /// <param name="file">ملف الصورة. Image file.</param>
        /// <returns>رابط الصورة الجديد. The newly stored image URL.</returns>
        [HttpPost("profile/image")]
        [RequestSizeLimit(6 * 1024 * 1024)]
        [Consumes("multipart/form-data")]
        public async Task<ActionResult<ResultDto<UploadUserProfileImageResponse>>> UploadProfileImage(IFormFile file)
        {
            if (file == null || file.Length == 0)
            {
                return Ok(ResultDto<UploadUserProfileImageResponse>.Failed("لا توجد صورة مرفوعة", "FILE_EMPTY"));
            }

            using var ms = new MemoryStream();
            await file.CopyToAsync(ms);
            var bytes = ms.ToArray();

            // Infer UserId from the current context when available.
            // استنتاج UserId من السياق عند توفره.
            var userIdClaim = User?.Claims?.FirstOrDefault(c => c.Type == "sub" || c.Type.EndsWith("/nameidentifier"))?.Value;
            Guid.TryParse(userIdClaim, out var userId);

            var command = new UploadUserProfileImageCommand
            {
                UserId = userId,
                FileName = file.FileName,
                ContentType = file.ContentType ?? "application/octet-stream",
                FileBytes = bytes,
            };

            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يتحقق من البريد الإلكتروني للمستخدم.
        /// Verifies the user's email address.
        /// </summary>
        /// <param name="command">بيانات التحقق. Verification details.</param>
        /// <returns>نتيجة التحقق. Verification result.</returns>
        [HttpPost("verify-email")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<VerifyEmailResponse>>> VerifyEmail([FromBody] VerifyEmailCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعيد إرسال رمز التحقق بالبريد الإلكتروني.
        /// Resends the email verification code.
        /// </summary>
        /// <param name="command">بيانات الإرسال. Resend details.</param>
        /// <returns>نتيجة الإرسال. Resend result.</returns>
        [HttpPost("resend-email-verification")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<ResendEmailVerificationResponse>>> ResendEmailVerification([FromBody] ResendEmailVerificationCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحذف حساب المستخدم.
        /// Deletes the user account.
        /// </summary>
        /// <param name="command">بيانات حذف الحساب. Account deletion details.</param>
        /// <returns>نتيجة الحذف. Deletion result.</returns>
        [HttpDelete("account")]
        public async Task<ActionResult<ResultDto<DeleteAccountResponse>>> DeleteAccount([FromBody] DeleteAccountCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحذف الحساب عبر نقطة نهاية POST البديلة.
        /// Deletes the account through the alternative POST endpoint.
        /// </summary>
        [HttpPost("account/delete")]
        public async Task<ActionResult<ResultDto<DeleteAccountResponse>>> DeleteAccountPost([FromBody] DeleteAccountCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يسجّل الدخول عبر مزود خارجي.
        /// Performs social login through an external provider.
        /// </summary>
        /// <param name="command">المزود ورمز التحقق. Provider and verification token.</param>
        /// <returns>بيانات تسجيل الدخول. Login response data.</returns>
        [HttpPost("social-login")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<ClientLoginUserResponse>>> SocialLogin([FromBody] YemenBooking.Application.Features.Authentication.Commands.Login.SocialLoginCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }
    }
}
