using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Authentication.Commands.PasswordReset;

    /// <summary>
    /// طلب إعادة تعيين كلمة المرور.
    /// password reset request.
    /// </summary>
public class ResetPasswordCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// الرمز
    /// token
    /// </summary>
    public string Token { get; set; } = string.Empty;
    /// <summary>
    /// كلمة المرور الجديدة
    /// new password
    /// </summary>
    public string NewPassword { get; set; } = string.Empty;
}
