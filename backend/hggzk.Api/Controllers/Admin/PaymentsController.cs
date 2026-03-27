using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Payments.Commands.RefundPayment;
using YemenBooking.Application.Features.Payments.Commands.VoidPayment;
using YemenBooking.Application.Features.Payments.Commands.PaymentStatus;
using YemenBooking.Application.Features.Payments.Queries.GetPaymentAnalytics;
using YemenBooking.Application.Features.Analytics.Queries.FinancialAnalytics;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Payments.Queries.GetAllPayments;
using YemenBooking.Application.Features.Payments.DTOs;
using YemenBooking.Application.Features.Payments.Queries.GetPaymentById;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يوفّر عمليات إدارة المدفوعات من لوحة الإدارة.
    /// Provides admin payment-management operations.
    /// </summary>
    [Authorize(Roles = "Admin")]
    public class PaymentsController : BaseAdminController
    {
    /// <summary>
    /// يهيئ المتحكم بالاعتماد على Mediator.
    /// Initializes the controller with Mediator.
    /// </summary>
        public PaymentsController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// ينشئ عملية استرداد لدفعة.
        /// Creates a payment refund.
        /// </summary>
        [HttpPost("refund")]
        public async Task<IActionResult> RefundPayment([FromBody] RefundPaymentCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يلغي دفعة قائمة.
        /// Voids an existing payment.
        /// </summary>
        [HttpPost("void")]
        public async Task<IActionResult> VoidPayment([FromBody] VoidPaymentCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحدّث حالة الدفعة.
        /// Updates the payment status.
        /// </summary>
        [HttpPut("{paymentId}/status")]
        public async Task<IActionResult> UpdatePaymentStatus(Guid paymentId, [FromBody] UpdatePaymentStatusCommand command)
        {
            command.PaymentId = paymentId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يجلب المدفوعات مع دعم المرشحات.
        /// Retrieves payments with filter support.
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAllPayments([FromQuery] GetAllPaymentsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب تفاصيل دفعة واحدة بحسب المعرّف.
        /// Retrieves a payment's details by identifier.
        /// </summary>
        [HttpGet("{paymentId}")]
        public async Task<IActionResult> GetPaymentById(Guid paymentId)
        {
            try
            {
                var query = new GetPaymentByIdQuery(paymentId);
                var result = await _mediator.Send(query);
                return Ok(ResultDto<PaymentDetailsDto>.Ok(result));
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(ResultDto<PaymentDetailsDto>.Failure(ex.Message));
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(ResultDto<PaymentDetailsDto>.Failure(ex.Message));
            }
            catch (Exception ex)
            {
                return BadRequest(ResultDto<PaymentDetailsDto>.Failure(ex.Message));
            }
        }

        /// <summary>
        /// يجلب تفاصيل الدفعة الكاملة مع الأنشطة والاستردادات.
        /// Retrieves full payment details including activities and refunds.
        /// </summary>
        [HttpGet("{paymentId}/details")]
        public async Task<IActionResult> GetPaymentDetails(Guid paymentId)
        {
            try
            {
                // نفس الـ query - يرجع نفس البيانات
                var query = new GetPaymentByIdQuery(paymentId);
                var result = await _mediator.Send(query);
                return Ok(ResultDto<PaymentDetailsDto>.Ok(result));
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(ResultDto<PaymentDetailsDto>.Failure(ex.Message));
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(ResultDto<PaymentDetailsDto>.Failure(ex.Message));
            }
            catch (Exception ex)
            {
                return BadRequest(ResultDto<PaymentDetailsDto>.Failure(ex.Message));
            }
        }

        /// <summary>
        /// يجلب تحليلات المدفوعات والإيرادات.
        /// Retrieves payment and revenue analytics.
        /// </summary>
        [HttpGet("analytics")]
        public async Task<IActionResult> GetPaymentAnalytics([FromQuery] GetPaymentAnalyticsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب تقرير الإيرادات.
        /// Retrieves the revenue report.
        /// </summary>
        [HttpGet("revenue-report")]
        public async Task<IActionResult> GetRevenueReport([FromQuery] GetRevenueReportQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب اتجاهات المدفوعات.
        /// Retrieves payment trends.
        /// </summary>
        [HttpGet("trends")]
        public async Task<IActionResult> GetPaymentTrends([FromQuery] GetPaymentAnalyticsQuery query)
        {
            var analyticsResult = await _mediator.Send(query);
            
            if (!analyticsResult.Success)
            {
                return Ok(ResultDto<List<PaymentTrendDto>>.Failure(
                    analyticsResult.Message ?? "فشل جلب اتجاهات المدفوعات"));
            }

            // إرجاع الاتجاهات فقط من التحليلات
            var trends = analyticsResult.Data?.Trends ?? new List<PaymentTrendDto>();
            return Ok(ResultDto<List<PaymentTrendDto>>.Ok(trends));
        }

        /// <summary>
        /// يجلب إحصائيات الاستردادات.
        /// Retrieves refund statistics.
        /// </summary>
        [HttpGet("refund-statistics")]
        public async Task<IActionResult> GetRefundStatistics([FromQuery] GetPaymentAnalyticsQuery query)
        {
            var analyticsResult = await _mediator.Send(query);
            
            if (!analyticsResult.Success)
            {
                return Ok(ResultDto<RefundAnalyticsDto>.Failure(
                    analyticsResult.Message ?? "فشل جلب إحصائيات الاستردادات"));
            }

            // إرجاع تحليلات الاستردادات فقط
            var refundStats = analyticsResult.Data?.RefundAnalytics ?? new RefundAnalyticsDto
            {
                TotalRefunds = 0,
                TotalRefundedAmount = new MoneyDto { Amount = 0, Currency = "YER", ExchangeRate = 1 },
                RefundRate = 0,
                AverageRefundTime = 0,
                RefundReasons = new Dictionary<string, int>(),
                Trends = new List<RefundTrendDto>()
            };

            return Ok(ResultDto<RefundAnalyticsDto>.Ok(refundStats));
        }
    }
} 
