using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Users;
using YemenBooking.Application.Features.Users.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Users.Queries.GetUserSettings;

    /// <summary>
    /// استعلام إعدادات المستخدم.
    /// user settings query.
    /// </summary>
public class GetUserSettingsQuery : IRequest<ResultDto<UserSettingsDto>>
{
    /// <summary>
    /// معرّف المستخدم
    /// user ID
    /// </summary>
    public Guid UserId { get; set; }
}