using MediatR;
using YemenBooking.Application.Common.Models;
using System;
using System.Collections.Generic;

namespace YemenBooking.Application.Features.Bookings.Commands.UpdateBooking;

/// <summary>
/// يمثل أمرًا ضمن نطاق الحجوزات.
/// Represents a booking-related command.
/// </summary>
public class UpdateBookingCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف الحجز
    /// Booking identifier.
    /// </summary>
    public Guid BookingId { get; set; }

    /// <summary>
    /// يمثل تاريخ تسجيل الوصول.
    /// Represents check in.
    /// </summary>
    public DateTime? CheckIn { get; set; }

    /// <summary>
    /// يمثل تاريخ تسجيل المغادرة.
    /// Represents check out.
    /// </summary>
    public DateTime? CheckOut { get; set; }

    /// <summary>
    /// يمثل عدد الضيوف.
    /// Represents guests count.
    /// </summary>
    public int? GuestsCount { get; set; }

    /// <summary>
    /// يمثل الخدمات.
    /// Represents services.
    /// </summary>
    public List<ServiceUpdateItem>? Services { get; set; }
}

/// <summary>
/// يمثل عنصرًا ضمن نطاق الحجوزات.
/// Represents an item in the booking-related feature area.
/// </summary>
public class ServiceUpdateItem
{
    /// <summary>
    /// معرّف الخدمة
    /// Service identifier.
    /// </summary>
    public Guid ServiceId { get; set; }

    /// <summary>
    /// يمثل الكمية.
    /// Represents quantity.
    /// </summary>
    public int Quantity { get; set; }
}