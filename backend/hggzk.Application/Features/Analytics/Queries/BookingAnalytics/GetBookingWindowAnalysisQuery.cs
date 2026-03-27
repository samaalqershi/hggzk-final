using System;
using MediatR;
using YemenBooking.Application.Features.Analytics;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Analytics.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Analytics.Queries.BookingAnalytics;

/// <summary>
/// يجلب تحليل نافذة الحجز لعقار محدد ضمن نطاق زمني.
/// Retrieves booking window analysis for a specific property within a time range.
/// </summary>
public class GetBookingWindowAnalysisQuery : IRequest<ResultDto<BookingWindowDto>>
{
    /// <summary>
    /// معرف العقار المستهدف.
    /// Target property identifier.
    /// </summary>
    public Guid PropertyId { get; set; }

    /// <summary>
    /// يُهيِّئ هذا الاستعلام بالمعرف المطلوب.
    /// Initializes this query with the required identifier.
    /// </summary>
    public GetBookingWindowAnalysisQuery(Guid propertyId)
    {
        PropertyId = propertyId;
    }
} 
