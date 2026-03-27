using System;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;
using System.Text.Json.Serialization;
using YemenBooking.Core.Enums;

namespace YemenBooking.Application.Features.Payments.DTOs
{
    /// <summary>
    /// DTO لبيانات الدفع
    /// DTO for payment data
    /// </summary>
    public class PaymentDto
    {
        /// <summary>معرف الدفعة</summary>
        public Guid Id { get; set; }

        /// <summary>معرف الحجز</summary>
        public Guid BookingId { get; set; }

        /// <summary>المبلغ المدفوع</summary>
        public decimal Amount { get; set; }
        
        /// <summary>المبلغ بصيغة MoneyDto</summary>
        public MoneyDto AmountMoney { get; set; }

        /// <summary>رقم المعاملة</summary>
        public string TransactionId { get; set; }

        /// <summary>طريقة الدفع</summary>
        [JsonPropertyName("paymentMethod")]
        public PaymentMethodEnum Method { get; set; }

        /// <summary>العملة</summary>
        public string Currency { get; set; } = "YER";

        /// <summary>حالة الدفع</summary>
        public PaymentStatus Status { get; set; }

        /// <summary>تاريخ الدفع</summary>
        public DateTime PaymentDate { get; set; }

        // 🎯 حقول المستخدم والحجز
        /// <summary>
        /// خاصية UserId.
        /// UserId property.
        /// </summary>
        public Guid? UserId { get; set; }
        /// <summary>
        /// خاصية UserName.
        /// UserName property.
        /// </summary>
        public string? UserName { get; set; }
        /// <summary>
        /// خاصية UserEmail.
        /// UserEmail property.
        /// </summary>
        public string? UserEmail { get; set; }

        // 🎯 حقول الوحدة والعقار
        /// <summary>
        /// خاصية UnitId.
        /// UnitId property.
        /// </summary>
        public Guid? UnitId { get; set; }
        /// <summary>
        /// خاصية UnitName.
        /// UnitName property.
        /// </summary>
        public string? UnitName { get; set; }
        /// <summary>
        /// خاصية PropertyId.
        /// PropertyId property.
        /// </summary>
        public Guid? PropertyId { get; set; }
        /// <summary>
        /// خاصية PropertyName.
        /// PropertyName property.
        /// </summary>
        public string? PropertyName { get; set; }

        // 🎯 حقول إضافية
        /// <summary>
        /// خاصية Description.
        /// Description property.
        /// </summary>
        public string? Description { get; set; }
        /// <summary>
        /// خاصية Notes.
        /// Notes property.
        /// </summary>
        public string? Notes { get; set; }
        /// <summary>
        /// خاصية ReceiptUrl.
        /// ReceiptUrl property.
        /// </summary>
        public string? ReceiptUrl { get; set; }
        /// <summary>
        /// خاصية InvoiceNumber.
        /// InvoiceNumber property.
        /// </summary>
        public string? InvoiceNumber { get; set; }
        /// <summary>
        /// خاصية GatewayTransactionId.
        /// GatewayTransactionId property.
        /// </summary>
        public string? GatewayTransactionId { get; set; }

        // 🎯 حقول المعالجة
        /// <summary>
        /// خاصية ProcessedBy.
        /// ProcessedBy property.
        /// </summary>
        public Guid? ProcessedBy { get; set; }
        /// <summary>
        /// خاصية ProcessedByName.
        /// ProcessedByName property.
        /// </summary>
        public string? ProcessedByName { get; set; }
        /// <summary>
        /// خاصية ProcessedAt.
        /// ProcessedAt property.
        /// </summary>
        public DateTime? ProcessedAt { get; set; }

        // 🎯 حقول الاسترداد
        /// <summary>
        /// خاصية IsRefundable.
        /// IsRefundable property.
        /// </summary>
        public bool? IsRefundable { get; set; }
        /// <summary>
        /// خاصية RefundDeadline.
        /// RefundDeadline property.
        /// </summary>
        public DateTime? RefundDeadline { get; set; }
        /// <summary>
        /// خاصية RefundedAmount.
        /// RefundedAmount property.
        /// </summary>
        public decimal? RefundedAmount { get; set; }
        /// <summary>
        /// خاصية RefundedAt.
        /// RefundedAt property.
        /// </summary>
        public DateTime? RefundedAt { get; set; }
        /// <summary>
        /// خاصية RefundReason.
        /// RefundReason property.
        /// </summary>
        public string? RefundReason { get; set; }
        /// <summary>
        /// خاصية RefundTransactionId.
        /// RefundTransactionId property.
        /// </summary>
        public string? RefundTransactionId { get; set; }

        // 🎯 حقول الإلغاء
        /// <summary>
        /// خاصية IsVoided.
        /// IsVoided property.
        /// </summary>
        public bool? IsVoided { get; set; }
        /// <summary>
        /// خاصية VoidedAt.
        /// VoidedAt property.
        /// </summary>
        public DateTime? VoidedAt { get; set; }
        /// <summary>
        /// خاصية VoidReason.
        /// VoidReason property.
        /// </summary>
        public string? VoidReason { get; set; }

        // 🎯 Metadata
        /// <summary>
        /// خاصية Metadata.
        /// Metadata property.
        /// </summary>
        public Dictionary<string, object>? Metadata { get; set; }
    }
} 