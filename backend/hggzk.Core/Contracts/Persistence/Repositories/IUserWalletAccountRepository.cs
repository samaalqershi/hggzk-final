using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع حساب محفظة المستخدم repository.
/// User wallet account repository repository interface.
/// </summary>
public interface IUserWalletAccountRepository : IRepository<UserWalletAccount>
{
    /// <summary>
    /// يجلب العنصر حسب المستخدم المعرّف.
    /// Gets the item by user id.
    /// </summary>
    Task<List<UserWalletAccount>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// ينفذ replace لـ المستخدم.
    /// Performs replace for user.
    /// </summary>
    Task<List<UserWalletAccount>> ReplaceForUserAsync(Guid userId, List<UserWalletAccount> accounts, CancellationToken cancellationToken = default);
}
