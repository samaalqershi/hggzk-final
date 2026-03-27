using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Reports.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Reports.Queries.GetReportsByProperty;

/// <summary>
/// يمثل استعلامًا ضمن نطاق البلاغات.
/// Represents a report-related query.
/// </summary>
public class GetReportsByPropertyQuery : IRequest<PaginatedResult<ReportDto>>
{
    /// <summary>
    /// معرّف العقار المستهدف.
    /// Identifier of the target property.
    /// </summary>
    public Guid PropertyId { get; set; }

    /// <summary>
    /// رقم الصفحة المطلوبة.
    /// Requested page number.
    /// </summary>
    public int PageNumber { get; set; } = 1;

    /// <summary>
    /// حجم الصفحة المطلوبة.
    /// Requested page size.
    /// </summary>
    public int PageSize { get; set; } = 10;
} 
