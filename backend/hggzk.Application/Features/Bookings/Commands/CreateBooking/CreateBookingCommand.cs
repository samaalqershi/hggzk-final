using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Enums;
using YemenBooking.Core.ValueObjects;
using YemenBooking.Application.Features.Bookings.Commands.CreateBooking;

namespace YemenBooking.Application.Features.Bookings.Commands.CreateBooking;

/// <summary>
/// يمثل أمرًا ضمن نطاق الحجوزات.
/// Represents a booking-related command.
/// </summary>
public class CreateBookingCommand : IRequest<ResultDto<CreateBookingResponse>>
{
    /// <summary>
    /// معرّف المستخدم
    /// User identifier.
    /// </summary>
    public Guid UserId { get; set; }
    
    /// <summary>
    /// معرّف الوحدة
    /// Unit identifier.
    /// </summary>
    public Guid UnitId { get; set; }
    
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
    /// يمثل الخدمات.
    /// Represents services.
    /// </summary>
    public List<BookingServiceRequest> Services { get; set; } = new();
    
    /// <summary>
    /// يمثل Special Requests.
    /// Represents special requests.
    /// </summary>
    public string? SpecialRequests { get; set; }
    
    /// <summary>
    /// يمثل مصدر الحجز.
    /// Represents booking source.
    /// </summary>
    public string BookingSource { get; set; } = "MobileApp";
}

/// <summary>
/// يمثل عنصرًا ضمن نطاق الحجوزات.
/// Represents an item in the booking-related feature area.
/// </summary>
public class BookingServiceRequest
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

/// <summary>
/// يمثل استجابة إنشاء الحجز.
/// represents the booking creation response
/// </summary>
public class CreateBookingResponse
{
    /// <summary>
    /// معرّف الحجز
    /// Booking identifier.
    /// </summary>
    public Guid BookingId { get; set; }
    
    /// <summary>
    /// يمثل رقم الحجز.
    /// Represents booking number.
    /// </summary>
    public string BookingNumber { get; set; } = string.Empty;
    
    /// <summary>
    /// يمثل السعر الإجمالي.
    /// Represents total price.
    /// </summary>
    public Money TotalPrice { get; set; } = null!;
    
    /// <summary>
    /// يمثل الحالة.
    /// Represents status.
    /// </summary>
    public BookingStatus Status { get; set; }
    
    /// <summary>
    /// يمثل الرسالة.
    /// Represents message.
    /// </summary>
    public string Message { get; set; } = string.Empty;
}