using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using YemenBooking.Core.Entities;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Seeds;

/// <summary>
/// Seeds per-user accounting accounts for billing and ownership flows.
/// يبذر الحسابات المحاسبية الخاصة بكل مستخدم لمسارات الفوترة والملكية.
/// </summary>
public static class UserAccountsSeeder
{
    /// <summary>
    /// Creates user accounts and related property accounts.
    /// ينشئ حسابات المستخدمين والحسابات المرتبطة بالعقارات.
    /// </summary>
    public static async Task SeedAsync(YemenBookingDbContext context, ILogger logger)
    {
        try
        {
            logger.LogInformation("🔄 بدء إنشاء الحسابات المحاسبية الشخصية للمستخدمين...");

            // Load users with their roles to derive the account type once.
            // تحميل المستخدمين مع أدوارهم لاشتقاق نوع الحساب مرة واحدة.
            var users = await context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .ToListAsync();

            if (!users.Any())
            {
                logger.LogWarning("⚠️ لا يوجد مستخدمون في النظام لإنشاء حسابات لهم");
                return;
            }

            // Resolve the parent accounts used by user-level accounts.
            // تحديد الحسابات الرئيسية المستخدمة لحسابات المستخدمين.
            var accountsReceivableMain = await context.ChartOfAccounts
                .FirstOrDefaultAsync(a => a.AccountNumber == "1110" || a.NameAr.Contains("ذمم مدينة"));
            
            var accountsPayableMain = await context.ChartOfAccounts
                .FirstOrDefaultAsync(a => a.AccountNumber == "2101" || a.NameAr.Contains("ذمم دائنة"));

            if (accountsReceivableMain == null || accountsPayableMain == null)
            {
                logger.LogError("❌ الحسابات الرئيسية غير موجودة في دليل الحسابات!");
                return;
            }

            var accountsToAdd = new List<ChartOfAccount>();
            var existingUserAccountIds = await context.ChartOfAccounts
                .Where(a => a.UserId != null)
                .Select(a => a.UserId)
                .ToListAsync();
                
            // Cache existing account numbers to avoid duplicates in this run.
            // تخزين أرقام الحسابات الحالية لتجنب التكرار في هذه العملية.
            var allExistingAccountNumbers = await context.ChartOfAccounts
                .Select(a => a.AccountNumber)
                .ToListAsync();
                
            int clientCounter = 1;
            int ownerCounter = 1;
            int walletCounter = 1;

            foreach (var user in users)
            {
                // Skip users that already have a dedicated account.
                // تخطي المستخدمين الذين لديهم حساب مخصص بالفعل.
                if (existingUserAccountIds.Contains(user.Id))
                {
                    logger.LogDebug($"✓ المستخدم {user.Name} لديه حساب محاسبي بالفعل");
                    continue;
                }

                // Derive the account type from the assigned roles.
                // تحديد نوع الحساب بناءً على الأدوار الممنوحة للمستخدم.
                var userRoles = user.UserRoles?.Select(ur => ur.Role?.Name).ToList() ?? new List<string>();
                bool isOwner = userRoles.Contains("Owner");
                bool isClient = userRoles.Contains("Client") || !userRoles.Any();
                
                // Create a receivable account for clients.
                // إنشاء حساب ذمم مدينة للعملاء.
                if (isClient)
                {
                    // Generate a stable unique client account number.
                    // توليد رقم حساب فريد وثابت نسبيًا للعميل.
                    string clientAccountNumber = $"1110-C{clientCounter:D4}";
                    while (allExistingAccountNumbers.Contains(clientAccountNumber))
                    {
                        clientAccountNumber = $"1110-C{++clientCounter:D4}";
                    }
                    
                    var clientAccount = new ChartOfAccount
                    {
                        Id = Guid.NewGuid(),
                        AccountNumber = clientAccountNumber,
                        NameAr = $"ذمم مدينة - {user.Name}",
                        NameEn = $"Accounts Receivable - {user.Name}",
                        AccountType = AccountType.Assets,
                        Category = AccountCategory.Sub,
                        ParentAccountId = accountsReceivableMain.Id,
                        NormalBalance = AccountNature.Debit,
                        Level = 4,
                        Description = $"حساب العميل {user.Name} - {user.Email}",
                        Balance = 0,
                        Currency = "YER",
                        IsActive = true,
                        IsSystemAccount = false,
                        CanPost = true,
                        UserId = user.Id,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = null // System-generated. / مُنشأ آليًا.
                    };
                    accountsToAdd.Add(clientAccount);
                    allExistingAccountNumbers.Add(clientAccountNumber);
                    logger.LogDebug($"✅ إنشاء حساب ذمم مدينة للعميل: {user.Name}");
                    clientCounter++;
                }

                // Create a payable account for owners.
                // إنشاء حساب ذمم دائنة للملاك.
                if (isOwner)
                {
                    // Generate a stable unique owner account number.
                    // توليد رقم حساب فريد وثابت نسبيًا للمالك.
                    string ownerAccountNumber = $"2101-O{ownerCounter:D4}";
                    while (allExistingAccountNumbers.Contains(ownerAccountNumber))
                    {
                        ownerAccountNumber = $"2101-O{++ownerCounter:D4}";
                    }
                    
                    var ownerAccount = new ChartOfAccount
                    {
                        Id = Guid.NewGuid(),
                        AccountNumber = ownerAccountNumber,
                        NameAr = $"ذمم دائنة - {user.Name}",
                        NameEn = $"Accounts Payable - {user.Name}",
                        AccountType = AccountType.Liabilities,
                        Category = AccountCategory.Sub,
                        ParentAccountId = accountsPayableMain.Id,
                        NormalBalance = AccountNature.Credit,
                        Level = 4,
                        Description = $"حساب المالك {user.Name} - {user.Email}",
                        Balance = 0,
                        Currency = "YER",
                        IsActive = true,
                        IsSystemAccount = false,
                        CanPost = true,
                        UserId = user.Id,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = null // System-generated. / مُنشأ آليًا.
                    };
                    accountsToAdd.Add(ownerAccount);
                    allExistingAccountNumbers.Add(ownerAccountNumber);
                    logger.LogDebug($"✅ إنشاء حساب ذمم دائنة للمالك: {user.Name}");
                    ownerCounter++;
                }

                // Optionally create an e-wallet account when the parent exists.
                // إنشاء حساب محفظة إلكترونية عند توفر الحساب الأب.
                var walletParent = await context.ChartOfAccounts
                    .FirstOrDefaultAsync(a => a.AccountNumber == "1103" || a.NameAr.Contains("المحافظ الإلكترونية"));
                
                if (walletParent != null)
                {
                    // Generate a unique wallet account number in this batch.
                    // توليد رقم حساب فريد للمحفظة ضمن هذه الدفعة.
                    string walletAccountNumber = $"1103-W{walletCounter:D4}";
                    while (allExistingAccountNumbers.Contains(walletAccountNumber))
                    {
                        walletAccountNumber = $"1103-W{++walletCounter:D4}";
                    }
                    
                    var walletAccount = new ChartOfAccount
                    {
                        Id = Guid.NewGuid(),
                        AccountNumber = walletAccountNumber,
                        NameAr = $"محفظة - {user.Name}",
                        NameEn = $"Wallet - {user.Name}",
                        AccountType = AccountType.Assets,
                        Category = AccountCategory.Sub,
                        ParentAccountId = walletParent.Id,
                        NormalBalance = AccountNature.Debit,
                        Level = 4,
                        Description = $"المحفظة الإلكترونية للمستخدم {user.Name}",
                        Balance = 0,
                        Currency = "YER",
                        IsActive = true,
                        IsSystemAccount = false,
                        CanPost = true,
                        UserId = user.Id,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = null // System-generated. / مُنشأ آليًا.
                    };
                    accountsToAdd.Add(walletAccount);
                    allExistingAccountNumbers.Add(walletAccountNumber);
                    logger.LogDebug($"✅ إنشاء حساب محفظة إلكترونية لـ: {user.Name}");
                    walletCounter++;
                }
            }

            // Persist the new accounts in the database.
            // حفظ الحسابات الجديدة في قاعدة البيانات.
            if (accountsToAdd.Any())
            {
                await context.ChartOfAccounts.AddRangeAsync(accountsToAdd);
                await context.SaveChangesAsync();
                logger.LogInformation($"✅ تم إنشاء {accountsToAdd.Count} حساب محاسبي شخصي بنجاح");
            }
            else
            {
                logger.LogInformation("ℹ️ جميع المستخدمين لديهم حسابات محاسبية بالفعل");
            }

            // Create property-linked accounts after user accounts.
            // إنشاء حسابات العقارات بعد حسابات المستخدمين.
            await CreatePropertyAccountsAsync(context, logger);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "❌ خطأ أثناء إنشاء الحسابات المحاسبية الشخصية");
            throw;
        }
    }

    /// <summary>
    /// Creates revenue accounts for active properties.
    /// ينشئ حسابات الإيراد للعقارات النشطة.
    /// </summary>
    private static async Task CreatePropertyAccountsAsync(YemenBookingDbContext context, ILogger logger)
    {
        try
        {
            var properties = await context.Properties
                .Where(p => p.IsActive)
                .ToListAsync();

            if (!properties.Any())
            {
                logger.LogDebug("لا توجد عقارات لإنشاء حسابات لها");
                return;
            }

            // Find the parent revenue account for property accounts.
            // البحث عن حساب الإيراد الرئيسي لحسابات العقارات.
            var revenueMain = await context.ChartOfAccounts
                .FirstOrDefaultAsync(a => a.AccountNumber == "4101" || a.NameAr.Contains("إيرادات الحجوزات"));

            if (revenueMain == null)
            {
                logger.LogWarning("⚠️ حساب إيرادات الحجوزات الرئيسي غير موجود");
                return;
            }

            var propertyAccountsToAdd = new List<ChartOfAccount>();
            var existingPropertyAccountIds = await context.ChartOfAccounts
                .Where(a => a.PropertyId != null)
                .Select(a => a.PropertyId)
                .ToListAsync();
                
            // Track property-related account numbers to keep generated values unique.
            // تتبع أرقام الحسابات المرتبطة بالعقارات لضمان فرادة القيم المولدة.
            var existingAccountNumbers = await context.ChartOfAccounts
                .Where(a => a.AccountNumber.StartsWith("4101-"))
                .Select(a => a.AccountNumber)
                .ToListAsync();
                
            int propertyCounter = 1;

            foreach (var property in properties)
            {
                if (existingPropertyAccountIds.Contains(property.Id))
                {
                    continue;
                }

                // Generate a property-specific account number.
                // توليد رقم حساب خاص بالعقار.
                string baseNumber = $"4101-P{propertyCounter:D4}-{property.Id.ToString().Substring(0, 4).ToUpper()}";
                string accountNumber = baseNumber;
                int suffix = 1;
                
                // Ensure the number stays unique across repeated runs.
                // التأكد من بقاء الرقم فريدًا حتى مع تكرار تشغيل البذر.
                while (existingAccountNumbers.Contains(accountNumber))
                {
                    accountNumber = $"{baseNumber}-{suffix++}";
                }
                
                var propertyAccount = new ChartOfAccount
                {
                    Id = Guid.NewGuid(),
                    AccountNumber = accountNumber,
                    NameAr = $"إيرادات - {property.Name}",
                    NameEn = $"Revenue - {property.Name}",
                    AccountType = AccountType.Revenue,
                    Category = AccountCategory.Sub,
                    ParentAccountId = revenueMain.Id,
                    NormalBalance = AccountNature.Credit,
                    Level = 4,
                    Description = $"حساب إيرادات العقار {property.Name} في {property.City}",
                    Balance = 0,
                    Currency = property.Currency ?? "YER",
                    IsActive = true,
                    IsSystemAccount = false,
                    CanPost = true,
                    PropertyId = property.Id,
                    UserId = property.OwnerId, // Link the account to the owner. / ربط الحساب بالمالك أيضًا.
                    CreatedAt = DateTime.UtcNow,
                    CreatedBy = null
                };
                propertyAccountsToAdd.Add(propertyAccount);
                existingAccountNumbers.Add(accountNumber); // Keep the in-memory set updated. / تحديث المجموعة في الذاكرة.
                propertyCounter++;
            }

            if (propertyAccountsToAdd.Any())
            {
                await context.ChartOfAccounts.AddRangeAsync(propertyAccountsToAdd);
                await context.SaveChangesAsync();
                logger.LogInformation($"✅ تم إنشاء {propertyAccountsToAdd.Count} حساب محاسبي للعقارات");
            }
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "❌ خطأ أثناء إنشاء حسابات العقارات");
            // Property-account seeding is best-effort.
            // بذر حسابات العقارات ذو طبيعة استكشافية.
        }
    }
}
