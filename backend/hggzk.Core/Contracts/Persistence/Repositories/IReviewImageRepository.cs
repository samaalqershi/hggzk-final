using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع التقييم الصورة repository.
/// Review image repository repository interface.
/// </summary>
public interface IReviewImageRepository : IRepository<ReviewImage>
{
    /// <summary>
    /// ينشئ التقييم الصورة.
    /// Creates review image.
    /// </summary>
    Task<ReviewImage> CreateReviewImageAsync(ReviewImage reviewImage, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الصور حسب التقييم.
    /// Gets images by review.
    /// </summary>
    Task<IEnumerable<ReviewImage>> GetImagesByReviewAsync(Guid reviewId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحذف التقييم الصورة.
    /// Deletes review image.
    /// </summary>
    Task<bool> DeleteReviewImageAsync(Guid reviewImageId, CancellationToken cancellationToken = default);
} 
