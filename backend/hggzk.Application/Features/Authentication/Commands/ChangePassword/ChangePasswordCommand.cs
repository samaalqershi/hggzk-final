using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Authentication;
using YemenBooking.Application.Features.Authentication.DTOs;

namespace YemenBooking.Application.Features.Authentication.Commands.ChangePassword
{
    /// <summary>
    /// طلب تغيير كلمة المرور.
    /// password change request.
    /// </summary>
    public class ChangePasswordCommand : IRequest<ResultDto<ChangePasswordResponse>>
{
    /// <summary>
    /// معرّف المستخدم
    /// user ID
    /// </summary>
    public Guid UserId { get; set; }
    
    /// <summary>
    /// كلمة المرور الحالية
    /// current password
    /// </summary>
    public string CurrentPassword { get; set; } = string.Empty;
    
        /// <summary>
        /// كلمة المرور الجديدة
        /// new password
        /// </summary>
        public string NewPassword { get; set; } = string.Empty;
    }
}