using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Accounting.Commands.Payouts;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يوفّر نقاط إدارة التوزيعات المالية للمدراء والمحاسبين.
    /// Provides admin and accountant endpoints for owner payout processing.
    /// </summary>
    [ApiController]
    [Route("api/admin/[controller]")]
    [Authorize(Roles = "Admin,Accountant,Finance")]
    public class AccountingController : ControllerBase
    {
        /// <summary>
        /// حقل _mediator.
        /// _mediator field.
        /// </summary>
        private readonly IMediator _mediator;

    /// <summary>
    /// يهيئ المتحكم باستخدام Mediator.
    /// Initializes the controller with Mediator.
    /// </summary>
        public AccountingController(IMediator mediator)
        {
            _mediator = mediator;
        }

    /// <summary>
    /// يعالج توزيعات الملاك وفق المعايير المحددة في الطلب.
    /// Processes owner payouts using the criteria supplied in the request.
    /// </summary>
        [HttpPost("owner-payouts/process")]
        public async Task<IActionResult> ProcessOwnerPayouts([FromBody] ProcessOwnerPayoutsRequest request)
        {
            var cmd = new ProcessOwnerPayoutsCommand
            {
                OwnerIds = request.OwnerIds?.Where(id => Guid.TryParse(id, out _)).Select(Guid.Parse).ToList() ?? new List<Guid>(),
                MinimumAmountThreshold = request.MinimumAmountThreshold ?? 1000,
                IncludePendingTransactions = request.IncludePendingTransactions ?? false,
                PreviewOnly = request.PreviewOnly ?? false,
                Notes = request.Notes ?? string.Empty
            };

            var result = await _mediator.Send(cmd);
            if (result.Success)
            {
                return Ok(result);
            }
            return BadRequest(result);
        }
    }

    /// <summary>
    /// يصف معايير طلب معالجة توزيعات الملاك.
    /// Describes the request payload for processing owner payouts.
    /// </summary>
    public class ProcessOwnerPayoutsRequest
    {
        /// <summary>
        /// معرّفات الملاك المطلوب تضمينهم.
        /// Owner identifiers to include in the run.
        /// </summary>
        public List<string>? OwnerIds { get; set; }
        /// <summary>
        /// الحد الأدنى للمبلغ الذي يفعّل المعالجة.
        /// The minimum amount threshold used for processing.
        /// </summary>
        public decimal? MinimumAmountThreshold { get; set; }
        /// <summary>
        /// يحدد ما إذا كانت القيود المعلقة تُحتسب ضمن المعالجة.
        /// Indicates whether pending transactions are included.
        /// </summary>
        public bool? IncludePendingTransactions { get; set; }
        /// <summary>
        /// يحدد ما إذا كان الطلب للتجربة فقط دون تنفيذ فعلي.
        /// Indicates a preview-only run without committing changes.
        /// </summary>
        public bool? PreviewOnly { get; set; }
        /// <summary>
        /// ملاحظات اختيارية مرافقة للمعالجة.
        /// Optional notes to attach to the processing run.
        /// </summary>
        public string? Notes { get; set; }
    }
}
