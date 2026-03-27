using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Reports.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Reports.Queries.GetReportStats
{
/// <summary>
/// يمثل استعلامًا ضمن نطاق البلاغات.
/// Represents a report-related query.
/// </summary>
    public class GetReportStatsQuery : IRequest<ReportStatsDto>
    {
    }
} 