using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.ValueObjects;

namespace YemenBooking.Application.Features.Bookings.Commands.AddServices;

/// <summary>
/// يمثل أمرًا ضمن نطاق الحجوزات.
/// Represents a booking-related command.
/// </summary>
public class AddServicesToBookingCommand : IRequest<ResultDto<AddServicesToBookingResponse>>
{
    /// <summary>
    /// معرّف الحجز
    /// Booking identifier.
    /// </summary>
    public Guid BookingId { get; set; }
    
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
/// يمثل استجابة إضافة الخدمات إلى الحجز.
/// Represents the response for adding services to a booking
/// </summary>
public class AddServicesToBookingResponse
{
    /// <summary>
    /// يحدد ما إذا كان النجاح
    /// Indicates whether success.
    /// </summary>
    public bool Success { get; set; }
    
    /// <summary>
    /// يمثل السعر الإجمالي الجديد.
    /// Represents new total price.
    /// </summary>
    public Money NewTotalPrice { get; set; } = null!;
    
    /// <summary>
    /// يمثل الرسالة.
    /// Represents message.
    /// </summary>
    public string Message { get; set; } = string.Empty;
}