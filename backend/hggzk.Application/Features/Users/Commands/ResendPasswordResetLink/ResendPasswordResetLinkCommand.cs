using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Users.Commands.ResendPasswordResetLink
{
    /// <summary>
    /// طلب إعادة إرسال رابط إعادة تعيين كلمة المرور.
    /// resend password reset link request.
    /// </summary>
    public class ResendPasswordResetLinkCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// البريد الإلكتروني
        /// email address
        /// </summary>
        public string Email { get; set; } = string.Empty;
    }
} 