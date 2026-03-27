using YemenBooking.Core.Entities;
using YemenBooking.Core.ValueObjects;
using YemenBooking.Core.Enums;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع الحجز repository.
/// Booking repository repository interface.
/// </summary>
public interface IBookingRepository : IRepository<Booking>
{
    /// <summary>
    /// ينشئ الحجز.
    /// Creates booking.
    /// </summary>
    Task<Booking> CreateBookingAsync(Booking booking, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الحجز حسب المعرّف.
    /// Gets booking by id.
    /// </summary>
    Task<Booking?> GetBookingByIdAsync(Guid bookingId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الحجز مع المستخدم.
    /// Gets booking with user.
    /// </summary>
    Task<Booking?> GetBookingWithUserAsync(Guid bookingId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الحجز مع الوحدة.
    /// Gets booking with unit.
    /// </summary>
    Task<Booking?> GetBookingWithUnitAsync(Guid bookingId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الحجز مع الخدمات.
    /// Gets booking with services.
    /// </summary>
    Task<Booking?> GetBookingWithServicesAsync(Guid bookingId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الحجز مع المدفوعات.
    /// Gets booking with payments.
    /// </summary>
    Task<Booking?> GetBookingWithPaymentsAsync(Guid bookingId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث الحجز.
    /// Updates booking.
    /// </summary>
    Task<Booking> UpdateBookingAsync(Booking booking, CancellationToken cancellationToken = default);

    /// <summary>
    /// يؤكد الحجز.
    /// Confirms booking.
    /// </summary>
    Task<bool> ConfirmBookingAsync(Guid bookingId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يلغي الحجز.
    /// Cancels booking.
    /// </summary>
    Task<bool> CancelBookingAsync(Guid bookingId, string reason, CancellationToken cancellationToken = default);

    /// <summary>
    /// يتحقق من النشط الحجوزات.
    /// Checks active bookings.
    /// </summary>
    Task<bool> CheckActiveBookingsAsync(Guid unitId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب conflicting الحجوزات.
    /// Gets conflicting bookings.
    /// </summary>
    Task<IEnumerable<Booking>> GetConflictingBookingsAsync(Guid unitId, DateTime checkIn, DateTime checkOut, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الحجوزات حسب المستخدم.
    /// Gets bookings by user.
    /// </summary>
    Task<IEnumerable<Booking>> GetBookingsByUserAsync(Guid userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الحجوزات حسب العقار.
    /// Gets bookings by property.
    /// </summary>
    Task<IEnumerable<Booking>> GetBookingsByPropertyAsync(Guid propertyId, DateTime? fromDate = null, DateTime? toDate = null, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الحجوزات حسب الوحدة.
    /// Gets bookings by unit.
    /// </summary>
    Task<IEnumerable<Booking>> GetBookingsByUnitAsync(Guid unitId, DateTime? fromDate = null, DateTime? toDate = null, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الحجوزات حسب التاريخ range.
    /// Gets bookings by date range.
    /// </summary>
    Task<IEnumerable<Booking>> GetBookingsByDateRangeAsync(DateTime fromDate, DateTime toDate, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الحجز الخدمات.
    /// Gets booking services.
    /// </summary>
    Task<IEnumerable<BookingService>> GetBookingServicesAsync(Guid bookingId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يضيف الخدمة إلى الحجز.
    /// Adds service to booking.
    /// </summary>
    Task<bool> AddServiceToBookingAsync(Guid bookingId, Guid serviceId, int quantity = 1, CancellationToken cancellationToken = default);

    /// <summary>
    /// يزيل الخدمة من الحجز.
    /// Removes service from booking.
    /// </summary>
    Task<bool> RemoveServiceFromBookingAsync(Guid bookingId, Guid serviceId, CancellationToken cancellationToken = default);

    /// <summary>
    /// ينفذ recalculate price.
    /// Performs recalculate price.
    /// </summary>
    Task<decimal> RecalculatePriceAsync(Guid bookingId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الإجمالي الحجوزات count.
    /// Gets total bookings count.
    /// </summary>
    Task<int> GetTotalBookingsCountAsync(Guid? propertyId, DateTime fromDate, DateTime toDate, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الإجمالي revenue.
    /// Gets total revenue.
    /// </summary>
    Task<decimal> GetTotalRevenueAsync(Guid? propertyId, DateTime fromDate, DateTime toDate, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الأول الحجز التاريخ لـ المستخدمين.
    /// Gets first booking date for users.
    /// </summary>
    Task<Dictionary<Guid, DateTime>> GetFirstBookingDateForUsersAsync(IEnumerable<Guid> userIds, CancellationToken cancellationToken = default);
}
