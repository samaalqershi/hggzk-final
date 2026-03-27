using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.DTOs;
using YemenBooking.Application.Features.AuditLog.Queries.GetAuditLogs;
using YemenBooking.Application.Features.AuditLog.Services;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يوفّر الوصول الإداري إلى سجلات التدقيق والنشاط.
    /// Provides admin access to audit and activity logs.
    /// </summary>
    public class AuditLogsController : BaseAdminController
    {
    /// <summary>
    /// خدمة استرجاع تفاصيل سجلات التدقيق.
    /// Service for retrieving audit log details.
    /// </summary>
        private readonly IAuditService _auditService;

    /// <summary>
    /// يهيئ المتحكم بخدمة التدقيق وMediator.
    /// Initializes the controller with the audit service and Mediator.
    /// </summary>
        public AuditLogsController(IMediator mediator, IAuditService auditService) : base(mediator)
        {
            _auditService = auditService;
        }


    /// <summary>
    /// يجلب سجلات التدقيق مع المرشحات الاختيارية.
    /// Retrieves audit logs with optional filters.
    /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAuditLogs([FromQuery] GetAuditLogsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

    /// <summary>
    /// يجلب التفاصيل الكاملة لسجل تدقيق محدد.
    /// Retrieves the full details for a specific audit log.
    /// </summary>
        [HttpGet("{auditLogId}/details")]
        public async Task<IActionResult> GetAuditLogDetails(Guid auditLogId, CancellationToken cancellationToken)
        {
            var log = await _auditService.GetAuditLogAsync(auditLogId, cancellationToken);
            if (log is null) return NotFound();

            var dto = new Application.Features.AuditLog.DTOs.AuditLogDto
            {
                Id = log.Id,
                TableName = log.TableName,
                Action = log.Action.ToString(),
                RecordId = log.RecordId,
                RecordName = (log.RecordId).ToString(),
                UserId = log.UserId,
                Username = log.Username ?? string.Empty,
                Notes = log.Notes,
                OldValues = log.OldValues,
                NewValues = log.NewValues,
                Metadata = log.Metadata,
                IsSlowOperation = log.IsSlowOperation,
                Changes = log.Notes ?? string.Empty,
                Timestamp = log.Timestamp
            };
            return Ok(dto);
        }

    }
} 
