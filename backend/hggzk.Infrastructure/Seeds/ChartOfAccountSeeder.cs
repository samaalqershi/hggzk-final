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
/// Seeds the core chart of accounts.
/// يبذر الهيكل الأساسي لدليل الحسابات.
/// </summary>
public static class ChartOfAccountSeeder
{
    /// <summary>
    /// Seeds base accounts and repairs critical gaps.
    /// يبذر الحسابات الأساسية ويصلح الفجوات الحرجة.
    /// </summary>
    public static async Task SeedAsync(YemenBookingDbContext context, ILogger logger)
    {
        try
        {
            logger.LogInformation("بدء بذر الحسابات الأساسية في دليل الحسابات");

            // If accounts already exist, only ensure critical entries.
            // إذا كانت الحسابات موجودة مسبقًا، نتحقق فقط من الحسابات الحرجة.
            if (await context.ChartOfAccounts.AnyAsync())
            {
                logger.LogInformation("دليل الحسابات يحتوي على بيانات بالفعل، سيتم فقط التأكد من الحسابات الحرجة");
                await EnsureCriticalAccountsAsync(context, logger);
                return;
            }

            var accounts = new List<ChartOfAccount>();

            // ==================== 1. Assets / الأصول ====================
            
            // Main asset group / مجموعة الأصول الرئيسية
            var assets = new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "1000",
                NameAr = "الأصول",
                NameEn = "Assets",
                AccountType = AccountType.Assets,
                Category = AccountCategory.Main,
                NormalBalance = AccountNature.Debit,
                Level = 1,
                Description = "جميع أصول الشركة",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = false,
                CreatedAt = DateTime.UtcNow
            };
            accounts.Add(assets);

            // Current assets / الأصول المتداولة
            var currentAssets = new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "1100",
                NameAr = "الأصول المتداولة",
                NameEn = "Current Assets",
                AccountType = AccountType.Assets,
                Category = AccountCategory.Sub,
                ParentAccountId = assets.Id,
                NormalBalance = AccountNature.Debit,
                Level = 2,
                Description = "الأصول قصيرة الأجل",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = false,
                CreatedAt = DateTime.UtcNow
            };
            accounts.Add(currentAssets);

            // Transit accounts used during processing.
            // حسابات انتقالية تُستخدم أثناء المعالجة.
            var transitAccounts = new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "1900",
                NameAr = "حسابات انتقالية",
                NameEn = "Transit Accounts",
                AccountType = AccountType.Assets,
                Category = AccountCategory.Sub,
                ParentAccountId = assets.Id,
                NormalBalance = AccountNature.Debit,
                Level = 2,
                Description = "حسابات مؤقتة للعمليات قيد المعالجة",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = false,
                CreatedAt = DateTime.UtcNow
            };
            accounts.Add(transitAccounts);

            // Payments currently in process.
            // المدفوعات قيد المعالجة.
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "1901",
                NameAr = "المدفوعات قيد المعالجة",
                NameEn = "Payments in Processing",
                AccountType = AccountType.Assets,
                Category = AccountCategory.Sub,
                ParentAccountId = transitAccounts.Id,
                NormalBalance = AccountNature.Debit,
                Level = 3,
                Description = "المدفوعات في انتظار التأكيد",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Cash / النقدية
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "1101",
                NameAr = "النقدية",
                NameEn = "Cash",
                AccountType = AccountType.Assets,
                Category = AccountCategory.Sub,
                ParentAccountId = currentAssets.Id,
                NormalBalance = AccountNature.Debit,
                Level = 3,
                Description = "النقد في الصندوق",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Bank / البنك
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "1102",
                NameAr = "البنك",
                NameEn = "Bank",
                AccountType = AccountType.Assets,
                Category = AccountCategory.Sub,
                ParentAccountId = currentAssets.Id,
                NormalBalance = AccountNature.Debit,
                Level = 3,
                Description = "الأرصدة البنكية",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // E-wallets / المحافظ الإلكترونية
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "1103",
                NameAr = "المحافظ الإلكترونية",
                NameEn = "E-Wallets",
                AccountType = AccountType.Assets,
                Category = AccountCategory.Sub,
                ParentAccountId = currentAssets.Id,
                NormalBalance = AccountNature.Debit,
                Level = 3,
                Description = "أرصدة المحافظ الإلكترونية",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Customer receivables / ذمم مدينة - عملاء
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "1110",
                NameAr = "ذمم مدينة - عملاء",
                NameEn = "Accounts Receivable - Customers",
                AccountType = AccountType.Assets,
                Category = AccountCategory.Sub,
                ParentAccountId = currentAssets.Id,
                NormalBalance = AccountNature.Debit,
                Level = 3,
                Description = "المبالغ المستحقة من العملاء",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Customer advances / الدفعات المقدمة من العملاء
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "1111",
                NameAr = "الدفعات المقدمة من العملاء",
                NameEn = "Customer Advances",
                AccountType = AccountType.Assets,
                Category = AccountCategory.Sub,
                ParentAccountId = currentAssets.Id,
                NormalBalance = AccountNature.Debit,
                Level = 3,
                Description = "المبالغ المدفوعة مقدماً من العملاء",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Guest current accounts / حسابات النزلاء الجارية
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "1112",
                NameAr = "حسابات النزلاء الجارية",
                NameEn = "Guest Current Accounts",
                AccountType = AccountType.Assets,
                Category = AccountCategory.Sub,
                ParentAccountId = currentAssets.Id,
                NormalBalance = AccountNature.Debit,
                Level = 3,
                Description = "حسابات النزلاء أثناء الإقامة",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // ==================== 2. Liabilities / الالتزامات ====================
            
            // Main liability group / مجموعة الالتزامات الرئيسية
            var liabilities = new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "2000",
                NameAr = "الالتزامات",
                NameEn = "Liabilities",
                AccountType = AccountType.Liabilities,
                Category = AccountCategory.Main,
                NormalBalance = AccountNature.Credit,
                Level = 1,
                Description = "جميع التزامات الشركة",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = false,
                CreatedAt = DateTime.UtcNow
            };
            accounts.Add(liabilities);

            // Current liabilities / الالتزامات المتداولة
            var currentLiabilities = new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "2100",
                NameAr = "الالتزامات المتداولة",
                NameEn = "Current Liabilities",
                AccountType = AccountType.Liabilities,
                Category = AccountCategory.Sub,
                ParentAccountId = liabilities.Id,
                NormalBalance = AccountNature.Credit,
                Level = 2,
                Description = "الالتزامات قصيرة الأجل",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = false,
                CreatedAt = DateTime.UtcNow
            };
            accounts.Add(currentLiabilities);

            // Owner payables / ذمم دائنة - ملاك
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "2101",
                NameAr = "ذمم دائنة - ملاك",
                NameEn = "Accounts Payable - Owners",
                AccountType = AccountType.Liabilities,
                Category = AccountCategory.Sub,
                ParentAccountId = currentLiabilities.Id,
                NormalBalance = AccountNature.Credit,
                Level = 3,
                Description = "المبالغ المستحقة للملاك",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Taxes payable / الضرائب المستحقة
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "2110",
                NameAr = "الضرائب المستحقة",
                NameEn = "Taxes Payable",
                AccountType = AccountType.Liabilities,
                Category = AccountCategory.Sub,
                ParentAccountId = currentLiabilities.Id,
                NormalBalance = AccountNature.Credit,
                Level = 3,
                Description = "الضرائب المستحقة الدفع",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Pending owner funds / أموال الملاك المعلقة
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "2105",
                NameAr = "أموال الملاك المعلقة",
                NameEn = "Owners' Funds Pending",
                AccountType = AccountType.Liabilities,
                Category = AccountCategory.Sub,
                ParentAccountId = currentLiabilities.Id,
                NormalBalance = AccountNature.Credit,
                Level = 3,
                Description = "المبالغ المحصلة للملاك في انتظار التحويل",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Platform commissions payable / عمولات المنصة المستحقة
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "2107",
                NameAr = "عمولات المنصة المستحقة",
                NameEn = "Platform Commissions Payable",
                AccountType = AccountType.Liabilities,
                Category = AccountCategory.Sub,
                ParentAccountId = currentLiabilities.Id,
                NormalBalance = AccountNature.Credit,
                Level = 3,
                Description = "عمولات المنصة المستحقة على الحجوزات والخدمات",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Trust account / حساب الأمانات
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "2106",
                NameAr = "حساب الأمانات",
                NameEn = "Trust Account",
                AccountType = AccountType.Liabilities,
                Category = AccountCategory.Sub,
                ParentAccountId = currentLiabilities.Id,
                NormalBalance = AccountNature.Credit,
                Level = 3,
                Description = "أموال العملاء المحتفظ بها كأمانة",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Security deposits / ودائع الضمان
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "2120",
                NameAr = "ودائع الضمان",
                NameEn = "Security Deposits",
                AccountType = AccountType.Liabilities,
                Category = AccountCategory.Sub,
                ParentAccountId = currentLiabilities.Id,
                NormalBalance = AccountNature.Credit,
                Level = 3,
                Description = "ودائع الضمان المستلمة من العملاء",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Deferred revenue / الإيرادات المؤجلة
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "2130",
                NameAr = "الإيرادات المؤجلة",
                NameEn = "Deferred Revenue",
                AccountType = AccountType.Liabilities,
                Category = AccountCategory.Sub,
                ParentAccountId = currentLiabilities.Id,
                NormalBalance = AccountNature.Credit,
                Level = 3,
                Description = "إيرادات محصلة مقدماً لخدمات لم تقدم بعد",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Accrued revenue / الإيرادات المستحقة
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "2140",
                NameAr = "الإيرادات المستحقة",
                NameEn = "Accrued Revenue",
                AccountType = AccountType.Liabilities,
                Category = AccountCategory.Sub,
                ParentAccountId = currentLiabilities.Id,
                NormalBalance = AccountNature.Credit,
                Level = 3,
                Description = "إيرادات مستحقة لم تحصل بعد",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Agent commissions payable / العمولات المستحقة للوكلاء
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "2150",
                NameAr = "العمولات المستحقة للوكلاء",
                NameEn = "Agent Commissions Payable",
                AccountType = AccountType.Liabilities,
                Category = AccountCategory.Sub,
                ParentAccountId = currentLiabilities.Id,
                NormalBalance = AccountNature.Credit,
                Level = 3,
                Description = "عمولات مستحقة للوكلاء والوسطاء",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // ==================== 3. Equity / حقوق الملكية ====================
            
            // Main equity group / مجموعة حقوق الملكية الرئيسية
            var equity = new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "3000",
                NameAr = "حقوق الملكية",
                NameEn = "Equity",
                AccountType = AccountType.Equity,
                Category = AccountCategory.Main,
                NormalBalance = AccountNature.Credit,
                Level = 1,
                Description = "حقوق ملكية الشركة",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = false,
                CreatedAt = DateTime.UtcNow
            };
            accounts.Add(equity);

            // Platform equity account / حساب المنصة
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "3100",
                NameAr = "حساب المنصة",
                NameEn = "Platform Account",
                AccountType = AccountType.Equity,
                Category = AccountCategory.Sub,
                ParentAccountId = equity.Id,
                NormalBalance = AccountNature.Credit,
                Level = 2,
                Description = "حساب أرباح المنصة",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Retained earnings / الأرباح المحتجزة
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "3200",
                NameAr = "الأرباح المحتجزة",
                NameEn = "Retained Earnings",
                AccountType = AccountType.Equity,
                Category = AccountCategory.Sub,
                ParentAccountId = equity.Id,
                NormalBalance = AccountNature.Credit,
                Level = 2,
                Description = "الأرباح المحتجزة",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // ==================== 4. Revenue / الإيرادات ====================
            
            // Main revenue group / مجموعة الإيرادات الرئيسية
            var revenue = new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "4000",
                NameAr = "الإيرادات",
                NameEn = "Revenue",
                AccountType = AccountType.Revenue,
                Category = AccountCategory.Main,
                NormalBalance = AccountNature.Credit,
                Level = 1,
                Description = "جميع إيرادات الشركة",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = false,
                CreatedAt = DateTime.UtcNow
            };
            accounts.Add(revenue);

            // Operating revenue / الإيرادات التشغيلية
            var operatingRevenue = new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "4100",
                NameAr = "الإيرادات التشغيلية",
                NameEn = "Operating Revenue",
                AccountType = AccountType.Revenue,
                Category = AccountCategory.Sub,
                ParentAccountId = revenue.Id,
                NormalBalance = AccountNature.Credit,
                Level = 2,
                Description = "الإيرادات من العمليات الأساسية",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = false,
                CreatedAt = DateTime.UtcNow
            };
            accounts.Add(operatingRevenue);

            // Booking revenue / إيرادات الحجوزات
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "4101",
                NameAr = "إيرادات الحجوزات",
                NameEn = "Booking Revenue",
                AccountType = AccountType.Revenue,
                Category = AccountCategory.Sub,
                ParentAccountId = operatingRevenue.Id,
                NormalBalance = AccountNature.Credit,
                Level = 3,
                Description = "الإيرادات من حجوزات العقارات",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Platform commissions / عمولات المنصة
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "4110",
                NameAr = "عمولات المنصة",
                NameEn = "Platform Commissions",
                AccountType = AccountType.Revenue,
                Category = AccountCategory.Sub,
                ParentAccountId = operatingRevenue.Id,
                NormalBalance = AccountNature.Credit,
                Level = 3,
                Description = "عمولات المنصة على الحجوزات",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Confirmed booking revenue / إيرادات الحجوزات المؤكدة
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "4102",
                NameAr = "إيرادات الحجوزات المؤكدة",
                NameEn = "Confirmed Booking Revenue",
                AccountType = AccountType.Revenue,
                Category = AccountCategory.Sub,
                ParentAccountId = operatingRevenue.Id,
                NormalBalance = AccountNature.Credit,
                Level = 3,
                Description = "إيرادات الحجوزات المؤكدة",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Realized booking revenue / إيرادات الحجوزات المحققة
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "4103",
                NameAr = "إيرادات الحجوزات المحققة",
                NameEn = "Realized Booking Revenue",
                AccountType = AccountType.Revenue,
                Category = AccountCategory.Sub,
                ParentAccountId = operatingRevenue.Id,
                NormalBalance = AccountNature.Credit,
                Level = 3,
                Description = "إيرادات الحجوزات المحققة بعد تسجيل الدخول",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Service fees / رسوم الخدمات
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "4120",
                NameAr = "رسوم الخدمات",
                NameEn = "Service Fees",
                AccountType = AccountType.Revenue,
                Category = AccountCategory.Sub,
                ParentAccountId = operatingRevenue.Id,
                NormalBalance = AccountNature.Credit,
                Level = 3,
                Description = "رسوم الخدمات الإضافية",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Cancellation fees / رسوم الإلغاء
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "4130",
                NameAr = "رسوم الإلغاء",
                NameEn = "Cancellation Fees",
                AccountType = AccountType.Revenue,
                Category = AccountCategory.Sub,
                ParentAccountId = operatingRevenue.Id,
                NormalBalance = AccountNature.Credit,
                Level = 3,
                Description = "رسوم إلغاء الحجوزات",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Late fees / رسوم التأخير
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "4140",
                NameAr = "رسوم التأخير",
                NameEn = "Late Fees",
                AccountType = AccountType.Revenue,
                Category = AccountCategory.Sub,
                ParentAccountId = operatingRevenue.Id,
                NormalBalance = AccountNature.Credit,
                Level = 3,
                Description = "رسوم التأخير في تسجيل الخروج",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // ==================== 5. Expenses / المصروفات ====================
            
            // Main expense group / مجموعة المصروفات الرئيسية
            var expenses = new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "5000",
                NameAr = "المصروفات",
                NameEn = "Expenses",
                AccountType = AccountType.Expenses,
                Category = AccountCategory.Main,
                NormalBalance = AccountNature.Debit,
                Level = 1,
                Description = "جميع مصروفات الشركة",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = false,
                CreatedAt = DateTime.UtcNow
            };
            accounts.Add(expenses);

            // Operating expenses / المصروفات التشغيلية
            var operatingExpenses = new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "5100",
                NameAr = "المصروفات التشغيلية",
                NameEn = "Operating Expenses",
                AccountType = AccountType.Expenses,
                Category = AccountCategory.Sub,
                ParentAccountId = expenses.Id,
                NormalBalance = AccountNature.Debit,
                Level = 2,
                Description = "مصروفات العمليات الأساسية",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = false,
                CreatedAt = DateTime.UtcNow
            };
            accounts.Add(operatingExpenses);

            // Bank fees / رسوم البنوك
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "5101",
                NameAr = "رسوم البنوك",
                NameEn = "Bank Fees",
                AccountType = AccountType.Expenses,
                Category = AccountCategory.Sub,
                ParentAccountId = operatingExpenses.Id,
                NormalBalance = AccountNature.Debit,
                Level = 3,
                Description = "رسوم ومصروفات البنوك",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Refunds / المستردات
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "5110",
                NameAr = "المستردات",
                NameEn = "Refunds",
                AccountType = AccountType.Expenses,
                Category = AccountCategory.Sub,
                ParentAccountId = operatingExpenses.Id,
                NormalBalance = AccountNature.Debit,
                Level = 3,
                Description = "المبالغ المستردة للعملاء",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Agent commissions / عمولات الوكلاء
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "5120",
                NameAr = "عمولات الوكلاء",
                NameEn = "Agent Commissions",
                AccountType = AccountType.Expenses,
                Category = AccountCategory.Sub,
                ParentAccountId = operatingExpenses.Id,
                NormalBalance = AccountNature.Debit,
                Level = 3,
                Description = "عمولات الوكلاء والوسطاء",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Sales returns / مردودات المبيعات
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "5130",
                NameAr = "مردودات المبيعات",
                NameEn = "Sales Returns",
                AccountType = AccountType.Expenses,
                Category = AccountCategory.Sub,
                ParentAccountId = operatingExpenses.Id,
                NormalBalance = AccountNature.Debit,
                Level = 3,
                Description = "مردودات المبيعات والخصومات",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Bad debt expenses / خسائر الديون المعدومة
            accounts.Add(new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = "5140",
                NameAr = "خسائر الديون المعدومة",
                NameEn = "Bad Debt Expenses",
                AccountType = AccountType.Expenses,
                Category = AccountCategory.Sub,
                ParentAccountId = operatingExpenses.Id,
                NormalBalance = AccountNature.Debit,
                Level = 3,
                Description = "خسائر من عدم تحصيل المديونيات",
                IsActive = true,
                IsSystemAccount = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow
            });

            // Persist the generated chart of accounts in one batch.
            // حفظ شجرة دليل الحسابات دفعة واحدة.
            await context.ChartOfAccounts.AddRangeAsync(accounts);
            await context.SaveChangesAsync();

            logger.LogInformation($"تم بذر {accounts.Count} حساب في دليل الحسابات بنجاح");
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "خطأ أثناء بذر الحسابات الأساسية في دليل الحسابات");
            throw;
        }
    }

    /// <summary>
    /// دالة EnsureCriticalAccountsAsync.
    /// EnsureCriticalAccountsAsync method.
    /// </summary>
    private static async Task EnsureCriticalAccountsAsync(YemenBookingDbContext context, ILogger logger)
    {
        var now = DateTime.UtcNow;
        var accounts = await context.ChartOfAccounts.ToListAsync();
        var byNumber = accounts
            .GroupBy(a => a.AccountNumber)
            .ToDictionary(g => g.Key, g => g.First());

        ChartOfAccount Ensure(
            string accountNumber,
            string nameAr,
            string nameEn,
            AccountType accountType,
            AccountCategory category,
            AccountNature normalBalance,
            int level,
            bool canPost,
            string description,
            string? parentAccountNumber = null)
        {
            // Resolve the parent first so nesting stays correct.
            // تحديد الحساب الأب أولًا حتى يبقى التداخل صحيحًا.
            byNumber.TryGetValue(parentAccountNumber ?? string.Empty, out var parentAccount);

            if (byNumber.TryGetValue(accountNumber, out var existing))
            {
                var changed = false;

                if (parentAccount != null && existing.ParentAccountId != parentAccount.Id)
                {
                    existing.ParentAccountId = parentAccount.Id;
                    changed = true;
                }

                if (!existing.IsActive)
                {
                    existing.IsActive = true;
                    changed = true;
                }

                if (!existing.IsSystemAccount)
                {
                    existing.IsSystemAccount = true;
                    changed = true;
                }

                if (canPost && !existing.CanPost)
                {
                    existing.CanPost = true;
                    changed = true;
                }

                if (changed)
                {
                    existing.UpdatedAt = now;
                }

                return existing;
            }

            var created = new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = accountNumber,
                NameAr = nameAr,
                NameEn = nameEn,
                AccountType = accountType,
                Category = category,
                ParentAccountId = parentAccount?.Id,
                NormalBalance = normalBalance,
                Level = level,
                Description = description,
                IsActive = true,
                IsSystemAccount = true,
                CanPost = canPost,
                CreatedAt = now
            };

            context.ChartOfAccounts.Add(created);
            byNumber[accountNumber] = created;
            return created;
        }

        // Assets hierarchy (for receivables/cash accounts used in entries)
        Ensure("1000", "الأصول", "Assets", AccountType.Assets, AccountCategory.Main, AccountNature.Debit, 1, false, "جميع أصول الشركة");
        Ensure("1100", "الأصول المتداولة", "Current Assets", AccountType.Assets, AccountCategory.Sub, AccountNature.Debit, 2, false, "الأصول قصيرة الأجل", "1000");
        Ensure("1101", "النقدية", "Cash", AccountType.Assets, AccountCategory.Sub, AccountNature.Debit, 3, true, "النقد في الصندوق", "1100");
        Ensure("1102", "البنك", "Bank", AccountType.Assets, AccountCategory.Sub, AccountNature.Debit, 3, true, "الأرصدة البنكية", "1100");
        Ensure("1103", "المحافظ الإلكترونية", "E-Wallets", AccountType.Assets, AccountCategory.Sub, AccountNature.Debit, 3, true, "أرصدة المحافظ الإلكترونية", "1100");
        Ensure("1110", "ذمم مدينة - عملاء", "Accounts Receivable - Customers", AccountType.Assets, AccountCategory.Sub, AccountNature.Debit, 3, true, "المبالغ المستحقة من العملاء", "1100");

        // Liabilities hierarchy (for owner pending and platform commission pending)
        Ensure("2000", "الالتزامات", "Liabilities", AccountType.Liabilities, AccountCategory.Main, AccountNature.Credit, 1, false, "جميع التزامات الشركة");
        Ensure("2100", "الالتزامات المتداولة", "Current Liabilities", AccountType.Liabilities, AccountCategory.Sub, AccountNature.Credit, 2, false, "الالتزامات قصيرة الأجل", "2000");
        Ensure("2101", "ذمم دائنة - ملاك", "Accounts Payable - Owners", AccountType.Liabilities, AccountCategory.Sub, AccountNature.Credit, 3, true, "المبالغ المستحقة للملاك", "2100");
        Ensure("2105", "أموال الملاك المعلقة", "Owners' Funds Pending", AccountType.Liabilities, AccountCategory.Sub, AccountNature.Credit, 3, true, "المبالغ المحصلة للملاك في انتظار التحويل", "2100");
        Ensure("2107", "عمولات المنصة المستحقة", "Platform Commissions Payable", AccountType.Liabilities, AccountCategory.Sub, AccountNature.Credit, 3, true, "عمولات المنصة المستحقة على الحجوزات والخدمات", "2100");
        Ensure("2110", "الضرائب المستحقة", "Taxes Payable", AccountType.Liabilities, AccountCategory.Sub, AccountNature.Credit, 3, true, "الضرائب المستحقة الدفع", "2100");

        // Equity hierarchy
        Ensure("3000", "حقوق الملكية", "Equity", AccountType.Equity, AccountCategory.Main, AccountNature.Credit, 1, false, "حقوق ملكية الشركة");
        Ensure("3100", "حساب المنصة", "Platform Account", AccountType.Equity, AccountCategory.Sub, AccountNature.Credit, 2, true, "حساب أرباح المنصة", "3000");

        // Revenue hierarchy (for commission and cancellation revenue postings)
        Ensure("4000", "الإيرادات", "Revenue", AccountType.Revenue, AccountCategory.Main, AccountNature.Credit, 1, false, "جميع إيرادات الشركة");
        Ensure("4100", "الإيرادات التشغيلية", "Operating Revenue", AccountType.Revenue, AccountCategory.Sub, AccountNature.Credit, 2, false, "الإيرادات من العمليات الأساسية", "4000");
        Ensure("4101", "إيرادات الحجوزات", "Booking Revenue", AccountType.Revenue, AccountCategory.Sub, AccountNature.Credit, 3, true, "الإيرادات من حجوزات العقارات", "4100");
        Ensure("4110", "عمولات المنصة", "Platform Commissions", AccountType.Revenue, AccountCategory.Sub, AccountNature.Credit, 3, true, "عمولات المنصة على الحجوزات", "4100");
        Ensure("4120", "رسوم الخدمات", "Service Fees", AccountType.Revenue, AccountCategory.Sub, AccountNature.Credit, 3, true, "رسوم الخدمات الإضافية", "4100");
        Ensure("4130", "رسوم الإلغاء", "Cancellation Fees", AccountType.Revenue, AccountCategory.Sub, AccountNature.Credit, 3, true, "رسوم إلغاء الحجوزات", "4100");

        // Expense hierarchy (for refunds/sales returns postings)
        Ensure("5000", "المصروفات", "Expenses", AccountType.Expenses, AccountCategory.Main, AccountNature.Debit, 1, false, "جميع مصروفات الشركة");
        Ensure("5100", "المصروفات التشغيلية", "Operating Expenses", AccountType.Expenses, AccountCategory.Sub, AccountNature.Debit, 2, false, "مصروفات العمليات الأساسية", "5000");
        Ensure("5110", "المستردات", "Refunds", AccountType.Expenses, AccountCategory.Sub, AccountNature.Debit, 3, true, "المبالغ المستردة للعملاء", "5100");
        Ensure("5130", "مردودات المبيعات", "Sales Returns", AccountType.Expenses, AccountCategory.Sub, AccountNature.Debit, 3, true, "مردودات المبيعات والخصومات", "5100");

        await context.SaveChangesAsync();
        logger.LogInformation("تم التحقق من الحسابات المحاسبية الحرجة للعمولات والقيود المالية");
    }
}
