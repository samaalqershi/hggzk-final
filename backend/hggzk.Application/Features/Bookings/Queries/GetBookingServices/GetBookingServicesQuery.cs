using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.PropertyServices.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Bookings.Queries.GetBookingServices;

/// <summary>
/// يمثل استعلامًا ضمن نطاق الحجوزات.
/// Represents a booking-related query.
/// </summary>
public class GetBookingServicesQuery : IRequest<ResultDto<IEnumerable<ServiceDto>>>
{
    /// <summary>
    /// معرّف الحجز
    /// Booking identifier.
    /// </summary>
    public Guid BookingId { get; set; }
} 