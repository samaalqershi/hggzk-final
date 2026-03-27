using MediatR;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.SearchAndFilters.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.SearchAndFilters.Queries.GetPopularDestinations;

/// <summary>
/// استعلام جلب الشائعة destinations.
/// Get Popular Destinations query.
/// </summary>
public class GetPopularDestinationsQuery : IRequest<ResultDto<List<PopularDestinationDto>>>
{
    /// <summary>
    /// القيمة الخاصة بـ العدد.
    /// Count value.
    /// </summary>
    public int Count { get; set; } = 10;
}
