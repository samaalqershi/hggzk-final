using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties.DTOs;

namespace YemenBooking.Application.Features.Properties.Queries.GetPendingProperties;

/// <summary>
/// استعلام للحصول على العقارات قيد المراجعة.
/// Query for retrieving properties pending approval.
/// </summary>
public class GetPendingPropertiesQuery : IRequest<PaginatedResult<YemenBooking.Application.Features.Properties.DTOs.PropertyDto>>
{
    /// <summary>
    /// رقم الصفحة.
    /// page number.
    /// </summary>
    public int PageNumber { get; set; } = 1;

    /// <summary>
    /// حجم الصفحة.
    /// page size.
    /// </summary>
    public int PageSize { get; set; } = 10;
} 
