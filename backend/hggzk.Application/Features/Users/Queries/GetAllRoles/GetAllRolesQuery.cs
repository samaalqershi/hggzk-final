using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Users;
using YemenBooking.Application.Features.Users.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Users.Queries.GetAllRoles;

/// <summary>
/// استعلام جلب جميع الأدوار.
/// all roles query.
/// </summary>
public class GetAllRolesQuery : IRequest<PaginatedResult<RoleDto>>
{
    /// <summary>
    /// رقم الصفحة
    /// page number
    /// </summary>
    public int PageNumber { get; set; } = 1;
    /// <summary>
    /// حجم الصفحة
    /// page size
    /// </summary>
    public int PageSize { get; set; } = 10;
}
