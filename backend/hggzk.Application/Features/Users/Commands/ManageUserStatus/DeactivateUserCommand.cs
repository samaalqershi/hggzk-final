using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Users.Commands.ManageUserStatus;

    /// <summary>
    /// طلب تعطيل مستخدم.
    /// user deactivation request.
    /// </summary>
public class DeactivateUserCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف المستخدم
    /// user ID
    /// </summary>
    public Guid UserId { get; set; }
} 
