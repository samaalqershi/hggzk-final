using MediatR;
using YemenBooking.Application.Common.Models;
using System;
using YemenBooking.Application.Features.Bookings.DTOs;

namespace YemenBooking.Application.Features.Bookings.Queries.GetBookingsByDateRange;

/// <summary>
/// يمثل استعلامًا ضمن نطاق الحجوزات.
/// Represents a booking-related query.
/// </summary>
public class GetBookingsByDateRangeQuery : IRequest<PaginatedResult<BookingDto>>
{
    /// <summary>
    /// يمثل تاريخ البداية.
    /// Represents start date.
    /// </summary>
    public DateTime StartDate { get; set; }

    /// <summary>
    /// يمثل تاريخ النهاية.
    /// Represents end date.
    /// </summary>
    public DateTime EndDate { get; set; }

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

    /// <summary>
    /// معرّف المستخدم
    /// User identifier.
    /// </summary>
    public Guid? UserId { get; set; }

    /// <summary>
    /// يمثل اسم الضيف أو البريد الإلكتروني.
    /// Represents guest name or email.
    /// </summary>
    public string? GuestNameOrEmail { get; set; }

    /// <summary>
    /// معرّف الوحدة
    /// Unit identifier.
    /// </summary>
    public Guid? UnitId { get; set; }

    /// <summary>
    /// يمثل مصدر الحجز.
    /// Represents booking source.
    /// </summary>
    public string? BookingSource { get; set; }

    /// <summary>
    /// يحدد ما إذا كان هل مباشر الوصول
    /// Indicates whether is walk in.
    /// </summary>
    public bool? IsWalkIn { get; set; }

    /// <summary>
    /// يمثل الحد الأدنى للسعر الإجمالي.
    /// Represents min total price.
    /// </summary>
    public decimal? MinTotalPrice { get; set; }

    /// <summary>
    /// يمثل الحد الأدنى لعدد الضيوف.
    /// Represents min guests count.
    /// </summary>
    public int? MinGuestsCount { get; set; }

    /// <summary>
    /// يمثل الترتيب حسب.
    /// Represents sort by.
    /// </summary>
    public string? SortBy { get; set; }
} 