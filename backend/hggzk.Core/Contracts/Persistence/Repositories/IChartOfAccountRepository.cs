using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع دليل لـ الحساب repository.
/// Chart of account repository repository interface.
/// </summary>
public interface IChartOfAccountRepository : IRepository<ChartOfAccount>
{
    /// <summary>
    /// يجلب الحساب list.
    /// Gets account list.
    /// </summary>
    Task<List<ChartOfAccount>> GetAccountListAsync();

    /// <summary>
    /// يجلب العنصر حسب الحساب النوع.
    /// Gets the item by account type.
    /// </summary>
    Task<List<ChartOfAccount>> GetByAccountTypeAsync(AccountType accountType);

    /// <summary>
    /// يجلب المستخدم الحساب.
    /// Gets user account.
    /// </summary>
    Task<ChartOfAccount> GetUserAccountAsync(Guid userId, AccountType accountType);

    /// <summary>
    /// يجلب المستخدم الحسابات.
    /// Gets user accounts.
    /// </summary>
    Task<List<ChartOfAccount>> GetUserAccountsAsync(Guid userId);

    /// <summary>
    /// يجلب العقار الحساب.
    /// Gets property account.
    /// </summary>
    Task<ChartOfAccount> GetPropertyAccountAsync(Guid propertyId, AccountType accountType);

    /// <summary>
    /// ينشئ العقار الحساب.
    /// Creates property account.
    /// </summary>
    Task<ChartOfAccount> CreatePropertyAccountAsync(Guid propertyId, string propertyName, AccountType accountType);

    /// <summary>
    /// يحدّث الحساب الرصيد.
    /// Updates account balance.
    /// </summary>
    Task<bool> UpdateAccountBalanceAsync(Guid accountId, decimal amount, bool isDebit);

    /// <summary>
    /// يبحث عن الحسابات.
    /// Searches accounts.
    /// </summary>
    Task<List<ChartOfAccount>> SearchAccountsAsync(string searchTerm);

    /// <summary>
    /// يجلب الحسابات الشجرة.
    /// Gets accounts tree.
    /// </summary>
    Task<List<ChartOfAccount>> GetAccountsTreeAsync();

    /// <summary>
    /// ينشئ الحساب الرقم.
    /// Generates account number.
    /// </summary>
    /// <param name="accountType"></param>
    /// <param name="isUserAccount"></param>
    /// <returns></returns>
    Task<string> GenerateAccountNumberAsync(AccountType accountType, bool isUserAccount);
    
    /// <summary>
    /// يجلب system الحساب.
    /// Gets system account.
    /// </summary>
    Task<ChartOfAccount> GetSystemAccountAsync(string accountName);

    /// <summary>
    /// ينشئ .
    /// Creates .
    /// </summary>
    Task<ChartOfAccount> CreateAsync(ChartOfAccount account, System.Threading.CancellationToken cancellationToken = default);

}
