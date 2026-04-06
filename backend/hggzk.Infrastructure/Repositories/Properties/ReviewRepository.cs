using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Properties
{
    /// <summary>
    /// Provides persistence operations and rating queries for reviews.
    /// يوفّر عمليات الحفظ واستعلامات التقييم الخاصة بالتقييمات.
    /// </summary>
    public class ReviewRepository : BaseRepository<Review>, IReviewRepository
    {
        /// <summary>
        /// يهيئ مثيلاً جديدًا من ReviewRepository باستخدام سياق قاعدة البيانات المشترك.
        /// Initializes a new instance of ReviewRepository with the shared database context.
        /// </summary>
        public ReviewRepository(YemenBookingDbContext context) : base(context) { }

    /// <summary>
    /// Creates a new review and stages it for persistence.
    /// ينشئ تقييمًا جديدًا ويجهزه للحفظ.
    /// </summary>
    public async Task<Review> CreateReviewAsync(Review review, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(review, cancellationToken);
        return review;
    }

        /// <summary>
        /// Retrieves the specified review by its identifier.
        /// يسترجع التقييم المحدد بواسطة المعرّف.
        /// </summary>
        public async Task<Review?> GetReviewByIdAsync(Guid reviewId, CancellationToken cancellationToken = default)
            => await _dbSet.FindAsync(new object[]{reviewId}, cancellationToken);

    /// <summary>
    /// Updates an existing review.
    /// يحدّث التقييم الموجود.
    /// </summary>
    public async Task<Review> UpdateReviewAsync(Review review, CancellationToken cancellationToken = default)
    {
        return TrackForUpdate(_dbSet, review);
    }

    /// <summary>
    /// Deletes the specified review.
    /// يحذف التقييم المحدد.
    /// </summary>
    public async Task<bool> DeleteReviewAsync(Guid reviewId, CancellationToken cancellationToken = default)
    {
        var review = await GetReviewByIdAsync(reviewId, cancellationToken);
        if (review == null) return false;
        _dbSet.Remove(review);
        return true;
    }

        /// <summary>
        /// Checks whether the user can submit a review for the booking.
        /// يتحقق مما إذا كان بإمكان المستخدم إضافة تقييم للحجز.
        /// </summary>
        public async Task<bool> CheckReviewEligibilityAsync(Guid bookingId, Guid userId, CancellationToken cancellationToken = default)
        {
            // Eligibility: booking exists and belongs to user and no existing review
            var exists = await _context.Bookings.AnyAsync(b => b.Id == bookingId && b.UserId == userId, cancellationToken);
            if (!exists) return false;
            return !await _dbSet.AnyAsync(r => r.BookingId == bookingId, cancellationToken);
        }

        /// <summary>
        /// Retrieves reviews linked to the specified property.
        /// يسترجع التقييمات المرتبطة بالعقار المحدد.
        /// </summary>
        public async Task<IEnumerable<Review>> GetReviewsByPropertyAsync(Guid propertyId, CancellationToken cancellationToken = default)
            => await _dbSet
                .Include(r => r.Booking)
                    .ThenInclude(b => b.User)
                .Include(r => r.Images)
                .Include(r => r.Property)
                .Where(r => r.PropertyId == propertyId)
                .ToListAsync(cancellationToken);

        /// <summary>
        /// Retrieves reviews written by the specified user.
        /// يسترجع التقييمات التي كتبها المستخدم المحدد.
        /// </summary>
        public async Task<IEnumerable<Review>> GetReviewsByUserAsync(Guid userId, CancellationToken cancellationToken = default)
            => await _dbSet.Where(r => r.Booking.UserId == userId).ToListAsync(cancellationToken);

        /// <summary>
        /// Retrieves the review associated with the specified booking.
        /// يسترجع التقييم المرتبط بالحجز المحدد.
        /// </summary>
        public async Task<Review?> GetReviewByBookingAsync(Guid bookingId, CancellationToken cancellationToken = default)
            => await _dbSet
                .Include(r => r.Images)
                .FirstOrDefaultAsync(r => r.BookingId == bookingId, cancellationToken);

        public async Task<(double AverageRating, int TotalReviews)> GetPropertyRatingStatsAsync(Guid propertyId, CancellationToken cancellationToken = default)
        {
            // Only include approved and non-disabled reviews in statistics
            var reviews = await _dbSet
                .Where(r => r.PropertyId == propertyId && !r.IsPendingApproval && !r.IsDisabled)
                .ToListAsync(cancellationToken);

            var count = reviews.Count;
            var avg = count > 0
                ? reviews.Average(r => (r.Cleanliness + r.Service + r.Location + r.Value) / 4.0)
                : 0.0;

            return (Math.Round(avg, 2), count);
        }

        /// <summary>
        /// Calculates the average rating for the specified property.
        /// يحسب متوسط التقييم للعقار المحدد.
        /// </summary>
        public async Task<double> CalculateAverageRatingAsync(Guid propertyId, CancellationToken cancellationToken = default)
        {
            var stats = await GetPropertyRatingStatsAsync(propertyId, cancellationToken);
            return stats.AverageRating;
        }

        /// <summary>
        /// Retrieves the booking identified by the given ID.
        /// يسترجع الحجز المحدد بواسطة المعرّف.
        /// </summary>
        public async Task<Booking?> GetBookingByIdAsync(Guid bookingId, CancellationToken cancellationToken = default)
        {
            return await _context.Bookings.FindAsync(new object[] { bookingId }, cancellationToken);
        }
    }
}
