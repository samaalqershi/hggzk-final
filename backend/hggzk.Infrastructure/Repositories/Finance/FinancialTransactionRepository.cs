using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Entities;
using InfrastructureDbContext = YemenBooking.Infrastructure.Data.Context.YemenBookingDbContext;

namespace YemenBooking.Infrastructure.Repositories.Finance;

/// <summary>
/// يمثل مستودعًا للوصول إلى المعاملات المالية.
/// Represents a repository for accessing financial transactions.
/// </summary>
public class FinancialTransactionRepository : BaseRepository<FinancialTransaction>, IFinancialTransactionRepository
{
/// <summary>
/// ينشئ المستودع مع سياق قاعدة البيانات المشترك.
/// Creates the repository with the shared database context.
/// </summary>
    public FinancialTransactionRepository(InfrastructureDbContext context) : base(context)
    {
    }

/// <summary>
/// يضيف السجل المطلوب إلى المستودع.
/// Adds the requested record to the repository.
/// </summary>
    public async Task<FinancialTransaction> AddAsync(FinancialTransaction transaction)
    {
        await _context.FinancialTransactions.AddAsync(transaction);
        return transaction;
    }

/// <summary>
/// يولّد القيمة أو المعرّف المطلوب.
/// Generates the requested value or identifier.
/// </summary>
    public async Task<string> GenerateTransactionNumberAsync()
    {
        var year = DateTime.UtcNow.Year;
        var month = DateTime.UtcNow.Month.ToString("D2");
        
        var lastTransaction = await _context.FinancialTransactions
            .AsNoTracking()
            .Where(t => t.TransactionNumber.StartsWith($"JV-{year}{month}"))
            .OrderByDescending(t => t.TransactionNumber)
            .FirstOrDefaultAsync();

        if (lastTransaction == null)
        {
            return $"JV-{year}{month}0001";
        }

        var lastNumber = lastTransaction.TransactionNumber.Substring(10);
        var nextNumber = (int.Parse(lastNumber) + 1).ToString("D4");
        return $"JV-{year}{month}{nextNumber}";
    }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<List<FinancialTransaction>> GetByBookingIdAsync(Guid bookingId)
    {
        return await _context.FinancialTransactions
            .AsNoTracking()
            .Include(t => t.DebitAccount)
            .Include(t => t.CreditAccount)
            .Include(t => t.FirstPartyUser)
            .Include(t => t.SecondPartyUser)
            .Where(t => t.BookingId == bookingId)
            .OrderBy(t => t.TransactionDate)
            .ToListAsync();
    }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<List<FinancialTransaction>> GetByUserIdAsync(Guid userId)
    {
        return await _context.FinancialTransactions
            .AsNoTracking()
            .Include(t => t.DebitAccount)
            .Include(t => t.CreditAccount)
            .Include(t => t.Property)
            .Include(t => t.Unit)
            .Where(t => t.FirstPartyUserId == userId || t.SecondPartyUserId == userId)
            .OrderByDescending(t => t.TransactionDate)
            .ToListAsync();
    }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<List<FinancialTransaction>> GetByPropertyIdAsync(Guid propertyId)
    {
        return await _context.FinancialTransactions
            .AsNoTracking()
            .Include(t => t.DebitAccount)
            .Include(t => t.CreditAccount)
            .Include(t => t.FirstPartyUser)
            .Include(t => t.SecondPartyUser)
            .Where(t => t.PropertyId == propertyId)
            .OrderByDescending(t => t.TransactionDate)
            .ToListAsync();
    }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<List<FinancialTransaction>> GetByPeriodAsync(DateTime startDate, DateTime endDate)
    {
        return await _context.FinancialTransactions
            .AsNoTracking()
            .Include(t => t.DebitAccount)
            .Include(t => t.CreditAccount)
            .Where(t => t.TransactionDate >= startDate && t.TransactionDate <= endDate)
            .OrderBy(t => t.TransactionDate)
            .ToListAsync();

    }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<List<FinancialTransaction>> GetByPeriodAsync(
        DateTime startDate,
        DateTime endDate,
        TransactionStatus? status,
        TransactionType? type,
        int? limit)
    {
        var query = _context.FinancialTransactions
            .AsNoTracking()
            .Include(t => t.DebitAccount)
            .Include(t => t.CreditAccount)
            .Where(t => t.TransactionDate >= startDate && t.TransactionDate <= endDate);

        if (status.HasValue)
            query = query.Where(t => t.Status == status.Value);

        if (type.HasValue)
            query = query.Where(t => t.TransactionType == type.Value);

        query = query
            .OrderByDescending(t => t.TransactionDate)
            .ThenByDescending(t => t.TransactionNumber);

        if (limit.HasValue && limit.Value > 0)
            query = query.Take(limit.Value);

        return await query.ToListAsync();
    }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<List<FinancialTransaction>> GetPendingForPostingAsync()
    {
        return await _context.FinancialTransactions
            .Include(t => t.DebitAccount)
            .Include(t => t.CreditAccount)
            .Where(t => t.Status == TransactionStatus.Approved && !t.IsPosted)
            .OrderBy(t => t.TransactionDate)
            .ToListAsync();
    }

/// <summary>
/// يرحّل السجل المالي إلى النظام المحاسبي.
/// Posts the financial record to the accounting system.
/// </summary>
    public async Task<bool> PostTransactionAsync(Guid transactionId)
    {
        var transaction = await _context.FinancialTransactions
            .Include(t => t.DebitAccount)
            .Include(t => t.CreditAccount)
            .FirstOrDefaultAsync(t => t.Id == transactionId);

        if (transaction == null || transaction.IsPosted)
            return false;

        transaction.IsPosted = true;
        transaction.PostingDate = DateTime.UtcNow;
        transaction.Status = TransactionStatus.Posted;

        // Update account balances.
        // تحديث أرصدة الحسابات.
        transaction.DebitAccount.Balance += transaction.Amount;
        transaction.CreditAccount.Balance -= transaction.Amount;
        return true;
    }

/// <summary>
/// يعكس العملية أو السجل المحدد.
/// Reverses the specified operation or record.
/// </summary>
    public async Task<FinancialTransaction?> ReverseTransactionAsync(Guid transactionId, string reason, Guid userId)
    {
        var originalTransaction = await _context.FinancialTransactions
            .Include(t => t.DebitAccount)
            .Include(t => t.CreditAccount)
            .FirstOrDefaultAsync(t => t.Id == transactionId);

        if (originalTransaction == null || originalTransaction.IsReversed)
            return null;

        // Create a reversal entry.
        // إنشاء قيد عكسي.
        var reverseTransaction = new FinancialTransaction
        {
            TransactionNumber = await GenerateTransactionNumberAsync(),
            TransactionDate = DateTime.UtcNow,
            EntryType = JournalEntryType.Reversal,
            TransactionType = originalTransaction.TransactionType,
            DebitAccountId = originalTransaction.CreditAccountId, // Swap accounts. / عكس الحسابات.
            CreditAccountId = originalTransaction.DebitAccountId,
            Amount = originalTransaction.Amount,
            Currency = originalTransaction.Currency,
            ExchangeRate = originalTransaction.ExchangeRate,
            BaseAmount = originalTransaction.BaseAmount,
            Description = $"عكس القيد: {originalTransaction.Description}",
            Narration = $"سبب العكس: {reason}",
            ReferenceNumber = originalTransaction.TransactionNumber,
            DocumentType = "Reversal",
            BookingId = originalTransaction.BookingId,
            PaymentId = originalTransaction.PaymentId,
            FirstPartyUserId = originalTransaction.SecondPartyUserId, // Swap parties. / عكس الأطراف.
            SecondPartyUserId = originalTransaction.FirstPartyUserId,
            PropertyId = originalTransaction.PropertyId,
            UnitId = originalTransaction.UnitId,
            Status = TransactionStatus.Approved,
            IsPosted = false,
            FiscalYear = DateTime.UtcNow.Year,
            FiscalPeriod = DateTime.UtcNow.Month,
            CreatedBy = userId,
            IsAutomatic = true,
            AutomaticSource = "Reversal"
        };

        // Mark the original entry as reversed.
        // تحديث القيد الأصلي.
        originalTransaction.IsReversed = true;
        originalTransaction.ReverseTransactionId = reverseTransaction.Id;

        await _context.FinancialTransactions.AddAsync(reverseTransaction);

        return reverseTransaction;
    }

    /// <summary>
    /// Gets a transaction summary by type.
    /// يسترجع ملخص القيود حسب النوع.
    /// </summary>
    public async Task<Dictionary<TransactionType, decimal>> GetTransactionSummaryByTypeAsync(DateTime startDate, DateTime endDate)
    {
        var summary = await _context.FinancialTransactions
            .Where(t => t.TransactionDate >= startDate 
                        && t.TransactionDate <= endDate 
                        && t.IsPosted 
                        && t.Status == TransactionStatus.Posted)
            .GroupBy(t => t.TransactionType)
            .Select(g => new { Type = g.Key, Total = g.Sum(t => t.Amount) })
            .ToDictionaryAsync(x => x.Type, x => x.Total);

        return summary;
    }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<decimal> GetAccountBalanceAtDateAsync(Guid accountId, DateTime date)
    {
        var debits = await _context.FinancialTransactions
            .Where(t => t.DebitAccountId == accountId 
                        && t.TransactionDate <= date 
                        && t.IsPosted 
                        && t.Status == TransactionStatus.Posted)
            .SumAsync(t => t.Amount);

        var credits = await _context.FinancialTransactions
            .Where(t => t.CreditAccountId == accountId 
                        && t.TransactionDate <= date 
                        && t.IsPosted 
                        && t.Status == TransactionStatus.Posted)
            .SumAsync(t => t.Amount);

        return debits - credits;
    }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<List<FinancialTransaction>> GetAccountStatementAsync(
        Guid accountId, 
        DateTime startDate, 
        DateTime endDate)
    {
        return await _context.FinancialTransactions
            .AsNoTracking()
            .Include(t => t.DebitAccount)
            .Include(t => t.CreditAccount)
            .Include(t => t.Booking)
            .Include(t => t.Payment)
            .Where(t => (t.DebitAccountId == accountId || t.CreditAccountId == accountId) 
                && t.TransactionDate >= startDate 
                && t.TransactionDate <= endDate 
                && t.IsPosted
                && t.Status == TransactionStatus.Posted)
            .OrderBy(t => t.TransactionDate)
            .ThenBy(t => t.TransactionNumber)
            .ToListAsync();
    }

/// <summary>
/// يبحث ضمن البيانات المخزنة ويعيد النتائج المطابقة.
/// Searches the persisted data and returns matching results.
/// </summary>
    public async Task<List<FinancialTransaction>> SearchTransactionsAsync(
        string searchTerm,
        TransactionType? transactionType = null,
        TransactionStatus? status = null,
        DateTime? startDate = null,
        DateTime? endDate = null)
    {
        var query = _context.FinancialTransactions
            .AsNoTracking()
            .Include(t => t.DebitAccount)
            .Include(t => t.CreditAccount)
            .Include(t => t.FirstPartyUser)
            .Include(t => t.SecondPartyUser)
            .AsQueryable();

        if (!string.IsNullOrEmpty(searchTerm))
        {
            query = query.Where(t => 
                t.TransactionNumber.Contains(searchTerm) ||
                t.Description.Contains(searchTerm) ||
                t.ReferenceNumber.Contains(searchTerm) ||
                t.Narration.Contains(searchTerm));
        }

        if (transactionType.HasValue)
            query = query.Where(t => t.TransactionType == transactionType.Value);

        if (status.HasValue)
            query = query.Where(t => t.Status == status.Value);

        if (startDate.HasValue)
            query = query.Where(t => t.TransactionDate >= startDate.Value);

        if (endDate.HasValue)
            query = query.Where(t => t.TransactionDate <= endDate.Value);

        return await query
            .OrderByDescending(t => t.TransactionDate)
            .Take(100)
            .ToListAsync();
    }

/// <summary>
/// يحسب عدد السجلات المطابقة.
/// Counts the matching records.
/// </summary>
    public async Task<int> CountByPeriodAsync(
        DateTime startDate,
        DateTime endDate,
        TransactionStatus? status,
        TransactionType? type)
    {
        var query = _context.FinancialTransactions
            .AsNoTracking()
            .Where(t => t.TransactionDate >= startDate && t.TransactionDate <= endDate);

        if (status.HasValue)
            query = query.Where(t => t.Status == status.Value);

        if (type.HasValue)
            query = query.Where(t => t.TransactionType == type.Value);

        return await query.CountAsync();
    }

    /// <summary>
    /// Gets multiple account balances in a single query.
    /// يسترجع أرصدة متعددة للحسابات في استعلام واحد.
    /// </summary>
    public async Task<Dictionary<Guid, decimal>> GetAccountsBalancesAsync(List<Guid> accountIds, DateTime asOfDate)
    {
        if (accountIds == null || !accountIds.Any())
            return new Dictionary<Guid, decimal>();

        // Use optimized raw SQL for performance.
        // استخدام SQL خام محسن للأداء.
        // Note: PostgreSQL lowercases unquoted identifiers.
        // ملاحظة: PostgreSQL يحول الأسماء غير المقتبسة إلى lowercase.
        var sql = @"
            WITH accountbalances AS (
                SELECT 
                    acc.""Id"" AS accountid,
                    acc.""AccountType"" AS accounttype,
                    COALESCE(SUM(CASE WHEN t.""DebitAccountId"" = acc.""Id"" THEN t.""Amount"" ELSE 0 END), 0) AS totaldebit,
                    COALESCE(SUM(CASE WHEN t.""CreditAccountId"" = acc.""Id"" THEN t.""Amount"" ELSE 0 END), 0) AS totalcredit
                FROM ""ChartOfAccounts"" acc
                LEFT JOIN ""FinancialTransactions"" t ON 
                    (t.""DebitAccountId"" = acc.""Id"" OR t.""CreditAccountId"" = acc.""Id"")
                    AND t.""Status"" = @status
                    AND t.""TransactionDate"" <= @asOfDate
                WHERE acc.""Id"" IN ({0})
                GROUP BY acc.""Id"", acc.""AccountType""
            )
            SELECT 
                accountid,
                CASE 
                    WHEN accounttype IN (1, 5) -- Assets, Expenses (AccountType enum) / الأصول والمصروفات
                        THEN totaldebit - totalcredit
                    ELSE -- Liabilities, Equity, Revenue / الالتزامات وحقوق الملكية والإيرادات
                        totalcredit - totaldebit
                END AS balance
            FROM accountbalances";

        // Build a named parameter list.
        // بناء قائمة معاملات مسماة.
        var parameterDefinitions = new List<(string Name, object Value)>
        {
            ("@status", (int)TransactionStatus.Posted),
            ("@asOfDate", asOfDate)
        };

        var accountIdParams = string.Join(",", accountIds.Select((id, index) =>
        {
            var parameterName = $"@accountId{index}";
            parameterDefinitions.Add((parameterName, id));
            return parameterName;
        }));

        sql = string.Format(sql, accountIdParams);

        // Execute the query using DbCommand with named parameters.
        // تنفيذ الاستعلام باستخدام DbCommand ومعاملات مسماة.
        using var command = _context.Database.GetDbConnection().CreateCommand();
        command.CommandText = sql;
        foreach (var (name, value) in parameterDefinitions)
        {
            var parameter = command.CreateParameter();
            parameter.ParameterName = name;
            parameter.Value = value ?? DBNull.Value;
            command.Parameters.Add(parameter);
        }
        
        await _context.Database.OpenConnectionAsync();
        
        var result = new Dictionary<Guid, decimal>();
        using var reader = await command.ExecuteReaderAsync();
        while (await reader.ReadAsync())
        {
            var accountId = reader.GetGuid(0);
            var balance = reader.GetDecimal(1);
            result[accountId] = balance;
        }
        
        return result;
    }

/// <summary>
/// يحفظ التغييرات المعلقة.
/// Saves the pending changes.
/// </summary>
    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        => _context.SaveChangesAsync(cancellationToken);
    
    // Helper class for query results. / فئة مساعدة لنتائج الاستعلام.
    private class AccountBalanceResult
    {
        /// <summary>
        /// معرّف الحساب الذي ينتمي إليه الرصيد المجمع.
        /// Identifier of the account associated with the aggregated balance.
        /// </summary>
        public Guid AccountId { get; set; }
        /// <summary>
        /// قيمة الرصيد المجمع للحساب ضمن نتيجة الاستعلام.
        /// Aggregated balance amount for the account within the query result.
        /// </summary>
        public decimal Balance { get; set; }
    }
}
