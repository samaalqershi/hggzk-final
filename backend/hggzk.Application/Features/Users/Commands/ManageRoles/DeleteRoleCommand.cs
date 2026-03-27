using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Users.Commands.ManageRoles;

/// <summary>
/// طلب حذف دور.
/// role deletion request.
/// </summary>
public class DeleteRoleCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف الدور
    /// role ID
    /// </summary>
    public Guid RoleId { get; set; }
}
