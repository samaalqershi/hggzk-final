using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Reports.Commands.ManageReports;

/// <summary>
/// يمثل أمرًا ضمن نطاق البلاغات.
/// Represents a report-related command.
/// </summary>
public class CreateReportCommand : IRequest<ResultDto<Guid>>
{
    /// <summary>
    /// معرّف المستخدم المُبلِّغ
    /// Reporter User identifier.
    /// </summary>
    public Guid ReporterUserId { get; set; }

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
    public string Reason { get; set; } = string.Empty;

    /// <summary>
    /// يمثل الوصف.
    /// Represents description.
    /// </summary>
    public string Description { get; set; } = string.Empty;
} 