using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Analytics.DTOs;
using YemenBooking.Application.Features.Reports.DTOs;
using PaymentStatus = YemenBooking.Core.Enums.PaymentStatus;

namespace YemenBooking.Application.Features.Accounting.Services;

/// <summary>
/// Implements the core financial accounting workflows for bookings, payments, and reports.
/// يطبّق مسارات المحاسبة المالية الأساسية للحجوزات والمدفوعات والتقارير.
/// </summary>
public class FinancialAccountingService : IFinancialAccountingService
{
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
    /// حقل _bookingRepository.
    /// _bookingRepository field.
    /// </summary>
    private readonly IBookingRepository _bookingRepository;
    /// <summary>
    /// حقل _paymentRepository.
    /// _paymentRepository field.
    /// </summary>
    private readonly IPaymentRepository _paymentRepository;
    /// <summary>
    /// حقل _userRepository.
    /// _userRepository field.
    /// </summary>
    private readonly IUserRepository _userRepository;
    /// <summary>
    /// حقل _propertyRepository.
    /// _propertyRepository field.
    /// </summary>
    private readonly IPropertyRepository _propertyRepository;
    /// <summary>
    /// حقل _unitRepository.
    /// _unitRepository field.
    /// </summary>
    private readonly IUnitRepository _unitRepository;
    /// <summary>
    /// حقل _systemSettingsService.
    /// _systemSettingsService field.
    /// </summary>
    private readonly ISystemSettingsService _systemSettingsService;
    /// <summary>
    /// حقل _logger.
    /// _logger field.
    /// </summary>
    private readonly ILogger<FinancialAccountingService> _logger;
    // Core system accounts.
    // حسابات النظام الأساسية.
    /// <summary>
    /// حقل SYSTEM_CASH_ACCOUNT.
    /// SYSTEM_CASH_ACCOUNT field.
    /// </summary>
    private const string SYSTEM_CASH_ACCOUNT = "النقدية";
    /// <summary>
    /// حقل SYSTEM_BANK_ACCOUNT.
    /// SYSTEM_BANK_ACCOUNT field.
    /// </summary>
    private const string SYSTEM_BANK_ACCOUNT = "البنك";
    /// <summary>
    /// حقل SYSTEM_REVENUE_ACCOUNT.
    /// SYSTEM_REVENUE_ACCOUNT field.
    /// </summary>
    private const string SYSTEM_REVENUE_ACCOUNT = "إيرادات الحجوزات";
    /// <summary>
    /// حقل SYSTEM_COMMISSION_ACCOUNT.
    /// SYSTEM_COMMISSION_ACCOUNT field.
    /// </summary>
    private const string SYSTEM_COMMISSION_ACCOUNT = "عمولات المنصة";
    /// <summary>
    /// حقل SYSTEM_TAX_ACCOUNT.
    /// SYSTEM_TAX_ACCOUNT field.
    /// </summary>
    private const string SYSTEM_TAX_ACCOUNT = "الضرائب المستحقة";
    /// <summary>
    /// حقل SYSTEM_RECEIVABLE_ACCOUNT.
    /// SYSTEM_RECEIVABLE_ACCOUNT field.
    /// </summary>
    private const string SYSTEM_RECEIVABLE_ACCOUNT = "ذمم مدينة - عملاء";
    /// <summary>
    /// حقل SYSTEM_PAYABLE_ACCOUNT.
    /// SYSTEM_PAYABLE_ACCOUNT field.
    /// </summary>
    private const string SYSTEM_PAYABLE_ACCOUNT = "ذمم دائنة - ملاك";
    /// <summary>
    /// حقل PLATFORM_ACCOUNT.
    /// PLATFORM_ACCOUNT field.
    /// </summary>
    private const string PLATFORM_ACCOUNT = "حساب المنصة";
    /// <summary>
    /// حقل OWNERS_FUNDS_PENDING_ACCOUNT.
    /// OWNERS_FUNDS_PENDING_ACCOUNT field.
    /// </summary>
    private const string OWNERS_FUNDS_PENDING_ACCOUNT = "أموال الملاك المعلقة";
    /// <summary>
    /// حقل PLATFORM_COMMISSION_PENDING_ACCOUNT.
    /// PLATFORM_COMMISSION_PENDING_ACCOUNT field.
    /// </summary>
    private const string PLATFORM_COMMISSION_PENDING_ACCOUNT = "عمولات المنصة المستحقة";
    /// <summary>
    /// حقل CANCELLATION_FEES_ACCOUNT.
    /// CANCELLATION_FEES_ACCOUNT field.
    /// </summary>
    private const string CANCELLATION_FEES_ACCOUNT = "رسوم الإلغاء";
    /// <summary>
    /// حقل SALES_RETURNS_ACCOUNT.
    /// SALES_RETURNS_ACCOUNT field.
    /// </summary>
    private const string SALES_RETURNS_ACCOUNT = "مردودات المبيعات";
    /// <summary>
    /// حقل DEFAULT_COMMISSION_RATE_SETTING_KEY.
    /// DEFAULT_COMMISSION_RATE_SETTING_KEY field.
    /// </summary>
    private const string DEFAULT_COMMISSION_RATE_SETTING_KEY = "Commission:DefaultRate";
    /// <summary>
    /// حقل DEFAULT_COMMISSION_RATE_PERCENT.
    /// DEFAULT_COMMISSION_RATE_PERCENT field.
    /// </summary>
    private const decimal DEFAULT_COMMISSION_RATE_PERCENT = 5m;

    /// <summary>
    /// منشئ FinancialAccountingService.
    /// FinancialAccountingService constructor.
    /// </summary>
    public FinancialAccountingService(
        IFinancialTransactionRepository transactionRepository,
        IChartOfAccountRepository accountRepository,
        IBookingRepository bookingRepository,
        IPaymentRepository paymentRepository,
        IUserRepository userRepository,
        IPropertyRepository propertyRepository,
        IUnitRepository unitRepository,
        ISystemSettingsService systemSettingsService,
        ILogger<FinancialAccountingService> logger)
    {
        _transactionRepository = transactionRepository;
        _accountRepository = accountRepository;
        _bookingRepository = bookingRepository;
        _paymentRepository = paymentRepository;
        _userRepository = userRepository;
        _propertyRepository = propertyRepository;
        _unitRepository = unitRepository;
        _systemSettingsService = systemSettingsService;
        _logger = logger;
    }

    /// <summary>
    /// يحفظ التغييرات المالية المجهّزة عبر نفس سياق المستودعات المحاسبية.
    /// Commits staged financial changes through the shared accounting repository context.
    /// </summary>
    private Task SaveChangesAsync()
        => _accountRepository.SaveChangesAsync();

    /// <summary>
    /// دالة ResolveCommissionRateFractionAsync.
    /// ResolveCommissionRateFractionAsync method.
    /// </summary>
    private async Task<decimal> ResolveCommissionRateFractionAsync(Property? property)
    {
        var percent = await ResolveCommissionRatePercentageAsync(property);
        return percent / 100m;
    }

    /// <summary>
    /// دالة ResolveCommissionRatePercentageAsync.
    /// ResolveCommissionRatePercentageAsync method.
    /// </summary>
    private async Task<decimal> ResolveCommissionRatePercentageAsync(Property? property)
    {
        if (property?.SystemCommissionRate.HasValue == true)
        {
            var propertyRate = property.SystemCommissionRate.Value;
            if (propertyRate >= 0m && propertyRate <= 100m)
            {
                return Math.Round(propertyRate, 2);
            }
        }

        try
        {
            var settings = await _systemSettingsService.GetSettingsAsync();
            if (settings.TryGetValue(DEFAULT_COMMISSION_RATE_SETTING_KEY, out var rawRate) &&
                TryParseCommissionPercentage(rawRate, out var parsedRate))
            {
                return parsedRate;
            }

            // Preserve backward compatibility with older deployment settings.
            // الحفاظ على التوافق مع إعدادات الإصدارات القديمة.
            if (settings.TryGetValue("DefaultCommissionRate", out var legacyRawRate) &&
                TryParseCommissionPercentage(legacyRawRate, out var legacyRate))
            {
                return legacyRate;
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "تعذر قراءة إعداد نسبة العمولة الافتراضية، سيتم استخدام القيمة الاحتياطية");
        }

        return DEFAULT_COMMISSION_RATE_PERCENT;
    }

    /// <summary>
    /// دالة TryParseCommissionPercentage.
    /// TryParseCommissionPercentage method.
    /// </summary>
    private static bool TryParseCommissionPercentage(string? value, out decimal rate)
    {
        rate = 0m;
        if (string.IsNullOrWhiteSpace(value))
        {
            return false;
        }

        var normalized = value.Trim().Replace(",", ".", StringComparison.Ordinal);
        if (!decimal.TryParse(normalized, NumberStyles.Number, CultureInfo.InvariantCulture, out var parsed))
        {
            return false;
        }

        if (parsed < 0m || parsed > 100m)
        {
            return false;
        }

        rate = Math.Round(parsed, 2);
        return true;
    }

    /// <summary>
    /// Records the accounting entries for a new booking.
    /// يسجل القيود المحاسبية الخاصة بحجز جديد.
    /// </summary>
    public async Task<FinancialTransaction> RecordBookingTransactionAsync(Guid bookingId, Guid userId)
    {
        try
        {
            var booking = await _bookingRepository.GetByIdAsync(bookingId);
            if (booking == null)
                throw new ArgumentException($"BookingDto {bookingId} not found");

            var user = await _userRepository.GetByIdAsync(booking.UserId);
            if (user == null)
                throw new ArgumentException($"User {booking.UserId} not found");

            var unit = await _unitRepository.GetByIdAsync(booking.UnitId);
            if (unit == null)
                throw new ArgumentException($"Unit {booking.UnitId} not found");

            var property = await _propertyRepository.GetByIdAsync(unit.PropertyId);
            if (property == null)
                throw new ArgumentException($"Property {unit.PropertyId} not found");

            // Resolve or create the related accounts.
            // تحديد أو إنشاء حسابات الأطراف.
            var customerAccount = await GetOrCreateCustomerAccountAsync(booking.UserId, user.Name);
            var ownersPendingAccount = await _accountRepository.GetSystemAccountAsync(OWNERS_FUNDS_PENDING_ACCOUNT);
            var commissionPendingAccount = await _accountRepository.GetSystemAccountAsync(PLATFORM_COMMISSION_PENDING_ACCOUNT);

            // Resolve the commission rate from property settings and global fallback.
            // تحديد نسبة العمولة من إعدادات العقار مع قيمة احتياطية عامة.
            var commissionRate = await ResolveCommissionRateFractionAsync(property);
            var totalAmount = booking.TotalPrice.Amount;
            var commissionAmount = Math.Round(totalAmount * commissionRate, 2);
            var ownerAmount = totalAmount - commissionAmount;

            if (booking.PlatformCommissionAmount != commissionAmount)
            {
                booking.PlatformCommissionAmount = commissionAmount;
                booking.UpdatedAt = DateTime.UtcNow;
                await _bookingRepository.UpdateAsync(booking);
            }

            // Entry 1: move the owner's share into pending owner funds.
            // القيد 1: تحويل حصة المالك إلى أموال الملاك المعلقة.
            var ownerDistributionTx = new FinancialTransaction
            {
                TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                TransactionDate = DateTime.UtcNow,
                EntryType = JournalEntryType.Sales,
                TransactionType = TransactionType.NewBooking,
                DebitAccountId = customerAccount.Id,
                CreditAccountId = ownersPendingAccount.Id,
                Amount = ownerAmount,
                Currency = booking.TotalPrice.Currency,
                ExchangeRate = 1,
                BaseAmount = ownerAmount,
                Description = $"توزيع حجز جديد (حصة المالك) للحجز {booking.Id}",
                Narration = $"حجز الوحدة {unit.Name} في {property.Name} للفترة {booking.CheckIn:yyyy-MM-dd} إلى {booking.CheckOut:yyyy-MM-dd}",
                ReferenceNumber = booking.Id.ToString(),
                DocumentType = "BookingDistribution",
                BookingId = bookingId,
                FirstPartyUserId = booking.UserId,
                SecondPartyUserId = property.OwnerId,
                PropertyId = property.Id,
                UnitId = unit.Id,
                Status = TransactionStatus.Posted,
                IsPosted = true,
                PostingDate = DateTime.UtcNow,
                FiscalYear = DateTime.UtcNow.Year,
                FiscalPeriod = DateTime.UtcNow.Month,
                Commission = commissionAmount,
                CommissionPercentage = commissionRate * 100,
                NetAmount = ownerAmount,
                CreatedBy = userId,
                CreatedAt = DateTime.UtcNow,
                IsAutomatic = true,
                AutomaticSource = "BookingSystem"
            };
            await _transactionRepository.AddAsync(ownerDistributionTx);

            // Entry 2: move the platform commission into accrued commission.
            // القيد 2: تحويل عمولة المنصة إلى العمولات المستحقة.
            var commissionPendingTx = new FinancialTransaction
            {
                TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                TransactionDate = DateTime.UtcNow,
                EntryType = JournalEntryType.Sales,
                TransactionType = TransactionType.PlatformCommission,
                DebitAccountId = customerAccount.Id,
                CreditAccountId = commissionPendingAccount.Id,
                Amount = commissionAmount,
                Currency = booking.TotalPrice.Currency,
                ExchangeRate = 1,
                BaseAmount = commissionAmount,
                Description = $"توزيع حجز جديد (عمولة المنصة) للحجز {booking.Id}",
                Narration = $"عمولة {commissionRate * 100}% مستحقة على الحجز",
                ReferenceNumber = booking.Id.ToString(),
                DocumentType = "BookingDistribution",
                BookingId = bookingId,
                FirstPartyUserId = booking.UserId,
                SecondPartyUserId = property.OwnerId,
                PropertyId = property.Id,
                UnitId = unit.Id,
                Status = TransactionStatus.Posted,
                IsPosted = true,
                PostingDate = DateTime.UtcNow,
                FiscalYear = DateTime.UtcNow.Year,
                FiscalPeriod = DateTime.UtcNow.Month,
                Commission = commissionAmount,
                CommissionPercentage = commissionRate * 100,
                NetAmount = ownerAmount,
                CreatedBy = userId,
                CreatedAt = DateTime.UtcNow,
                IsAutomatic = true,
                AutomaticSource = "BookingSystem"
            };
            await _transactionRepository.AddAsync(commissionPendingTx);

            await SaveChangesAsync();
            _logger.LogInformation($"BookingDto distribution recorded for booking {bookingId}");
            return ownerDistributionTx;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error recording booking transaction for booking {bookingId}");
            throw;
        }
    }

    /// <summary>
    /// Records a payment transaction for a booking.
    /// يسجل عملية دفع مرتبطة بحجز.
    /// </summary>
    public async Task<FinancialTransaction> RecordPaymentTransactionAsync(Guid paymentId, Guid userId)
    {
        try
        {
            var payment = await _paymentRepository.GetByIdAsync(paymentId);
            if (payment == null)
                throw new ArgumentException($"Payment {paymentId} not found");

            var booking = await _bookingRepository.GetByIdAsync(payment.BookingId);
            var user = await _userRepository.GetByIdAsync(booking.UserId);
            var unit = await _unitRepository.GetByIdAsync(booking.UnitId);
            var property = await _propertyRepository.GetByIdAsync(unit.PropertyId);

            // Select posting accounts based on the payment method.
            // تحديد حسابات القيد حسب طريقة الدفع.
            var paymentMethodAccount = payment.PaymentMethod switch
            {
                PaymentMethodEnum.CreditCard => await _accountRepository.GetSystemAccountAsync(SYSTEM_BANK_ACCOUNT),
                PaymentMethodEnum.CashWallet => await _accountRepository.GetSystemAccountAsync("المحافظ الإلكترونية"),
                PaymentMethodEnum.JwaliWallet => await _accountRepository.GetSystemAccountAsync("المحافظ الإلكترونية"),
                PaymentMethodEnum.OneCashWallet => await _accountRepository.GetSystemAccountAsync("المحافظ الإلكترونية"),
                PaymentMethodEnum.FloskWallet => await _accountRepository.GetSystemAccountAsync("المحافظ الإلكترونية"),
                PaymentMethodEnum.JaibWallet => await _accountRepository.GetSystemAccountAsync("المحافظ الإلكترونية"),
                PaymentMethodEnum.EWallet => await _accountRepository.GetSystemAccountAsync("المحافظ الإلكترونية"),
                PaymentMethodEnum.Paypal => await _accountRepository.GetSystemAccountAsync(SYSTEM_BANK_ACCOUNT),
                PaymentMethodEnum.Cash => await _accountRepository.GetSystemAccountAsync(SYSTEM_CASH_ACCOUNT),
                _ => await _accountRepository.GetSystemAccountAsync(SYSTEM_CASH_ACCOUNT)
            };

            var customerAccount = await GetOrCreateUserAccountAsync(booking.UserId, user.Name, AccountType.Assets);

            var transactionType = payment.Status == PaymentStatus.Pending 
                ? TransactionType.AdvancePayment 
                : TransactionType.FinalPayment;

            var transaction = new FinancialTransaction
            {
                TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                TransactionDate = payment.PaymentDate,
                EntryType = JournalEntryType.CashReceipts,
                TransactionType = transactionType,
                DebitAccountId = paymentMethodAccount.Id,
                CreditAccountId = customerAccount.Id,
                Amount = payment.Amount.Amount,
                Currency = payment.Amount.Currency,
                ExchangeRate = 1,
                BaseAmount = payment.Amount.Amount,
                Description = $"دفعة من العميل {user.Name} للحجز {booking.Id}",
                Narration = $"استلام دفعة بواسطة {payment.PaymentMethod} - معرف المعاملة: {payment.TransactionId}",
                ReferenceNumber = payment.TransactionId,
                DocumentType = "Payment",
                BookingId = booking.Id,
                PaymentId = paymentId,
                FirstPartyUserId = booking.UserId,
                PropertyId = property.Id,
                UnitId = unit.Id,
                Status = TransactionStatus.Approved,
                FiscalYear = payment.PaymentDate.Year,
                FiscalPeriod = payment.PaymentDate.Month,
                CreatedBy = userId,
                CreatedAt = DateTime.UtcNow,
                IsAutomatic = true,
                AutomaticSource = "PaymentSystem"
            };

            await _transactionRepository.AddAsync(transaction);

            // Post the entry immediately when the payment is confirmed.
            // ترحيل القيد مباشرة عند تأكيد الدفعة.
            if (payment.Status == Core.Enums.PaymentStatus.Successful)
            {
                await _transactionRepository.PostTransactionAsync(transaction.Id);
            }

            await SaveChangesAsync();
            _logger.LogInformation($"Payment transaction recorded for payment {paymentId}");
            return transaction;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error recording payment transaction for payment {paymentId}");
            throw;
        }
    }

    /// <summary>
    /// Records a booking cancellation and keeps the legacy entry point.
    /// يسجل إلغاء الحجز مع الحفاظ على نقطة الدخول القديمة.
    /// </summary>
    public async Task<FinancialTransaction> RecordBookingCancellationAsync(Guid bookingId, string reason, Guid userId)
    {
        try
        {
            var booking = await _bookingRepository.GetByIdAsync(bookingId);
            if (booking == null)
                throw new ArgumentException($"BookingDto {bookingId} not found");

            // Load the original booking entries.
            // جلب القيود الأصلية للحجز.
            var originalTransactions = await _transactionRepository.GetByBookingIdAsync(bookingId);
            
            var user = await _userRepository.GetByIdAsync(booking.UserId);
            var unit = await _unitRepository.GetByIdAsync(booking.UnitId);
            var property = await _propertyRepository.GetByIdAsync(unit.PropertyId);

            var customerAccount = await GetOrCreateUserAccountAsync(booking.UserId, user.Name, AccountType.Assets);
            var revenueAccount = await _accountRepository.GetSystemAccountAsync(SYSTEM_REVENUE_ACCOUNT);

            // Reverse the original booking entry.
            // عكس قيد الحجز الأصلي.
            var cancellationTransaction = new FinancialTransaction
            {
                TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                TransactionDate = DateTime.UtcNow,
                EntryType = JournalEntryType.Reversal,
                TransactionType = TransactionType.BookingCancellation,
                DebitAccountId = revenueAccount.Id, // Reverse the original entry. / عكس القيد الأصلي.
                CreditAccountId = customerAccount.Id,
                Amount = booking.TotalPrice.Amount,
                Currency = booking.TotalPrice.Currency,
                ExchangeRate = 1,
                BaseAmount = booking.TotalPrice.Amount,
                Description = $"إلغاء الحجز رقم {booking.Id}",
                Narration = $"سبب الإلغاء: {reason}",
                ReferenceNumber = booking.Id.ToString(),
                DocumentType = "Cancellation",
                BookingId = bookingId,
                FirstPartyUserId = booking.UserId,
                SecondPartyUserId = property.OwnerId,
                PropertyId = property.Id,
                UnitId = unit.Id,
                Status = TransactionStatus.Approved,
                FiscalYear = DateTime.UtcNow.Year,
                FiscalPeriod = DateTime.UtcNow.Month,
                CancellationReason = reason,
                CancelledAt = DateTime.UtcNow,
                CancelledBy = userId,
                CreatedBy = userId,
                CreatedAt = DateTime.UtcNow,
                IsAutomatic = true,
                AutomaticSource = "CancellationSystem"
            };

            await _transactionRepository.AddAsync(cancellationTransaction);

            // Reverse all entries linked to the booking.
            // عكس جميع القيود المرتبطة بالحجز.
            foreach (var originalTx in originalTransactions.Where(t => !t.IsReversed))
            {
                await _transactionRepository.ReverseTransactionAsync(originalTx.Id, reason, userId);
            }

            await SaveChangesAsync();
            _logger.LogInformation($"BookingDto cancellation recorded for booking {bookingId}");
            return cancellationTransaction;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error recording booking cancellation for booking {bookingId}");
            throw;
        }
    }

    /// <summary>
    /// Records a refund transaction.
    /// يسجل عملية استرداد مبلغ.
    /// </summary>
    public async Task<FinancialTransaction> RecordRefundTransactionAsync(
        Guid bookingId, 
        decimal amount, 
        string reason, 
        Guid userId)
    {
        try
        {
            var booking = await _bookingRepository.GetByIdAsync(bookingId);
            if (booking == null)
                throw new ArgumentException($"BookingDto {bookingId} not found");

            var user = await _userRepository.GetByIdAsync(booking.UserId);
            if (user == null)
                throw new ArgumentException($"User {booking.UserId} not found");

            var unit = await _unitRepository.GetByIdAsync(booking.UnitId);
            if (unit == null)
                throw new ArgumentException($"Unit {booking.UnitId} not found");

            var property = await _propertyRepository.GetByIdAsync(unit.PropertyId);
            if (property == null)
                throw new ArgumentException($"Property {unit.PropertyId} not found");

            var salesReturnsAccount = await _accountRepository.GetSystemAccountAsync(SALES_RETURNS_ACCOUNT);
            var cashOrBankAccount = await _accountRepository.GetSystemAccountAsync(SYSTEM_BANK_ACCOUNT)
                ?? await _accountRepository.GetSystemAccountAsync(SYSTEM_CASH_ACCOUNT);

            var refundTransaction = new FinancialTransaction
            {
                TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                TransactionDate = DateTime.UtcNow,
                EntryType = JournalEntryType.CashPayments,
                TransactionType = TransactionType.Refund,
                DebitAccountId = salesReturnsAccount.Id,
                CreditAccountId = cashOrBankAccount.Id,
                Amount = amount,
                Currency = booking.TotalPrice.Currency,
                ExchangeRate = 1,
                BaseAmount = amount,
                Description = $"استرداد مبلغ للعميل {user.Name}",
                Narration = $"سبب الاسترداد: {reason}",
                ReferenceNumber = booking.Id.ToString(),
                DocumentType = "Refund",
                BookingId = bookingId,
                FirstPartyUserId = booking.UserId,
                PropertyId = property.Id,
                UnitId = unit.Id,
                Status = TransactionStatus.Approved,
                FiscalYear = DateTime.UtcNow.Year,
                FiscalPeriod = DateTime.UtcNow.Month,
                CreatedBy = userId,
                CreatedAt = DateTime.UtcNow,
                IsAutomatic = false
            };

            await _transactionRepository.AddAsync(refundTransaction);
            await CreateCommissionRefundReversalEntriesAsync(
                booking,
                user,
                property,
                unit,
                amount,
                reason,
                userId);

            await SaveChangesAsync();
            _logger.LogInformation($"Refund transaction recorded for booking {bookingId}, amount: {amount}");
            return refundTransaction;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error recording refund for booking {bookingId}");
            throw;
        }
    }

    /// <summary>
    /// Records an owner payout transaction.
    /// يسجل عملية دفعة للمالك.
    /// </summary>
    public async Task<FinancialTransaction> RecordOwnerPayoutAsync(
        Guid propertyId,
        Guid ownerId,
        decimal amount,
        string description,
        Guid userId)
    {
        try
        {
            var property = await _propertyRepository.GetByIdAsync(propertyId);
            if (property == null)
                throw new ArgumentException($"Property {propertyId} not found");

            var owner = await _userRepository.GetByIdAsync(ownerId);

            var ownerAccount = await GetOrCreateUserAccountAsync(ownerId, owner.Name, AccountType.Liabilities);
            var bankAccount = await _accountRepository.GetSystemAccountAsync(SYSTEM_BANK_ACCOUNT);

            var payoutTransaction = new FinancialTransaction
            {
                TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                TransactionDate = DateTime.UtcNow,
                EntryType = JournalEntryType.CashPayments,
                TransactionType = TransactionType.OwnerPayout,
                DebitAccountId = ownerAccount.Id,
                CreditAccountId = bankAccount.Id,
                Amount = amount,
                Currency = "YER",
                ExchangeRate = 1,
                BaseAmount = amount,
                Description = $"دفعة للمالك {owner.Name}",
                Narration = description,
                ReferenceNumber = Guid.NewGuid().ToString(),
                DocumentType = "OwnerPayout",
                SecondPartyUserId = ownerId,
                PropertyId = propertyId,
                Status = TransactionStatus.Approved,
                FiscalYear = DateTime.UtcNow.Year,
                FiscalPeriod = DateTime.UtcNow.Month,
                CreatedBy = userId,
                CreatedAt = DateTime.UtcNow,
                IsAutomatic = false
            };

            await _transactionRepository.AddAsync(payoutTransaction);

            await SaveChangesAsync();
            _logger.LogInformation($"Owner payout recorded for property {propertyId}, amount: {amount}");
            return payoutTransaction;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error recording owner payout for property {propertyId}");
            throw;
        }
    }

    /// <summary>
    /// Records the booking completion entry.
    /// يسجل قيد إكمال الحجز.
    /// </summary>
    public async Task<FinancialTransaction> RecordBookingCompletionAsync(
        Guid bookingId,
        decimal finalAmount,
        Guid userId)
    {
        try
        {
            var booking = await _bookingRepository.GetByIdAsync(bookingId);
            if (booking == null)
                throw new ArgumentException($"BookingDto {bookingId} not found");

            var user = await _userRepository.GetByIdAsync(booking.UserId);
            if (user == null)
                throw new ArgumentException($"User {booking.UserId} not found");

            var unit = await _unitRepository.GetByIdAsync(booking.UnitId);
            if (unit == null)
                throw new ArgumentException($"Unit {booking.UnitId} not found");

            var property = await _propertyRepository.GetByIdAsync(unit.PropertyId);
            if (property == null)
                throw new ArgumentException($"Property {unit.PropertyId} not found");

            var customerAccount = await GetOrCreateUserAccountAsync(booking.UserId, user.Name, AccountType.Assets);
            var ownerAccount = await GetOrCreateUserAccountAsync(property.OwnerId, property.Owner?.Name ?? "Owner", AccountType.Liabilities);
            var platformAccount = await _accountRepository.GetSystemAccountAsync(PLATFORM_ACCOUNT);
            if (platformAccount == null)
                throw new InvalidOperationException($"System account '{PLATFORM_ACCOUNT}' not found");

            var normalizedFinalAmount = Math.Round(finalAmount, 2);

            // Resolve the final commission rate from property settings and fallback defaults.
            // تحديد نسبة العمولة النهائية من إعدادات العقار والقيم الاحتياطية.
            var commissionRate = await ResolveCommissionRateFractionAsync(property);
            var commissionAmount = Math.Round(normalizedFinalAmount * commissionRate, 2);
            var ownerAmount = Math.Round(normalizedFinalAmount - commissionAmount, 2);

            // Transfer the owner share from the customer account to the owner account.
            // تحويل حصة المالك من حساب العميل إلى حساب المالك.
            var transferTransaction = new FinancialTransaction
            {
                TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                TransactionDate = DateTime.UtcNow,
                EntryType = JournalEntryType.GeneralJournal,
                TransactionType = TransactionType.FinalPayment,
                DebitAccountId = ownerAccount.Id,
                CreditAccountId = customerAccount.Id,
                Amount = ownerAmount,
                Currency = booking.TotalPrice.Currency,
                ExchangeRate = 1,
                BaseAmount = ownerAmount,
                Description = $"إكمال الحجز رقم {booking.Id}",
                Narration = $"تحويل المبلغ النهائي للمالك بعد خصم العمولة",
                ReferenceNumber = booking.Id.ToString(),
                DocumentType = "BookingCompletion",
                BookingId = bookingId,
                FirstPartyUserId = booking.UserId,
                SecondPartyUserId = property.OwnerId,
                PropertyId = property.Id,
                UnitId = unit.Id,
                Status = TransactionStatus.Posted,
                IsPosted = true,
                PostingDate = DateTime.UtcNow,
                FiscalYear = DateTime.UtcNow.Year,
                FiscalPeriod = DateTime.UtcNow.Month,
                Commission = commissionAmount,
                CommissionPercentage = commissionRate * 100,
                NetAmount = ownerAmount,
                CreatedBy = userId,
                CreatedAt = DateTime.UtcNow,
                IsAutomatic = true,
                AutomaticSource = "BookingCompletionSystem"
            };

            await _transactionRepository.AddAsync(transferTransaction);

            // Update account balances.
            // تحديث أرصدة الحسابات.
            await _accountRepository.UpdateAccountBalanceAsync(ownerAccount.Id, ownerAmount, true);
            await _accountRepository.UpdateAccountBalanceAsync(customerAccount.Id, normalizedFinalAmount, false);
            await _accountRepository.UpdateAccountBalanceAsync(platformAccount.Id, commissionAmount, false);

            await SaveChangesAsync();
            _logger.LogInformation($"BookingDto completion recorded for booking {bookingId}");
            return transferTransaction;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error recording booking completion for booking {bookingId}");
            throw;
        }
    }

    /// <summary>
    /// دالة CreateCommissionRefundReversalEntriesAsync.
    /// CreateCommissionRefundReversalEntriesAsync method.
    /// </summary>
    private async Task CreateCommissionRefundReversalEntriesAsync(
        Booking booking,
        User bookingUser,
        Property property,
        Unit unit,
        decimal refundAmount,
        string reason,
        Guid userId)
    {
        if (refundAmount <= 0m || booking.TotalPrice.Amount <= 0m)
        {
            return;
        }

        var bookingTransactions = (await _transactionRepository.GetByBookingIdAsync(booking.Id)).ToList();
        if (!bookingTransactions.Any())
        {
            return;
        }

        var customerAccount = await GetOrCreateCustomerAccountAsync(booking.UserId, bookingUser.Name);

        var sourceCommissionTransactions = bookingTransactions
            .Where(t =>
                t.TransactionType == TransactionType.PlatformCommission &&
                t.Amount > 0m &&
                t.Status == TransactionStatus.Posted &&
                !t.IsReversed &&
                !string.Equals(t.DocumentType, "CommissionRefundReversal", StringComparison.OrdinalIgnoreCase) &&
                !string.Equals(t.DocumentType, "Reversal", StringComparison.OrdinalIgnoreCase))
            .ToList();

        if (!sourceCommissionTransactions.Any())
        {
            return;
        }

        // Calculate the base commission from entries that actually charged the customer.
        // احتساب العمولة الأساسية من القيود التي حمّلت العميل بالعمولة فعلاً.
        var commissionChargeTransactions = sourceCommissionTransactions
            .Where(t => t.DebitAccountId == customerAccount.Id)
            .ToList();
        if (!commissionChargeTransactions.Any())
        {
            return;
        }

        var totalCommissionCharged = Math.Round(commissionChargeTransactions.Sum(t => t.Amount), 2);
        if (totalCommissionCharged <= 0m)
        {
            return;
        }

        var existingCommissionReversals = bookingTransactions
            .Where(t =>
                t.TransactionType == TransactionType.PlatformCommission &&
                t.Amount > 0m &&
                string.Equals(t.DocumentType, "CommissionRefundReversal", StringComparison.OrdinalIgnoreCase))
            .ToList();

        var totalCommissionAlreadyReversed = Math.Round(existingCommissionReversals.Sum(t => t.Amount), 2);
        var totalRefundedAmount = bookingTransactions
            .Where(t =>
                t.TransactionType == TransactionType.Refund &&
                t.Amount > 0m &&
                !t.IsReversed)
            .Sum(t => t.Amount);
        var cumulativeRefundRatio = Math.Min(1m, Math.Max(0m, totalRefundedAmount / booking.TotalPrice.Amount));
        var targetReversedCommission = Math.Round(totalCommissionCharged * cumulativeRefundRatio, 2);
        var commissionToReverse = Math.Round(targetReversedCommission - totalCommissionAlreadyReversed, 2);
        if (commissionToReverse <= 0m)
        {
            return;
        }

        var netByAccount = new Dictionary<Guid, decimal>();
        static void AddToNet(IDictionary<Guid, decimal> map, Guid accountId, decimal delta)
        {
            if (accountId == Guid.Empty)
            {
                return;
            }

            map.TryGetValue(accountId, out var currentValue);
            map[accountId] = currentValue + delta;
        }

        foreach (var tx in sourceCommissionTransactions)
        {
            AddToNet(netByAccount, tx.CreditAccountId, tx.Amount);
            AddToNet(netByAccount, tx.DebitAccountId, -tx.Amount);
        }

        foreach (var reversal in existingCommissionReversals)
        {
            AddToNet(netByAccount, reversal.DebitAccountId, -reversal.Amount);
            AddToNet(netByAccount, reversal.CreditAccountId, reversal.Amount);
        }

        var availableBuckets = netByAccount
            .Where(x => x.Key != customerAccount.Id && x.Value > 0m)
            .Select(x => new
            {
                AccountId = x.Key,
                AvailableAmount = Math.Round(x.Value, 2)
            })
            .OrderByDescending(x => x.AvailableAmount)
            .ToList();

        var totalAvailable = availableBuckets.Sum(x => x.AvailableAmount);
        if (totalAvailable <= 0m)
        {
            return;
        }

        commissionToReverse = Math.Min(commissionToReverse, Math.Round(totalAvailable, 2));
        if (commissionToReverse <= 0m)
        {
            return;
        }

        var remainingToAllocate = commissionToReverse;
        for (var i = 0; i < availableBuckets.Count && remainingToAllocate > 0m; i++)
        {
            var bucket = availableBuckets[i];
            var isLastBucket = i == availableBuckets.Count - 1;

            var allocatedAmount = isLastBucket
                ? remainingToAllocate
                : Math.Round(commissionToReverse * (bucket.AvailableAmount / totalAvailable), 2);

            allocatedAmount = Math.Min(allocatedAmount, bucket.AvailableAmount);
            allocatedAmount = Math.Min(allocatedAmount, remainingToAllocate);
            if (allocatedAmount <= 0m)
            {
                continue;
            }

            var reversalTransaction = new FinancialTransaction
            {
                TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                TransactionDate = DateTime.UtcNow,
                EntryType = JournalEntryType.Reversal,
                TransactionType = TransactionType.PlatformCommission,
                DebitAccountId = bucket.AccountId,
                CreditAccountId = customerAccount.Id,
                Amount = allocatedAmount,
                Currency = booking.TotalPrice.Currency,
                ExchangeRate = 1,
                BaseAmount = allocatedAmount,
                Description = $"عكس عمولة المنصة لاسترداد الحجز {booking.Id}",
                Narration = $"عكس عمولة متناسبة مع الاسترداد. السبب: {reason}",
                ReferenceNumber = booking.Id.ToString(),
                DocumentType = "CommissionRefundReversal",
                BookingId = booking.Id,
                FirstPartyUserId = booking.UserId,
                SecondPartyUserId = property.OwnerId,
                PropertyId = property.Id,
                UnitId = unit.Id,
                Status = TransactionStatus.Posted,
                IsPosted = true,
                PostingDate = DateTime.UtcNow,
                FiscalYear = DateTime.UtcNow.Year,
                FiscalPeriod = DateTime.UtcNow.Month,
                Commission = allocatedAmount,
                CommissionPercentage = Math.Round((allocatedAmount / booking.TotalPrice.Amount) * 100m, 2),
                CreatedBy = userId,
                CreatedAt = DateTime.UtcNow,
                IsAutomatic = true,
                AutomaticSource = "RefundSystem"
            };

            await _transactionRepository.AddAsync(reversalTransaction);
            remainingToAllocate = Math.Round(remainingToAllocate - allocatedAmount, 2);
        }

        if (remainingToAllocate > 0m)
        {
            _logger.LogWarning(
                "تعذر عكس كامل عمولة الحجز {BookingId}. المتبقي غير المعكوس: {RemainingAmount}",
                booking.Id,
                remainingToAllocate);
        }
    }

    // Helper methods.
    // الدوال المساعدة.

    /// <summary>
    /// Gets or creates the customer receivables account.
    /// يحصل على حساب ذمم العميل أو ينشئه عند الحاجة.
    /// </summary>
    private async Task<ChartOfAccount> GetOrCreateCustomerAccountAsync(Guid customerId, string customerName)
    {

        var accountName = $"ذمم مدينة - عميل #{customerId}";
        var account = await _accountRepository.GetUserAccountAsync(customerId, AccountType.Assets);
        if (account == null)
        {
            var accountNumber = await _accountRepository.GenerateAccountNumberAsync(AccountType.Assets, true);
            account = new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = accountNumber,
                NameAr = accountName,
                NameEn = $"Accounts Receivable - Customer #{customerName}",
                AccountType = AccountType.Assets,
                Category = AccountCategory.Sub,
                NormalBalance = AccountNature.Debit,
                IsActive = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow,
                Description = $"حساب ذمم مدينة للعميل {customerName}",
                UserId = customerId // Link the account to the customer.
            };
            await _accountRepository.CreateAsync(account);
        }
        return account;
    }

    /// <summary>
    /// Gets or creates the owner payables account.
    /// يحصل على حساب ذمم المالك أو ينشئه عند الحاجة.
    /// </summary>
    private async Task<ChartOfAccount> GetOrCreateOwnerPayableAccountAsync(Guid ownerId, string ownerName)
    {
        var accountName = $"ذمم دائنة - مالك #{ownerId}";
        var account = await _accountRepository.GetUserAccountAsync(ownerId, AccountType.Liabilities);
        if (account == null)
        {
            var accountNumber = await _accountRepository.GenerateAccountNumberAsync(AccountType.Liabilities, true);

            account = new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = accountNumber,
                NameAr = accountName,
                NameEn = $"Accounts Payable - Owner #{ownerName}",
                AccountType = AccountType.Liabilities,
                Category = AccountCategory.Sub,
                NormalBalance = AccountNature.Credit,
                IsActive = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow,
                Description = $"حساب ذمم دائنة للمالك {ownerName}",
                UserId = ownerId // Link the account to the owner.
            };
            await _accountRepository.CreateAsync(account);
        }
        return account;
    }

    /// <summary>
    /// Gets or creates the owner's commission payable account.
    /// يحصل على حساب العمولات المستحقة للمالك أو ينشئه عند الحاجة.
    /// </summary>
    private async Task<ChartOfAccount> GetOrCreateOwnerCommissionAccountAsync(Guid ownerId, string ownerName)
    {
        var accountName = $"عمولات مستحقة - مالك #{ownerId}";
        // Look up the owner's commission payable account.
        // البحث عن حساب العمولات المستحقة للمالك.
        var accounts = await _accountRepository.GetAccountListAsync();
        var account = accounts.FirstOrDefault(a => 
            a.NameAr == accountName || 
            (a.Description != null && a.Description.Contains($"عمولات مستحقة للمالك {ownerId}")));
        
        if (account == null)
        {
            // Generate a readable account number instead of using a GUID.
            // توليد رقم حساب مقروء بدلًا من استخدام GUID.
            var accountNumber = await _accountRepository.GenerateAccountNumberAsync(AccountType.Liabilities, true);
            
            account = new ChartOfAccount
            {
                Id = Guid.NewGuid(),
                AccountNumber = accountNumber,
                NameAr = accountName,
                NameEn = $"Commission Payable - Owner #{ownerName}",
                AccountType = AccountType.Liabilities,
                Category = AccountCategory.Sub,
                NormalBalance = AccountNature.Credit,
                IsActive = true,
                CanPost = true,
                CreatedAt = DateTime.UtcNow,
                Description = $"حساب عمولات مستحقة للمالك {ownerName}",
                UserId = ownerId
            };
            await _accountRepository.CreateAsync(account);
        }
        return account;
    }

    /// <summary>
    /// Legacy helper kept for backward compatibility.
    /// دالة قديمة محفوظة للتوافق مع الإصدارات السابقة.
    /// </summary>
    [Obsolete("استخدم GetOrCreateCustomerAccountAsync أو GetOrCreateOwnerPayableAccountAsync")]
    private async Task<ChartOfAccount> GetOrCreateUserAccountAsync(Guid userId, string userName, AccountType accountType)
    {
        if (accountType == AccountType.Assets)
        {
            return await GetOrCreateCustomerAccountAsync(userId, userName);
        }
        else if (accountType == AccountType.Liabilities)
        {
            return await GetOrCreateOwnerPayableAccountAsync(userId, userName);
        }
        throw new InvalidOperationException($"نوع الحساب غير مدعوم: {accountType}");
    }

    /// <summary>
    /// دالة GetOrCreatePropertyAccountAsync.
    /// GetOrCreatePropertyAccountAsync method.
    /// </summary>
    private async Task<ChartOfAccount> GetOrCreatePropertyAccountAsync(Guid propertyId, string propertyName, AccountType accountType)
    {
        var account = await _accountRepository.GetPropertyAccountAsync(propertyId, accountType);
        if (account == null)
        {
            account = await _accountRepository.CreatePropertyAccountAsync(propertyId, propertyName, accountType);
            await SaveChangesAsync();
        }
        return account;
    }



    /// <summary>
    /// Gets a financial report for a period.
    /// يحصل على تقرير مالي لفترة محددة.
    /// </summary>
    public async Task<FinancialReportDto> GetFinancialReportAsync(DateTime startDate, DateTime endDate)
    {
        // Use aggregate counts instead of materializing all entries.
        // استخدام العدّ التجميعي بدلًا من جلب جميع القيود إلى الذاكرة.
        var transactionCount = await _transactionRepository.CountByPeriodAsync(startDate, endDate, null, null);
        var summary = await _transactionRepository.GetTransactionSummaryByTypeAsync(startDate, endDate);

        var report = new FinancialReportDto
        {
            StartDate = startDate,
            EndDate = endDate,
            TotalRevenue = summary.Where(s => IsRevenueType(s.Key)).Sum(s => s.Value),
            TotalExpenses = summary.Where(s => IsExpenseType(s.Key)).Sum(s => s.Value),
            TotalCommissions = summary.GetValueOrDefault(TransactionType.PlatformCommission, 0),
            TotalRefunds = summary.GetValueOrDefault(TransactionType.Refund, 0),
            TransactionCount = transactionCount,
            TransactionsByType = summary,
            NetProfit = 0 // Calculated later. / سيُحسب لاحقًا.
        };

        report.NetProfit = report.TotalRevenue - report.TotalExpenses - report.TotalRefunds;

        return report;
    }

    /// <summary>
    /// دالة IsRevenueType.
    /// IsRevenueType method.
    /// </summary>
    private bool IsRevenueType(TransactionType type)
    {
        return type == TransactionType.NewBooking || 
               type == TransactionType.FinalPayment || 
               type == TransactionType.PlatformCommission ||
               type == TransactionType.ServiceFee ||
               type == TransactionType.LateFee ||
               type == TransactionType.OtherIncome;
    }

    /// <summary>
    /// دالة IsExpenseType.
    /// IsExpenseType method.
    /// </summary>
    private bool IsExpenseType(TransactionType type)
    {
        return type == TransactionType.OwnerPayout || 
               type == TransactionType.OperationalExpense ||
               type == TransactionType.AgentCommission;
    }


    /// <summary>
    /// Creates the customer financial account.
    /// ينشئ الحساب المالي للعميل.
    /// </summary>
    public async Task<bool> CreateCustomerFinancialAccountAsync(Guid customerId, string customerName, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء إنشاء الحساب المالي للعميل {CustomerId} - {CustomerName}", customerId, customerName);

            // Create a single receivables account for the customer.
            // إنشاء حساب واحد فقط للذمم المدينة الخاصة بالعميل.
            var receivableAccount = await GetOrCreateCustomerAccountAsync(customerId, customerName);
            if (receivableAccount == null)
            {
                _logger.LogError("فشل إنشاء حساب الذمم المدينة للعميل {CustomerId}", customerId);
                return false;
            }

            await SaveChangesAsync();
            _logger.LogInformation("تم إنشاء الحساب المالي بنجاح للعميل {CustomerId}", customerId);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في إنشاء الحساب المالي للعميل {CustomerId}", customerId);
            throw;
        }
    }

    /// <summary>
    /// Creates the owner financial accounts.
    /// ينشئ الحسابات المالية للمالك.
    /// </summary>
    public async Task<bool> CreateOwnerFinancialAccountsAsync(Guid ownerId, string ownerName, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء إنشاء الحسابات المالية للمالك {OwnerId} - {OwnerName}", ownerId, ownerName);

            // Create two owner accounts:
            // إنشاء حسابين للمالك:
            // 1. Payables account for the owner.
            // 1. حساب ذمم دائنة للمالك.
            var payableAccount = await GetOrCreateOwnerPayableAccountAsync(ownerId, ownerName);
            if (payableAccount == null)
            {
                _logger.LogError("فشل إنشاء حساب الذمم الدائنة للمالك {OwnerId}", ownerId);
                return false;
            }

            // 2. Commission payable account for the owner.
            // 2. حساب عمولات مستحقة للمالك.
            var commissionAccount = await GetOrCreateOwnerCommissionAccountAsync(ownerId, ownerName);
            if (commissionAccount == null)
            {
                _logger.LogError("فشل إنشاء حساب العمولات المستحقة للمالك {OwnerId}", ownerId);
                return false;
            }

            await SaveChangesAsync();
            _logger.LogInformation("تم إنشاء الحسابات المالية بنجاح للمالك {OwnerId}", ownerId);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في إنشاء الحسابات المالية للمالك {OwnerId}", ownerId);
            throw;
        }
    }

    /// <summary>
    /// Legacy compatibility wrapper for older callers.
    /// غلاف توافق قديم للجهات المستدعية القديمة.
    /// </summary>
    [Obsolete("استخدم CreateCustomerFinancialAccountAsync للعملاء أو CreateOwnerFinancialAccountsAsync للملاك")]
    public async Task<bool> CreateUserFinancialAccountsAsync(Guid userId, string userName, CancellationToken cancellationToken)
    {
        _logger.LogWarning("استخدام دالة قديمة CreateUserFinancialAccountsAsync - يجب التحديث");
        // For backward compatibility, create the customer account only.
        // للتوافق مع الإصدارات القديمة، ننشئ حساب العميل فقط.
        return await CreateCustomerFinancialAccountAsync(userId, userName, cancellationToken);
    }

    /// <summary>
    /// Checks whether the user has financial transactions.
    /// يتحقق من وجود عمليات مالية للمستخدم.
    /// </summary>
    public async Task<bool> HasFinancialTransactionsAsync(Guid userId)
    {
        try
        {
            var transactions = await _transactionRepository.GetByUserIdAsync(userId);
            return transactions.Any();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في التحقق من العمليات المالية للمستخدم {UserId}", userId);
            return false;
        }
    }

    /// <summary>
    /// Records a booking cancellation transaction.
    /// يسجل قيد إلغاء الحجز.
    /// </summary>
    public async Task<FinancialTransaction> RecordCancellationTransactionAsync(Guid bookingId, Guid userId)
    {
        try
        {
            var booking = await _bookingRepository.GetByIdAsync(bookingId);
            if (booking == null)
                throw new ArgumentException($"BookingDto {bookingId} not found");

            var transaction = new FinancialTransaction
            {
                TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                TransactionDate = DateTime.UtcNow,
                EntryType = JournalEntryType.GeneralJournal,
                TransactionType = TransactionType.BookingCancellation,
                Amount = booking.TotalPrice.Amount,
                Currency = booking.TotalPrice.Currency,
                Description = $"إلغاء الحجز رقم {booking.Id}",
                ReferenceNumber = booking.Id.ToString(),
                BookingId = bookingId,
                Status = TransactionStatus.Draft,
                CreatedBy = userId,
                CreatedAt = DateTime.UtcNow
            };

            await _transactionRepository.AddAsync(transaction);
            await SaveChangesAsync();
            return transaction;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error recording cancellation for booking {bookingId}");
            throw;
        }
    }

    /// <summary>
    /// Records a refund transaction.
    /// يسجل عملية استرداد مبلغ.
    /// </summary>
    public async Task<FinancialTransaction> RecordRefundTransactionAsync(Guid bookingId, decimal refundAmount, Guid userId)
    {
        return await RecordRefundTransactionAsync(bookingId, refundAmount, "استرداد", userId);
    }

    /// <summary>
    /// Records an owner payout transaction.
    /// يسجل عملية دفعة للمالك.
    /// </summary>
    public async Task<FinancialTransaction> RecordOwnerPayoutAsync(Guid propertyId, decimal amount, Guid userId)
    {
        try
        {
            var property = await _propertyRepository.GetByIdAsync(propertyId);
            if (property == null)
                throw new ArgumentException($"Property {propertyId} not found");

            var transaction = new FinancialTransaction
            {
                TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                TransactionDate = DateTime.UtcNow,
                EntryType = JournalEntryType.CashPayments,
                TransactionType = TransactionType.OwnerPayout,
                Amount = amount,
                Currency = "YER",
                Description = $"دفعة للمالك - العقار {property.Name}",
                PropertyId = propertyId,
                Status = TransactionStatus.Draft,
                CreatedBy = userId,
                CreatedAt = DateTime.UtcNow
            };

            await _transactionRepository.AddAsync(transaction);
            await SaveChangesAsync();
            return transaction;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error recording owner payout for property {propertyId}");
            throw;
        }
    }

    /// <summary>
    /// Records an expense transaction.
    /// يسجل مصروفًا.
    /// </summary>
    public async Task<FinancialTransaction> RecordExpenseAsync(string description, decimal amount, AccountType accountType, Guid userId)
    {
        try
        {
            var transaction = new FinancialTransaction
            {
                TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                TransactionDate = DateTime.UtcNow,
                EntryType = JournalEntryType.GeneralJournal,
                TransactionType = TransactionType.OperationalExpense,
                Amount = amount,
                Currency = "YER",
                Description = description,
                Status = TransactionStatus.Draft,
                CreatedBy = userId,
                CreatedAt = DateTime.UtcNow
            };

            await _transactionRepository.AddAsync(transaction);
            await SaveChangesAsync();
            return transaction;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error recording expense: {description}");
            throw;
        }
    }

    /// <summary>
    /// Gets revenue chart data.
    /// يحصل على بيانات مخطط الإيرادات.
    /// </summary>
    public async Task<List<FinancialChartDto>> GetRevenueChartDataAsync(DateTime startDate, DateTime endDate)
    {
        try
        {
            // Use an aggregated summary from the database instead of loading all entries.
            // استخدام ملخص مجمّع من قاعدة البيانات بدلاً من تحميل كل القيود.
            var summary = await _transactionRepository.GetTransactionSummaryByTypeAsync(startDate, endDate);

            var revenueTypes = new[]
            {
                TransactionType.NewBooking,
                TransactionType.AdvancePayment,
                TransactionType.FinalPayment,
                TransactionType.PlatformCommission,
                TransactionType.ServiceFee,
                TransactionType.LateFee,
                TransactionType.OtherIncome
            };

            var revenueByType = revenueTypes
                .Select(t => new { Type = t, Value = summary.GetValueOrDefault(t, 0m) })
                .Where(x => x.Value > 0)
                .Select(x => new FinancialChartDto
                {
                    Label = GetTransactionTypeLabel(x.Type),
                    Value = x.Value,
                    Color = GetRevenueColor(x.Type),
                    Category = "Revenue"
                })
                .OrderByDescending(x => x.Value)
                .ToList();

            return revenueByType;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في الحصول على بيانات مخطط الإيرادات");
            throw;
        }
    }

    /// <summary>
    /// Gets expense chart data.
    /// يحصل على بيانات مخطط المصروفات.
    /// </summary>
    public async Task<List<FinancialChartDto>> GetExpenseChartDataAsync(DateTime startDate, DateTime endDate)
    {
        try
        {
            // Use an aggregated summary from the database instead of loading all entries.
            // استخدام ملخص مجمّع من قاعدة البيانات بدلاً من تحميل كل القيود.
            var summary = await _transactionRepository.GetTransactionSummaryByTypeAsync(startDate, endDate);

            var expenseTypes = new[]
            {
                TransactionType.OwnerPayout,
                TransactionType.Refund,
                TransactionType.OperationalExpense,
                TransactionType.Tax,
                TransactionType.AgentCommission,
                TransactionType.SecurityDepositRefund,
                TransactionType.Compensation
            };

            var expenseByType = expenseTypes
                .Select(t => new { Type = t, Value = summary.GetValueOrDefault(t, 0m) })
                .Where(x => x.Value > 0)
                .Select(x => new FinancialChartDto
                {
                    Label = GetTransactionTypeLabel(x.Type),
                    Value = x.Value,
                    Color = GetExpenseColor(x.Type),
                    Category = "Expense"
                })
                .OrderByDescending(x => x.Value)
                .ToList();

            return expenseByType;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في الحصول على بيانات مخطط المصروفات");
            throw;
        }
    }

    /// <summary>
    /// Gets cash flow chart data.
    /// يحصل على بيانات التدفق النقدي.
    /// </summary>
    public async Task<List<FinancialChartDto>> GetCashFlowChartDataAsync(DateTime startDate, DateTime endDate)
    {
        try
        {
            // Reduce retrieved data by pushing status filtering into the database.
            // تقليل البيانات المسترجعة بدفع فلترة الحالة إلى قاعدة البيانات.
            var transactions = await _transactionRepository.GetByPeriodAsync(
                startDate,
                endDate,
                TransactionStatus.Posted,
                null,
                null);
            
            // Group by month.
            // تجميع حسب الشهر.
            var cashFlowByMonth = transactions
                .GroupBy(t => new { t.TransactionDate.Year, t.TransactionDate.Month })
                .Select(g =>
                {
                    var monthDate = new DateTime(g.Key.Year, g.Key.Month, 1, 0, 0, 0, DateTimeKind.Utc);
                    var revenues = g.Where(t => IsRevenueTransaction(t.TransactionType)).Sum(t => t.Amount);
                    var expenses = g.Where(t => IsExpenseTransaction(t.TransactionType)).Sum(t => t.Amount);
                    
                    return new FinancialChartDto
                    {
                        Label = GetMonthNameInArabic(g.Key.Month) + " " + g.Key.Year,
                        Value = revenues - expenses,
                        Date = monthDate,
                        Color = (revenues - expenses) >= 0 ? "#00FF88" : "#FF3366",
                        Category = "CashFlow"
                    };
                })
                .OrderBy(x => x.Date)
                .ToList();

            return cashFlowByMonth;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في الحصول على بيانات التدفق النقدي");
            throw;
        }
    }

    /// <summary>
    /// Gets a comprehensive financial summary.
    /// يحصل على ملخص مالي شامل.
    /// </summary>
    public async Task<FinancialSummaryDto> GetFinancialSummaryAsync()
    {
        try
        {
            var now = DateTime.UtcNow;
            var startOfMonth = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);
            var endOfMonth = startOfMonth.AddMonths(1).AddDays(-1);

            // Load all required data.
            // جلب جميع البيانات المطلوبة.
            var allAccounts = await _accountRepository.GetAccountsTreeAsync();
            var monthTransactions = await _transactionRepository.GetByPeriodAsync(startOfMonth, endOfMonth);
            var allTransactions = await _transactionRepository.GetByPeriodAsync(
                DateTime.UtcNow.AddYears(-1), DateTime.UtcNow);
            var allBookings = await _bookingRepository.GetAllAsync();
            var bookings = allBookings.Where(b => 
                b.CreatedAt >= startOfMonth && b.CreatedAt <= endOfMonth).ToList();
            var properties = await _propertyRepository.GetAllAsync();
            var units = await _unitRepository.GetAllAsync();

            // Calculate assets and liabilities.
            // حساب الأصول والخصوم.
            var totalAssets = await CalculateTotalByAccountTypeAsync(AccountType.Assets);
            var totalLiabilities = await CalculateTotalByAccountTypeAsync(AccountType.Liabilities);
            var totalEquity = await CalculateTotalByAccountTypeAsync(AccountType.Equity);
            
            // Calculate current assets and liabilities.
            // حساب الأصول والخصوم المتداولة.
            var currentAssets = await CalculateCurrentAssetsAsync();
            var currentLiabilities = await CalculateCurrentLiabilitiesAsync();
            var workingCapital = currentAssets - currentLiabilities;

            // Calculate liquidity ratios.
            // حساب نسب السيولة.
            var currentRatio = currentLiabilities > 0 ? currentAssets / currentLiabilities : 0;
            var quickRatio = currentLiabilities > 0 ? (currentAssets - 0) / currentLiabilities : 0; // Inventory is not tracked here yet. / لا يتم تتبع المخزون هنا بعد.
            var cashRatio = currentLiabilities > 0 ? await GetCashBalanceAsync() / currentLiabilities : 0;

            // Calculate leverage ratios.
            // حساب نسب الديون.
            var debtToEquityRatio = totalEquity > 0 ? totalLiabilities / totalEquity : 0;
            var debtToAssetsRatio = totalAssets > 0 ? totalLiabilities / totalAssets : 0;

            // Calculate monthly revenue and expenses.
            // حساب الإيرادات والمصروفات للشهر.
            var monthRevenue = monthTransactions.Where(t => IsRevenueTransaction(t.TransactionType)).Sum(t => t.Amount);
            var monthExpenses = monthTransactions.Where(t => IsExpenseTransaction(t.TransactionType)).Sum(t => t.Amount);
            var monthProfit = monthRevenue - monthExpenses;

            // Calculate profitability ratios.
            // حساب نسب الربحية.
            var returnOnAssets = totalAssets > 0 ? (monthProfit * 12) / totalAssets * 100 : 0; // Annualized. / محسوب على أساس سنوي.
            var returnOnEquity = totalEquity > 0 ? (monthProfit * 12) / totalEquity * 100 : 0; // Annualized. / محسوب على أساس سنوي.
            var grossProfitMargin = monthRevenue > 0 ? monthProfit / monthRevenue * 100 : 0;
            var netProfitMargin = monthRevenue > 0 ? monthProfit / monthRevenue * 100 : 0;
            var operatingProfitMargin = monthRevenue > 0 ? (monthProfit + 0) / monthRevenue * 100 : 0; // Operating expenses are not isolated yet. / لا يتم فصل المصروفات التشغيلية هنا بعد.

            // Calculate cash flow.
            // حساب التدفقات النقدية.
            var cashFromOperations = monthTransactions.Where(t => 
                t.TransactionType != TransactionType.InterAccountTransfer).Sum(t =>
                IsRevenueTransaction(t.TransactionType) ? t.Amount : -t.Amount);
            
            // Calculate occupancy rate.
            // حساب معدل الإشغال.
            var occupiedUnits = bookings.Select(b => b.UnitId).Distinct().Count();
            var totalUnitsCount = units.Count();
            var occupancyRate = totalUnitsCount > 0 ? (decimal)occupiedUnits / totalUnitsCount * 100 : 0;

            // Calculate average booking value.
            // حساب متوسط قيمة الحجز.
            var averageBookingValue = bookings.Any() ? bookings.Average(b => b.TotalPrice.Amount) : 0;

            return new FinancialSummaryDto
            {
                // Assets and liabilities.
                // الأصول والخصوم.
                TotalAssets = totalAssets,
                TotalLiabilities = totalLiabilities,
                TotalEquity = totalEquity,
                CurrentAssets = currentAssets,
                CurrentLiabilities = currentLiabilities,
                WorkingCapital = workingCapital,
                
                // Liquidity ratios.
                // نسب السيولة.
                CurrentRatio = currentRatio,
                QuickRatio = quickRatio,
                CashRatio = cashRatio,
                
                // Leverage ratios.
                // نسب الديون.
                DebtToEquityRatio = debtToEquityRatio,
                DebtToAssetsRatio = debtToAssetsRatio,
                
                // Profitability ratios.
                // نسب الربحية.
                ReturnOnAssets = returnOnAssets,
                ReturnOnEquity = returnOnEquity,
                GrossProfitMargin = grossProfitMargin,
                NetProfitMargin = netProfitMargin,
                OperatingProfitMargin = operatingProfitMargin,
                
                // Cash flow.
                // التدفق النقدي.
                CashFromOperations = cashFromOperations,
                CashFromInvesting = 0, // Can be calculated later. / يمكن حسابها لاحقاً.
                CashFromFinancing = 0, // Can be calculated later. / يمكن حسابها لاحقاً.
                NetCashFlow = cashFromOperations,
                
                // Additional metrics.
                // مؤشرات إضافية.
                ActiveBookings = bookings.Count(),
                TotalProperties = properties.Count(),
                TotalUnits = totalUnitsCount,
                OccupancyRate = occupancyRate,
                AverageBookingValue = averageBookingValue,
                CustomerAcquisitionCost = 0, // Can be calculated later. / يمكن حسابها لاحقاً.
                CustomerLifetimeValue = 0, // Can be calculated later. / يمكن حسابها لاحقاً.
                
                // Timestamps.
                // التاريخ.
                CalculatedAt = DateTime.UtcNow,
                PeriodStart = startOfMonth,
                PeriodEnd = endOfMonth
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في الحصول على الملخص المالي");
            throw;
        }
    }

    // Helper methods. / الدوال المساعدة.
    /// <summary>
    /// دالة IsRevenueTransaction.
    /// IsRevenueTransaction method.
    /// </summary>
    private bool IsRevenueTransaction(TransactionType type)
    {
        return type == TransactionType.NewBooking ||
               type == TransactionType.AdvancePayment ||
               type == TransactionType.FinalPayment ||
               type == TransactionType.PlatformCommission ||
               type == TransactionType.ServiceFee ||
               type == TransactionType.LateFee ||
               type == TransactionType.OtherIncome;
    }

    /// <summary>
    /// دالة IsExpenseTransaction.
    /// IsExpenseTransaction method.
    /// </summary>
    private bool IsExpenseTransaction(TransactionType type)
    {
        return type == TransactionType.OwnerPayout ||
               type == TransactionType.Refund ||
               type == TransactionType.OperationalExpense ||
               type == TransactionType.Tax ||
               type == TransactionType.AgentCommission ||
               type == TransactionType.SecurityDepositRefund ||
               type == TransactionType.Compensation;
    }

    /// <summary>
    /// دالة GetTransactionTypeLabel.
    /// GetTransactionTypeLabel method.
    /// </summary>
    private string GetTransactionTypeLabel(TransactionType type)
    {
        return type switch
        {
            TransactionType.NewBooking => "حجوزات جديدة",
            TransactionType.AdvancePayment => "دفعات مقدمة",
            TransactionType.FinalPayment => "دفعات نهائية",
            TransactionType.PlatformCommission => "عمولات المنصة",
            TransactionType.ServiceFee => "رسوم خدمات",
            TransactionType.LateFee => "غرامات تأخير",
            TransactionType.OtherIncome => "إيرادات أخرى",
            TransactionType.OwnerPayout => "دفعات للملاك",
            TransactionType.Refund => "مستردات",
            TransactionType.OperationalExpense => "مصاريف تشغيلية",
            TransactionType.Tax => "ضرائب",
            TransactionType.AgentCommission => "عمولات وكلاء",
            TransactionType.SecurityDepositRefund => "استرداد تأمينات",
            TransactionType.Compensation => "تعويضات",
            _ => type.ToString()
        };
    }

    /// <summary>
    /// دالة GetRevenueColor.
    /// GetRevenueColor method.
    /// </summary>
    private string GetRevenueColor(TransactionType type)
    {
        return type switch
        {
            TransactionType.NewBooking => "#00FF88",
            TransactionType.AdvancePayment => "#4FACFE",
            TransactionType.FinalPayment => "#00D9FF",
            TransactionType.PlatformCommission => "#9D50FF",
            TransactionType.ServiceFee => "#FFB800",
            TransactionType.LateFee => "#FF9500",
            TransactionType.OtherIncome => "#8B95B7",
            _ => "#00FF88"
        };
    }

    /// <summary>
    /// دالة GetExpenseColor.
    /// GetExpenseColor method.
    /// </summary>
    private string GetExpenseColor(TransactionType type)
    {
        return type switch
        {
            TransactionType.OwnerPayout => "#FF3366",
            TransactionType.Refund => "#FF6B6B",
            TransactionType.OperationalExpense => "#FFB800",
            TransactionType.Tax => "#8B95B7",
            TransactionType.AgentCommission => "#A855F7",
            TransactionType.SecurityDepositRefund => "#F97316",
            TransactionType.Compensation => "#EF4444",
            _ => "#FF3366"
        };
    }

    /// <summary>
    /// دالة GetMonthNameInArabic.
    /// GetMonthNameInArabic method.
    /// </summary>
    private string GetMonthNameInArabic(int month)
    {
        return month switch
        {
            1 => "يناير",
            2 => "فبراير",
            3 => "مارس",
            4 => "أبريل",
            5 => "مايو",
            6 => "يونيو",
            7 => "يوليو",
            8 => "أغسطس",
            9 => "سبتمبر",
            10 => "أكتوبر",
            11 => "نوفمبر",
            12 => "ديسمبر",
            _ => ""
        };
    }

    /// <summary>
    /// دالة CalculateTotalByAccountTypeAsync.
    /// CalculateTotalByAccountTypeAsync method.
    /// </summary>
    private async Task<decimal> CalculateTotalByAccountTypeAsync(AccountType accountType)
    {
        var accounts = await _accountRepository.GetByAccountTypeAsync(accountType);
        decimal total = 0;
        
        foreach (var account in accounts)
        {
            var balance = await _transactionRepository.GetAccountBalanceAtDateAsync(account.Id, DateTime.UtcNow);
            total += balance;
        }
        
        return total;
    }

    /// <summary>
    /// دالة CalculateCurrentAssetsAsync.
    /// CalculateCurrentAssetsAsync method.
    /// </summary>
    private async Task<decimal> CalculateCurrentAssetsAsync()
    {
        // Calculate current assets (cash + receivables + ...).
        // حساب الأصول المتداولة (النقد + الذمم المدينة + ...).
        var cashAccounts = await _accountRepository.GetSystemAccountAsync(SYSTEM_CASH_ACCOUNT);
        var bankAccounts = await _accountRepository.GetSystemAccountAsync(SYSTEM_BANK_ACCOUNT);
        var receivableAccounts = await _accountRepository.GetSystemAccountAsync(SYSTEM_RECEIVABLE_ACCOUNT);
        
        decimal total = 0;
        if (cashAccounts != null)
            total += await _transactionRepository.GetAccountBalanceAtDateAsync(cashAccounts.Id, DateTime.UtcNow);
        if (bankAccounts != null)
            total += await _transactionRepository.GetAccountBalanceAtDateAsync(bankAccounts.Id, DateTime.UtcNow);
        if (receivableAccounts != null)
            total += await _transactionRepository.GetAccountBalanceAtDateAsync(receivableAccounts.Id, DateTime.UtcNow);
            
        return total;
    }

    /// <summary>
    /// دالة CalculateCurrentLiabilitiesAsync.
    /// CalculateCurrentLiabilitiesAsync method.
    /// </summary>
    private async Task<decimal> CalculateCurrentLiabilitiesAsync()
    {
        // Calculate current liabilities.
        // حساب الخصوم المتداولة.
        var payableAccounts = await _accountRepository.GetSystemAccountAsync(SYSTEM_PAYABLE_ACCOUNT);
        var taxAccounts = await _accountRepository.GetSystemAccountAsync(SYSTEM_TAX_ACCOUNT);
        
        decimal total = 0;
        if (payableAccounts != null)
            total += await _transactionRepository.GetAccountBalanceAtDateAsync(payableAccounts.Id, DateTime.UtcNow);
        if (taxAccounts != null)
            total += await _transactionRepository.GetAccountBalanceAtDateAsync(taxAccounts.Id, DateTime.UtcNow);
            
        return total;
    }

    /// <summary>
    /// دالة GetCashBalanceAsync.
    /// GetCashBalanceAsync method.
    /// </summary>
    private async Task<decimal> GetCashBalanceAsync()
    {
        var cashAccounts = await _accountRepository.GetSystemAccountAsync(SYSTEM_CASH_ACCOUNT);
        var bankAccounts = await _accountRepository.GetSystemAccountAsync(SYSTEM_BANK_ACCOUNT);
        
        decimal total = 0;
        if (cashAccounts != null)
            total += await _transactionRepository.GetAccountBalanceAtDateAsync(cashAccounts.Id, DateTime.UtcNow);
        if (bankAccounts != null)
            total += await _transactionRepository.GetAccountBalanceAtDateAsync(bankAccounts.Id, DateTime.UtcNow);
            
        return total;
    }

    /// <summary>
    /// Records booking confirmation by recognizing commission revenue.
    /// يسجل تأكيد الحجز عبر إثبات إيراد العمولة.
    /// </summary>
    public async Task<FinancialTransaction> RecordBookingConfirmationTransactionAsync(Guid bookingId, Guid userId)
    {
        try
        {
            var booking = await _bookingRepository.GetByIdAsync(bookingId);
            if (booking == null)
                throw new ArgumentException($"BookingDto {bookingId} not found");

            var unit = await _unitRepository.GetByIdAsync(booking.UnitId);
            if (unit == null)
                throw new ArgumentException($"Unit {booking.UnitId} not found");

            var property = await _propertyRepository.GetByIdAsync(unit.PropertyId);
            if (property == null)
                throw new ArgumentException($"Property {unit.PropertyId} not found");

            // Calculate the commission using property settings first, then global defaults.
            // حساب العمولة باستخدام إعدادات العقار أولاً ثم القيم العامة الافتراضية.
            var commissionRate = await ResolveCommissionRateFractionAsync(property);
            var totalAmount = booking.TotalPrice.Amount;
            var commissionAmount = Math.Round(totalAmount * commissionRate, 2);

            // Required accounts.
            // الحسابات المطلوبة.
            var commissionPendingAccount = await _accountRepository.GetSystemAccountAsync(PLATFORM_COMMISSION_PENDING_ACCOUNT);
            var commissionRevenueAccount = await _accountRepository.GetSystemAccountAsync(SYSTEM_COMMISSION_ACCOUNT);

            // Accounting entry: recognize commission revenue.
            // القيد المحاسبي: إثبات إيراد العمولة.
            // From commission payable to commission revenue.
            // من حـ/ عمولات المنصة المستحقة إلى حـ/ إيرادات عمولات المنصة.
            var confirmationTransaction = new FinancialTransaction
            {
                TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                TransactionDate = DateTime.UtcNow,
                EntryType = JournalEntryType.GeneralJournal,
                TransactionType = TransactionType.PlatformCommission,
                DebitAccountId = commissionPendingAccount.Id,
                CreditAccountId = commissionRevenueAccount.Id,
                Amount = commissionAmount,
                Currency = booking.TotalPrice.Currency,
                ExchangeRate = 1,
                BaseAmount = commissionAmount,
                Description = $"تحقق إيراد عمولة الحجز {booking.Id}",
                Narration = $"تحقق إيراد العمولة عند تأكيد الحجز",
                ReferenceNumber = booking.Id.ToString(),
                DocumentType = "BookingConfirmation",
                BookingId = bookingId,
                Status = TransactionStatus.Posted,
                IsPosted = true,
                PostingDate = DateTime.UtcNow,
                FiscalYear = DateTime.UtcNow.Year,
                FiscalPeriod = DateTime.UtcNow.Month,
                Commission = commissionAmount,
                CommissionPercentage = commissionRate * 100,
                CreatedBy = userId,
                CreatedAt = DateTime.UtcNow,
                IsAutomatic = true,
                AutomaticSource = "BookingConfirmationSystem"
            };

            await _transactionRepository.AddAsync(confirmationTransaction);
            await SaveChangesAsync();
            
            _logger.LogInformation($"BookingDto confirmation commission transaction recorded for booking {bookingId}");
            return confirmationTransaction;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error recording booking confirmation transaction for booking {bookingId}");
            throw;
        }
    }

    /// <summary>
    /// Records checkout by releasing the owner's funds.
    /// يسجل تسجيل الخروج عبر تحرير أموال المالك.
    /// </summary>
    public async Task<FinancialTransaction> RecordCheckoutTransactionAsync(Guid bookingId, Guid userId)
    {
        try
        {
            var booking = await _bookingRepository.GetByIdAsync(bookingId);
            if (booking == null)
                throw new ArgumentException($"BookingDto {bookingId} not found");

            var unit = await _unitRepository.GetByIdAsync(booking.UnitId);
            if (unit == null)
                throw new ArgumentException($"Unit {booking.UnitId} not found");

            var property = await _propertyRepository.GetByIdAsync(unit.PropertyId);
            if (property == null)
                throw new ArgumentException($"Property {unit.PropertyId} not found");

            // Calculate the owner's share after commission.
            // حساب مبلغ المالك بعد خصم العمولة.
            var commissionRate = await ResolveCommissionRateFractionAsync(property);
            var totalAmount = booking.TotalPrice.Amount;
            var commissionAmount = Math.Round(totalAmount * commissionRate, 2);
            var ownerAmount = totalAmount - commissionAmount;

            // Required accounts.
            // الحسابات المطلوبة.
            var ownersPendingAccount = await _accountRepository.GetSystemAccountAsync(OWNERS_FUNDS_PENDING_ACCOUNT);
            var ownersPayableAccount = await GetOrCreateOwnerPayableAccountAsync(property.OwnerId, property.Owner?.Name ?? "Owner");

            // Accounting entry: release funds payable to the owner.
            // القيد المحاسبي: تحرير المبالغ المستحقة للمالك.
            // From owners pending funds to owners payable.
            // من حـ/ أموال الملاك المعلقة إلى حـ/ ذمم دائنة - ملاك.
            var checkoutTransaction = new FinancialTransaction
            {
                TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                TransactionDate = DateTime.UtcNow,
                EntryType = JournalEntryType.GeneralJournal,
                TransactionType = TransactionType.FinalPayment,
                DebitAccountId = ownersPendingAccount.Id,
                CreditAccountId = ownersPayableAccount.Id,
                Amount = ownerAmount,
                Currency = booking.TotalPrice.Currency,
                ExchangeRate = 1,
                BaseAmount = ownerAmount,
                Description = $"تحرير أموال المالك للحجز {booking.Id}",
                Narration = $"نقل المبلغ من معلق إلى مستحق الدفع للمالك عند تسجيل الخروج",
                ReferenceNumber = booking.Id.ToString(),
                DocumentType = "CheckOut",
                BookingId = bookingId,
                SecondPartyUserId = property.OwnerId,
                PropertyId = property.Id,
                Status = TransactionStatus.Posted,
                IsPosted = true,
                PostingDate = DateTime.UtcNow,
                FiscalYear = DateTime.UtcNow.Year,
                FiscalPeriod = DateTime.UtcNow.Month,
                NetAmount = ownerAmount,
                CreatedBy = userId,
                CreatedAt = DateTime.UtcNow,
                IsAutomatic = true,
                AutomaticSource = "CheckOutSystem"
            };

            await _transactionRepository.AddAsync(checkoutTransaction);
            await SaveChangesAsync();
            
            _logger.LogInformation($"Checkout transaction recorded for booking {bookingId}");
            return checkoutTransaction;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error recording checkout transaction for booking {bookingId}");
            throw;
        }
    }

    /// <summary>
    /// Records a booking cancellation with cancellation fees.
    /// يسجل إلغاء الحجز مع احتساب رسوم الإلغاء.
    /// </summary>
    public async Task<FinancialTransaction> RecordCancellationWithFeesAsync(
        Guid bookingId, 
        decimal cancellationFeePercentage, 
        Guid userId)
    {
        try
        {
            var booking = await _bookingRepository.GetByIdAsync(bookingId);
            if (booking == null)
                throw new ArgumentException($"BookingDto {bookingId} not found");

            var unit = await _unitRepository.GetByIdAsync(booking.UnitId);
            if (unit == null)
                throw new ArgumentException($"Unit {booking.UnitId} not found");

            var property = await _propertyRepository.GetByIdAsync(unit.PropertyId);
            if (property == null)
                throw new ArgumentException($"Property {unit.PropertyId} not found");

            var user = await _userRepository.GetByIdAsync(booking.UserId);
            if (user == null)
                throw new ArgumentException($"User {booking.UserId} not found");

            var totalAmount = booking.TotalPrice.Amount;
            var cancellationFee = Math.Round(totalAmount * (cancellationFeePercentage / 100m), 2);
            var refundAmount = Math.Round(totalAmount - cancellationFee, 2);

            // Split the cancellation fee using the approved commission rate.
            // توزيع رسوم الإلغاء حسب نسبة العمولة المعتمدة.
            var commissionRate = await ResolveCommissionRateFractionAsync(property);
            var platformShareFromTotal = Math.Round(totalAmount * commissionRate, 2);
            var ownerShareFromTotal = Math.Round(totalAmount - platformShareFromTotal, 2);

            // Required accounts.
            // الحسابات المطلوبة.
            var ownersPendingAccount = await _accountRepository.GetSystemAccountAsync(OWNERS_FUNDS_PENDING_ACCOUNT);
            if (ownersPendingAccount == null)
                throw new InvalidOperationException($"System account '{OWNERS_FUNDS_PENDING_ACCOUNT}' not found");

            var platformPendingAccount = await _accountRepository.GetSystemAccountAsync(PLATFORM_COMMISSION_PENDING_ACCOUNT);
            if (platformPendingAccount == null)
                throw new InvalidOperationException($"System account '{PLATFORM_COMMISSION_PENDING_ACCOUNT}' not found");

            var customerAccount = await GetOrCreateCustomerAccountAsync(booking.UserId, user.Name);
            var cancellationFeesAccount = await _accountRepository.GetSystemAccountAsync(CANCELLATION_FEES_ACCOUNT);
            if (cancellationFeesAccount == null)
                throw new InvalidOperationException($"System account '{CANCELLATION_FEES_ACCOUNT}' not found");

            FinancialTransaction? cancellationTransaction = null;

            // Entry 1: reverse the owner's share from pending funds.
            // القيد الأول: عكس حصة المالك من الأموال المعلقة.
            if (ownerShareFromTotal > 0m)
            {
                var ownerReversalTransaction = new FinancialTransaction
                {
                    TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                    TransactionDate = DateTime.UtcNow,
                    EntryType = JournalEntryType.Reversal,
                    TransactionType = TransactionType.BookingCancellation,
                    DebitAccountId = ownersPendingAccount.Id,
                    CreditAccountId = customerAccount.Id,
                    Amount = ownerShareFromTotal,
                    Currency = booking.TotalPrice.Currency,
                    ExchangeRate = 1,
                    BaseAmount = ownerShareFromTotal,
                    Description = $"عكس حصة المالك عند إلغاء الحجز {booking.Id}",
                    Narration = $"إلغاء مع رسوم {cancellationFeePercentage}% - استحقاق استرداد {refundAmount} {booking.TotalPrice.Currency}",
                    ReferenceNumber = booking.Id.ToString(),
                    DocumentType = "CancellationWithFees",
                    BookingId = bookingId,
                    FirstPartyUserId = booking.UserId,
                    SecondPartyUserId = property.OwnerId,
                    PropertyId = property.Id,
                    Status = TransactionStatus.Posted,
                    IsPosted = true,
                    PostingDate = DateTime.UtcNow,
                    FiscalYear = DateTime.UtcNow.Year,
                    FiscalPeriod = DateTime.UtcNow.Month,
                    CancellationReason = booking.CancellationReason,
                    CancelledAt = DateTime.UtcNow,
                    CancelledBy = userId,
                    CreatedBy = userId,
                    CreatedAt = DateTime.UtcNow,
                    IsAutomatic = true,
                    AutomaticSource = "CancellationSystem"
                };

                await _transactionRepository.AddAsync(ownerReversalTransaction);
                cancellationTransaction ??= ownerReversalTransaction;
            }

            // Entry 2: reverse the pending platform commission.
            // القيد الثاني: عكس عمولة المنصة المعلقة.
            if (platformShareFromTotal > 0m)
            {
                var platformReversalTransaction = new FinancialTransaction
                {
                    TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                    TransactionDate = DateTime.UtcNow,
                    EntryType = JournalEntryType.Reversal,
                    TransactionType = TransactionType.PlatformCommission,
                    DebitAccountId = platformPendingAccount.Id,
                    CreditAccountId = customerAccount.Id,
                    Amount = platformShareFromTotal,
                    Currency = booking.TotalPrice.Currency,
                    ExchangeRate = 1,
                    BaseAmount = platformShareFromTotal,
                    Description = $"عكس عمولة المنصة للحجز الملغي {booking.Id}",
                    Narration = $"عكس العمولة المعلقة عند إلغاء الحجز برسوم {cancellationFeePercentage}%",
                    ReferenceNumber = booking.Id.ToString(),
                    DocumentType = "CancellationWithFees",
                    BookingId = bookingId,
                    FirstPartyUserId = booking.UserId,
                    SecondPartyUserId = property.OwnerId,
                    PropertyId = property.Id,
                    UnitId = unit.Id,
                    Status = TransactionStatus.Posted,
                    IsPosted = true,
                    PostingDate = DateTime.UtcNow,
                    FiscalYear = DateTime.UtcNow.Year,
                    FiscalPeriod = DateTime.UtcNow.Month,
                    Commission = platformShareFromTotal,
                    CommissionPercentage = commissionRate * 100,
                    CreatedBy = userId,
                    CreatedAt = DateTime.UtcNow,
                    IsAutomatic = true,
                    AutomaticSource = "CancellationSystem"
                };

                await _transactionRepository.AddAsync(platformReversalTransaction);
                cancellationTransaction ??= platformReversalTransaction;
            }

            // Entry 3: record the cancellation fee as revenue.
            // القيد الثالث: تسجيل رسوم الإلغاء كإيراد.
            if (cancellationFee > 0)
            {
                var feeTransaction = new FinancialTransaction
                {
                    TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                    TransactionDate = DateTime.UtcNow,
                    EntryType = JournalEntryType.GeneralJournal,
                    TransactionType = TransactionType.ServiceFee,
                    DebitAccountId = customerAccount.Id,
                    CreditAccountId = cancellationFeesAccount.Id,
                    Amount = cancellationFee,
                    Currency = booking.TotalPrice.Currency,
                    ExchangeRate = 1,
                    BaseAmount = cancellationFee,
                    Description = $"رسوم إلغاء الحجز {booking.Id}",
                    Narration = $"رسوم إلغاء بنسبة {cancellationFeePercentage}%",
                    ReferenceNumber = booking.Id.ToString(),
                    DocumentType = "CancellationFee",
                    BookingId = bookingId,
                    Status = TransactionStatus.Posted,
                    IsPosted = true,
                    PostingDate = DateTime.UtcNow,
                    FiscalYear = DateTime.UtcNow.Year,
                    FiscalPeriod = DateTime.UtcNow.Month,
                    CreatedBy = userId,
                    CreatedAt = DateTime.UtcNow,
                    IsAutomatic = true,
                    AutomaticSource = "CancellationFeeSystem"
                };

                await _transactionRepository.AddAsync(feeTransaction);
            }

            if (cancellationTransaction == null)
            {
                throw new InvalidOperationException("No cancellation entries were generated");
            }

            await SaveChangesAsync();
            _logger.LogInformation($"Cancellation with fees transaction recorded for booking {bookingId}");
            return cancellationTransaction;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error recording cancellation with fees for booking {bookingId}");
            throw;
        }
    }

    /// <summary>
    /// Records an additional service transaction.
    /// يسجل قيد خدمة إضافية.
    /// </summary>
    public async Task<FinancialTransaction> RecordAdditionalServiceTransactionAsync(
        Guid bookingId,
        Guid serviceId,
        decimal serviceAmount,
        string serviceName,
        Guid userId)
    {
        try
        {
            var booking = await _bookingRepository.GetByIdAsync(bookingId);
            if (booking == null)
                throw new ArgumentException($"BookingDto {bookingId} not found");

            var unit = await _unitRepository.GetByIdAsync(booking.UnitId);
            if (unit == null)
                throw new ArgumentException($"Unit {booking.UnitId} not found");

            var property = await _propertyRepository.GetByIdAsync(unit.PropertyId);
            if (property == null)
                throw new ArgumentException($"Property {unit.PropertyId} not found");

            var user = await _userRepository.GetByIdAsync(booking.UserId);
            if (user == null)
                throw new ArgumentException($"User {booking.UserId} not found");

            // Calculate commission on the additional service.
            // حساب العمولة على الخدمة الإضافية.
            var commissionRate = await ResolveCommissionRateFractionAsync(property);
            var commissionAmount = Math.Round(serviceAmount * commissionRate, 2);
            var ownerAmount = serviceAmount - commissionAmount;

            // Required accounts.
            // الحسابات المطلوبة.
            var customerAccount = await GetOrCreateUserAccountAsync(booking.UserId, user.Name, AccountType.Assets);
            var ownersPendingAccount = await _accountRepository.GetSystemAccountAsync(OWNERS_FUNDS_PENDING_ACCOUNT);
            var platformPendingAccount = await _accountRepository.GetSystemAccountAsync(PLATFORM_COMMISSION_PENDING_ACCOUNT);

            // Accounting entry: additional service revenue split.
            // القيد المحاسبي: توزيع قيمة الخدمة الإضافية.
            // From customer receivables to owner funds pending and platform commission payable.
            // من حـ/ ذمم مدينة - عملاء إلى حـ/ أموال الملاك المعلقة وعمولات المنصة المستحقة.
            var serviceTransaction = new FinancialTransaction
            {
                TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                TransactionDate = DateTime.UtcNow,
                EntryType = JournalEntryType.Sales,
                TransactionType = TransactionType.ServiceFee,
                DebitAccountId = customerAccount.Id,
                CreditAccountId = ownersPendingAccount.Id,
                Amount = ownerAmount,
                Currency = booking.TotalPrice.Currency,
                ExchangeRate = 1,
                BaseAmount = ownerAmount,
                Description = $"خدمة إضافية: {serviceName} للحجز {booking.Id}",
                Narration = $"إضافة خدمة {serviceName} بقيمة {serviceAmount}",
                ReferenceNumber = serviceId.ToString(),
                DocumentType = "AdditionalService",
                BookingId = bookingId,
                FirstPartyUserId = booking.UserId,
                SecondPartyUserId = property.OwnerId,
                PropertyId = property.Id,
                Status = TransactionStatus.Posted,
                IsPosted = true,
                PostingDate = DateTime.UtcNow,
                FiscalYear = DateTime.UtcNow.Year,
                FiscalPeriod = DateTime.UtcNow.Month,
                Commission = commissionAmount,
                CommissionPercentage = commissionRate * 100,
                NetAmount = ownerAmount,
                CreatedBy = userId,
                CreatedAt = DateTime.UtcNow,
                IsAutomatic = true,
                AutomaticSource = "ServiceSystem"
            };

            await _transactionRepository.AddAsync(serviceTransaction);

            // Additional service commission entry: from customer receivables to platform commission payable.
            // قيد عمولة الخدمة الإضافية: من ح/ ذمم مدينة - عملاء إلى ح/ عمولات المنصة المستحقة.
            if (commissionAmount > 0)
            {
                var commissionPendingAccount = await _accountRepository.GetSystemAccountAsync(PLATFORM_COMMISSION_PENDING_ACCOUNT);
                var serviceCommissionTx = new FinancialTransaction
                {
                    TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                    TransactionDate = DateTime.UtcNow,
                    EntryType = JournalEntryType.Sales,
                    TransactionType = TransactionType.PlatformCommission,
                    DebitAccountId = customerAccount.Id,
                    CreditAccountId = commissionPendingAccount.Id,
                    Amount = commissionAmount,
                    Currency = booking.TotalPrice.Currency,
                    ExchangeRate = 1,
                    BaseAmount = commissionAmount,
                    Description = $"عمولة خدمة إضافية: {serviceName} للحجز {booking.Id}",
                    Narration = $"عمولة {commissionRate * 100}% على الخدمة الإضافية",
                    ReferenceNumber = serviceId.ToString(),
                    DocumentType = "AdditionalServiceCommission",
                    BookingId = bookingId,
                    FirstPartyUserId = booking.UserId,
                    SecondPartyUserId = property.OwnerId,
                    PropertyId = property.Id,
                    Status = TransactionStatus.Posted,
                    IsPosted = true,
                    PostingDate = DateTime.UtcNow,
                    FiscalYear = DateTime.UtcNow.Year,
                    FiscalPeriod = DateTime.UtcNow.Month,
                    Commission = commissionAmount,
                    CommissionPercentage = commissionRate * 100,
                    NetAmount = 0,
                    CreatedBy = userId,
                    CreatedAt = DateTime.UtcNow,
                    IsAutomatic = true,
                    AutomaticSource = "ServiceSystem"
                };

                await _transactionRepository.AddAsync(serviceCommissionTx);
            }
            
            await SaveChangesAsync();
            _logger.LogInformation($"Additional service transaction recorded for booking {bookingId}, service {serviceId}");
            return serviceTransaction;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error recording additional service transaction for booking {bookingId}");
            throw;
        }
    }

    /// <summary>
    /// Closes an accounting period.
    /// يقفل الفترة المحاسبية.
    /// </summary>
    public async Task<bool> CloseAccountingPeriodAsync(int year, int month, Guid userId)
    {
        try
        {
            _logger.LogInformation($"Starting accounting period closure for {month}/{year}");

            var startDate = new DateTime(year, month, 1, 0, 0, 0, DateTimeKind.Utc);
            var endDate = startDate.AddMonths(1).AddSeconds(-1);

            // Load all transactions for the period.
            // الحصول على جميع المعاملات للفترة.
            var periodTransactions = await _transactionRepository.GetByPeriodAsync(startDate, endDate);

            // Verify that all transactions are posted.
            // التحقق من أن جميع المعاملات مرحلة.
            var unpostedTransactions = periodTransactions.Where(t => !t.IsPosted).ToList();
            if (unpostedTransactions.Any())
            {
                _logger.LogWarning($"Cannot close period {month}/{year} - {unpostedTransactions.Count} unposted transactions found");
                return false;
            }

            // Calculate total revenue and expenses.
            // حساب مجاميع الإيرادات والمصروفات.
            var totalRevenue = periodTransactions
                .Where(t => IsRevenueTransaction(t.TransactionType))
                .Sum(t => t.Amount);

            var totalExpenses = periodTransactions
                .Where(t => IsExpenseTransaction(t.TransactionType))
                .Sum(t => t.Amount);

            var netProfit = totalRevenue - totalExpenses;

            // Required accounts.
            // الحسابات المطلوبة.
            var revenueAccounts = await _accountRepository.GetByAccountTypeAsync(AccountType.Revenue);
            var expenseAccounts = await _accountRepository.GetByAccountTypeAsync(AccountType.Expenses);
            var retainedEarningsAccount = await _accountRepository.GetSystemAccountAsync("الأرباح المحتجزة");
            var incomeSummaryAccount = await _accountRepository.GetSystemAccountAsync("ملخص الدخل") 
                ?? await CreateIncomeSummaryAccountAsync();

            // Revenue closing entries.
            // قيد إقفال الإيرادات.
            if (totalRevenue > 0)
            {
                foreach (var revenueAccount in revenueAccounts)
                {
                    var accountRevenue = periodTransactions
                        .Where(t => t.CreditAccountId == revenueAccount.Id)
                        .Sum(t => t.Amount);

                    if (accountRevenue > 0)
                    {
                        var closingEntry = new FinancialTransaction
                        {
                            TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                            TransactionDate = endDate,
                            EntryType = JournalEntryType.Closing,
                            TransactionType = TransactionType.Adjustment,
                            DebitAccountId = revenueAccount.Id,
                            CreditAccountId = incomeSummaryAccount.Id,
                            Amount = accountRevenue,
                            Currency = "YER",
                            ExchangeRate = 1,
                            BaseAmount = accountRevenue,
                            Description = $"إقفال حساب {revenueAccount.NameAr} للفترة {month}/{year}",
                            Narration = $"قيد إقفال الإيرادات",
                            ReferenceNumber = $"CLOSE-{year}{month:D2}",
                            DocumentType = "PeriodClosing",
                            Status = TransactionStatus.Posted,
                            IsPosted = true,
                            PostingDate = DateTime.UtcNow,
                            FiscalYear = year,
                            FiscalPeriod = month,
                            CreatedBy = userId,
                            CreatedAt = DateTime.UtcNow,
                            IsAutomatic = true,
                            AutomaticSource = "PeriodClosingSystem"
                        };

                        await _transactionRepository.AddAsync(closingEntry);
                    }
                }
            }

            // Expense closing entries.
            // قيد إقفال المصروفات.
            if (totalExpenses > 0)
            {
                foreach (var expenseAccount in expenseAccounts)
                {
                    var accountExpense = periodTransactions
                        .Where(t => t.DebitAccountId == expenseAccount.Id)
                        .Sum(t => t.Amount);

                    if (accountExpense > 0)
                    {
                        var closingEntry = new FinancialTransaction
                        {
                            TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                            TransactionDate = endDate,
                            EntryType = JournalEntryType.Closing,
                            TransactionType = TransactionType.Adjustment,
                            DebitAccountId = incomeSummaryAccount.Id,
                            CreditAccountId = expenseAccount.Id,
                            Amount = accountExpense,
                            Currency = "YER",
                            ExchangeRate = 1,
                            BaseAmount = accountExpense,
                            Description = $"إقفال حساب {expenseAccount.NameAr} للفترة {month}/{year}",
                            Narration = $"قيد إقفال المصروفات",
                            ReferenceNumber = $"CLOSE-{year}{month:D2}",
                            DocumentType = "PeriodClosing",
                            Status = TransactionStatus.Posted,
                            IsPosted = true,
                            PostingDate = DateTime.UtcNow,
                            FiscalYear = year,
                            FiscalPeriod = month,
                            CreatedBy = userId,
                            CreatedAt = DateTime.UtcNow,
                            IsAutomatic = true,
                            AutomaticSource = "PeriodClosingSystem"
                        };

                        await _transactionRepository.AddAsync(closingEntry);
                    }
                }
            }

            // Transfer net profit or loss to retained earnings.
            // قيد نقل صافي الربح أو الخسارة إلى الأرباح المحتجزة.
            if (netProfit != 0)
            {
                var profitTransferEntry = new FinancialTransaction
                {
                    TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                    TransactionDate = endDate,
                    EntryType = JournalEntryType.Closing,
                    TransactionType = TransactionType.Adjustment,
                    DebitAccountId = netProfit > 0 ? incomeSummaryAccount.Id : retainedEarningsAccount.Id,
                    CreditAccountId = netProfit > 0 ? retainedEarningsAccount.Id : incomeSummaryAccount.Id,
                    Amount = Math.Abs(netProfit),
                    Currency = "YER",
                    ExchangeRate = 1,
                    BaseAmount = Math.Abs(netProfit),
                    Description = netProfit > 0 
                        ? $"نقل صافي الربح للفترة {month}/{year}" 
                        : $"نقل صافي الخسارة للفترة {month}/{year}",
                    Narration = $"صافي {(netProfit > 0 ? "الربح" : "الخسارة")}: {Math.Abs(netProfit)} YER",
                    ReferenceNumber = $"PROFIT-{year}{month:D2}",
                    DocumentType = "ProfitTransfer",
                    Status = TransactionStatus.Posted,
                    IsPosted = true,
                    PostingDate = DateTime.UtcNow,
                    FiscalYear = year,
                    FiscalPeriod = month,
                    NetAmount = netProfit,
                    CreatedBy = userId,
                    CreatedAt = DateTime.UtcNow,
                    IsAutomatic = true,
                    AutomaticSource = "PeriodClosingSystem"
                };

                await _transactionRepository.AddAsync(profitTransferEntry);
            }

            await SaveChangesAsync();
            _logger.LogInformation($"Accounting period {month}/{year} closed successfully. Net profit: {netProfit}");
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error closing accounting period {month}/{year}");
            throw;
        }
    }

    /// <summary>
    /// Creates the income summary account.
    /// ينشئ حساب ملخص الدخل.
    /// </summary>
    private async Task<ChartOfAccount> CreateIncomeSummaryAccountAsync()
    {
        var incomeSummaryAccount = new ChartOfAccount
        {
            Id = Guid.NewGuid(),
            AccountNumber = "3900",
            NameAr = "ملخص الدخل",
            NameEn = "Income Summary",
            AccountType = AccountType.Equity,
            Category = AccountCategory.Sub,
            NormalBalance = AccountNature.Credit,
            Level = 2,
            Description = "Temporary account for closing revenue and expenses. / حساب مؤقت لإقفال الإيرادات والمصروفات.",
            IsActive = true,
            IsSystemAccount = true,
            CanPost = true,
            CreatedAt = DateTime.UtcNow
        };

        await _accountRepository.CreateAsync(incomeSummaryAccount);
        return incomeSummaryAccount;
    }

    /// <summary>
    /// Processes owner payout transfers.
    /// يعالج تحويل مستحقات الملاك.
    /// </summary>
    public async Task<int> ProcessOwnerPayoutsAsync(Guid userId)
    {
        try
        {
            _logger.LogInformation("Starting owner payouts processing");

            // Load the system accounts used for owner payouts.
            // جلب حسابات النظام المستخدمة لتسديد مستحقات الملاك.
            var payableAccount = await _accountRepository.GetSystemAccountAsync(SYSTEM_PAYABLE_ACCOUNT);
            var bankAccount = await _accountRepository.GetSystemAccountAsync(SYSTEM_BANK_ACCOUNT);

            // Build the owner list with their outstanding balances.
            // إعداد قائمة الملاك مع أرصدتهم المستحقة.
            var allUsers = await _userRepository.GetAllAsync();
            var allProperties = await _propertyRepository.GetAllAsync();
            var ownerIds = allProperties.Select(p => p.OwnerId).Distinct();
            var owners = allUsers.Where(u => ownerIds.Contains(u.Id)).ToList();
            int payoutsProcessed = 0;

            foreach (var owner in owners)
            {
                var ownerPayableAccount = await GetOrCreateOwnerPayableAccountAsync(owner.Id, owner.Name);
                var balance = await _transactionRepository.GetAccountBalanceAtDateAsync(ownerPayableAccount.Id, DateTime.UtcNow);

                if (balance > 0)
                {
                    // Accounting entry: settle owner payouts.
                    // القيد المحاسبي: تسديد مستحقات الملاك.
                    // From owner payables to bank transfers.
                    // من حـ/ ذمم دائنة - ملاك إلى حـ/ البنك - تحويلات.
                    var payoutTransaction = new FinancialTransaction
                    {
                        TransactionNumber = await _transactionRepository.GenerateTransactionNumberAsync(),
                        TransactionDate = DateTime.UtcNow,
                        EntryType = JournalEntryType.CashPayments,
                        TransactionType = TransactionType.OwnerPayout,
                        DebitAccountId = ownerPayableAccount.Id,
                        CreditAccountId = bankAccount.Id,
                        Amount = balance,
                        Currency = "YER",
                        ExchangeRate = 1,
                        BaseAmount = balance,
                        Description = $"تحويل مستحقات المالك {owner.Name}",
                        Narration = $"تحويل مستحقات مجمعة بقيمة {balance} YER",
                        ReferenceNumber = $"PAYOUT-{DateTime.UtcNow:yyyyMMdd}-{owner.Id}",
                        DocumentType = "OwnerPayout",
                        SecondPartyUserId = owner.Id,
                        Status = TransactionStatus.Posted,
                        IsPosted = true,
                        PostingDate = DateTime.UtcNow,
                        FiscalYear = DateTime.UtcNow.Year,
                        FiscalPeriod = DateTime.UtcNow.Month,
                        NetAmount = balance,
                        CreatedBy = userId,
                        CreatedAt = DateTime.UtcNow,
                        IsAutomatic = true,
                        AutomaticSource = "PayoutSystem"
                    };

                    await _transactionRepository.AddAsync(payoutTransaction);
                    payoutsProcessed++;
                    
                    _logger.LogInformation($"Processed payout for owner {owner.Name}: {balance} YER");
                }
            }

            await SaveChangesAsync();
            _logger.LogInformation($"Owner payouts processing completed. {payoutsProcessed} payouts processed");
            return payoutsProcessed;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing owner payouts");
            throw;
        }
    }
}
