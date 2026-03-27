using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Properties
{
    /// <summary>
    /// Provides persistence operations for review responses.
    /// يوفّر عمليات الحفظ الخاصة بردود التقييمات.
    /// </summary>
    public class ReviewResponseRepository : IReviewResponseRepository
    {
        private readonly YemenBookingDbContext _context;
        private readonly DbSet<ReviewResponse> _responses;

        /// <summary>
        /// يهيئ مثيلاً جديدًا من ReviewResponseRepository باستخدام سياق قاعدة البيانات المشترك.
        /// Initializes a new instance of ReviewResponseRepository with the shared database context.
        /// </summary>
        public ReviewResponseRepository(YemenBookingDbContext context)
        {
            _context = context;
            _responses = context.Set<ReviewResponse>();
        }

    /// <summary>
    /// Creates a new review response and stages it for persistence.
    /// ينشئ رد تقييم جديدًا ويجهزه للحفظ.
    /// </summary>
    public async Task<ReviewResponse> CreateAsync(ReviewResponse response, CancellationToken cancellationToken = default)
    {
        await _responses.AddAsync(response, cancellationToken);
        return response;
    }

        /// <summary>
        /// Retrieves the specified review response by its identifier.
        /// يسترجع رد التقييم المحدد بواسطة المعرّف.
        /// </summary>
        public async Task<ReviewResponse?> GetByIdAsync(Guid responseId, CancellationToken cancellationToken = default)
        {
            return await _responses
                .AsNoTracking()
                .FirstOrDefaultAsync(response => response.Id == responseId, cancellationToken);
        }

        /// <summary>
        /// Retrieves responses linked to the specified review.
        /// يسترجع الردود المرتبطة بالتقييم المحدد.
        /// </summary>
        public async Task<IEnumerable<ReviewResponse>> GetByReviewIdAsync(Guid reviewId, CancellationToken cancellationToken = default)
        {
            return await _responses
                .AsNoTracking()
                .Where(r => r.ReviewId == reviewId)
                .OrderByDescending(r => r.RespondedAt)
                .ToListAsync(cancellationToken);
        }

    /// <summary>
    /// Deletes the specified review response.
    /// يحذف رد التقييم المحدد.
    /// </summary>
    public async Task<bool> DeleteAsync(Guid responseId, CancellationToken cancellationToken = default)
    {
        var entity = await _responses.FindAsync(new object[] { responseId }, cancellationToken);
        if (entity == null) return false;
        _responses.Remove(entity);
        return true;
    }

        /// <summary>
        /// Persists the pending changes to the database.
        /// يحفظ التغييرات المعلّقة في قاعدة البيانات.
        /// </summary>
        public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
            => _context.SaveChangesAsync(cancellationToken);
}
}
