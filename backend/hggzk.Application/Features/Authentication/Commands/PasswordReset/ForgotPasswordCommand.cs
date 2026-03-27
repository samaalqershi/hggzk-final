using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Authentication.Commands.PasswordReset;

    /// <summary>
    /// طلب استعادة كلمة المرور.
    /// password recovery request.
    /// </summary>
public class ForgotPasswordCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// البريد الإلكتروني
    /// email address
    /// </summary>
    public string Email { get; set; } = string.Empty;
}
