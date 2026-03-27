using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Reports.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Reports.Queries.GetReportsByReportedUser;

/// <summary>
/// يمثل استعلامًا ضمن نطاق البلاغات.
/// Represents a report-related query.
/// </summary>
public class GetReportsByReportedUserQuery : IRequest<PaginatedResult<ReportDto>>
{
    /// <summary>
    /// معرّف المستخدم
    /// User identifier.
    /// </summary>
    public Guid UserId { get; set; }

    /// <summary>
    /// يمثل رقم الصفحة.
    /// Represents page number.
    /// </summary>
    public int PageNumber { get; set; } = 1;

    /// <summary>
    /// يمثل حجم الصفحة.
    /// Represents page size.
    /// </summary>
    public int PageSize { get; set; } = 10;
} 