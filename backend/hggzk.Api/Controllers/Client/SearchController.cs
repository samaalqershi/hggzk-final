using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.SearchAndFilters.Queries.SearchSuggestions;
using YemenBooking.Application.Common.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// يوفر اقتراحات البحث للعميل.
    /// Exposes client search suggestions.
    /// </summary>
    [ApiController]
    [Route("api/client/[controller]")]
    [AllowAnonymous]
    public class SearchController : BaseClientController
    {
        /// <summary>
        /// ينشئ مثيلاً جديداً من <see cref="SearchController"/>.
        /// Creates a new <see cref="SearchController"/> instance.
        /// </summary>
        public SearchController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// يجلب اقتراحات بحث اعتماداً على المدخلات السابقة.
        /// Retrieves search suggestions based on previous input.
        /// </summary>
        /// <param name="query">معايير الاقتراح.</param>
        /// <returns>قائمة اقتراحات نصية.</returns>
        [HttpGet("suggestions")]
        public async Task<ActionResult<ResultDto<List<string>>>> GetSearchSuggestions([FromQuery] GetSearchSuggestionsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
}
