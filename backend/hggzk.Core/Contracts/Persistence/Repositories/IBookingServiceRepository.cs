using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع الحجز الخدمة repository.
/// Booking service repository repository interface.
/// </summary>
public interface IBookingServiceRepository : IRepository<BookingService>
{
    /// <summary>
    /// يضيف الخدمة إلى الحجز.
    /// Adds service to booking.
    /// </summary>
    Task<BookingService> AddServiceToBookingAsync(BookingService bookingService, CancellationToken cancellationToken = default);

    /// <summary>
    /// يزيل الخدمة من الحجز.
    /// Removes service from booking.
    /// </summary>
    Task<bool> RemoveServiceFromBookingAsync(Guid bookingId, Guid serviceId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الحجز الخدمات.
    /// Gets booking services.
    /// </summary>
    Task<IEnumerable<BookingService>> GetBookingServicesAsync(Guid bookingId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث الحجز الخدمة.
    /// Updates booking service.
    /// </summary>
    Task<BookingService> UpdateBookingServiceAsync(BookingService bookingService, CancellationToken cancellationToken = default);
}
