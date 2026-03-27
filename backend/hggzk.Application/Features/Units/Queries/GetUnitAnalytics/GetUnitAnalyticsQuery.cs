using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Units.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Units.Queries.GetUnitAnalytics;

/// <summary>
/// استعلام جلب الوحدة التحليلات.
/// Get Unit Analytics query.
/// </summary>
public class GetUnitAnalyticsQuery : IRequest<ResultDto<UnitAnalyticsDto>>
{
    /// <summary>
    /// معرّف الوحدة.
    /// Unit identifier.
    /// </summary>
    public Guid UnitId { get; set; }

    /// <summary>
    /// القيمة الخاصة بـ from date.
    /// From Date value.
    /// </summary>
    public DateTime? FromDate { get; set; }

    /// <summary>
    /// القيمة الخاصة بـ to date.
    /// To Date value.
    /// </summary>
    public DateTime? ToDate { get; set; }
}
