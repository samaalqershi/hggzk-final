using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Payments.Commands.ProcessPayment;
using YemenBooking.Application.Features.Payments.Queries.GetPaymentMethods;
using YemenBooking.Application.Features.Payments.Queries.GetUserPayments;
using YemenBooking.Application.Features.Payments.DTOs;
using YemenBooking.Application.Common.Models;
using System.Collections.Generic;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// متحكم المدفوعات الخاص بالعميل.
    /// Client payments controller.
    /// </summary>
    public class PaymentsController : BaseClientController
    {
        /// <summary>
        /// يهيئ نسخة جديدة من [PaymentsController].
        /// Initializes a new instance of [PaymentsController].
        /// </summary>
        /// <param name="mediator">وسيط MediatR المستخدم لمعالجة الطلبات. MediatR mediator used to process requests.</param>
        public PaymentsController(IMediator mediator) : base(mediator)
        {
        }

        /// <summary>
        /// يعالج دفعة جديدة.
        /// Processes a new payment.
        /// </summary>
        /// <param name="command">بيانات الدفع. Payment details.</param>
        /// <returns>نتيجة معالجة الدفع. Payment processing result.</returns>
        [HttpPost("process")]
        public async Task<ActionResult<ResultDto<ProcessPaymentResponse>>> ProcessPayment([FromBody] ProcessPaymentCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }


        /// <summary>
        /// يعيد سجل مدفوعات المستخدم.
        /// Returns the user's payment history.
        /// </summary>
        /// <param name="query">معايير البحث. Query parameters.</param>
        /// <returns>تاريخ المدفوعات. Payment history.</returns>
        [HttpGet("history")]
        public async Task<ActionResult<ResultDto<PaginatedResult<ClientPaymentDto>>>> GetUserPayments([FromQuery] ClientGetUserPaymentsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
}
