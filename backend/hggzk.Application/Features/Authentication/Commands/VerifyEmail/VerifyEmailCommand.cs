using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Authentication;
using YemenBooking.Application.Features.Authentication.DTOs;

namespace YemenBooking.Application.Features.Authentication.Commands.VerifyEmail;

    /// <summary>
    /// طلب التحقق من البريد الإلكتروني.
    /// email verification request.
    /// </summary>
public class VerifyEmailCommand : IRequest<ResultDto<VerifyEmailResponse>>
{
    /// <summary>
    /// معرّف المستخدم
    /// user ID
    /// </summary>
    public Guid UserId { get; set; }
    
    /// <summary>
    /// رمز التحقق
    /// verification token
    /// </summary>
    public string VerificationToken { get; set; } = string.Empty;
}