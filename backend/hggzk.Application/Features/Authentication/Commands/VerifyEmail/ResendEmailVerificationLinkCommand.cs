using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Authentication.Commands.VerifyEmail
{
    /// <summary>
    /// طلب إعادة إرسال رابط التحقق من البريد الإلكتروني.
    /// resend email verification link request.
    /// </summary>
    public class ResendEmailVerificationLinkCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// البريد الإلكتروني
        /// email address
        /// </summary>
        public string Email { get; set; } = string.Empty;
    }
} 