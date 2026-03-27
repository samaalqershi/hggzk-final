using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Authentication.DTOs;

namespace YemenBooking.Application.Features.Authentication.Commands.Login;

/// <summary>
/// طلب تسجيل الدخول.
/// login request.
/// </summary>
public class LoginCommand : IRequest<ResultDto<AuthResultDto>>
{
    /// <summary>
    /// البريد الإلكتروني
    /// email address
    /// </summary>
    public string Email { get; set; } = string.Empty;
    /// <summary>
    /// كلمة المرور
    /// password
    /// </summary>
    public string Password { get; set; } = string.Empty;
    /// <summary>
    /// تذكرني
    /// remember me
    /// </summary>
    public bool RememberMe { get; set; } = false;
}
