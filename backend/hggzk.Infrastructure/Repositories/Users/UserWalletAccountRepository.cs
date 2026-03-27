using System;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Users;

/// <summary>
/// مستودع حسابات محفظة المستخدم.
/// User wallet account repository.
/// </summary>
public class UserWalletAccountRepository : BaseRepository<UserWalletAccount>, IUserWalletAccountRepository
{
    /// <summary>
    /// ينشئ مثيلاً جديداً من UserWalletAccountRepository.
    /// Initializes a new instance of UserWalletAccountRepository.
    /// </summary>
    public UserWalletAccountRepository(YemenBookingDbContext context) : base(context)
    {
    }

    /// <summary>
    /// يجلب الإعدادات حسب المستخدم.
    /// Gets settings by user.
    /// </summary>
    public async Task<List<UserWalletAccount>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(x => x.UserId == userId)
            .OrderByDescending(x => x.IsDefault)
            .ThenBy(x => x.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    /// <summary>
    /// يستبدل حسابات المحفظة للمستخدم.
    /// Replaces the user wallet accounts.
    /// </summary>
    public async Task<List<UserWalletAccount>> ReplaceForUserAsync(Guid userId, List<UserWalletAccount> accounts, CancellationToken cancellationToken = default)
    {
        var existing = await _dbSet.Where(x => x.UserId == userId).ToListAsync(cancellationToken);
        if (existing.Any())
        {
            _dbSet.RemoveRange(existing);
        }

        if (accounts != null && accounts.Any())
        {
            foreach (var acc in accounts)
            {
                acc.UserId = userId;
                if (acc.Id == Guid.Empty)
                    acc.Id = Guid.NewGuid();
                if (acc.CreatedAt == default)
                    acc.CreatedAt = DateTime.UtcNow;
                acc.UpdatedAt = DateTime.UtcNow;
            }

            await _dbSet.AddRangeAsync(accounts, cancellationToken);
        }

        return await GetByUserIdAsync(userId, cancellationToken);
    }
}
