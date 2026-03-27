using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.SearchAndFilters.Queries.FilterAnalytics;
using YemenBooking.Application.Features.Analytics.DTOs;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يوفّر تحليلات لاستخدام الفلاتر الديناميكية الخاصة بالوحدات.
    /// Provides analytics for unit dynamic filter usage.
    /// </summary>
    [Route("api/admin/search-analytics/unit-dynamic-filters")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class SearchFiltersAnalyticsController : ControllerBase
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
        public SearchFiltersAnalyticsController(IMediator mediator)
        {
            _mediator = mediator;
        }

        /// <summary>
        /// يعرض تحليلات الفلاتر الديناميكية للوحدات.
        /// Returns analytics for unit dynamic filters.
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<ResultDto<List<FieldFilterAnalyticsDto>>>> GetUnitDynamicFilterAnalytics(
            [FromQuery] GetUnitDynamicFilterAnalyticsQuery query,
            CancellationToken cancellationToken)
        {
            var result = await _mediator.Send(query, cancellationToken);
            return Ok(result);
        }
    }
} 
