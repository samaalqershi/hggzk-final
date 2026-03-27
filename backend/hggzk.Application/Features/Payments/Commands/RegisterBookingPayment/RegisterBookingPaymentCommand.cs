using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Features.Payments.DTOs;

namespace YemenBooking.Application.Features.Payments.Commands.RegisterBookingPayment;

/// <summary>
/// يمثل أمرًا ضمن نطاق المدفوعات.
/// Represents a payment-related command.
/// </summary>
public class RegisterBookingPaymentCommand : IRequest<ResultDto<PaymentDto>>
{
    /// <summary>
    /// معرّف الحجز
    /// Booking identifier.
    /// </summary>
    public Guid BookingId { get; set; }

    /// <summary>
    /// يمثل المبلغ.
    /// Represents amount.
    /// </summary>
    public MoneyDto Amount { get; set; }

    /// <summary>
    /// يمثل طريقة الدفع.
    /// Represents payment method.
    /// </summary>
    public PaymentMethodEnum PaymentMethod { get; set; }

    /// <summary>
    /// يمثل معرّف العملية.
    /// Represents transaction id.
    /// </summary>
    public string TransactionId { get; set; } = string.Empty;

    /// <summary>
    /// يمثل الملاحظات.
    /// Represents notes.
    /// </summary>
    public string Notes { get; set; } = string.Empty;

    /// <summary>
    /// يمثل الدفع التاريخ.
    /// Represents payment date.
    /// </summary>
    public DateTime? PaymentDate { get; set; }
}
