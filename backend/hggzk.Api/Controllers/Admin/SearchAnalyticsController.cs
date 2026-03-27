using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.SearchAndFilters.Queries.SearchAnalytics;
using YemenBooking.Application.Features.Analytics.DTOs;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يوفّر تحليلات البحث ومؤشرات الاستخدام للمدراء.
    /// Provides search analytics and usage indicators for admins.
    /// </summary>
    [Route("api/admin/search-analytics")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class SearchAnalyticsController : ControllerBase
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
        public SearchAnalyticsController(IMediator mediator)
        {
            _mediator = mediator;
        }

        /// <summary>
        /// يعرض تحليلات البحث مع إمكانية التصفية بالتواريخ.
        /// Returns search analytics with optional date filters.
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<ResultDto<SearchAnalyticsDto>>> GetSearchAnalytics([FromQuery] GetSearchAnalyticsQuery query, CancellationToken cancellationToken)
        {
            var result = await _mediator.Send(query, cancellationToken);
            return Ok(result);
        }
    }
} 
