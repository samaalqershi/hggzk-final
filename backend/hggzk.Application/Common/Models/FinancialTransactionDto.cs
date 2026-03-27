using System;
using System.Linq;
using System.Collections.Generic;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Common.Models;

/// <summary>
/// Represents a financial transaction without circular entity references.
/// يمثل معاملة مالية بدون مراجع دائرية للكيانات.
/// </summary>
public class FinancialTransactionDto
{
    /// <summary>
    /// المعرف الفريد للمعاملة المالية.
    /// Unique identifier of the financial transaction.
    /// </summary>
    public Guid Id { get; set; }

    /// <summary>
    /// الرقم المرجعي الداخلي للمعاملة.
    /// Internal transaction reference number.
    /// </summary>
    public string TransactionNumber { get; set; }

    /// <summary>
    /// تاريخ تنفيذ المعاملة.
    /// Date when the transaction occurred.
    /// </summary>
    public DateTime TransactionDate { get; set; }

    /// <summary>
    /// نوع القيد المحاسبي.
    /// Journal entry type.
    /// </summary>
    public JournalEntryType EntryType { get; set; }

    /// <summary>
    /// التصنيف التشغيلي للمعاملة.
    /// Operational transaction type.
    /// </summary>
    public TransactionType TransactionType { get; set; }

    /// <summary>
    /// معرف الحساب المدين.
    /// Debit account identifier.
    /// </summary>
    public Guid DebitAccountId { get; set; }

    /// <summary>
    /// معرف الحساب الدائن.
    /// Credit account identifier.
    /// </summary>
    public Guid CreditAccountId { get; set; }

    /// <summary>
    /// المبلغ الأصلي للمعاملة.
    /// Original transaction amount.
    /// </summary>
    public decimal Amount { get; set; }

    /// <summary>
    /// رمز العملة المستخدمة في المبلغ الأصلي.
    /// Currency code used for the original amount.
    /// </summary>
    public string Currency { get; set; }

    /// <summary>
    /// سعر الصرف المطبق وقت المعاملة.
    /// Exchange rate applied at transaction time.
    /// </summary>
    public decimal ExchangeRate { get; set; }

    /// <summary>
    /// المبلغ بعد التحويل إلى العملة الأساسية.
    /// Amount converted to the base currency.
    /// </summary>
    public decimal BaseAmount { get; set; }

    /// <summary>
    /// الوصف المختصر للمعاملة.
    /// Short description of the transaction.
    /// </summary>
    public string Description { get; set; }

    /// <summary>
    /// السرد أو البيان التفصيلي للمعاملة.
    /// Detailed narration for the transaction.
    /// </summary>
    public string Narration { get; set; }

    /// <summary>
    /// رقم المرجع الخارجي أو المستندي.
    /// External or document reference number.
    /// </summary>
    public string ReferenceNumber { get; set; }

    /// <summary>
    /// نوع المستند المرتبط بالمعاملة.
    /// Document type associated with the transaction.
    /// </summary>
    public string DocumentType { get; set; }

    /// <summary>
    /// معرف الحجز المرتبط إن وجد.
    /// Related booking identifier when available.
    /// </summary>
    public Guid? BookingId { get; set; }

    /// <summary>
    /// معرف الدفعة المرتبطة إن وجد.
    /// Related payment identifier when available.
    /// </summary>
    public Guid? PaymentId { get; set; }

    /// <summary>
    /// معرف المستخدم الأول في المعاملة إن وجد.
    /// First-party user identifier when available.
    /// </summary>
    public Guid? FirstPartyUserId { get; set; }

    /// <summary>
    /// معرف المستخدم الثاني في المعاملة إن وجد.
    /// Second-party user identifier when available.
    /// </summary>
    public Guid? SecondPartyUserId { get; set; }

    /// <summary>
    /// معرف العقار المرتبط إن وجد.
    /// Related property identifier when available.
    /// </summary>
    public Guid? PropertyId { get; set; }

    /// <summary>
    /// معرف الوحدة المرتبطة إن وجد.
    /// Related unit identifier when available.
    /// </summary>
    public Guid? UnitId { get; set; }

    /// <summary>
    /// الحالة الحالية للمعاملة.
    /// Current transaction status.
    /// </summary>
    public TransactionStatus Status { get; set; }

    /// <summary>
    /// تاريخ الترحيل المحاسبي إن تم الترحيل.
    /// Posting date when the transaction has been posted.
    /// </summary>
    public DateTime? PostingDate { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت المعاملة مُرحلة.
    /// Indicates whether the transaction is posted.
    /// </summary>
    public bool IsPosted { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت المعاملة قد عُكست.
    /// Indicates whether the transaction has been reversed.
    /// </summary>
    public bool IsReversed { get; set; }

    /// <summary>
    /// معرف معاملة العكس إن وجدت.
    /// Reverse transaction identifier when available.
    /// </summary>
    public Guid? ReverseTransactionId { get; set; }

    /// <summary>
    /// السنة المالية الخاصة بالمعاملة.
    /// Fiscal year of the transaction.
    /// </summary>
    public int FiscalYear { get; set; }

    /// <summary>
    /// الفترة المالية داخل السنة.
    /// Fiscal period within the year.
    /// </summary>
    public int FiscalPeriod { get; set; }

    /// <summary>
    /// معرف اليومية المرتبطة إن وجد.
    /// Related journal identifier when available.
    /// </summary>
    public Guid? JournalId { get; set; }

    /// <summary>
    /// رقم الدفعة المحاسبية.
    /// Accounting batch number.
    /// </summary>
    public string BatchNumber { get; set; }

    /// <summary>
    /// ملاحظات إضافية على المعاملة.
    /// Additional notes for the transaction.
    /// </summary>
    public string Notes { get; set; }

    /// <summary>
    /// قيمة العمولة المقتطعة إن وجدت.
    /// Commission value when applicable.
    /// </summary>
    public decimal? Commission { get; set; }

    /// <summary>
    /// نسبة العمولة إن وجدت.
    /// Commission percentage when applicable.
    /// </summary>
    public decimal? CommissionPercentage { get; set; }

    /// <summary>
    /// قيمة الضريبة إن وجدت.
    /// Tax value when applicable.
    /// </summary>
    public decimal? Tax { get; set; }

    /// <summary>
    /// نسبة الضريبة إن وجدت.
    /// Tax percentage when applicable.
    /// </summary>
    public decimal? TaxPercentage { get; set; }

    /// <summary>
    /// قيمة الخصم إن وجدت.
    /// Discount value when applicable.
    /// </summary>
    public decimal? Discount { get; set; }

    /// <summary>
    /// نسبة الخصم إن وجدت.
    /// Discount percentage when applicable.
    /// </summary>
    public decimal? DiscountPercentage { get; set; }

    /// <summary>
    /// صافي المبلغ النهائي بعد الإضافات والخصومات.
    /// Final net amount after additions and deductions.
    /// </summary>
    public decimal NetAmount { get; set; }

    /// <summary>
    /// وقت إنشاء السجل.
    /// Record creation timestamp.
    /// </summary>
    public DateTime CreatedAt { get; set; }

    /// <summary>
    /// المستخدم الذي أنشأ السجل إن وجد.
    /// Identifier of the user who created the record when available.
    /// </summary>
    public Guid? CreatedBy { get; set; }

    /// <summary>
    /// وقت آخر تحديث للسجل.
    /// Last update timestamp.
    /// </summary>
    public DateTime? UpdatedAt { get; set; }

    /// <summary>
    /// المستخدم الذي حدّث السجل آخر مرة إن وجد.
    /// Identifier of the user who last updated the record when available.
    /// </summary>
    public Guid? UpdatedBy { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت المعاملة أُنشئت آلياً.
    /// Indicates whether the transaction was generated automatically.
    /// </summary>
    public bool IsAutomatic { get; set; }

    /// <summary>
    /// مصدر الأتمتة أو النظام الذي أنشأ المعاملة آلياً.
    /// Automation source or subsystem that generated the transaction automatically.
    /// </summary>
    public string AutomaticSource { get; set; }

    /// <summary>
    /// معلومات الحساب المدين بدون العلاقات الدائرية.
    /// Debit-account information without circular relationships.
    /// </summary>
    public SimpleAccountDto DebitAccount { get; set; }

    /// <summary>
    /// معلومات الحساب الدائن بدون العلاقات الدائرية.
    /// Credit-account information without circular relationships.
    /// </summary>
    public SimpleAccountDto CreditAccount { get; set; }

    /// <summary>
    /// Converts a financial transaction entity into a DTO.
    /// يحول كيان المعاملة المالية إلى DTO.
    /// </summary>
    public static FinancialTransactionDto FromEntity(FinancialTransaction transaction)
    {
        if (transaction == null)
            return null;

        return new FinancialTransactionDto
        {
            Id = transaction.Id,
            TransactionNumber = transaction.TransactionNumber,
            TransactionDate = transaction.TransactionDate,
            EntryType = transaction.EntryType,
            TransactionType = transaction.TransactionType,
            DebitAccountId = transaction.DebitAccountId,
            CreditAccountId = transaction.CreditAccountId,
            Amount = transaction.Amount,
            Currency = transaction.Currency,
            ExchangeRate = transaction.ExchangeRate,
            BaseAmount = transaction.BaseAmount,
            Description = transaction.Description,
            Narration = transaction.Narration,
            ReferenceNumber = transaction.ReferenceNumber,
            DocumentType = transaction.DocumentType,
            BookingId = transaction.BookingId,
            PaymentId = transaction.PaymentId,
            FirstPartyUserId = transaction.FirstPartyUserId,
            SecondPartyUserId = transaction.SecondPartyUserId,
            PropertyId = transaction.PropertyId,
            UnitId = transaction.UnitId,
            Status = transaction.Status,
            PostingDate = transaction.PostingDate,
            IsPosted = transaction.IsPosted,
            IsReversed = transaction.IsReversed,
            ReverseTransactionId = transaction.ReverseTransactionId,
            FiscalYear = transaction.FiscalYear,
            FiscalPeriod = transaction.FiscalPeriod,
            JournalId = transaction.JournalId,
            BatchNumber = transaction.BatchNumber,
            Notes = transaction.Notes,
            Commission = transaction.Commission,
            CommissionPercentage = transaction.CommissionPercentage,
            Tax = transaction.Tax,
            TaxPercentage = transaction.TaxPercentage,
            Discount = transaction.Discount,
            DiscountPercentage = transaction.DiscountPercentage,
            NetAmount = transaction.NetAmount,
            CreatedAt = transaction.CreatedAt,
            CreatedBy = transaction.CreatedBy,
            UpdatedAt = transaction.UpdatedAt,
            UpdatedBy = transaction.UpdatedBy,
            IsAutomatic = transaction.IsAutomatic,
            AutomaticSource = transaction.AutomaticSource,
            DebitAccount = transaction.DebitAccount != null 
                ? SimpleAccountDto.FromEntity(transaction.DebitAccount) 
                : null,
            CreditAccount = transaction.CreditAccount != null 
                ? SimpleAccountDto.FromEntity(transaction.CreditAccount) 
                : null
        };
    }

    /// <summary>
    /// Converts a sequence of transaction entities into DTOs.
    /// يحول تسلسلًا من كيانات المعاملات إلى DTOs.
    /// </summary>
    public static List<FinancialTransactionDto> FromEntities(IEnumerable<FinancialTransaction> transactions)
    {
        if (transactions == null)
            return new List<FinancialTransactionDto>();

        return transactions
            .Select(t => FromEntity(t))
            .OrderByDescending(t => t.TransactionDate)
            .ToList();
    }
}

/// <summary>
/// Represents a simplified account contract without navigation properties.
/// يمثل عقد حساب مبسطًا بدون خصائص تنقل.
/// </summary>
public class SimpleAccountDto
{
    /// <summary>
    /// المعرف الفريد للحساب.
    /// Unique identifier of the account.
    /// </summary>
    public Guid Id { get; set; }

    /// <summary>
    /// رقم الحساب.
    /// Account number.
    /// </summary>
    public string AccountNumber { get; set; }

    /// <summary>
    /// اسم الحساب بالعربية.
    /// Arabic account name.
    /// </summary>
    public string NameAr { get; set; }

    /// <summary>
    /// اسم الحساب بالإنجليزية.
    /// English account name.
    /// </summary>
    public string NameEn { get; set; }

    /// <summary>
    /// نوع الحساب المحاسبي.
    /// Accounting account type.
    /// </summary>
    public AccountType AccountType { get; set; }

    /// <summary>
    /// الطبيعة المحاسبية الافتراضية للحساب.
    /// Normal account balance nature.
    /// </summary>
    public AccountNature NormalBalance { get; set; }

    /// <summary>
    /// Converts an account entity into a simplified DTO.
    /// يحول كيان الحساب إلى DTO مبسط.
    /// </summary>
    /// <param name="account">The account entity. كيان الحساب.</param>
    /// <returns>The simplified account DTO. النسخة المبسطة من الحساب.</returns>
    public static SimpleAccountDto FromEntity(ChartOfAccount account)
    {
        if (account == null)
            return null;

        return new SimpleAccountDto
        {
            Id = account.Id,
            AccountNumber = account.AccountNumber,
            NameAr = account.NameAr,
            NameEn = account.NameEn,
            AccountType = account.AccountType,
            NormalBalance = account.NormalBalance
        };
    }
}
