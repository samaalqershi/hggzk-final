using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.SearchAndFilters.Commands.Search;
using YemenBooking.Application.Features.Units.Queries.SearchUnits;

namespace YemenBooking.Api.Controllers.Common
{
    /// <summary>
    /// نقاط البحث المشتركة للعقارات والوحدات.
    /// Shared search endpoints for properties and units.
    /// </summary>
    public class SearchController : BaseCommonController
    {
        /// <summary>
        /// ينشئ متحكم البحث المشترك مع المرسل الوسيط.
        /// Creates the shared search controller with the mediator.
        /// </summary>
        public SearchController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// يبحث في العقارات باستخدام معايير ديناميكية.
        /// Searches properties using dynamic criteria.
        /// </summary>
        [HttpPost("properties")]
        public async Task<IActionResult> SearchProperties([FromBody] SearchPropertiesCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يبحث في الوحدات باستخدام معايير ديناميكية.
        /// Searches units using dynamic criteria.
        /// </summary>
        [HttpPost("units")]
        public async Task<IActionResult> SearchUnits([FromBody] SearchUnitsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
} 
