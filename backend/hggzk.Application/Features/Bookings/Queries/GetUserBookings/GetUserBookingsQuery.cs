using MediatR;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Bookings;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Bookings.Queries.GetUserBookings;

/// <summary>
/// يمثل استعلامًا ضمن نطاق الحجوزات.
/// Represents a booking-related query.
/// </summary>
public class GetUserBookingsQuery : IRequest<ResultDto<PaginatedResult<BookingDto>>>
{
    /// <summary>
    /// معرّف المستخدم
    /// User identifier.
    /// </summary>
    public Guid UserId { get; set; }
    
    /// <summary>
    /// يمثل الحالة.
    /// Represents status.
    /// </summary>
    public BookingStatus? Status { get; set; }
    
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

/// <summary>
/// يمثل نموذج بيانات مرتبطًا بنطاق الحجوزات.
/// Represents a data model for the booking-related feature area.
/// </summary>
public class BookingDto
{
    /// <summary>
    /// معرّف 
    /// Id identifier.
    /// </summary>
    public Guid Id { get; set; }

    /// <summary>
    /// معرّف المستخدم
    /// User identifier.
    /// </summary>
    public Guid UserId { get; set; }

    /// <summary>
    /// معرّف العقار
    /// Property identifier.
    /// </summary>
    public Guid PropertyId { get; set; }

    /// <summary>
    /// معرّف الوحدة
    /// Unit identifier.
    /// </summary>
    public Guid UnitId { get; set; }
    
    /// <summary>
    /// يمثل رقم الحجز.
    /// Represents booking number.
    /// </summary>
    public string BookingNumber { get; set; } = string.Empty;
    
    /// <summary>
    /// يمثل العقار Name.
    /// Represents property name.
    /// </summary>
    public string PropertyName { get; set; } = string.Empty;

    /// <summary>
    /// يمثل المستخدم Name.
    /// Represents user name.
    /// </summary>
    public string UserName { get; set; } = string.Empty;
    
    /// <summary>
    /// يمثل الوحدة Name.
    /// Represents unit name.
    /// </summary>
    public string UnitName { get; set; } = string.Empty;
    
    /// <summary>
    /// يمثل تاريخ تسجيل الوصول.
    /// Represents check in.
    /// </summary>
    public DateTime CheckIn { get; set; }
    
    /// <summary>
    /// يمثل تاريخ تسجيل المغادرة.
    /// Represents check out.
    /// </summary>
    public DateTime CheckOut { get; set; }
    
    /// <summary>
    /// يمثل عدد الضيوف.
    /// Represents guests count.
    /// </summary>
    public int GuestsCount { get; set; }
    
    /// <summary>
    /// يمثل السعر الإجمالي.
    /// Represents total price.
    /// </summary>
    public decimal TotalPrice { get; set; }
    
    /// <summary>
    /// يمثل العملة.
    /// Represents currency.
    /// </summary>
    public string Currency { get; set; } = string.Empty;
    
    /// <summary>
    /// يمثل الحالة.
    /// Represents status.
    /// </summary>
    public BookingStatus Status { get; set; }
    
    /// <summary>
    /// يمثل Booked At.
    /// Represents booked at.
    /// </summary>
    public DateTime BookedAt { get; set; }
    
    /// <summary>
    /// يمثل العقار Image Url.
    /// Represents property image url.
    /// </summary>
    public string PropertyImageUrl { get; set; } = string.Empty;
    
    /// <summary>
    /// يحدد ما إذا كان يمكن إلغاء
    /// Indicates whether can cancel.
    /// </summary>
    public bool CanCancel { get; set; }
    
    /// <summary>
    /// يحدد ما إذا كان يمكن Review
    /// Indicates whether can review.
    /// </summary>
    public bool CanReview { get; set; }
    
    /// <summary>
    /// يحدد ما إذا كان يمكن Modify
    /// Indicates whether can modify.
    /// </summary>
    public bool CanModify { get; set; }

    /// <summary>
    /// يحدد ما إذا كان هل Paid
    /// Indicates whether is paid.
    /// </summary>
    public bool IsPaid { get; set; }
}
