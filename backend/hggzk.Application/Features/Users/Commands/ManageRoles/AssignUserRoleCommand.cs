using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Users.Commands.ManageRoles;

    /// <summary>
    /// طلب إسناد دور لمستخدم.
    /// user role assignment request.
    /// </summary>
public class AssignUserRoleCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف المستخدم
    /// user ID
    /// </summary>
    public Guid UserId { get; set; }

    /// <summary>
    /// معرّف الدور
    /// role ID
    /// </summary>
    public Guid RoleId { get; set; }
} 