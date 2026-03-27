using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع رد التقييم repository.
/// Review response repository repository interface.
/// </summary>
public interface IReviewResponseRepository
{
    /// <summary>
    /// ينشئ .
    /// Creates .
    /// </summary>
    Task<ReviewResponse> CreateAsync(ReviewResponse response, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب العنصر حسب المعرّف.
    /// Gets the item by id.
    /// </summary>
    Task<ReviewResponse?> GetByIdAsync(Guid responseId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب العنصر حسب التقييم المعرّف.
    /// Gets the item by review id.
    /// </summary>
    Task<IEnumerable<ReviewResponse>> GetByReviewIdAsync(Guid reviewId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يحذف .
    /// Deletes .
    /// </summary>
    Task<bool> DeleteAsync(Guid responseId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحفظ التغييرات المعلقة.
    /// Saves pending changes.
    /// </summary>
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
