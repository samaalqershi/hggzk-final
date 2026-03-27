using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Authentication;
using System;
using YemenBooking.Application.Features.Authentication.DTOs;

namespace YemenBooking.Application.Features.Authentication.Commands.Account
{
    /// <summary>
    /// طلب حذف الحساب.
    /// account deletion request.
    /// </summary>
    public class DeleteAccountCommand : IRequest<ResultDto<DeleteAccountResponse>>
{
    /// <summary>
    /// معرّف المستخدم
    /// user ID
    /// </summary>
    public Guid UserId { get; set; }
    
    /// <summary>
    /// كلمة المرور
    /// password
    /// </summary>
    public string? Password { get; set; }

    /// <summary>
    /// مزوّد تسجيل الدخول الاجتماعي
    /// social login provider
    /// </summary>
    public string? SocialProvider { get; set; }

    /// <summary>
    /// رمز تسجيل الدخول الاجتماعي
    /// social login token
    /// </summary>
    public string? SocialToken { get; set; }

    /// <summary>
    /// nonce تسجيل الدخول الاجتماعي
    /// social login nonce
    /// </summary>
    public string? SocialNonce { get; set; }
    
        /// <summary>
        /// السبب
        /// reason
        /// </summary>
        public string? Reason { get; set; }
    }
}
