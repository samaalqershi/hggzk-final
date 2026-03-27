using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Users;
using YemenBooking.Application.Features.Users.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Users.Queries.GetUsersByRole;

    /// <summary>
    /// استعلام المستخدمون حسب الدور.
    /// users by role query.
    /// </summary>
public class GetUsersByRoleQuery : IRequest<PaginatedResult<UserDto>>
{
    /// <summary>
    /// اسم الدور
    /// role name
    /// </summary>
    public string RoleName { get; set; } = string.Empty;

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