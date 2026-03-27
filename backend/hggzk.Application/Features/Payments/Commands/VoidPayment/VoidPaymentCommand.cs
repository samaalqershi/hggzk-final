using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Payments.Commands.VoidPayment;

/// <summary>
/// يمثل أمرًا ضمن نطاق المدفوعات.
/// Represents a payment-related command.
/// </summary>
public class VoidPaymentCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف الدفع
    /// Payment identifier.
    /// </summary>
    public Guid PaymentId { get; set; }
}