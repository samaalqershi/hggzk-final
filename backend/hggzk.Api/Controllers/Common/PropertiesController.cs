using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Properties.Queries.SearchProperties;

namespace YemenBooking.Api.Controllers.Common
{
    /// <summary>
    /// البحث المشترك عن العقارات.
    /// Shared property search endpoint.
    /// </summary>
    public class PropertiesController : BaseCommonController
    {
        /// <summary>
        /// ينشئ متحكم البحث المشترك مع المرسل الوسيط.
        /// Creates the shared search controller with the mediator.
        /// </summary>
        public PropertiesController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// يبحث في العقارات باستخدام الفلاتر والموقع والمسافة.
        /// Searches properties using filters, location, and distance.
        /// </summary>
        [HttpGet("search")]
        public async Task<IActionResult> SearchProperties([FromQuery] SearchPropertiesQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
} 
