using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Features.Payments.DTOs;

namespace YemenBooking.Application.Features.Payments.Commands.PaymentStatus;

/// <summary>
/// يمثل أمرًا ضمن نطاق المدفوعات.
/// Represents a payment-related command.
/// </summary>
public class UpdatePaymentStatusCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف الدفع
    /// Payment identifier.
    /// </summary>
    public Guid PaymentId { get; set; }

    /// <summary>
    /// يمثل الحالة الجديدة.
    /// Represents new status.
    /// </summary>
    public YemenBooking.Core.Enums.PaymentStatus NewStatus { get; set; }

    /// <summary>
    /// يمثل الاسترداد Record.
    /// Represents refund record.
    /// </summary>
    public RefundDto? RefundRecord { get; set; }
} 