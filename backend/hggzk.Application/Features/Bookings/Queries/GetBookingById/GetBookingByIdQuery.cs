using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Bookings;
using System;
using YemenBooking.Application.Features.Bookings.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Bookings.Queries.GetBookingById;

/// <summary>
/// يمثل استعلامًا ضمن نطاق الحجوزات.
/// Represents a booking-related query.
/// </summary>
public class GetBookingByIdQuery : IRequest<ResultDto<BookingDetailsDto>>
{
    /// <summary>
    /// معرّف الحجز
    /// Booking identifier.
    /// </summary>
    public Guid BookingId { get; set; }
} 