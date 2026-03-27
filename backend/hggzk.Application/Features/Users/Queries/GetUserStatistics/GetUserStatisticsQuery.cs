using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Users.DTOs;

namespace YemenBooking.Application.Features.Users.Queries.GetUserStatistics;

    /// <summary>
    /// استعلام إحصائيات المستخدم.
    /// user statistics query.
    /// </summary>
public class GetUserStatisticsQuery : IRequest<ResultDto<UserStatisticsDto>>
{
    /// <summary>
    /// معرّف المستخدم
    /// user ID
    /// </summary>
    public Guid UserId { get; set; }
}
