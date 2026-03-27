using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Threading;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Infrastructure.Data.Context;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Infrastructure.Repositories.Finance;

/// <summary>
/// يمثل مستودعًا للوصول إلى دليل الحسابات.
/// Represents a repository for accessing chart of accounts.
/// </summary>
public class ChartOfAccountRepository : BaseRepository<ChartOfAccount>, IChartOfAccountRepository
{
/// <summary>
/// ينشئ المستودع مع سياق قاعدة البيانات المشترك.
/// Creates the repository with the shared database context.
/// </summary>
    public ChartOfAccountRepository(YemenBookingDbContext context) : base(context) { }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<List<ChartOfAccount>> GetAccountListAsync()
    {
        return await _context.ChartOfAccounts
            .AsNoTracking()
            .OrderBy(a => a.AccountNumber)
            .ToListAsync();
    }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<List<ChartOfAccount>> GetByAccountTypeAsync(AccountType accountType)
    {
        return await _context.ChartOfAccounts
            .Include(a => a.ParentAccount)
            .Where(a => a.AccountType == accountType && a.IsActive)
            .OrderBy(a => a.AccountNumber)
            .ToListAsync();
    }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<ChartOfAccount> GetUserAccountAsync(Guid userId, AccountType accountType)
    {
        return await _context.ChartOfAccounts
            .FirstOrDefaultAsync(a => a.UserId == userId && a.AccountType == accountType && a.IsActive);
    }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<List<ChartOfAccount>> GetUserAccountsAsync(Guid userId)
    {
        return await _context.ChartOfAccounts
            .AsNoTracking()
            .Where(a => a.UserId == userId && a.IsActive)
            .ToListAsync();
    }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<ChartOfAccount> GetPropertyAccountAsync(Guid propertyId, AccountType accountType)
    {
        return await _context.ChartOfAccounts
            .FirstOrDefaultAsync(a => a.PropertyId == propertyId && a.AccountType == accountType && a.IsActive);
    }

/// <summary>
/// ينشئ سجلًا جديدًا في المستودع.
/// Creates a new record in the repository.
/// </summary>
    public async Task<ChartOfAccount> CreatePropertyAccountAsync(Guid propertyId, string propertyName, AccountType accountType)
    {
        var accountNumber = await GenerateAccountNumberAsync(accountType, false);
        
        var account = new ChartOfAccount
        {
            AccountNumber = accountNumber,
            NameAr = $"حساب {GetAccountTypeNameAr(accountType)} - {propertyName}",
            NameEn = $"{GetAccountTypeNameEn(accountType)} Account - {propertyName}",
            AccountType = accountType,
            Category = AccountCategory.Sub,
            NormalBalance = GetAccountNormalBalance(accountType),
            Level = 3,
            Description = $"حساب العقار {propertyName}",
            Balance = 0,
            Currency = "YER",
            IsActive = true,
            IsSystemAccount = false,
            CanPost = true,
            PropertyId = propertyId,
            CreatedAt = DateTime.UtcNow,
            ParentAccountId = await GetParentAccountIdForType(accountType)
        };

        await _context.ChartOfAccounts.AddAsync(account);

        return account;
    }

/// <summary>
/// ينشئ سجلًا جديدًا في المستودع.
/// Creates a new record in the repository.
/// </summary>
    public async Task<ChartOfAccount> CreateAsync(ChartOfAccount account, CancellationToken cancellationToken = default)
    {
        // Check for an existing account number before insert.
        // التحقق من عدم وجود رقم حساب مكرر قبل الإضافة.
        var existingAccount = await _context.ChartOfAccounts
            .AsNoTracking()
            .FirstOrDefaultAsync(a => a.AccountNumber == account.AccountNumber, cancellationToken);
        
        if (existingAccount != null)
        {
            // Regenerate the account number.
            // إعادة توليد رقم الحساب.
            account.AccountNumber = await GenerateUniqueAccountNumberAsync(account.AccountType, account.UserId.HasValue, cancellationToken);
        }

        await _context.ChartOfAccounts.AddAsync(account, cancellationToken);
        return account;
    }
    
    private async Task<string> GenerateUniqueAccountNumberAsync(AccountType accountType, bool isUserAccount, CancellationToken cancellationToken = default)
    {
        var prefix = accountType switch
        {
            AccountType.Assets => "1",
            AccountType.Liabilities => "2",
            AccountType.Equity => "3",
            AccountType.Revenue => "4",
            AccountType.Expenses => "5",
            _ => "9"
        };

        var subPrefix = isUserAccount ? "1" : "2";
        
        // Use a bounded retry loop to avoid duplicate numbers.
        // استخدام حلقة إعادة محدودة لتفادي الأرقام المكررة.
        var maxRetries = 10;
        for (var i = 0; i < maxRetries; i++)
        {
            var lastAccount = await _context.ChartOfAccounts
                .Where(a => a.AccountNumber.StartsWith($"{prefix}{subPrefix}"))
                .OrderByDescending(a => a.AccountNumber)
                .FirstOrDefaultAsync(cancellationToken);

            string newAccountNumber;
            if (lastAccount == null)
            {
                newAccountNumber = $"{prefix}{subPrefix}001";
            }
            else
            {
                var lastNumber = int.Parse(lastAccount.AccountNumber.Substring(2));
                newAccountNumber = $"{prefix}{subPrefix}{(lastNumber + 1 + i):D3}"; // إضافة i للتفرد
            }
            
            // Check that the generated number does not already exist.
            // التحقق من عدم وجود هذا الرقم.
            var exists = await _context.ChartOfAccounts
                .AsNoTracking()
                .AnyAsync(a => a.AccountNumber == newAccountNumber, cancellationToken);
                
            if (!exists)
            {
                return newAccountNumber;
            }
        }
        
        // Fall back to a random suffix if all retries fail.
        // استخدام لاحقة عشوائية إذا فشلت كل المحاولات.
        return $"{prefix}{subPrefix}{Random.Shared.Next(1000, 9999)}";
    }

/// <summary>
/// يحدّث السجل المطلوب في المستودع.
/// Updates the requested record in the repository.
/// </summary>
    public async Task<bool> UpdateAccountBalanceAsync(Guid accountId, decimal amount, bool isDebit)
    {
        var account = await _context.ChartOfAccounts.FindAsync(accountId);
        if (account == null)
            return false;

        if ((account.NormalBalance == AccountNature.Debit && isDebit) ||
            (account.NormalBalance == AccountNature.Credit && !isDebit))
        {
            account.Balance += amount;
        }
        else
        {
            account.Balance -= amount;
        }

        account.UpdatedAt = DateTime.UtcNow;

        return true;
    }

/// <summary>
/// يبحث ضمن البيانات المخزنة ويعيد النتائج المطابقة.
/// Searches the persisted data and returns matching results.
/// </summary>
    public async Task<List<ChartOfAccount>> SearchAccountsAsync(string searchTerm)
    {
        return await _context.ChartOfAccounts
            .Include(a => a.ParentAccount)
            .Where(a => a.IsActive && (
                a.AccountNumber.Contains(searchTerm) ||
                a.NameAr.Contains(searchTerm) ||
                a.NameEn.Contains(searchTerm) ||
                a.Description.Contains(searchTerm)))
            .OrderBy(a => a.AccountNumber)
            .Take(50)
            .ToListAsync();
    }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<List<ChartOfAccount>> GetAccountsTreeAsync()
    {
        // Use AsNoTracking for read-only performance.
        // استخدام AsNoTracking لتحسين الأداء في عمليات القراءة.
        return await _context.ChartOfAccounts
            .AsNoTracking()
            .Include(a => a.SubAccounts)
                .ThenInclude(s => s.SubAccounts)
                    .ThenInclude(s => s.SubAccounts)
            .Where(a => a.ParentAccountId == null && a.IsActive)
            .OrderBy(a => a.AccountNumber)
            .ToListAsync();
    }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<ChartOfAccount> GetSystemAccountAsync(string accountName)
    {
        return await _context.ChartOfAccounts
            .FirstOrDefaultAsync(a => a.IsSystemAccount && 
                (a.NameEn == accountName || a.NameAr == accountName));
    }

    // Helper methods. / دوال مساعدة.

/// <summary>
/// يولّد القيمة أو المعرّف المطلوب.
/// Generates the requested value or identifier.
/// </summary>
    public async Task<string> GenerateAccountNumberAsync(AccountType accountType, bool isUserAccount)
    {
        var prefix = accountType switch
        {
            AccountType.Assets => "1",
            AccountType.Liabilities => "2",
            AccountType.Equity => "3",
            AccountType.Revenue => "4",
            AccountType.Expenses => "5",
            _ => "9"
        };

        var subPrefix = isUserAccount ? "1" : "2"; // User accounts use 1; property accounts use 2. / حسابات المستخدمين 1، وحسابات العقارات 2.

        var lastAccount = await _context.ChartOfAccounts
            .Where(a => a.AccountNumber.StartsWith($"{prefix}{subPrefix}"))
            .OrderByDescending(a => a.AccountNumber)
            .FirstOrDefaultAsync();

        if (lastAccount == null)
        {
            return $"{prefix}{subPrefix}001";
        }

        var lastNumber = int.Parse(lastAccount.AccountNumber.Substring(2));
        return $"{prefix}{subPrefix}{(lastNumber + 1):D3}";
    }

    private async Task<Guid?> GetParentAccountIdForType(AccountType accountType)
    {
        var parentAccountName = accountType switch
        {
            AccountType.Assets => "الأصول المتداولة",
            AccountType.Liabilities => "الالتزامات المتداولة",
            AccountType.Equity => "حقوق الملكية",
            AccountType.Revenue => "الإيرادات التشغيلية",
            AccountType.Expenses => "المصروفات التشغيلية",
            _ => null
        };

        if (parentAccountName == null)
            return null;

        var parentAccount = await _context.ChartOfAccounts
            .FirstOrDefaultAsync(a => a.NameAr == parentAccountName);

        return parentAccount?.Id;
    }

    private string GetAccountTypeNameAr(AccountType accountType) => accountType switch
    {
        AccountType.Assets => "أصول",
        AccountType.Liabilities => "التزامات",
        AccountType.Equity => "حقوق ملكية",
        AccountType.Revenue => "إيرادات",
        AccountType.Expenses => "مصروفات",
        _ => "عام"
    };

    private string GetAccountTypeNameEn(AccountType accountType) => accountType switch
    {
        AccountType.Assets => "Assets",
        AccountType.Liabilities => "Liabilities",
        AccountType.Equity => "Equity",
        AccountType.Revenue => "Revenue",
        AccountType.Expenses => "Expenses",
        _ => "General"
    };

    private AccountNature GetAccountNormalBalance(AccountType accountType) => accountType switch
    {
        AccountType.Assets => AccountNature.Debit,
        AccountType.Expenses => AccountNature.Debit,
        AccountType.Liabilities => AccountNature.Credit,
        AccountType.Equity => AccountNature.Credit,
        AccountType.Revenue => AccountNature.Credit,
        _ => AccountNature.Debit
    };
}
