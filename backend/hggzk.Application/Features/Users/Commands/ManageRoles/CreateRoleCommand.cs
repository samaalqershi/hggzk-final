using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Users.Commands.ManageRoles;

/// <summary>
/// طلب إنشاء دور.
/// role creation request.
/// </summary>
public class CreateRoleCommand : IRequest<ResultDto<Guid>>
{
    /// <summary>
    /// الاسم
    /// name
    /// </summary>
    public string Name { get; set; } = string.Empty;
}
