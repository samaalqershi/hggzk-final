using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Entities;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Analytics.DTOs;
using YemenBooking.Application.Features.Reports.DTOs;

namespace YemenBooking.Application.Features.Accounting.Services;

/// <summary>
/// Represents the contract for financial accounting operations and reports.
/// يمثل عقد عمليات المحاسبة المالية والتقارير المرتبطة بها.
/// </summary>
public interface IFinancialAccountingService
{
    /// <summary>
    /// Records the financial transaction for a new booking.
    /// يسجل العملية المالية لحجز جديد.
    /// </summary>
    Task<FinancialTransaction> RecordBookingTransactionAsync(Guid bookingId, Guid userId);

    /// <summary>
    /// Records a payment transaction.
    /// يسجل عملية دفع.
    /// </summary>
    Task<FinancialTransaction> RecordPaymentTransactionAsync(Guid paymentId, Guid userId);

    /// <summary>
    /// Records a cancellation transaction.
    /// يسجل عملية إلغاء الحجز.
    /// </summary>
    Task<FinancialTransaction> RecordCancellationTransactionAsync(Guid bookingId, Guid userId);
    
    /// <summary>
    /// Records a cancellation transaction with the provided reason.
    /// يسجل عملية إلغاء الحجز مع السبب المحدد.
    /// </summary>
    Task<FinancialTransaction> RecordBookingCancellationAsync(Guid bookingId, string reason, Guid userId);

    /// <summary>
    /// Records a refund transaction.
    /// يسجل عملية استرداد مبلغ.
    /// </summary>
    Task<FinancialTransaction> RecordRefundTransactionAsync(Guid bookingId, decimal refundAmount, Guid userId);

    /// <summary>
    /// Records an owner payout transaction.
    /// يسجل عملية دفعة للمالك.
    /// </summary>
    Task<FinancialTransaction> RecordOwnerPayoutAsync(Guid propertyId, decimal amount, Guid userId);
    
    /// <summary>
    /// Records an expense transaction.
    /// يسجل عملية مصروف.
    /// </summary>
    Task<FinancialTransaction> RecordExpenseAsync(string description, decimal amount, AccountType accountType, Guid userId);

    /// <summary>
    /// Records a booking completion transaction.
    /// يسجل عملية إكمال الحجز.
    /// </summary>
    Task<FinancialTransaction> RecordBookingCompletionAsync(Guid bookingId, decimal finalAmount, Guid userId);

    /// <summary>
    /// Gets revenue chart data for the requested range.
    /// يحصل على بيانات مخطط الإيرادات للنطاق المطلوب.
    /// </summary>
    Task<List<FinancialChartDto>> GetRevenueChartDataAsync(DateTime startDate, DateTime endDate);
    
    /// <summary>
    /// Gets expense chart data for the requested range.
    /// يحصل على بيانات مخطط المصروفات للنطاق المطلوب.
    /// </summary>
    Task<List<FinancialChartDto>> GetExpenseChartDataAsync(DateTime startDate, DateTime endDate);
    
    /// <summary>
    /// Gets cash-flow chart data for the requested range.
    /// يحصل على بيانات مخطط التدفق النقدي للنطاق المطلوب.
    /// </summary>
    Task<List<FinancialChartDto>> GetCashFlowChartDataAsync(DateTime startDate, DateTime endDate);
    
    /// <summary>
    /// Gets the aggregated financial summary.
    /// يحصل على الملخص المالي المجمع.
    /// </summary>
    Task<FinancialSummaryDto> GetFinancialSummaryAsync();

    /// <summary>
    /// Gets a financial report for the specified period.
    /// يحصل على تقرير مالي للفترة المحددة.
    /// </summary>
    Task<FinancialReportDto> GetFinancialReportAsync(DateTime startDate, DateTime endDate);

    /// <summary>
    /// Creates a customer financial account.
    /// ينشئ الحساب المالي للعميل.
    /// </summary>
    Task<bool> CreateCustomerFinancialAccountAsync(Guid customerId, string customerName, CancellationToken cancellationToken);

    /// <summary>
    /// Creates the owner financial accounts required by the accounting flow.
    /// ينشئ الحسابات المالية المطلوبة للمالك ضمن التدفق المحاسبي.
    /// </summary>
    Task<bool> CreateOwnerFinancialAccountsAsync(Guid ownerId, string ownerName, CancellationToken cancellationToken);

    /// <summary>
    /// Creates legacy user financial accounts for backward compatibility.
    /// ينشئ الحسابات المالية القديمة للتوافق مع الإصدارات السابقة.
    /// </summary>
    [System.Obsolete("Use CreateCustomerFinancialAccountAsync for customers or CreateOwnerFinancialAccountsAsync for owners.")]
    Task<bool> CreateUserFinancialAccountsAsync(Guid userId, string userName, CancellationToken cancellationToken);

    /// <summary>
    /// Checks whether the user has financial transactions.
    /// يتحقق من وجود عمليات مالية للمستخدم.
    /// </summary>
    Task<bool> HasFinancialTransactionsAsync(Guid userId);

    /// <summary>
    /// Records the booking confirmation entry and recognizes commission revenue.
    /// يسجل قيد تأكيد الحجز ويثبت إيراد العمولة.
    /// </summary>
    Task<FinancialTransaction> RecordBookingConfirmationTransactionAsync(Guid bookingId, Guid userId);

    /// <summary>
    /// Records the checkout entry and releases owner funds.
    /// يسجل قيد تسجيل الخروج ويحرر أموال المالك.
    /// </summary>
    Task<FinancialTransaction> RecordCheckoutTransactionAsync(Guid bookingId, Guid userId);

    /// <summary>
    /// Records a cancellation entry that includes cancellation fees.
    /// يسجل قيد إلغاء الحجز متضمنًا رسوم الإلغاء.
    /// </summary>
    Task<FinancialTransaction> RecordCancellationWithFeesAsync(Guid bookingId, decimal cancellationFeePercentage, Guid userId);

    /// <summary>
    /// Records an additional service transaction.
    /// يسجل عملية خدمة إضافية.
    /// </summary>
    Task<FinancialTransaction> RecordAdditionalServiceTransactionAsync(
        Guid bookingId,
        Guid serviceId,
        decimal serviceAmount,
        string serviceName,
        Guid userId);

    /// <summary>
    /// Closes an accounting period.
    /// يقفل فترة محاسبية.
    /// </summary>
    Task<bool> CloseAccountingPeriodAsync(int year, int month, Guid userId);

    /// <summary>
    /// Transfers owner payouts.
    /// يحول مستحقات الملاك.
    /// </summary>
    Task<int> ProcessOwnerPayoutsAsync(Guid userId);

    /// <summary>
    /// Records a refund transaction with a reason.
    /// يسجل استرداد مبلغ مع السبب.
    /// </summary>
    Task<FinancialTransaction> RecordRefundTransactionAsync(
        Guid bookingId, 
        decimal amount, 
        string reason, 
        Guid userId);

    /// <summary>
    /// Records an owner payout transaction with a description.
    /// يسجل دفعة للمالك مع وصف.
    /// </summary>
    Task<FinancialTransaction> RecordOwnerPayoutAsync(
        Guid propertyId,
        Guid ownerId,
        decimal amount,
        string description,
        Guid userId);
}
