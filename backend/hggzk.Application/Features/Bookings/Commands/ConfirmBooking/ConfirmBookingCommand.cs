using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Bookings.Commands.ConfirmBooking;

/// <summary>
/// يمثل أمرًا ضمن نطاق الحجوزات.
/// Represents a booking-related command.
/// </summary>
public class ConfirmBookingCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف الحجز
    /// Booking identifier.
    /// </summary>
    public Guid BookingId { get; set; }
} 