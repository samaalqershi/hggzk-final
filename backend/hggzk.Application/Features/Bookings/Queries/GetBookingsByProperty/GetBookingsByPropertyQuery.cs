using MediatR;
using YemenBooking.Application.Common.Models;
using System;
using System.Collections.Generic;
using YemenBooking.Application.Features.Bookings.DTOs;

namespace YemenBooking.Application.Features.Bookings.Queries.GetBookingsByProperty;

/// <summary>
/// يمثل استعلامًا ضمن نطاق الحجوزات.
/// Represents a booking-related query.
/// </summary>
public class GetBookingsByPropertyQuery : IRequest<PaginatedResult<BookingDto>>
{
    /// <summary>
    /// معرّف العقار المستهدف.
    /// Identifier of the target property.
    /// </summary>
    public Guid PropertyId { get; set; }

    /// <summary>
    /// تاريخ بداية النطاق الزمني المطلوب.
    /// Start date of the requested time range.
    /// </summary>
    public DateTime? StartDate { get; set; }

    /// <summary>
    /// تاريخ نهاية النطاق الزمني المطلوب.
    /// End date of the requested time range.
    /// </summary>
    public DateTime? EndDate { get; set; }

    /// <summary>
    /// رقم الصفحة المطلوبة.
    /// Requested page number.
    /// </summary>
    public int PageNumber { get; set; } = 1;

    /// <summary>
    /// حجم الصفحة المطلوبة.
    /// Requested page size.
    /// </summary>
    public int PageSize { get; set; } = 10;

    /// <summary>
    /// معرّف المستخدم لتقييد النتائج عند الحاجة.
    /// User identifier used to scope the results when needed.
    /// </summary>
    public Guid? UserId { get; set; }

    /// <summary>
    /// معرّف نوع العقار لتصفية النتائج.
    /// Property type identifier used to filter the results.
    /// </summary>
    public Guid? PropertyTypeId { get; set; }

    /// <summary>
    /// قائمة معرّفات المرافق المطلوب أن ترتبط بها النتائج.
    /// List of amenity identifiers that the results should match.
    /// </summary>
    public List<Guid>? AmenityIds { get; set; }

    /// <summary>
    /// حالة الحجز المطلوبة.
    /// Requested booking status.
    /// </summary>
    public string? Status { get; set; }

    /// <summary>
    /// حالة الدفع المطلوبة.
    /// Requested payment status.
    /// </summary>
    public string? PaymentStatusDto { get; set; }

    /// <summary>
    /// اسم الضيف أو البريد الإلكتروني للبحث النصي.
    /// Guest name or email used for text search.
    /// </summary>
    public string? GuestNameOrEmail { get; set; }

    /// <summary>
    /// مصدر الحجز المطلوب.
    /// Requested booking source.
    /// </summary>
    public string? BookingSource { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت النتائج تخص الحجوزات المباشرة.
    /// Indicates whether the results should include walk-in bookings.
    /// </summary>
    public bool? IsWalkIn { get; set; }

    /// <summary>
    /// الحد الأدنى للسعر الإجمالي.
    /// Minimum total price filter.
    /// </summary>
    public decimal? MinTotalPrice { get; set; }

    /// <summary>
    /// الحد الأدنى لعدد الضيوف.
    /// Minimum guests count filter.
    /// </summary>
    public int? MinGuestsCount { get; set; }

    /// <summary>
    /// الحقل المستخدم في الترتيب.
    /// Field used for sorting.
    /// </summary>
    public string? SortBy { get; set; }
} 
