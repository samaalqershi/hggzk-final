using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Properties
{
    /// <summary>
    /// Provides persistence operations for review images.
    /// يوفّر عمليات الحفظ الخاصة بصور التقييمات.
    /// </summary>
    public class ReviewImageRepository : BaseRepository<ReviewImage>, IReviewImageRepository
    {
        /// <summary>
        /// يهيئ مثيلاً جديدًا من ReviewImageRepository باستخدام سياق قاعدة البيانات المشترك.
        /// Initializes a new instance of ReviewImageRepository with the shared database context.
        /// </summary>
        public ReviewImageRepository(YemenBookingDbContext context) : base(context) { }

    /// <summary>
    /// Creates a new review image and stages it for persistence.
    /// ينشئ صورة تقييم جديدة ويجهزها للحفظ.
    /// </summary>
    public async Task<ReviewImage> CreateReviewImageAsync(ReviewImage reviewImage, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(reviewImage, cancellationToken);
        return reviewImage;
    }

        /// <summary>
        /// Retrieves images linked to the specified review.
        /// يسترجع الصور المرتبطة بالتقييم المحدد.
        /// </summary>
        public async Task<IEnumerable<ReviewImage>> GetImagesByReviewAsync(Guid reviewId, CancellationToken cancellationToken = default)
            => await _dbSet.Where(img => img.ReviewId == reviewId).ToListAsync(cancellationToken);

    /// <summary>
    /// Deletes the specified review image.
    /// يحذف صورة التقييم المحددة.
    /// </summary>
    public async Task<bool> DeleteReviewImageAsync(Guid reviewImageId, CancellationToken cancellationToken = default)
    {
        var img = await GetByIdAsync(reviewImageId, cancellationToken);
        if (img == null) return false;
        _dbSet.Remove(img);
        return true;
    }
}
} 
