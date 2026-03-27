using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Bookings.DTOs;

namespace YemenBooking.Application.Features.Bookings.Queries.GetBookingsByStatus;

/// <summary>
/// يمثل استعلامًا ضمن نطاق الحجوزات.
/// Represents a booking-related query.
/// </summary>
public class GetBookingsByStatusQuery : IRequest<PaginatedResult<BookingDto>>
{
    /// <summary>
    /// يمثل الحالة.
    /// Represents status.
    /// </summary>
    public string Status { get; set; } = string.Empty;

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