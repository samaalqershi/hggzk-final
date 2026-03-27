using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Payments.DTOs;
using YemenBooking.Core.Enums;
using YemenBooking.Core.ValueObjects;
using System;
using System.Collections.Generic;

namespace YemenBooking.Application.Features.Payments.Commands.ProcessPayment
{
/// <summary>
/// يمثل أمرًا ضمن نطاق المدفوعات.
/// Represents a payment-related command.
/// </summary>
    public class ProcessPaymentCommand : IRequest<ResultDto<ProcessPaymentResponse>>
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
    public Money Amount { get; set; } = null!;
    
    /// <summary>
    /// يمثل طريقة الدفع.
    /// Represents payment method.
    /// </summary>
    public PaymentMethodEnum PaymentMethod { get; set; }
    
    /// <summary>
    /// يمثل تفاصيل البطاقة.
    /// Represents card details.
    /// </summary>
    public CardDetails? CardDetails { get; set; }
    
    /// <summary>
    /// يمثل معرّف المحفظة.
    /// Represents wallet id.
    /// </summary>
    public string? WalletId { get; set; }

    /// <summary>
    /// بيانات دفع عامة خاصة بطريقة الدفع
    /// General payment data for method-specific fields (e.g. OTP for SabaCash wallet)
    /// </summary>
    public Dictionary<string, object>? PaymentData { get; set; }
}

/// <summary>
/// يمثل تفاصيل البطاقة.
/// Represents card details.
/// </summary>
public class CardDetails
{
    /// <summary>
    /// يمثل البطاقة الرقم.
    /// Represents card number.
    /// </summary>
    public string CardNumber { get; set; } = string.Empty;
    
    /// <summary>
    /// يمثل Cardholder name.
    /// Represents cardholder name.
    /// </summary>
    public string CardholderName { get; set; } = string.Empty;
    
    /// <summary>
    /// يمثل Expiry month.
    /// Represents expiry month.
    /// </summary>
    public int ExpiryMonth { get; set; }
    
    /// <summary>
    /// يمثل Expiry year.
    /// Represents expiry year.
    /// </summary>
    public int ExpiryYear { get; set; }
    
    /// <summary>
    /// يمثل CVV.
    /// Represents CVV.
    /// </summary>
    public string CVV { get; set; } = string.Empty;
    }
}
