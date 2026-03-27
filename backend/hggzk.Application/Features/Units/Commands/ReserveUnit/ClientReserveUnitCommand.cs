using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Units.Commands.ReserveUnit;

/// <summary>
/// أمر client حجز الوحدة.
/// Client Reserve Unit command.
/// </summary>
public class ClientReserveUnitCommand : IRequest<ResultDto<ClientUnitReservationResponse>>
{
    /// <summary>
    /// معرّف الوحدة.
    /// Unit identifier.
    /// </summary>
    public Guid UnitId { get; set; }

    /// <summary>
    /// معرّف المستخدم.
    /// User identifier.
    /// </summary>
    public Guid UserId { get; set; }

    /// <summary>
    /// القيمة الخاصة بـ التحقق من in date.
    /// Check In Date value.
    /// </summary>
    public DateTime CheckInDate { get; set; }

    /// <summary>
    /// القيمة الخاصة بـ التحقق من out date.
    /// Check Out Date value.
    /// </summary>
    public DateTime CheckOutDate { get; set; }

    /// <summary>
    /// القيمة الخاصة بـ adults.
    /// Adults value.
    /// </summary>
    public int Adults { get; set; } = 1;

    /// <summary>
    /// القيمة الخاصة بـ children.
    /// Children value.
    /// </summary>
    public int Children { get; set; } = 0;

    /// <summary>
    /// القيمة الخاصة بـ reservation duration minutes.
    /// Reservation Duration Minutes value.
    /// </summary>
    public int ReservationDurationMinutes { get; set; } = 15;

    /// <summary>
    /// معرّف session.
    /// Session identifier.
    /// </summary>
    public string? SessionId { get; set; }

    /// <summary>
    /// القيمة الخاصة بـ special الملاحظات.
    /// Special Notes value.
    /// </summary>
    public string? SpecialNotes { get; set; }
}

/// <summary>
/// أمر client حجز الوحدة.
/// Client Reserve Unit command.
/// </summary>
public class ClientUnitReservationResponse
{
    /// <summary>
    /// معرّف reservation.
    /// Reservation identifier.
    /// </summary>
    public Guid ReservationId { get; set; }

    /// <summary>
    /// معرّف الوحدة.
    /// Unit identifier.
    /// </summary>
    public Guid UnitId { get; set; }

    /// <summary>
    /// اسم الوحدة.
    /// Unit name.
    /// </summary>
    public string UnitName { get; set; } = string.Empty;

    /// <summary>
    /// القيمة الخاصة بـ expires at.
    /// Expires At value.
    /// </summary>
    public DateTime ExpiresAt { get; set; }

    /// <summary>
    /// القيمة الخاصة بـ total السعر.
    /// Total Price value.
    /// </summary>
    public decimal TotalPrice { get; set; }

    /// <summary>
    /// العملة.
    /// Currency.
    /// </summary>
    public string Currency { get; set; } = "YER";

    /// <summary>
    /// القيمة الخاصة بـ reservation الرمز.
    /// Reservation Token value.
    /// </summary>
    public string ReservationToken { get; set; } = string.Empty;

    /// <summary>
    /// الحالة.
    /// Status.
    /// </summary>
    public string Status { get; set; } = "Active";

    /// <summary>
    /// تاريخ الإنشاء.
    /// Creation timestamp.
    /// </summary>
    public DateTime CreatedAt { get; set; }
}