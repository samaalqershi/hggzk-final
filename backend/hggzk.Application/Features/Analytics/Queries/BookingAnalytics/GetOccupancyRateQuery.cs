using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Analytics.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Analytics.Queries.BookingAnalytics
{
/// <summary>
/// يجلب معدل الإشغال لعقار محدد ضمن نطاق زمني.
/// Retrieves occupancy rate for a specific property within a date range.
/// </summary>
public class GetOccupancyRateQuery : IRequest<decimal>
{
    /// <summary>
    /// معرف العقار المستهدف.
    /// Target property identifier.
    /// </summary>
    public Guid PropertyId { get; set; }

    /// <summary>
    /// النطاق الزمني المعتمد للحساب.
    /// Date range used for the calculation.
    /// </summary>
    public DateRangeDto Range { get; set; }

    /// <summary>
    /// يُهيِّئ هذا الاستعلام بالمعطيات المطلوبة.
    /// Initializes this query with the required data.
    /// </summary>
    public GetOccupancyRateQuery(Guid propertyId, DateRangeDto range)
    {
        PropertyId = propertyId;
            Range = range;
        }
    }
} 
