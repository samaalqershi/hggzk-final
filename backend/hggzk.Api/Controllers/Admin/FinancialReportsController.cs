using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Caching.Memory;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Accounting.Services;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Entities;
using YemenBooking.Application.Features.Analytics.DTOs;

namespace YemenBooking.Api.Controllers.Admin;

/// <summary>
/// يوفّر تقارير مالية ومحاسبية ضمن لوحة الإدارة.
/// Provides financial and accounting reports in the admin area.
/// </summary>
[ApiController]
[Route("api/admin/[controller]")]
[Authorize(Roles = "Admin")]
public class FinancialReportsController : ControllerBase
{
    /// <summary>
    /// حقل _logger.
    /// _logger field.
    /// </summary>
    private readonly ILogger<FinancialReportsController> _logger;
    /// <summary>
    /// حقل _financialAccountingService.
    /// _financialAccountingService field.
    /// </summary>
    private readonly IFinancialAccountingService _financialAccountingService;
    /// <summary>
    /// حقل _transactionRepository.
    /// _transactionRepository field.
    /// </summary>
    private readonly IFinancialTransactionRepository _transactionRepository;
    /// <summary>
    /// حقل _accountRepository.
    /// _accountRepository field.
    /// </summary>
    private readonly IChartOfAccountRepository _accountRepository;
    /// <summary>
    /// حقل _currentUserService.
    /// _currentUserService field.
    /// </summary>
    private readonly ICurrentUserService _currentUserService;
    /// <summary>
    /// حقل _cache.
    /// _cache field.
    /// </summary>
    private readonly IMemoryCache _cache;

    /// <summary>
    /// يهيئ المتحكم بخدمات التقارير والاعتماديات الداعمة.
    /// Initializes the controller with reporting services and supporting dependencies.
    /// </summary>
    /// <param name="logger">مسجل الأحداث الخاص بالمتحكم.</param>
    /// <param name="financialAccountingService">خدمة إعداد التقارير المالية.</param>
    /// <param name="transactionRepository">مستودع القيود المالية.</param>
    /// <param name="accountRepository">مستودع دليل الحسابات.</param>
    /// <param name="currentUserService">خدمة المستخدم الحالي.</param>
    /// <param name="cache">ذاكرة مؤقتة لنتائج التقارير المتكررة.</param>
    public FinancialReportsController(
        ILogger<FinancialReportsController> logger,
        IFinancialAccountingService financialAccountingService,
        IFinancialTransactionRepository transactionRepository,
        IChartOfAccountRepository accountRepository,
        ICurrentUserService currentUserService,
        IMemoryCache cache)
    {
        _logger = logger;
        _financialAccountingService = financialAccountingService;
        _transactionRepository = transactionRepository;
        _accountRepository = accountRepository;
        _currentUserService = currentUserService;
        _cache = cache;
    }

    /// <summary>
    /// يجلب التقرير المالي لفترة محددة.
    /// Retrieves the financial report for a specific period.
    /// </summary>
    [HttpGet("report")]
    public async Task<IActionResult> GetFinancialReport(
        [FromQuery] DateTime startDate,
        [FromQuery] DateTime endDate)
    {
        try
        {
            // Normalize DateTime values to UTC for PostgreSQL compatibility.
            // تطبيع قيم DateTime إلى UTC للتوافق مع PostgreSQL.
            startDate = DateTime.SpecifyKind(startDate, DateTimeKind.Utc);
            endDate = DateTime.SpecifyKind(endDate, DateTimeKind.Utc);
            
            var report = await _financialAccountingService.GetFinancialReportAsync(startDate, endDate);
            return Ok(new
            {
                success = true,
                data = report
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting financial report");
            return StatusCode(500, new { success = false, message = "خطأ في الحصول على التقرير المالي" });
        }
    }

    /// <summary>
    /// يجلب دليل الحسابات مع دعم التخزين المؤقت.
    /// Retrieves the chart of accounts with caching support.
    /// </summary>
    [HttpGet("chart-of-accounts")]
    public async Task<IActionResult> GetChartOfAccounts([FromQuery] AccountType? type = null)
    {
        try
        {
            // Build a cache key for the current slice.
            // إنشاء مفتاح ذاكرة مؤقتة للقطاع الحالي.
            string cacheKey = $"chart_of_accounts_{type?.ToString() ?? "all"}_{DateTime.UtcNow:yyyyMMddHH}";
            
            // Try the cache before querying the repositories.
            // محاولة الذاكرة المؤقتة قبل الاستعلام من المستودعات.
            if (_cache.TryGetValue<List<ChartOfAccountDto>>(cacheKey, out var cachedAccounts))
            {
                _logger.LogInformation("Loaded chart of accounts from cache.");
                return Ok(new
                {
                    success = true,
                    data = cachedAccounts,
                    cached = true
                });
            }

            List<ChartOfAccount> accounts;
            
            if (type.HasValue)
            {
                // Filter by account type when requested.
                // الفلترة حسب النوع عند الطلب.
                accounts = await _accountRepository.GetByAccountTypeAsync(type.Value);
            }
            else
            {
                // Load the full account tree.
                // تحميل شجرة الحسابات الكاملة.
                accounts = await _accountRepository.GetAccountsTreeAsync();
            }
            
            // Collect all account IDs, including nested sub-accounts.
            // جمع جميع معرّفات الحسابات بما فيها الفرعية.
            var allAccountIds = new List<Guid>();
            foreach (var account in accounts)
            {
                allAccountIds.Add(account.Id);
                if (account.SubAccounts?.Any() == true)
                {
                    allAccountIds.AddRange(account.SubAccounts.Select(s => s.Id));
                }
            }

            // Fetch all balances in a single optimized query.
            // جلب جميع الأرصدة في استعلام واحد محسن.
            var balances = await _transactionRepository.GetAccountsBalancesAsync(allAccountIds, DateTime.UtcNow);
            
            // Apply balances in parallel for faster projection.
            // تطبيق الأرصدة بشكل متوازي لتحسين الإسقاط.
            Parallel.ForEach(accounts, account =>
            {
                account.Balance = balances.ContainsKey(account.Id) ? balances[account.Id] : 0;
                
                if (account.SubAccounts?.Any() == true)
                {
                    Parallel.ForEach(account.SubAccounts, subAccount =>
                    {
                        subAccount.Balance = balances.ContainsKey(subAccount.Id) ? balances[subAccount.Id] : 0;
                    });
                }
            });
            
            // Project to DTOs to prevent circular references.
            // التحويل إلى DTO لتجنب المراجع الدائرية.
            var accountDtos = ChartOfAccountDto.FromEntities(accounts, includeSubAccounts: !type.HasValue);
            
            // Cache the result for a short interval.
            // حفظ النتيجة في الذاكرة المؤقتة لفترة قصيرة.
            var cacheOptions = new MemoryCacheEntryOptions()
                .SetSlidingExpiration(TimeSpan.FromMinutes(5))
                .SetAbsoluteExpiration(TimeSpan.FromMinutes(10))
                .SetPriority(CacheItemPriority.High);
                
            _cache.Set(cacheKey, accountDtos, cacheOptions);
            _logger.LogInformation("Cached chart of accounts.");
            
            return Ok(new
            {
                success = true,
                data = accountDtos,
                cached = false
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting chart of accounts");
            return StatusCode(500, new { success = false, message = "خطأ في الحصول على دليل الحسابات" });
        }
    }

    /// <summary>
    /// يجلب الحسابات حسب النوع للتوافق مع المستهلكين الحاليين.
    /// Retrieves accounts by type for compatibility with existing clients.
    /// </summary>
    [HttpGet("accounts")]
    public async Task<IActionResult> GetAccountsByType([FromQuery] AccountType? type = null)
    {
        return await GetChartOfAccounts(type);
    }

    /// <summary>
    /// يبحث في دليل الحسابات.
    /// Searches the chart of accounts.
    /// </summary>
    [HttpGet("accounts/search")]
    public async Task<IActionResult> SearchAccounts([FromQuery] string query)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(query))
            {
                return BadRequest(new { success = false, message = "يجب إدخال نص البحث" });
            }

            var accounts = await _accountRepository.SearchAccountsAsync(query);
            var accountDtos = ChartOfAccountDto.FromEntities(accounts, includeSubAccounts: false);
            
            return Ok(new
            {
                success = true,
                data = accountDtos
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error searching accounts");
            return StatusCode(500, new { success = false, message = "خطأ في البحث عن الحسابات" });
        }
    }

    /// <summary>
    /// يجلب القيود المالية خلال فترة محددة.
    /// Retrieves financial transactions for a specific period.
    /// </summary>
    [HttpGet("transactions")]
    public async Task<IActionResult> GetTransactions(
        [FromQuery] DateTime startDate,
        [FromQuery] DateTime endDate,
        [FromQuery] TransactionStatus? status = null,
        [FromQuery] TransactionType? type = null,
        [FromQuery] int? limit = null)
    {
        try
        {
            // Normalize DateTime values to UTC for PostgreSQL compatibility.
            // تطبيع قيم DateTime إلى UTC للتوافق مع PostgreSQL.
            startDate = DateTime.SpecifyKind(startDate, DateTimeKind.Utc);
            endDate = DateTime.SpecifyKind(endDate, DateTimeKind.Utc);
            
            var transactions = await _transactionRepository.GetByPeriodAsync(
                startDate,
                endDate,
                status,
                type,
                limit);

            // Project to DTOs to prevent circular references.
            // التحويل إلى DTO لتجنب المراجع الدائرية.
            var transactionDtos = FinancialTransactionDto.FromEntities(transactions);

            return Ok(new
            {
                success = true,
                data = transactionDtos,
                count = transactionDtos.Count
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting transactions");
            return StatusCode(500, new { success = false, message = "خطأ في الحصول على القيود المحاسبية" });
        }
    }

    /// <summary>
    /// يجلب القيود المالية الخاصة بحجز محدد.
    /// Retrieves financial transactions for a specific booking.
    /// </summary>
    [HttpGet("transactions/booking/{bookingId}")]
    public async Task<IActionResult> GetBookingTransactions(Guid bookingId)
    {
        try
        {
            var transactions = await _transactionRepository.GetByBookingIdAsync(bookingId);
            var transactionDtos = FinancialTransactionDto.FromEntities(transactions);
            
            return Ok(new
            {
                success = true,
                data = transactionDtos,
                count = transactionDtos.Count
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting booking transactions");
            return StatusCode(500, new { success = false, message = "خطأ في الحصول على قيود الحجز" });
        }
    }

    /// <summary>
    /// يجلب القيود المالية الخاصة بعقار محدد.
    /// Retrieves financial transactions for a specific property.
    /// </summary>
    [HttpGet("transactions/property/{propertyId}")]
    public async Task<IActionResult> GetPropertyTransactions(Guid propertyId)
    {
        try
        {
            var transactions = await _transactionRepository.GetByPropertyIdAsync(propertyId);
            var transactionDtos = FinancialTransactionDto.FromEntities(transactions);
            
            return Ok(new
            {
                success = true,
                data = transactionDtos,
                count = transactionDtos.Count
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting property transactions");
            return StatusCode(500, new { success = false, message = "خطأ في الحصول على قيود العقار" });
        }
    }

    /// <summary>
    /// يجلب القيود المالية الخاصة بمستخدم محدد.
    /// Retrieves financial transactions for a specific user.
    /// </summary>
    [HttpGet("transactions/user/{userId}")]
    public async Task<IActionResult> GetUserTransactions(Guid userId)
    {
        try
        {
            var transactions = await _transactionRepository.GetByUserIdAsync(userId);
            var transactionDtos = FinancialTransactionDto.FromEntities(transactions);
            
            return Ok(new
            {
                success = true,
                data = transactionDtos,
                count = transactionDtos.Count
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting user transactions");
            return StatusCode(500, new { success = false, message = "خطأ في الحصول على قيود المستخدم" });
        }
    }

    /// <summary>
    /// يفرغ ذاكرة دليل الحسابات المؤقتة.
    /// Clears the chart-of-accounts cache.
    /// </summary>
    [HttpPost("chart-of-accounts/clear-cache")]
    public IActionResult ClearChartOfAccountsCache()
    {
        try
        {
            // Remove all chart-of-accounts cache entries.
            // حذف جميع مفاتيح دليل الحسابات من الذاكرة المؤقتة.
            _cache.Remove("chart_of_accounts_all");
            foreach (AccountType accountType in Enum.GetValues(typeof(AccountType)))
            {
                _cache.Remove($"chart_of_accounts_{accountType}");
            }
            
            _logger.LogInformation("تم حذف الذاكرة المؤقتة لدليل الحسابات");
            
            return Ok(new
            {
                success = true,
                message = "تم حذف الذاكرة المؤقتة بنجاح"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error clearing cache");
            return StatusCode(500, new { success = false, message = "خطأ في حذف الذاكرة المؤقتة" });
        }
    }

    /// <summary>
    /// يجلب كشف حساب لفترة محددة.
    /// Retrieves an account statement for a date range.
    /// </summary>
    [HttpGet("account-statement/{accountId}")]
    public async Task<IActionResult> GetAccountStatement(
        Guid accountId,
        [FromQuery] DateTime startDate,
        [FromQuery] DateTime endDate)
    {
        try
        {
            var statement = await _transactionRepository.GetAccountStatementAsync(accountId, startDate, endDate);
            var balance = await _transactionRepository.GetAccountBalanceAtDateAsync(accountId, endDate);
            
            return Ok(new
            {
                success = true,
                data = new
                {
                    accountId,
                    startDate,
                    endDate,
                    transactions = statement,
                    closingBalance = balance,
                    transactionCount = statement.Count
                }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting account statement");
            return StatusCode(500, new { success = false, message = "خطأ في الحصول على كشف الحساب" });
        }
    }

    /// <summary>
    /// يبحث في القيود المالية.
    /// Searches financial transactions.
    /// </summary>
    [HttpGet("transactions/search")]
    public async Task<IActionResult> SearchTransactions(
        [FromQuery] string searchTerm,
        [FromQuery] TransactionType? type = null,
        [FromQuery] TransactionStatus? status = null,
        [FromQuery] DateTime? startDate = null,
        [FromQuery] DateTime? endDate = null)
    {
        try
        {
            var transactions = await _transactionRepository.SearchTransactionsAsync(
                searchTerm,
                type,
                status,
                startDate,
                endDate);

            var transactionDtos = FinancialTransactionDto.FromEntities(transactions);

            return Ok(new
            {
                success = true,
                data = transactionDtos,
                count = transactionDtos.Count
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error searching transactions");
            return StatusCode(500, new { success = false, message = "خطأ في البحث عن القيود" });
        }
    }

    /// <summary>
    /// يرحّل القيود المعلقة.
    /// Posts pending transactions.
    /// </summary>
    [HttpPost("post-pending")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> PostPendingTransactions()
    {
        try
        {
            var pendingTransactions = await _transactionRepository.GetPendingForPostingAsync();
            var postedCount = 0;
            var failedCount = 0;

            foreach (var transaction in pendingTransactions)
            {
                try
                {
                    await _transactionRepository.PostTransactionAsync(transaction.Id);
                    postedCount++;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to post transaction {TransactionId}", transaction.Id);
                    failedCount++;
                }
            }

            await _transactionRepository.SaveChangesAsync();
            return Ok(new
            {
                success = true,
                message = $"تم ترحيل {postedCount} قيد بنجاح، فشل {failedCount} قيد",
                data = new
                {
                    posted = postedCount,
                    failed = failedCount,
                    total = pendingTransactions.Count
                }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error posting pending transactions");
            return StatusCode(500, new { success = false, message = "خطأ في ترحيل القيود المعلقة" });
        }
    }

    /// <summary>
    /// يعكس قيدًا ماليًا.
    /// Reverses a financial transaction.
    /// </summary>
    [HttpPost("transactions/{transactionId}/reverse")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> ReverseTransaction(
        Guid transactionId,
        [FromBody] ReverseTransactionRequest request)
    {
        try
        {
            // Get the current user ID from claims.
            // جلب معرف المستخدم الحالي من المطالبات.
            var userIdClaim = User.FindFirst("UserId")?.Value;
            if (string.IsNullOrEmpty(userIdClaim))
            {
                return Unauthorized(new { success = false, message = "معرف المستخدم غير موجود" });
            }

            var userId = Guid.Parse(userIdClaim);
            var reverseTransaction = await _transactionRepository.ReverseTransactionAsync(
                transactionId,
                request.Reason,
                userId);

            if (reverseTransaction == null)
            {
                return BadRequest(new { success = false, message = "لا يمكن عكس هذا القيد" });
            }

            await _transactionRepository.SaveChangesAsync();
            return Ok(new
            {
                success = true,
                message = "تم عكس القيد بنجاح",
                data = reverseTransaction
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error reversing transaction");
            return StatusCode(500, new { success = false, message = "خطأ في عكس القيد" });
        }
    }

    /// <summary>
    /// يجلب ملخص القيود حسب النوع.
    /// Retrieves a transaction summary by type.
    /// </summary>
    [HttpGet("summary-by-type")]
    public async Task<IActionResult> GetTransactionSummaryByType(
        [FromQuery] DateTime startDate,
        [FromQuery] DateTime endDate)
    {
        try
        {
            var summary = await _transactionRepository.GetTransactionSummaryByTypeAsync(startDate, endDate);
            
            return Ok(new
            {
                success = true,
                data = summary,
                period = new { startDate, endDate }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting transaction summary");
            return StatusCode(500, new { success = false, message = "خطأ في الحصول على ملخص القيود" });
        }
    }

    /// <summary>
    /// يجلب رصيد الحساب عند تاريخ محدد.
    /// Retrieves the account balance as of a specific date.
    /// </summary>
    [HttpGet("account-balance/{accountId}")]
    public async Task<IActionResult> GetAccountBalance(
        Guid accountId,
        [FromQuery] DateTime? atDate = null)
    {
        try
        {
            var date = atDate ?? DateTime.UtcNow;
            var balance = await _transactionRepository.GetAccountBalanceAtDateAsync(accountId, date);
            var account = await _accountRepository.GetByIdAsync(accountId);
            
            return Ok(new
            {
                success = true,
                data = new
                {
                    accountId,
                    accountNumber = account?.AccountNumber,
                    accountName = account?.NameAr,
                    balance,
                    currency = account?.Currency ?? "YER",
                    asOfDate = date
                }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting account balance");
            return StatusCode(500, new { success = false, message = "خطأ في الحصول على رصيد الحساب" });
        }
    }

    /// <summary>
    /// يجلب بيانات مخطط الإيرادات.
    /// Retrieves revenue chart data.
    /// </summary>
    [HttpGet("charts/revenue")]
    public async Task<IActionResult> GetRevenueChart(
        [FromQuery] DateTime startDate,
        [FromQuery] DateTime endDate)
    {
        try
        {
            var chartData = await _financialAccountingService.GetRevenueChartDataAsync(startDate, endDate);
            return Ok(new
            {
                success = true,
                data = chartData
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting revenue chart data");
            return StatusCode(500, new { success = false, message = "خطأ في الحصول على بيانات مخطط الإيرادات" });
        }
    }

    /// <summary>
    /// يجلب بيانات مخطط المصروفات.
    /// Retrieves expense chart data.
    /// </summary>
    [HttpGet("charts/expenses")]
    public async Task<IActionResult> GetExpenseChart(
        [FromQuery] DateTime startDate,
        [FromQuery] DateTime endDate)
    {
        try
        {
            var chartData = await _financialAccountingService.GetExpenseChartDataAsync(startDate, endDate);
            return Ok(new
            {
                success = true,
                data = chartData
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting expense chart data");
            return StatusCode(500, new { success = false, message = "خطأ في الحصول على بيانات مخطط المصروفات" });
        }
    }

    /// <summary>
    /// يجلب بيانات التدفق النقدي.
    /// Retrieves cash flow chart data.
    /// </summary>
    [HttpGet("charts/cash-flow")]
    public async Task<IActionResult> GetCashFlowChart(
        [FromQuery] DateTime startDate,
        [FromQuery] DateTime endDate)
    {
        try
        {
            var chartData = await _financialAccountingService.GetCashFlowChartDataAsync(startDate, endDate);
            return Ok(new
            {
                success = true,
                data = chartData
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting cash flow chart data");
            return StatusCode(500, new { success = false, message = "خطأ في الحصول على بيانات التدفق النقدي" });
        }
    }

    /// <summary>
    /// يجلب الملخص المالي الشامل.
    /// Retrieves the comprehensive financial summary.
    /// </summary>
    [HttpGet("financial-summary")]
    public async Task<IActionResult> GetFinancialSummary()
    {
        try
        {
            var cacheKey = $"financial_summary_{DateTime.UtcNow:yyyyMMddHHmm}"; // Cache key changes per minute. / يتغير مفتاح الذاكرة المؤقتة كل دقيقة.
            if (_cache.TryGetValue(cacheKey, out FinancialSummaryDto cachedSummary))
            {
                return Ok(new
                {
                    success = true,
                    data = cachedSummary,
                    cached = true
                });
            }

            var summary = await _financialAccountingService.GetFinancialSummaryAsync();

            var cacheOptions = new MemoryCacheEntryOptions()
                .SetSlidingExpiration(TimeSpan.FromMinutes(1))
                .SetAbsoluteExpiration(TimeSpan.FromMinutes(2))
                .SetPriority(CacheItemPriority.High);
            _cache.Set(cacheKey, summary, cacheOptions);

            return Ok(new
            {
                success = true,
                data = summary,
                cached = false
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting financial summary");
            return StatusCode(500, new { success = false, message = "خطأ في الحصول على الملخص المالي" });
        }
    }
}

/// <summary>
/// يصف سبب عكس القيد المالي.
/// Describes the reason for reversing a financial transaction.
/// </summary>
public class ReverseTransactionRequest
{
    /// <summary>
    /// سبب عكس القيد.
    /// The reversal reason.
    /// </summary>
    public string Reason { get; set; }
}
