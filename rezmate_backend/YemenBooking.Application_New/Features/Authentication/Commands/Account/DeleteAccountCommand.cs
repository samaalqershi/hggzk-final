using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Authentication;
using System;
using YemenBooking.Application.Features.Authentication.DTOs;

namespace YemenBooking.Application.Features.Authentication.Commands.Account
{
    /// <summary>
    /// أمر حذف حساب المستخدم
    /// Command to delete user account
    /// </summary>
    public class DeleteAccountCommand : IRequest<ResultDto<DeleteAccountResponse>>
{
    /// <summary>
    /// معرف المستخدم
    /// </summary>
    public Guid UserId { get; set; }
    
    /// <summary>
    /// كلمة المرور للتأكيد
    /// </summary>
    public string? Password { get; set; }

    /// <summary>
    /// مزود تسجيل الدخول الاجتماعي لتأكيد الهوية (google|apple|facebook)
    /// </summary>
    public string? SocialProvider { get; set; }

    /// <summary>
    /// توكن مزود تسجيل الدخول الاجتماعي لتأكيد الهوية
    /// </summary>
    public string? SocialToken { get; set; }

    /// <summary>
    /// Nonce خام من Apple (عند الحاجة)
    /// </summary>
    public string? SocialNonce { get; set; }
    
        /// <summary>
        /// سبب حذف الحساب
        /// </summary>
        public string? Reason { get; set; }
    }
}
