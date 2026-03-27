using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Analytics.Queries.Dashboard;
using YemenBooking.Application.Features.Analytics.DTOs;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يوفّر إحصائيات لوحة التحكم للمدراء.
    /// Provides dashboard statistics for admins.
    /// </summary>
    [ApiController]
    [Route("api/admin/dashboard")]
    [Authorize(Roles = "Admin")]
    public class StatisticsController : ControllerBase
    {
        /// <summary>
        /// وسيط تنفيذ الاستعلامات والأوامر.
        /// Mediator for queries and commands.
        /// </summary>
        private readonly IMediator _mediator;

        /// <summary>
        /// ينشئ المتحكم مع حقن الوسيط.
        /// Creates the controller with the mediator dependency.
        /// </summary>
        public StatisticsController(IMediator mediator)
        {
            _mediator = mediator;
        }

        /// <summary>
        /// يعرض إحصائيات لوحة التحكم المجمعة.
        /// Returns the aggregated dashboard statistics.
        /// </summary>
        [HttpGet("stats")]
        public async Task<ActionResult<DashboardStatsDto>> GetStats()
        {
            var stats = await _mediator.Send(new GetDashboardStatsQuery());
            return Ok(stats);
        }
    }
} 
