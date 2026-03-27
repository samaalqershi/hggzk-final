using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Bookings.Commands.CancelBooking;

/// <summary>
/// يمثل أمرًا ضمن نطاق الحجوزات.
/// Represents a booking-related command.
/// </summary>
public class CancelBookingCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف الحجز
    /// Booking identifier.
    /// </summary>
    public Guid BookingId { get; set; }
    
    /// <summary>
    /// معرّف المستخدم
    /// User identifier.
    /// </summary>
    public Guid UserId { get; set; }
    
    /// <summary>
    /// سبب الإلغاء المقدم عند تنفيذ العملية.
    /// Cancellation reason provided when submitting the request.
    /// </summary>
    public string CancellationReason { get; set; } = string.Empty;

    /// <summary>
    /// يحدد ما إذا كان يجب استرداد المدفوعات المرتبطة قبل الإلغاء.
    /// Indicates whether related payments should be refunded before cancellation.
    /// </summary>
    public bool RefundPayments { get; set; } = false;
}
