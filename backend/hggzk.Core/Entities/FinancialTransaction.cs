using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YemenBooking.Core.Entities;

/// <summary>
/// كيان القيود المحاسبية - يسجل جميع العمليات المالية في النظام
/// Represents a financial transaction recorded in the system.
/// </summary>
[Display(Name = "القيود المحاسبية")]
public class FinancialTransaction : BaseEntity<Guid>
{
    /// <summary>
    /// رقم القيد.
    /// Sequential and unique transaction number.
    /// </summary>
    [Required]
    [Display(Name = "رقم القيد")]
    public string TransactionNumber { get; set; }

    /// <summary>
    /// تاريخ القيد.
    /// Transaction date.
    /// </summary>
    [Required]
    [Display(Name = "تاريخ القيد")]
    public DateTime TransactionDate { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// نوع القيد المحاسبي.
    /// Journal entry type.
    /// </summary>
    [Required]
    [Display(Name = "نوع القيد")]
    public JournalEntryType EntryType { get; set; }

    /// <summary>
    /// نوع العملية المالية.
    /// Financial transaction type.
    /// </summary>
    [Required]
    [Display(Name = "نوع العملية")]
    public TransactionType TransactionType { get; set; }

    /// <summary>
    /// معرف الحساب المدين.
    /// Identifier of the debit account.
    /// </summary>
    [Required]
    [Display(Name = "الحساب المدين")]
    public Guid DebitAccountId { get; set; }

    /// <summary>
    /// الحساب المدين.
    /// Debit account.
    /// </summary>
    [ForeignKey("DebitAccountId")]
    public virtual ChartOfAccount DebitAccount { get; set; }

    /// <summary>
    /// معرف الحساب الدائن.
    /// Identifier of the credit account.
    /// </summary>
    [Required]
    [Display(Name = "الحساب الدائن")]
    public Guid CreditAccountId { get; set; }

    /// <summary>
    /// الحساب الدائن.
    /// Credit account.
    /// </summary>
    [ForeignKey("CreditAccountId")]
    public virtual ChartOfAccount CreditAccount { get; set; }

    /// <summary>
    /// المبلغ.
    /// Transaction amount.
    /// </summary>
    [Required]
    [Display(Name = "المبلغ")]
    [Column(TypeName = "decimal(18,2)")]
    public decimal Amount { get; set; }

    /// <summary>
    /// العملة.
    /// Transaction currency.
    /// </summary>
    [Required]
    [Display(Name = "العملة")]
    public string Currency { get; set; } = "YER";

    /// <summary>
    /// سعر الصرف.
    /// Exchange rate used when the currency differs from the base currency.
    /// </summary>
    [Display(Name = "سعر الصرف")]
    [Column(TypeName = "decimal(18,4)")]
    public decimal ExchangeRate { get; set; } = 1;

    /// <summary>
    /// المبلغ بالعملة الأساسية.
    /// Amount in the base currency.
    /// </summary>
    [Display(Name = "المبلغ بالعملة الأساسية")]
    [Column(TypeName = "decimal(18,2)")]
    public decimal BaseAmount { get; set; }

    /// <summary>
    /// وصف القيد.
    /// Transaction description.
    /// </summary>
    [Required]
    [Display(Name = "وصف القيد")]
    public string Description { get; set; }

    /// <summary>
    /// البيان التفصيلي.
    /// Detailed narration.
    /// </summary>
    [Display(Name = "البيان التفصيلي")]
    public string Narration { get; set; }

    /// <summary>
    /// رقم المستند المرجعي.
    /// Reference document number.
    /// </summary>
    [Display(Name = "رقم المستند المرجعي")]
    public string ReferenceNumber { get; set; }

    /// <summary>
    /// نوع المستند المرجعي.
    /// Reference document type such as Invoice or Receipt.
    /// </summary>
    [Display(Name = "نوع المستند")]
    public string DocumentType { get; set; }

    /// <summary>
    /// معرف الحجز المرتبط.
    /// Associated booking ID, if any.
    /// </summary>
    [Display(Name = "معرف الحجز")]
    public Guid? BookingId { get; set; }

    /// <summary>
    /// الحجز المرتبط.
    /// Associated booking.
    /// </summary>
    public virtual Booking Booking { get; set; }

    /// <summary>
    /// معرف الدفعة المرتبطة.
    /// Associated payment ID, if any.
    /// </summary>
    [Display(Name = "معرف الدفعة")]
    public Guid? PaymentId { get; set; }

    /// <summary>
    /// الدفعة المرتبطة.
    /// Associated payment.
    /// </summary>
    public virtual Payment Payment { get; set; }

    /// <summary>
    /// معرف المستخدم الطرف الأول.
    /// Identifier of the first party user, usually the debtor.
    /// </summary>
    [Display(Name = "الطرف الأول")]
    public Guid? FirstPartyUserId { get; set; }

    /// <summary>
    /// المستخدم الطرف الأول.
    /// First party user.
    /// </summary>
    [ForeignKey("FirstPartyUserId")]
    public virtual User FirstPartyUser { get; set; }

    /// <summary>
    /// معرف المستخدم الطرف الثاني.
    /// Identifier of the second party user, usually the creditor.
    /// </summary>
    [Display(Name = "الطرف الثاني")]
    public Guid? SecondPartyUserId { get; set; }

    /// <summary>
    /// المستخدم الطرف الثاني.
    /// Second party user.
    /// </summary>
    [ForeignKey("SecondPartyUserId")]
    public virtual User SecondPartyUser { get; set; }

    /// <summary>
    /// معرف العقار المرتبط.
    /// Associated property ID, if any.
    /// </summary>
    [Display(Name = "معرف العقار")]
    public Guid? PropertyId { get; set; }

    /// <summary>
    /// العقار المرتبط.
    /// Associated property.
    /// </summary>
    public virtual Property Property { get; set; }

    /// <summary>
    /// معرف الوحدة المرتبطة.
    /// Associated unit ID, if any.
    /// </summary>
    [Display(Name = "معرف الوحدة")]
    public Guid? UnitId { get; set; }

    /// <summary>
    /// الوحدة المرتبطة.
    /// Associated unit.
    /// </summary>
    public virtual Unit Unit { get; set; }

    /// <summary>
    /// حالة القيد.
    /// Transaction status.
    /// </summary>
    [Required]
    [Display(Name = "حالة القيد")]
    public TransactionStatus Status { get; set; } = TransactionStatus.Draft;

    /// <summary>
    /// تاريخ الترحيل.
    /// Posting date.
    /// </summary>
    [Display(Name = "تاريخ الترحيل")]
    public DateTime? PostingDate { get; set; }

    /// <summary>
    /// يحدد ما إذا كان القيد مرحّلًا.
    /// Indicates whether the transaction is posted.
    /// </summary>
    [Display(Name = "مرحّل")]
    public bool IsPosted { get; set; } = false;

    /// <summary>
    /// يحدد ما إذا كان القيد معكوسًا.
    /// Indicates whether the transaction is reversed.
    /// </summary>
    [Display(Name = "معكوس")]
    public bool IsReversed { get; set; } = false;

    /// <summary>
    /// معرف القيد العكسي.
    /// Identifier of the reverse transaction, if any.
    /// </summary>
    [Display(Name = "القيد العكسي")]
    public Guid? ReverseTransactionId { get; set; }

    /// <summary>
    /// القيد العكسي.
    /// Reverse transaction.
    /// </summary>
    [ForeignKey("ReverseTransactionId")]
    public virtual FinancialTransaction ReverseTransaction { get; set; }

    /// <summary>
    /// السنة المالية.
    /// Fiscal year.
    /// </summary>
    [Display(Name = "السنة المالية")]
    public int FiscalYear { get; set; }

    /// <summary>
    /// الفترة المحاسبية.
    /// Accounting period, usually a month.
    /// </summary>
    [Display(Name = "الفترة المحاسبية")]
    public int FiscalPeriod { get; set; }

    /// <summary>
    /// معرف دفتر اليومية.
    /// Journal identifier.
    /// </summary>
    [Display(Name = "دفتر اليومية")]
    public Guid? JournalId { get; set; }

    /// <summary>
    /// رقم الدفعة.
    /// Batch number for grouped entries.
    /// </summary>
    [Display(Name = "رقم الدفعة")]
    public string BatchNumber { get; set; }

    /// <summary>
    /// المرفقات بصيغة JSON.
    /// Attachments stored as JSON document links.
    /// </summary>
    [Display(Name = "المرفقات")]
    public string AttachmentsJson { get; set; }

    /// <summary>
    /// ملاحظات إضافية.
    /// Additional notes.
    /// </summary>
    [Display(Name = "ملاحظات")]
    public string Notes { get; set; }

    /// <summary>
    /// العمولة.
    /// Commission, if any.
    /// </summary>
    [Display(Name = "العمولة")]
    [Column(TypeName = "decimal(18,2)")]
    public decimal? Commission { get; set; }

    /// <summary>
    /// نسبة العمولة.
    /// Commission percentage.
    /// </summary>
    [Display(Name = "نسبة العمولة")]
    [Column(TypeName = "decimal(5,2)")]
    public decimal? CommissionPercentage { get; set; }

    /// <summary>
    /// الضريبة.
    /// Tax, if any.
    /// </summary>
    [Display(Name = "الضريبة")]
    [Column(TypeName = "decimal(18,2)")]
    public decimal? Tax { get; set; }

    /// <summary>
    /// نسبة الضريبة.
    /// Tax percentage.
    /// </summary>
    [Display(Name = "نسبة الضريبة")]
    [Column(TypeName = "decimal(5,2)")]
    public decimal? TaxPercentage { get; set; }

    /// <summary>
    /// الخصم.
    /// Discount, if any.
    /// </summary>
    [Display(Name = "الخصم")]
    [Column(TypeName = "decimal(18,2)")]
    public decimal? Discount { get; set; }

    /// <summary>
    /// نسبة الخصم.
    /// Discount percentage.
    /// </summary>
    [Display(Name = "نسبة الخصم")]
    [Column(TypeName = "decimal(5,2)")]
    public decimal? DiscountPercentage { get; set; }

    /// <summary>
    /// المبلغ الصافي بعد الخصومات والضرائب.
    /// Net amount after discounts and taxes.
    /// </summary>
    [Display(Name = "المبلغ الصافي")]
    [Column(TypeName = "decimal(18,2)")]
    public decimal NetAmount { get; set; }

    /// <summary>
    /// تاريخ الإنشاء.
    /// Creation date.
    /// </summary>
    [Display(Name = "تاريخ الإنشاء")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// معرف المستخدم الذي أنشأ القيد.
    /// Identifier of the user who created the transaction.
    /// </summary>
    [Display(Name = "أنشأه")]
    public Guid? CreatedBy { get; set; }

    /// <summary>
    /// المستخدم الذي أنشأ القيد.
    /// User who created the transaction.
    /// </summary>
    [ForeignKey("CreatedBy")]
    public virtual User CreatedByUser { get; set; }

    /// <summary>
    /// تاريخ آخر تحديث.
    /// Last update date.
    /// </summary>
    [Display(Name = "تاريخ آخر تحديث")]
    public DateTime? UpdatedAt { get; set; }

    /// <summary>
    /// معرف المستخدم الذي عدّل القيد.
    /// Identifier of the user who updated the transaction.
    /// </summary>
    [Display(Name = "عدّله")]
    public Guid? UpdatedBy { get; set; }

    /// <summary>
    /// المستخدم الذي عدّل القيد.
    /// User who updated the transaction.
    /// </summary>
    [ForeignKey("UpdatedBy")]
    public virtual User UpdatedByUser { get; set; }

    /// <summary>
    /// تاريخ الموافقة.
    /// Approval date.
    /// </summary>
    [Display(Name = "تاريخ الموافقة")]
    public DateTime? ApprovedAt { get; set; }

    /// <summary>
    /// معرف المستخدم الذي وافق على القيد.
    /// Identifier of the user who approved the transaction.
    /// </summary>
    [Display(Name = "وافق عليه")]
    public Guid? ApprovedBy { get; set; }

    /// <summary>
    /// المستخدم الذي وافق على القيد.
    /// User who approved the transaction.
    /// </summary>
    [ForeignKey("ApprovedBy")]
    public virtual User ApprovedByUser { get; set; }

    /// <summary>
    /// سبب الإلغاء.
    /// Cancellation reason, if any.
    /// </summary>
    [Display(Name = "سبب الإلغاء")]
    public string CancellationReason { get; set; }

    /// <summary>
    /// تاريخ الإلغاء.
    /// Cancellation date.
    /// </summary>
    [Display(Name = "تاريخ الإلغاء")]
    public DateTime? CancelledAt { get; set; }

    /// <summary>
    /// معرف المستخدم الذي ألغى القيد.
    /// Identifier of the user who cancelled the transaction.
    /// </summary>
    [Display(Name = "ألغاه")]
    public Guid? CancelledBy { get; set; }

    /// <summary>
    /// المستخدم الذي ألغى القيد.
    /// User who cancelled the transaction.
    /// </summary>
    [ForeignKey("CancelledBy")]
    public virtual User CancelledByUser { get; set; }

    /// <summary>
    /// يحدد ما إذا كان القيد تلقائيًا.
    /// Indicates whether the transaction is automatic.
    /// </summary>
    [Display(Name = "قيد تلقائي")]
    public bool IsAutomatic { get; set; } = false;

    /// <summary>
    /// مصدر القيد التلقائي.
    /// Source of the automatic transaction.
    /// </summary>
    [Display(Name = "مصدر القيد")]
    public string AutomaticSource { get; set; }

    /// <summary>
    /// علامات إضافية للبحث والتصنيف.
    /// Additional tags for search and categorization.
    /// </summary>
    [Display(Name = "العلامات")]
    public string Tags { get; set; }
}

/// <summary>
/// أنواع القيود المحاسبية
/// Journal entry types.
/// </summary>
public enum JournalEntryType
{
    /// <summary>
    /// قيد يومية عام.
    /// General journal entry.
    /// </summary>
    [Display(Name = "قيد يومية عام")]
    GeneralJournal = 1,

    /// <summary>
    /// مبيعات.
    /// Sales.
    /// </summary>
    [Display(Name = "قيد مبيعات")]
    Sales = 2,

    /// <summary>
    /// مشتريات.
    /// Purchases.
    /// </summary>
    [Display(Name = "قيد مشتريات")]
    Purchases = 3,

    /// <summary>
    /// مقبوضات نقدية.
    /// Cash receipts.
    /// </summary>
    [Display(Name = "قيد مقبوضات")]
    CashReceipts = 4,

    /// <summary>
    /// مدفوعات نقدية.
    /// Cash payments.
    /// </summary>
    [Display(Name = "قيد مدفوعات")]
    CashPayments = 5,

    /// <summary>
    /// تسوية.
    /// Adjustment.
    /// </summary>
    [Display(Name = "قيد تسوية")]
    Adjustment = 6,

    /// <summary>
    /// إقفال.
    /// Closing.
    /// </summary>
    [Display(Name = "قيد إقفال")]
    Closing = 7,

    /// <summary>
    /// افتتاحي.
    /// Opening.
    /// </summary>
    [Display(Name = "قيد افتتاحي")]
    Opening = 8,

    /// <summary>
    /// عكسي.
    /// Reversal.
    /// </summary>
    [Display(Name = "قيد عكسي")]
    Reversal = 9
}

/// <summary>
/// أنواع العمليات المالية
/// Financial transaction types.
/// </summary>
public enum TransactionType
{
    /// <summary>
    /// حجز جديد.
    /// New booking.
    /// </summary>
    [Display(Name = "حجز جديد")]
    NewBooking = 1,

    /// <summary>
    /// دفعة مقدمة.
    /// Advance payment.
    /// </summary>
    [Display(Name = "دفعة مقدمة")]
    AdvancePayment = 2,

    /// <summary>
    /// دفعة نهائية.
    /// Final payment.
    /// </summary>
    [Display(Name = "دفعة نهائية")]
    FinalPayment = 3,

    /// <summary>
    /// إلغاء حجز.
    /// Booking cancellation.
    /// </summary>
    [Display(Name = "إلغاء حجز")]
    BookingCancellation = 4,

    /// <summary>
    /// استرداد.
    /// Refund.
    /// </summary>
    [Display(Name = "استرداد مبلغ")]
    Refund = 5,

    /// <summary>
    /// عمولة المنصة.
    /// Platform commission.
    /// </summary>
    [Display(Name = "عمولة منصة")]
    PlatformCommission = 6,

    /// <summary>
    /// دفعة للمالك.
    /// Owner payout.
    /// </summary>
    [Display(Name = "دفعة للمالك")]
    OwnerPayout = 7,

    /// <summary>
    /// رسوم خدمة.
    /// Service fee.
    /// </summary>
    [Display(Name = "رسوم خدمة")]
    ServiceFee = 8,

    /// <summary>
    /// ضريبة.
    /// Tax.
    /// </summary>
    [Display(Name = "ضريبة")]
    Tax = 9,

    /// <summary>
    /// خصم.
    /// Discount.
    /// </summary>
    [Display(Name = "خصم")]
    Discount = 10,

    /// <summary>
    /// غرامة تأخير.
    /// Late fee.
    /// </summary>
    [Display(Name = "غرامة تأخير")]
    LateFee = 11,

    /// <summary>
    /// تعويض.
    /// Compensation.
    /// </summary>
    [Display(Name = "تعويض")]
    Compensation = 12,

    /// <summary>
    /// إيداع ضمان.
    /// Security deposit.
    /// </summary>
    [Display(Name = "إيداع ضمان")]
    SecurityDeposit = 13,

    /// <summary>
    /// استرداد إيداع ضمان.
    /// Security deposit refund.
    /// </summary>
    [Display(Name = "استرداد ضمان")]
    SecurityDepositRefund = 14,

    /// <summary>
    /// مصروف تشغيلي.
    /// Operational expense.
    /// </summary>
    [Display(Name = "مصروفات تشغيلية")]
    OperationalExpense = 15,

    /// <summary>
    /// إيراد آخر.
    /// Other income.
    /// </summary>
    [Display(Name = "إيرادات أخرى")]
    OtherIncome = 16,

    /// <summary>
    /// تحويل بين حسابات.
    /// Inter-account transfer.
    /// </summary>
    [Display(Name = "تحويل بين حسابات")]
    InterAccountTransfer = 17,

    /// <summary>
    /// تسوية.
    /// Adjustment.
    /// </summary>
    [Display(Name = "تسوية")]
    Adjustment = 18,

    /// <summary>
    /// رصيد افتتاحي.
    /// Opening balance.
    /// </summary>
    [Display(Name = "رصيد افتتاحي")]
    OpeningBalance = 19,

    /// <summary>
    /// عمولة وكيل.
    /// Agent commission.
    /// </summary>
    [Display(Name = "عمولة وكيل")]
    AgentCommission = 20
}

/// <summary>
/// حالات القيد المحاسبي
/// Financial transaction statuses.
/// </summary>
public enum TransactionStatus
{
    /// <summary>
    /// مسودة.
    /// Draft.
    /// </summary>
    [Display(Name = "مسودة")]
    Draft = 1,

    /// <summary>
    /// معلق.
    /// Pending.
    /// </summary>
    [Display(Name = "معلق")]
    Pending = 2,

    /// <summary>
    /// مرحّل.
    /// Posted.
    /// </summary>
    [Display(Name = "مرحّل")]
    Posted = 3,

    /// <summary>
    /// معتمد.
    /// Approved.
    /// </summary>
    [Display(Name = "موافق عليه")]
    Approved = 4,

    /// <summary>
    /// مرفوض.
    /// Rejected.
    /// </summary>
    [Display(Name = "مرفوض")]
    Rejected = 5,

    /// <summary>
    /// ملغي.
    /// Cancelled.
    /// </summary>
    [Display(Name = "ملغي")]
    Cancelled = 6,

    /// <summary>
    /// معكوس.
    /// Reversed.
    /// </summary>
    [Display(Name = "معكوس")]
    Reversed = 7
}
