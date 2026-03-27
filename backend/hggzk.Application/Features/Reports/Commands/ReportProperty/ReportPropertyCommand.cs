using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Reports;
using YemenBooking.Application.Features.Reports.DTOs;

namespace YemenBooking.Application.Features.Reports.Commands.ReportProperty;

/// <summary>
/// يمثل أمرًا ضمن نطاق البلاغات.
/// Represents a report-related command.
/// </summary>
public class ReportPropertyCommand : IRequest<ResultDto<ReportPropertyResponse>>
{
    /// <summary>
    /// معرّف المستخدم المُبلِّغ.
    /// Identifier of the reporting user.
    /// </summary>
    public Guid ReporterUserId { get; set; }
    
    /// <summary>
    /// معرّف العقار المُبلَّغ عنه.
    /// Identifier of the reported property.
    /// </summary>
    public Guid ReportedPropertyId { get; set; }
    
    /// <summary>
    /// سبب الإبلاغ.
    /// Reason for the report.
    /// </summary>
    public string Reason { get; set; } = string.Empty;
    
    /// <summary>
    /// وصف إضافي يوضح البلاغ.
    /// Additional description clarifying the report.
    /// </summary>
    public string Description { get; set; } = string.Empty;
}
