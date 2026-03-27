using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Payments.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Payments.Queries.GetUserPayments;

/// <summary>
/// يمثل استعلامًا ضمن نطاق المدفوعات.
/// Represents a payment-related query.
/// </summary>
public class ClientGetUserPaymentsQuery : IRequest<ResultDto<PaginatedResult<ClientPaymentDto>>>
{
    /// <summary>
    /// معرّف المستخدم
    /// User identifier.
    /// </summary>
    public Guid UserId { get; set; }

    /// <summary>
    /// يمثل رقم الصفحة.
    /// Represents page number.
    /// </summary>
    public int PageNumber { get; set; } = 1;

    /// <summary>
    /// يمثل حجم الصفحة.
    /// Represents page size.
    /// </summary>
    public int PageSize { get; set; } = 10;

    /// <summary>
    /// يمثل الحالة.
    /// Represents status.
    /// </summary>
    public string? Status { get; set; }

    /// <summary>
    /// يمثل طريقة الدفع.
    /// Represents payment method.
    /// </summary>
    public string? PaymentMethod { get; set; }

    /// <summary>
    /// يمثل تاريخ البداية.
    /// Represents from date.
    /// </summary>
    public DateTime? FromDate { get; set; }

    /// <summary>
    /// يمثل تاريخ النهاية.
    /// Represents to date.
    /// </summary>
    public DateTime? ToDate { get; set; }

    /// <summary>
    /// يمثل الحد الأدنى للمبلغ.
    /// Represents min amount.
    /// </summary>
    public decimal? MinAmount { get; set; }

    /// <summary>
    /// يمثل الحد الأقصى للمبلغ.
    /// Represents max amount.
    /// </summary>
    public decimal? MaxAmount { get; set; }
}

/// <summary>
/// يمثل نموذج بيانات مرتبطًا بنطاق المدفوعات.
/// Represents a data model for the payment-related feature area.
/// </summary>
    public class ClientPaymentDto
    {
        /// <summary>
        /// معرّف 
        /// Id identifier.
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// معرّف الحجز
        /// Booking identifier.
        /// </summary>
        public Guid BookingId { get; set; }

        /// <summary>
        /// يمثل رقم الحجز.
        /// Represents booking number.
        /// </summary>
        public string BookingNumber { get; set; } = string.Empty;

        /// <summary>
        /// يمثل العقار Name.
        /// Represents property name.
        /// </summary>
        public string PropertyName { get; set; } = string.Empty;

        /// <summary>
        /// يمثل الوحدة Name.
        /// Represents unit name.
        /// </summary>
        public string UnitName { get; set; } = string.Empty;

        /// <summary>
        /// يمثل المبلغ.
        /// Represents amount.
        /// </summary>
        public decimal Amount { get; set; }

        /// <summary>
        /// يمثل العملة.
        /// Represents currency.
        /// </summary>
        public string Currency { get; set; } = "YER";

        /// <summary>
        /// يمثل طريقة الدفع.
        /// Represents payment method.
        /// </summary>
        public string PaymentMethod { get; set; } = string.Empty;

        /// <summary>
        /// يمثل الحالة.
        /// Represents status.
        /// </summary>
        public string Status { get; set; } = string.Empty;

        /// <summary>
        /// يمثل تاريخ الإنشاء.
        /// Represents created at.
        /// </summary>
        public DateTime CreatedAt { get; set; }

        /// <summary>
        /// يمثل تاريخ المعالجة.
        /// Represents processed at.
        /// </summary>
        public DateTime? ProcessedAt { get; set; }

        /// <summary>
        /// يمثل المرجع الخارجي.
        /// Represents external reference.
        /// </summary>
        public string? ExternalReference { get; set; }

        /// <summary>
        /// يمثل رقم الفاتورة.
        /// Represents invoice number.
        /// </summary>
        public string? InvoiceNumber { get; set; }

        /// <summary>
        /// يمثل الملاحظات.
        /// Represents notes.
        /// </summary>
        public string? Notes { get; set; }

        /// <summary>
        /// يمثل سبب الفشل.
        /// Represents failure reason.
        /// </summary>
        public string? FailureReason { get; set; }

        /// <summary>
        /// يمثل الرسوم.
        /// Represents fees.
        /// </summary>
        public decimal Fees { get; set; }

        /// <summary>
        /// يمثل Taxes.
        /// Represents taxes.
        /// </summary>
        public decimal Taxes { get; set; }

        /// <summary>
        /// يمثل المبلغ الصافي.
        /// Represents net amount.
        /// </summary>
        public decimal NetAmount { get; set; }

        /// <summary>
        /// يحدد ما إذا كان قابلية الاسترداد
        /// Indicates whether can refund.
        /// </summary>
        public bool CanRefund { get; set; }

        /// <summary>
        /// يمثل تاريخ انتهاء الاسترداد.
        /// Represents refund expiry date.
        /// </summary>
        public DateTime? RefundExpiryDate { get; set; }
}
