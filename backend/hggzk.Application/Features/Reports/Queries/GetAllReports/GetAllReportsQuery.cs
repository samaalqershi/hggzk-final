using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Reports.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Reports.Queries.GetAllReports;

/// <summary>
/// يمثل استعلامًا ضمن نطاق البلاغات.
/// Represents a report-related query.
/// </summary>
public class GetAllReportsQuery : IRequest<PaginatedResult<ReportDto>>
{
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

    /// <summary>
    /// معرّف المستخدم المُبلِّغ
    /// Reporter User identifier.
    /// </summary>
    public Guid? ReporterUserId { get; set; }

    /// <summary>
    /// معرّف المستخدم المُبلَّغ عنه
    /// Reported User identifier.
    /// </summary>
    public Guid? ReportedUserId { get; set; }

    /// <summary>
    /// معرّف العقار المُبلَّغ عنه
    /// Reported Property identifier.
    /// </summary>
    public Guid? ReportedPropertyId { get; set; }

    /// <summary>
    /// يمثل السبب.
    /// Represents reason.
    /// </summary>
    public string? Reason { get; set; }

    /// <summary>
    /// يمثل الحالة.
    /// Represents status.
    /// </summary>
    public string? Status { get; set; }

    /// <summary>
    /// يمثل تاريخ البداية.
    /// Represents from date.
    /// </summary>
    public DateTime? FromDate { get; set; }

    /// <summary>
    /// يمثل تاريخ النهاية.
    /// Represents to date.
    /// </summary>
    public DateTime? ToDate { get; set; }

    /// <summary>
    /// يمثل عبارة البحث.
    /// Represents search term.
    /// </summary>
    public string? SearchTerm { get; set; }
} 