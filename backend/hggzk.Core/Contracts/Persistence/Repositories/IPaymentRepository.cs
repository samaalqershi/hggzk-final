using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع الدفع repository.
/// Payment repository repository interface.
/// </summary>
public interface IPaymentRepository : IRepository<Payment>
{
    /// <summary>
    /// ينفذ process الدفع.
    /// Performs process payment.
    /// </summary>
    Task<Payment> ProcessPaymentAsync(Payment payment, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث الدفع.
    /// Updates payment.
    /// </summary>
    Task<Payment> UpdatePaymentAsync(Payment payment, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب المدفوعات حسب الحجز.
    /// Gets payments by booking.
    /// </summary>
    Task<IEnumerable<Payment>> GetPaymentsByBookingAsync(Guid bookingId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب المدفوعات حسب المستخدم.
    /// Gets payments by user.
    /// </summary>
    Task<IEnumerable<Payment>> GetPaymentsByUserAsync(Guid userId, DateTime? fromDate = null, DateTime? toDate = null, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الإجمالي paid amount.
    /// Gets total paid amount.
    /// </summary>
    Task<decimal> GetTotalPaidAmountAsync(Guid bookingId, CancellationToken cancellationToken = default);

}
