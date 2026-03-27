using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.SearchAndFilters.Queries.SearchLogs;
using YemenBooking.Application.Features.SearchAndFilters.DTOs;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يوفّر سجلات البحث التشغيلية للمدراء مع إمكانات الاستعراض والتحليل.
    /// Provides operational search logs for admins with review and analysis support.
    /// </summary>
    [Route("api/admin/search-logs")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class SearchLogsController : ControllerBase
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
        public SearchLogsController(IMediator mediator)
        {
            _mediator = mediator;
        }

        /// <summary>
        /// يعرض سجلات البحث مع الفلترة ودعم الصفحات.
        /// Returns search logs with filtering and pagination.
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<PaginatedResult<SearchLogDto>>> GetSearchLogs([FromQuery] GetSearchLogsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
} 
