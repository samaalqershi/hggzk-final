using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.SearchAndFilters.Queries.GetPopularDestinations;
using YemenBooking.Application.Features.SearchAndFilters.Queries.GetRecommendedProperties;
using YemenBooking.Application.Common.Models;
using System.Collections.Generic;
using YemenBooking.Application.Features.SearchAndFilters.DTOs;
using YemenBooking.Application.Features.SearchAndFilters.Queries.GetSearchFilters;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// يوفر فلاتر البحث والاقتراحات المرتبطة بها.
    /// Exposes search filters and related discovery endpoints.
    /// </summary>
    public class SearchFiltersController : BaseClientController
    {
        /// <summary>
        /// ينشئ مثيلاً جديداً من <see cref="SearchFiltersController"/>.
        /// Creates a new <see cref="SearchFiltersController"/> instance.
        /// </summary>
        public SearchFiltersController(IMediator mediator) : base(mediator)
        {
        }

        /// <summary>
        /// يجلب الوجهات الشائعة.
        /// Retrieves popular destinations.
        /// </summary>
        /// <returns>قائمة الوجهات الشائعة.</returns>
        [HttpGet("popular-destinations")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<List<PopularDestinationDto>>>> GetPopularDestinations()
        {
            var query = new GetPopularDestinationsQuery();
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب العقارات الموصى بها.
        /// Retrieves recommended properties.
        /// </summary>
        /// <param name="query">معايير التوصية.</param>
        /// <returns>قائمة العقارات الموصى بها.</returns>
        [HttpGet("recommended-properties")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<PaginatedResult<PropertySearchResultDto>>>> GetRecommendedProperties([FromQuery] GetRecommendedPropertiesQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب فلاتر البحث المتاحة.
        /// Retrieves available search filters.
        /// </summary>
        /// <returns>فلاتر البحث المتاحة.</returns>
        [HttpGet("filters")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<SearchFiltersDto>>> GetSearchFilters([FromQuery] GetSearchFiltersQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
}
