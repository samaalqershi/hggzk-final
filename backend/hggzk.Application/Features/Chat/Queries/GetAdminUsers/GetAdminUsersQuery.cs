using YemenBooking.Application.Features.Users.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Chat.Queries.GetAdminUsers
{
    using System.Collections.Generic;
    using MediatR;
    using YemenBooking.Application.Common.Models;
    using YemenBooking.Application.Features.Users;

    /// <summary>
    /// يمثل استعلامًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area query.
    /// </summary>
    public class GetAdminUsersQuery : IRequest<ResultDto<IEnumerable<ChatUserDto>>>
    {
    }
}
