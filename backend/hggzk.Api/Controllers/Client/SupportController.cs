using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Support.Commands.SendSupportMessage;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// يوفر قنوات التواصل والدعم للعميل.
    /// Exposes client support and contact endpoints.
    /// </summary>
    public class SupportController : BaseClientController
    {
        /// <summary>
        /// ينشئ مثيلاً جديداً من <see cref="SupportController"/>.
        /// Creates a new <see cref="SupportController"/> instance.
        /// </summary>
        public SupportController(IMediator mediator) : base(mediator)
        {
        }

        /// <summary>
        /// يرسل رسالة دعم.
        /// Sends a support message.
        /// </summary>
        /// <param name="command">بيانات رسالة الدعم.</param>
        /// <returns>نتيجة الإرسال.</returns>
        [HttpPost("send")]
        public async Task<ActionResult<ResultDto<SendSupportMessageResponse>>> SendSupportMessage(
            [FromBody] SendSupportMessageCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }
    }
}
