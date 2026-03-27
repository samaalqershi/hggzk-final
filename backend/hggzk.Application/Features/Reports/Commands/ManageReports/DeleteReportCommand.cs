using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Reports.Commands.ManageReports;

/// <summary>
/// يمثل أمرًا ضمن نطاق البلاغات.
/// Represents a report-related command.
/// </summary>
public class DeleteReportCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف 
    /// Id identifier.
    /// </summary>
    public Guid Id { get; set; }

    /// <summary>
    /// يمثل Deletion السبب.
    /// Represents deletion reason.
    /// </summary>
    public string? DeletionReason { get; set; }
} 