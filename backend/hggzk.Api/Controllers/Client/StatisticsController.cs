using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Users.Queries.GetUserStatistics;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Users.DTOs;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// يوفر إحصائيات المستخدم للعميل.
    /// Exposes user statistics for clients.
    /// </summary>
    public class StatisticsController : BaseClientController
    {
        /// <summary>
        /// ينشئ مثيلاً جديداً من <see cref="StatisticsController"/>.
        /// Creates a new <see cref="StatisticsController"/> instance.
        /// </summary>
        public StatisticsController(IMediator mediator) : base(mediator)
        {
        }

        /// <summary>
        /// يجلب إحصائيات المستخدم.
        /// Retrieves user statistics.
        /// </summary>
        /// <param name="query">معايير الإحصائيات.</param>
        /// <returns>إحصائيات المستخدم.</returns>
        [HttpGet("user")]
        public async Task<ActionResult<ResultDto<UserStatisticsDto>>> GetUserStatistics([FromQuery] GetUserStatisticsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
}
