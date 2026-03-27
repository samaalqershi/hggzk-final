using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Bookings.DTOs;
using System;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Bookings.Queries.GetBookingsByUnit;

/// <summary>
/// يمثل استعلامًا ضمن نطاق الحجوزات.
/// Represents a booking-related query.
/// </summary>
public class GetBookingsByUnitQuery : IRequest<PaginatedResult<BookingDto>>
{
    /// <summary>
    /// معرّف الوحدة
    /// Unit identifier.
    /// </summary>
    public Guid UnitId { get; set; }

    /// <summary>
    /// يمثل تاريخ البداية.
    /// Represents start date.
    /// </summary>
    public DateTime? StartDate { get; set; }

    /// <summary>
    /// يمثل تاريخ النهاية.
    /// Represents end date.
    /// </summary>
    public DateTime? EndDate { get; set; }

    /// <summary>
    /// يمثل رقم الصفحة.
    /// Represents page number.
    /// </summary>
    public int PageNumber { get; set; } = 1;

    /// <summary>
    /// يمثل حجم الصفحة.
    /// Represents page size.
    /// </summary>
    public int PageSize { get; set; } = 10;
} 