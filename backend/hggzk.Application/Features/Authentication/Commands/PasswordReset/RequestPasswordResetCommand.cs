using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Authentication;
using System.ComponentModel.DataAnnotations;
using YemenBooking.Application.Features.Authentication.DTOs;

namespace YemenBooking.Application.Features.Authentication.Commands.PasswordReset
{
    /// <summary>
    /// طلب طلب إعادة تعيين كلمة المرور.
    /// password reset request request.
    /// </summary>
    public class RequestPasswordResetCommand : IRequest<ResultDto<RequestPasswordResetResponse>>
    {
        /// <summary>
        /// البريد الإلكتروني أو رقم الهاتف
        /// email address or phone number
        /// </summary>
        [Required(ErrorMessage = "البريد الإلكتروني أو رقم الهاتف مطلوب")]
        public string EmailOrPhone { get; set; } = string.Empty;
    }
}