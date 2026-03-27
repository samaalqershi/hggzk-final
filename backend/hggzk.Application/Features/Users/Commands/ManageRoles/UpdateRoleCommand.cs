using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Users.Commands.ManageRoles;

/// <summary>
/// طلب تحديث دور.
/// role update request.
/// </summary>
public class UpdateRoleCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف الدور
    /// role ID
    /// </summary>
    public Guid RoleId { get; set; }
    /// <summary>
    /// الاسم
    /// name
    /// </summary>
    public string Name { get; set; } = string.Empty;
}
