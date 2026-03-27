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
public class GetUserLifetimeStatsQuery : IRequest<ResultDto<UserLifetimeStatsDto>>
{
    /// <summary>
    /// معرف المستخدم
    /// User identifier
    /// </summary>
    public Guid UserId { get; set; }

    /// <summary>
    /// يُهيِّئ هذا الاستعلام بالقيم الأساسية المطلوبة.
    /// Initializes this query with the required values.
    /// </summary>
    public GetUserLifetimeStatsQuery(Guid userId)
    {
        UserId = userId;
    }
} 