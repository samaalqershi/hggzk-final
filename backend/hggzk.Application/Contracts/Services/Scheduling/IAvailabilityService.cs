using YemenBooking.Application.Features.Units.Commands.BulkOperations;

namespace YemenBooking.Application.Contracts.Services.Scheduling;

/// <summary>
/// يعرّف عمليات فحص الإتاحة وحجز الفترات وتحريرها على مستوى الوحدات.
/// Defines availability checks plus block/release operations for unit scheduling.
/// </summary>
public interface IAvailabilityService
{
    /// <summary>
    /// يتحقق من توفر الوحدة خلال فترة محددة مع إمكانية استثناء حجز قائم من التعارض.
    /// Checks whether a unit is available during the given period, optionally excluding an existing booking.
    /// </summary>
    Task<bool> CheckAvailabilityAsync(Guid unitId, DateTime checkIn, DateTime checkOut, Guid? excludeBookingId = null);

    /// <summary>
    /// يضع حجزًا على الأيام التابعة للحجز الجديد داخل جدول الإتاحة.
    /// Blocks the schedule dates associated with a newly created booking.
    /// </summary>
    Task BlockForBookingAsync(Guid unitId, Guid bookingId, DateTime checkIn, DateTime checkOut);

    /// <summary>
    /// يحرر الأيام المحجوزة لحجز معين ويعيدها إلى حالة الإتاحة المناسبة.
    /// Releases the dates reserved for a booking and restores their proper availability state.
    /// </summary>
    Task ReleaseBookingAsync(Guid bookingId);

    /// <summary>
    /// يجلب تقويم الإتاحة الشهري للوحدة بصيغة مبسطة مناسبة للعرض.
    /// Retrieves the unit monthly availability calendar in a simplified display-friendly form.
    /// </summary>
    Task<Dictionary<DateTime, string>> GetMonthlyCalendarAsync(Guid unitId, int year, int month);

    /// <summary>
    /// يطبق تغييرات إتاحة مجمعة على الوحدة ضمن عدة فترات.
    /// Applies bulk availability updates for a unit across multiple periods.
    /// </summary>
    Task ApplyBulkAvailabilityAsync(Guid unitId, List<AvailabilityPeriodDto> periods);

    /// <summary>
    /// يعيد معرفات الوحدات المتاحة داخل كيان محدد خلال فترة ووفق عدد الضيوف.
    /// Returns the identifiers of units available in a property for the requested period and guest count.
    /// </summary>
    Task<IEnumerable<Guid>> GetAvailableUnitsInPropertyAsync(
        Guid propertyId,
        DateTime checkIn,
        DateTime checkOut,
        int guestCount,
        CancellationToken cancellationToken = default);
}
