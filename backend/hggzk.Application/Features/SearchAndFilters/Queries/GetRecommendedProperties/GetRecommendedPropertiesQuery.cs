using MediatR;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.SearchAndFilters;
using YemenBooking.Application.Features.SearchAndFilters.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.SearchAndFilters.Queries.GetRecommendedProperties;

/// <summary>
/// استعلام جلب الموصى بها العقارات.
/// Get Recommended Properties query.
/// </summary>
public class GetRecommendedPropertiesQuery : IRequest<ResultDto<PaginatedResult<PropertySearchResultDto>>>
{
    /// <summary>
    /// معرّف المستخدم.
    /// User identifier.
    /// </summary>
    public Guid UserId { get; set; }
    
    /// <summary>
    /// القيمة الخاصة بـ العدد.
    /// Count value.
    /// </summary>
    public int Count { get; set; } = 5;
    
    /// <summary>
    /// القيمة الخاصة بـ المدينة.
    /// City value.
    /// </summary>
    public string? City { get; set; }
}