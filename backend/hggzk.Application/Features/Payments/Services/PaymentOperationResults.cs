using System;
using YemenBooking.Core.Enums;

namespace YemenBooking.Application.Features.Payments.Services;

/// <summary>
/// Represents the result of a payment operation.
/// يمثل نتيجة عملية الدفع.
/// </summary>
public class PaymentResult
{
    /// <summary>Indicates whether the operation succeeded. يشير إلى نجاح العملية.</summary>
    public bool IsSuccess { get; set; }

    /// <summary>The internal transaction identifier. معرف العملية الداخلي.</summary>
    public string TransactionId { get; set; } = string.Empty;

    /// <summary>A human-readable status message. رسالة حالة قابلة للعرض.</summary>
    public string Message { get; set; } = string.Empty;

    /// <summary>The resulting payment status. حالة الدفع الناتجة.</summary>
    public PaymentStatus Status { get; set; }

    /// <summary>The amount actually processed. المبلغ الذي تمت معالجته فعلياً.</summary>
    public decimal ProcessedAmount { get; set; }

    /// <summary>The calculated fees. الرسوم المحتسبة.</summary>
    public decimal Fees { get; set; }

    /// <summary>The timestamp of processing. وقت تنفيذ العملية.</summary>
    public DateTime ProcessedAt { get; set; }

    /// <summary>The gateway transaction identifier. معرف المعاملة لدى بوابة الدفع.</summary>
    public string GatewayTransactionId { get; set; } = string.Empty;

    /// <summary>Optional machine-readable error code. رمز خطأ اختياري للمعالجة البرمجية.</summary>
    public string? ErrorCode { get; set; }
}

/// <summary>
/// Represents the result of a refund operation.
/// يمثل نتيجة عملية الاسترجاع.
/// </summary>
public class RefundResult
{
    /// <summary>Indicates whether the refund succeeded. يشير إلى نجاح الاسترجاع.</summary>
    public bool IsSuccess { get; set; }

    /// <summary>The refund identifier. معرف الاسترجاع.</summary>
    public string RefundId { get; set; } = string.Empty;

    /// <summary>A human-readable status message. رسالة حالة قابلة للعرض.</summary>
    public string Message { get; set; } = string.Empty;

    /// <summary>The refunded amount. المبلغ المسترجع.</summary>
    public decimal RefundedAmount { get; set; }

    /// <summary>The timestamp of the refund. وقت تنفيذ الاسترجاع.</summary>
    public DateTime RefundedAt { get; set; }
}
