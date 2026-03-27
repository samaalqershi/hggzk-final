using System;
using MediatR;
using YemenBooking.Application.Features.Analytics;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Analytics.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Analytics.Queries.FinancialAnalytics;

    /// <summary>
    /// يمثل استعلامًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area query.
    /// </summary>
public class GetPlatformRevenueBreakdownQuery : IRequest<ResultDto<RevenueBreakdownDto>>
{
    /// <summary>
    /// النطاق الزمني
    /// Date range
    /// </summary>
    public DateRangeDto Range { get; set; }

    /// <summary>
    /// يُهيِّئ هذا الاستعلام بالقيم الأساسية المطلوبة.
    /// Initializes this query with the required values.
    /// </summary>
    public GetPlatformRevenueBreakdownQuery(DateRangeDto range)
    {
        Range = range;
    }
} 