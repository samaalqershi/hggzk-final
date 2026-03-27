using System;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Reports.Commands.ManageReports;
using YemenBooking.Application.Features.Reports.Queries.GetAllReports;
using YemenBooking.Application.Features.Reports.Queries.GetReportsByProperty;
using YemenBooking.Application.Features.Reports.Queries.GetReportsByReportedUser;
using YemenBooking.Application.Features.Reports.Queries.GetReportStats;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يدير البلاغات الإدارية المتعلقة بالمحتوى أو المستخدمين داخل المنصة.
    /// Manages admin-facing reports for content or user moderation.
    /// </summary>
    public class ReportsController : BaseAdminController
    {
        /// <summary>
        /// ينشئ نسخة من المتحكم مع حقن وسيط الأوامر والاستعلامات.
        /// Creates the controller with the command/query mediator.
        /// </summary>
        public ReportsController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// ينشئ بلاغًا جديدًا للمراجعة الإدارية.
        /// Creates a new report for administrative review.
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreateReport([FromBody] CreateReportCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحدث بيانات بلاغ قائم.
        /// Updates an existing report.
        /// </summary>
        [HttpPut("{reportId}")]
        public async Task<IActionResult> UpdateReport(Guid reportId, [FromBody] UpdateReportCommand command)
        {
            command.Id = reportId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحذف بلاغًا من النظام.
        /// Deletes a report from the system.
        /// </summary>
        [HttpDelete("{reportId}")]
        public async Task<IActionResult> DeleteReport(Guid reportId)
        {
            var command = new DeleteReportCommand { Id = reportId };
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعرض قائمة البلاغات مع دعم الصفحات.
        /// Returns a paginated list of reports.
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAllReports([FromQuery] GetAllReportsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعرض البلاغات المرتبطة بعقار محدد.
        /// Returns reports associated with a specific property.
        /// </summary>
        [HttpGet("property/{propertyId}")]
        public async Task<IActionResult> GetReportsByProperty(Guid propertyId, [FromQuery] GetReportsByPropertyQuery query)
        {
            query.PropertyId = propertyId;
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعرض البلاغات المرتبطة بمستخدم محدد بوصفه الطرف المُبلَّغ عنه.
        /// Returns reports linked to a specific reported user.
        /// </summary>
        [HttpGet("reported-user/{reportedUserId}")]
        public async Task<IActionResult> GetReportsByReportedUser(Guid reportedUserId, [FromQuery] GetReportsByReportedUserQuery query)
        {
            query.UserId = reportedUserId;
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعرض مؤشرات وإحصاءات البلاغات للمراجعة التشغيلية.
        /// Returns report metrics and statistics for operational review.
        /// </summary>
        [HttpGet("stats")]
        public async Task<IActionResult> GetReportStats()
        {
            var result = await _mediator.Send(new GetReportStatsQuery());
            return Ok(result);
        }
    }
} 
