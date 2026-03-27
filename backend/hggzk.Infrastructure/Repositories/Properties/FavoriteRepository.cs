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
    /// Provides persistence operations for user favorites.
    /// يوفّر عمليات الحفظ الخاصة بمفضلات المستخدمين.
    /// </summary>
    public class FavoriteRepository : BaseRepository<Favorite>, IFavoriteRepository
    {
        /// <summary>
        /// يهيئ مثيلاً جديدًا من FavoriteRepository باستخدام سياق قاعدة البيانات المشترك.
        /// Initializes a new instance of FavoriteRepository with the shared database context.
        /// </summary>
        public FavoriteRepository(YemenBookingDbContext context) : base(context) { }

        /// <summary>
        /// Retrieves all favorites for the specified user.
        /// يسترجع جميع المفضلات الخاصة بالمستخدم المحدد.
        /// </summary>
        public async Task<IEnumerable<Favorite>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default)
        {
            return await _dbSet.AsNoTracking()
                .Where(f => f.UserId == userId && !f.IsDeleted)
                .OrderByDescending(f => f.DateAdded)
                .ToListAsync(cancellationToken);
        }

        public async Task<(IEnumerable<Favorite> Items, int TotalCount)> GetUserFavoritesAsync(Guid userId, int pageNumber = 1, int pageSize = 10, CancellationToken cancellationToken = default)
        {
            if (pageNumber < 1) pageNumber = 1;
            if (pageSize < 1) pageSize = 10;

            var query = _dbSet.AsNoTracking().Where(f => f.UserId == userId && !f.IsDeleted);
            var total = await query.CountAsync(cancellationToken);
            var items = await query
                .OrderByDescending(f => f.DateAdded)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync(cancellationToken);

            return (items, total);
        }

        /// <summary>
        /// Checks whether the favorite already exists for the specified user and property.
        /// يتحقق مما إذا كانت المفضلة موجودة بالفعل للمستخدم والعقار المحددين.
        /// </summary>
        public async Task<bool> ExistsAsync(Guid userId, Guid propertyId, CancellationToken cancellationToken = default)
        {
            return await _dbSet.AsNoTracking().AnyAsync(
                f => f.UserId == userId && f.PropertyId == propertyId && !f.IsDeleted,
                cancellationToken);
        }

    /// <summary>
    /// Creates a new favorite and stages it for persistence.
    /// ينشئ مفضلة جديدة ويجهزها للحفظ.
    /// </summary>
    public async Task<Favorite> CreateFavoriteAsync(Favorite favorite, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(favorite, cancellationToken);
        return favorite;
    }

    /// <summary>
    /// Deletes the specified favorite.
    /// يحذف المفضلة المحددة.
    /// </summary>
    public new async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var entity = await _dbSet.FirstOrDefaultAsync(f => f.Id == id, cancellationToken);
        if (entity == null) return false;
        _dbSet.Remove(entity);
        return true;
    }

    /// <summary>
    /// Deletes the favorite for the specified user and property pair.
    /// يحذف المفضلة الخاصة بالمستخدم والعقار المحددين.
    /// </summary>
    public async Task<bool> DeleteByUserAndPropertyAsync(Guid userId, Guid propertyId, CancellationToken cancellationToken = default)
    {
        var entity = await _dbSet.FirstOrDefaultAsync(
            f => f.UserId == userId && f.PropertyId == propertyId,
            cancellationToken);
        if (entity == null) return false;
        _dbSet.Remove(entity);
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
