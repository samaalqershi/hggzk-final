using System;
using MediatR;
using YemenBooking.Application.Features.Analytics;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Analytics.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Analytics.Queries.PropertyAnalytics;

/// <summary>
/// يجلب مقارنة أداء العقار بين فترتين زمنيتين.
/// Retrieves property performance comparison between two time ranges.
/// </summary>
public class GetPropertyPerformanceComparisonQuery : IRequest<ResultDto<PerformanceComparisonDto>>
{
    /// <summary>
    /// معرف العقار المستهدف.
    /// Target property identifier.
    /// </summary>
    public Guid PropertyId { get; set; }

    /// <summary>
    /// النطاق الزمني الحالي للمقارنة.
    /// Current date range for the comparison.
    /// </summary>
    public DateRangeDto CurrentRange { get; set; }

    /// <summary>
    /// النطاق الزمني السابق للمقارنة.
    /// Previous date range for the comparison.
    /// </summary>
    public DateRangeDto PreviousRange { get; set; }

    /// <summary>
    /// يُهيِّئ هذا الاستعلام بجميع نطاقات المقارنة المطلوبة.
    /// Initializes this query with the required comparison ranges.
    /// </summary>
    public GetPropertyPerformanceComparisonQuery(Guid propertyId, DateRangeDto currentRange, DateRangeDto previousRange)
    {
        PropertyId = propertyId;
        CurrentRange = currentRange;
        PreviousRange = previousRange;
    }
} 
