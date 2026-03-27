using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Payments.Commands.RefundPayment;

/// <summary>
/// يمثل أمرًا ضمن نطاق المدفوعات.
/// Represents a payment-related command.
/// </summary>
public class RefundPaymentCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف الدفع
    /// Payment identifier.
    /// </summary>
    public Guid PaymentId { get; set; }

    /// <summary>
    /// يمثل مبلغ الاسترداد.
    /// Represents refund amount.
    /// </summary>
    public MoneyDto RefundAmount { get; set; }
    /// <summary>
    /// يمثل سبب الاسترداد.
    /// Represents refund reason.
    /// </summary>
    public string RefundReason { get; set; }
} 