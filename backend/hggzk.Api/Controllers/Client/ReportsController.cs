using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Reports.Commands.ReportProperty;
using YemenBooking.Application.Features.Reports.DTOs;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// يوفر واجهات الإبلاغ الخاصة بالعميل.
    /// Exposes client-facing reporting endpoints.
    /// </summary>
    public class ReportsController : BaseClientController
    {
        /// <summary>
        /// ينشئ مثيلاً جديداً من <see cref="ReportsController"/>.
        /// Creates a new <see cref="ReportsController"/> instance.
        /// </summary>
        public ReportsController(IMediator mediator) : base(mediator)
        {
        }

        /// <summary>
        /// يرسل بلاغاً عن عقار محدد.
        /// Submits a report for a specific property.
        /// </summary>
        /// <param name="command">بيانات البلاغ.</param>
        /// <returns>نتيجة عملية الإبلاغ.</returns>
        [HttpPost("property")]
        public async Task<ActionResult<ResultDto<ReportPropertyResponse>>> ReportProperty([FromBody] ReportPropertyCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }
    }
}
