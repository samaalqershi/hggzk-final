using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع القيد المالي repository.
/// Financial transaction repository repository interface.
/// </summary>
public interface IFinancialTransactionRepository
{
    /// <summary>
    /// يضيف .
    /// Adds .
    /// </summary>
    Task<FinancialTransaction> AddAsync(FinancialTransaction transaction);
    
    /// <summary>
    /// ينشئ القيد الرقم.
    /// Generates transaction number.
    /// </summary>
    Task<string> GenerateTransactionNumberAsync();

    /// <summary>
    /// يجلب العنصر حسب الحجز المعرّف.
    /// Gets the item by booking id.
    /// </summary>
    Task<List<FinancialTransaction>> GetByBookingIdAsync(Guid bookingId);

    /// <summary>
    /// يجلب العنصر حسب المستخدم المعرّف.
    /// Gets the item by user id.
    /// </summary>
    Task<List<FinancialTransaction>> GetByUserIdAsync(Guid userId);

    /// <summary>
    /// يجلب العنصر حسب العقار المعرّف.
    /// Gets the item by property id.
    /// </summary>
    Task<List<FinancialTransaction>> GetByPropertyIdAsync(Guid propertyId);

    /// <summary>
    /// يجلب العنصر حسب period.
    /// Gets the item by period.
    /// </summary>
    Task<List<FinancialTransaction>> GetByPeriodAsync(DateTime startDate, DateTime endDate);

    /// <summary>
    /// يجلب العنصر حسب period.
    /// Gets the item by period.
    /// </summary>
    Task<List<FinancialTransaction>> GetByPeriodAsync(DateTime startDate, DateTime endDate, TransactionStatus? status, TransactionType? type, int? limit);

    /// <summary>
    /// يجلب المعلقة لـ posting.
    /// Gets pending for posting.
    /// </summary>
    Task<List<FinancialTransaction>> GetPendingForPostingAsync();

    /// <summary>
    /// يرحّل القيد.
    /// Posts transaction.
    /// </summary>
    Task<bool> PostTransactionAsync(Guid transactionId);

    /// <summary>
    /// يعكس القيد.
    /// Reverses transaction.
    /// </summary>
    Task<FinancialTransaction?> ReverseTransactionAsync(Guid transactionId, string reason, Guid userId);

    /// <summary>
    /// يجلب القيد الملخص حسب النوع.
    /// Gets transaction summary by type.
    /// </summary>
    Task<Dictionary<TransactionType, decimal>> GetTransactionSummaryByTypeAsync(DateTime startDate, DateTime endDate);

    /// <summary>
    /// يحسب حسب period.
    /// Counts by period.
    /// </summary>
    Task<int> CountByPeriodAsync(DateTime startDate, DateTime endDate, TransactionStatus? status, TransactionType? type);

    /// <summary>
    /// يجلب الحساب الرصيد at التاريخ.
    /// Gets account balance at date.
    /// </summary>
    Task<decimal> GetAccountBalanceAtDateAsync(Guid accountId, DateTime asOfDate);
    
    /// <summary>
    /// يجلب الحسابات الأرصدة.
    /// Gets accounts balances.
    /// </summary>
    Task<Dictionary<Guid, decimal>> GetAccountsBalancesAsync(List<Guid> accountIds, DateTime asOfDate);

    /// <summary>
    /// يجلب الحساب كشف الحساب.
    /// Gets account statement.
    /// </summary>
    Task<List<FinancialTransaction>> GetAccountStatementAsync(Guid accountId, DateTime startDate, DateTime endDate);

    /// <summary>
    /// يبحث عن القيود.
    /// Searches transactions.
    /// </summary>
    Task<List<FinancialTransaction>> SearchTransactionsAsync(
        string searchTerm,
        TransactionType? transactionType = null,
        TransactionStatus? status = null,
        DateTime? startDate = null,
        DateTime? endDate = null);

    /// <summary>
    /// يحفظ التغييرات المعلقة.
    /// Saves pending changes.
    /// </summary>
    Task<int> SaveChangesAsync(System.Threading.CancellationToken cancellationToken = default);
}
