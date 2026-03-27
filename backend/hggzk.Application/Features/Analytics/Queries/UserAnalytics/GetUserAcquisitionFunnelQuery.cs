using System;
using MediatR;
using YemenBooking.Application.Features.Analytics;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Analytics.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Analytics.Queries.UserAnalytics;

    /// <summary>
    /// يمثل استعلامًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area query.
    /// </summary>
public class GetUserAcquisitionFunnelQuery : IRequest<ResultDto<UserFunnelDto>>
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
    public GetUserAcquisitionFunnelQuery(DateRangeDto range)
    {
        Range = range;
    }
} 