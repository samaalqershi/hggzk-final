using System;
using System.Collections.Generic;
using System.Linq;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Analytics.DTOs;

/// <summary>
/// DTO لدليل الحسابات - يمنع المراجع الدائرية
/// Chart of Accounts DTO - Prevents circular references
/// </summary>
public class ChartOfAccountDto
{
    /// <summary>
    /// خاصية Id.
    /// Id property.
    /// </summary>
    public Guid Id { get; set; }
    /// <summary>
    /// خاصية AccountNumber.
    /// AccountNumber property.
    /// </summary>
    public string AccountNumber { get; set; }
    /// <summary>
    /// خاصية NameAr.
    /// NameAr property.
    /// </summary>
    public string NameAr { get; set; }
    /// <summary>
    /// خاصية NameEn.
    /// NameEn property.
    /// </summary>
    public string NameEn { get; set; }
    /// <summary>
    /// خاصية AccountType.
    /// AccountType property.
    /// </summary>
    public AccountType AccountType { get; set; }
    /// <summary>
    /// خاصية Category.
    /// Category property.
    /// </summary>
    public AccountCategory Category { get; set; }
    /// <summary>
    /// خاصية NormalBalance.
    /// NormalBalance property.
    /// </summary>
    public AccountNature NormalBalance { get; set; }
    /// <summary>
    /// خاصية Level.
    /// Level property.
    /// </summary>
    public int Level { get; set; }
    /// <summary>
    /// خاصية Description.
    /// Description property.
    /// </summary>
    public string Description { get; set; }
    /// <summary>
    /// خاصية Balance.
    /// Balance property.
    /// </summary>
    public decimal Balance { get; set; }
    /// <summary>
    /// خاصية Currency.
    /// Currency property.
    /// </summary>
    public string Currency { get; set; }
    /// <summary>
    /// خاصية IsActive.
    /// IsActive property.
    /// </summary>
    public bool IsActive { get; set; }
    /// <summary>
    /// خاصية IsSystemAccount.
    /// IsSystemAccount property.
    /// </summary>
    public bool IsSystemAccount { get; set; }
    /// <summary>
    /// خاصية CanPost.
    /// CanPost property.
    /// </summary>
    public bool CanPost { get; set; }
    /// <summary>
    /// خاصية ParentAccountId.
    /// ParentAccountId property.
    /// </summary>
    public Guid? ParentAccountId { get; set; }
    /// <summary>
    /// خاصية UserId.
    /// UserId property.
    /// </summary>
    public Guid? UserId { get; set; }
    /// <summary>
    /// خاصية PropertyId.
    /// PropertyId property.
    /// </summary>
    public Guid? PropertyId { get; set; }
    /// <summary>
    /// خاصية CreatedAt.
    /// CreatedAt property.
    /// </summary>
    public DateTime CreatedAt { get; set; }
    /// <summary>
    /// خاصية UpdatedAt.
    /// UpdatedAt property.
    /// </summary>
    public DateTime? UpdatedAt { get; set; }
    
    /// <summary>
    /// الحسابات الفرعية (بدون parentAccount لمنع المراجع الدائرية)
    /// Sub-accounts (without parentAccount to prevent circular references)
    /// </summary>
    public List<ChartOfAccountDto> SubAccounts { get; set; } = new List<ChartOfAccountDto>();

    /// <summary>
    /// تحويل من Entity إلى DTO
    /// Convert from Entity to DTO
    /// </summary>
    public static ChartOfAccountDto FromEntity(ChartOfAccount account, bool includeSubAccounts = true)
    {
        if (account == null)
            return null;

        var dto = new ChartOfAccountDto
        {
            Id = account.Id,
            AccountNumber = account.AccountNumber,
            NameAr = account.NameAr,
            NameEn = account.NameEn,
            AccountType = account.AccountType,
            Category = account.Category,
            NormalBalance = account.NormalBalance,
            Level = account.Level,
            Description = account.Description,
            Balance = account.Balance,
            Currency = account.Currency,
            IsActive = account.IsActive,
            IsSystemAccount = account.IsSystemAccount,
            CanPost = account.CanPost,
            ParentAccountId = account.ParentAccountId,
            UserId = account.UserId,
            PropertyId = account.PropertyId,
            CreatedAt = account.CreatedAt,
            UpdatedAt = account.UpdatedAt
        };

        // تضمين الحسابات الفرعية بشكل تكراري بدون المراجع العكسية
        // Include sub-accounts recursively without reverse references
        if (includeSubAccounts && account.SubAccounts != null && account.SubAccounts.Count > 0)
        {
            dto.SubAccounts = account.SubAccounts
                .Select(sub => FromEntity(sub, true))
                .OrderBy(s => s.AccountNumber)
                .ToList();
        }

        return dto;
    }

    /// <summary>
    /// تحويل قائمة من Entities إلى DTOs
    /// Convert list of Entities to DTOs
    /// </summary>
    public static List<ChartOfAccountDto> FromEntities(IEnumerable<ChartOfAccount> accounts, bool includeSubAccounts = true)
    {
        if (accounts == null)
            return new List<ChartOfAccountDto>();

        return accounts
            .Select(a => FromEntity(a, includeSubAccounts))
            .OrderBy(a => a.AccountNumber)
            .ToList();
    }
}
