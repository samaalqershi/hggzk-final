using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Reports.Commands.ManageReports;

/// <summary>
/// يمثل أمرًا ضمن نطاق البلاغات.
/// Represents a report-related command.
/// </summary>
public class UpdateReportCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف 
    /// Id identifier.
    /// </summary>
    public Guid Id { get; set; }

    /// <summary>
    /// يمثل السبب.
    /// Represents reason.
    /// </summary>
    public string? Reason { get; set; }

    /// <summary>
    /// يمثل الوصف.
    /// Represents description.
    /// </summary>
    public string? Description { get; set; }
} 