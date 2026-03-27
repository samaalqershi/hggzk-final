using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع التقييم repository.
/// Review repository repository interface.
/// </summary>
public interface IReviewRepository : IRepository<Review>
{
    /// <summary>
    /// ينشئ التقييم.
    /// Creates review.
    /// </summary>
    Task<Review> CreateReviewAsync(Review review, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب التقييم حسب المعرّف.
    /// Gets review by id.
    /// </summary>
    Task<Review?> GetReviewByIdAsync(Guid reviewId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث التقييم.
    /// Updates review.
    /// </summary>
    Task<Review> UpdateReviewAsync(Review review, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحذف التقييم.
    /// Deletes review.
    /// </summary>
    Task<bool> DeleteReviewAsync(Guid reviewId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب التقييمات حسب العقار.
    /// Gets reviews by property.
    /// </summary>
    Task<IEnumerable<Review>> GetReviewsByPropertyAsync(Guid propertyId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب التقييمات حسب المستخدم.
    /// Gets reviews by user.
    /// </summary>
    Task<IEnumerable<Review>> GetReviewsByUserAsync(Guid userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب التقييم حسب الحجز.
    /// Gets review by booking.
    /// </summary>
    Task<Review?> GetReviewByBookingAsync(Guid bookingId, CancellationToken cancellationToken = default);

    /// <summary>
    /// الحصول على إحصائيات تقييم الكيان
    /// Get property rating stats
    /// </summary>
    Task<(double AverageRating, int TotalReviews)> GetPropertyRatingStatsAsync(Guid propertyId, CancellationToken cancellationToken = default);
}
