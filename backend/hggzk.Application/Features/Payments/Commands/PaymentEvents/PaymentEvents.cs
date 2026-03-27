using System;
using YemenBooking.Core.Enums;
using YemenBooking.Core.Interfaces.Events;
using YemenBooking.Core.ValueObjects;

namespace YemenBooking.Application.Features.Payments.Commands.PaymentEvents
{
    /// <summary>
    /// Event for processed payments
    /// </summary>
    public class PaymentProcessedEvent : IPaymentProcessedEvent
    {
        /// <summary>
        /// خاصية PaymentId.
        /// PaymentId property.
        /// </summary>
        public Guid PaymentId { get; set; }
        /// <summary>
        /// خاصية BookingId.
        /// BookingId property.
        /// </summary>
        public Guid BookingId { get; set; }
        /// <summary>
        /// خاصية Amount.
        /// Amount property.
        /// </summary>
        public Money Amount { get; set; }
        /// <summary>
        /// خاصية Method.
        /// Method property.
        /// </summary>
        public string Method { get; set; } = null!;
        /// <summary>
        /// خاصية TransactionId.
        /// TransactionId property.
        /// </summary>
        public string TransactionId { get; set; } = null!;
        /// <summary>
        /// خاصية Status.
        /// Status property.
        /// </summary>
        public string Status { get; set; } = null!;
        /// <summary>
        /// خاصية ProcessedAt.
        /// ProcessedAt property.
        /// </summary>
        public DateTime ProcessedAt { get; set; }
        /// <summary>
        /// خاصية Currency.
        /// Currency property.
        /// </summary>
        public string Currency { get; set; } = null!;
        /// <summary>
        /// خاصية Notes.
        /// Notes property.
        /// </summary>
        public string? Notes { get; set; }

        /// <summary>
        /// خاصية EventId.
        /// EventId property.
        /// </summary>
        public Guid EventId { get; set; }

        /// <summary>
        /// خاصية OccurredOn.
        /// OccurredOn property.
        /// </summary>
        public DateTime OccurredOn { get; set; }

        /// <summary>
        /// خاصية EventType.
        /// EventType property.
        /// </summary>
        public string EventType { get; set; }

        /// <summary>
        /// خاصية Version.
        /// Version property.
        /// </summary>
        public int Version { get; set; }

        /// <summary>
        /// خاصية UserId.
        /// UserId property.
        /// </summary>
        public Guid? UserId { get; set; }

        /// <summary>
        /// خاصية CorrelationId.
        /// CorrelationId property.
        /// </summary>
        public string? CorrelationId { get; set; }
    }

    /// <summary>
    /// Event for refunded payments
    /// </summary>
    public class PaymentRefundedEvent : IPaymentRefundedEvent
    {
        /// <summary>
        /// خاصية PaymentId.
        /// PaymentId property.
        /// </summary>
        public Guid PaymentId { get; set; }
        /// <summary>
        /// خاصية BookingId.
        /// BookingId property.
        /// </summary>
        public Guid BookingId { get; set; }
        /// <summary>
        /// خاصية RefundAmount.
        /// RefundAmount property.
        /// </summary>
        public decimal RefundAmount { get; set; }
        /// <summary>
        /// خاصية RefundReason.
        /// RefundReason property.
        /// </summary>
        public string RefundReason { get; set; } = null!;
        /// <summary>
        /// خاصية RefundTransactionId.
        /// RefundTransactionId property.
        /// </summary>
        public string RefundTransactionId { get; set; } = null!;
        /// <summary>
        /// خاصية RefundedAt.
        /// RefundedAt property.
        /// </summary>
        public DateTime RefundedAt { get; set; }
        /// <summary>
        /// خاصية RefundMethod.
        /// RefundMethod property.
        /// </summary>
        public PaymentMethodEnum RefundMethod { get; set; }
        /// <summary>
        /// خاصية RefundStatus.
        /// RefundStatus property.
        /// </summary>
        public YemenBooking.Core.Enums.PaymentStatus RefundStatus { get; set; }
        /// <summary>
        /// خاصية OriginalAmount.
        /// OriginalAmount property.
        /// </summary>
        public decimal OriginalAmount { get; set; }
        /// <summary>
        /// خاصية Currency.
        /// Currency property.
        /// </summary>
        public string Currency { get; set; } = null!;
        /// <summary>
        /// خاصية Notes.
        /// Notes property.
        /// </summary>
        public string? Notes { get; set; }
        /// <summary>
        /// خاصية EventId.
        /// EventId property.
        /// </summary>
        public Guid EventId { get; set; }
        /// <summary>
        /// خاصية OccurredOn.
        /// OccurredOn property.
        /// </summary>
        public DateTime OccurredOn { get; set; }
        /// <summary>
        /// خاصية EventType.
        /// EventType property.
        /// </summary>
        public string EventType { get; set; }
        /// <summary>
        /// خاصية Version.
        /// Version property.
        /// </summary>
        public int Version { get; set; }
        /// <summary>
        /// خاصية UserId.
        /// UserId property.
        /// </summary>
        public Guid? UserId { get; set; }
        /// <summary>
        /// خاصية CorrelationId.
        /// CorrelationId property.
        /// </summary>
        public string? CorrelationId { get; set; }

    }

    /// <summary>
    /// Event for updated payment status
    /// </summary>
    public class PaymentStatusUpdatedEvent : IPaymentStatusUpdatedEvent
    {
        /// <summary>
        /// خاصية PaymentId.
        /// PaymentId property.
        /// </summary>
        public Guid PaymentId { get; set; }
        /// <summary>
        /// خاصية BookingId.
        /// BookingId property.
        /// </summary>
        public Guid BookingId { get; set; }
        /// <summary>
        /// خاصية PreviousStatus.
        /// PreviousStatus property.
        /// </summary>
        public YemenBooking.Core.Enums.PaymentStatus PreviousStatus { get; set; }
        /// <summary>
        /// خاصية NewStatus.
        /// NewStatus property.
        /// </summary>
        public YemenBooking.Core.Enums.PaymentStatus NewStatus { get; set; }
        /// <summary>
        /// خاصية UpdatedAt.
        /// UpdatedAt property.
        /// </summary>
        public DateTime UpdatedAt { get; set; }
        /// <summary>
        /// خاصية UpdateReason.
        /// UpdateReason property.
        /// </summary>
        public string? UpdateReason { get; set; }
        /// <summary>
        /// خاصية UpdatedByUserId.
        /// UpdatedByUserId property.
        /// </summary>
        public Guid? UpdatedByUserId { get; set; }
        /// <summary>
        /// خاصية Amount.
        /// Amount property.
        /// </summary>
        public decimal Amount { get; set; }
        /// <summary>
        /// خاصية TransactionId.
        /// TransactionId property.
        /// </summary>
        public string TransactionId { get; set; } = null!;
        /// <summary>
        /// خاصية Notes.
        /// Notes property.
        /// </summary>
        public string? Notes { get; set; }
        /// <summary>
        /// خاصية EventId.
        /// EventId property.
        /// </summary>
        public Guid EventId { get; set; }
        /// <summary>
        /// خاصية OccurredOn.
        /// OccurredOn property.
        /// </summary>
        public DateTime OccurredOn { get; set; }
        /// <summary>
        /// خاصية EventType.
        /// EventType property.
        /// </summary>
        public string EventType { get; set; }
        /// <summary>
        /// خاصية Version.
        /// Version property.
        /// </summary>
        public int Version { get; set; }
        /// <summary>
        /// خاصية UserId.
        /// UserId property.
        /// </summary>
        public Guid? UserId { get; set; }
        /// <summary>
        /// خاصية CorrelationId.
        /// CorrelationId property.
        /// </summary>
        public string? CorrelationId { get; set; }

    }

    /// <summary>
    /// Event for voided payments
    /// </summary>
    public class PaymentVoidedEvent : IPaymentFailedEvent
    {
        /// <summary>
        /// خاصية PaymentId.
        /// PaymentId property.
        /// </summary>
        public Guid PaymentId { get; set; }
        /// <summary>
        /// خاصية BookingId.
        /// BookingId property.
        /// </summary>
        public Guid BookingId { get; set; }
        /// <summary>
        /// خاصية AttemptedAt.
        /// AttemptedAt property.
        /// </summary>
        public DateTime AttemptedAt { get; set; } = DateTime.UtcNow;
        /// <summary>
        /// خاصية UserId.
        /// UserId property.
        /// </summary>
        public Guid? UserId { get; set; }
        /// <summary>
        /// خاصية AttemptedAmount.
        /// AttemptedAmount property.
        /// </summary>
        public Money AttemptedAmount { get; set; }
        /// <summary>
        /// خاصية Method.
        /// Method property.
        /// </summary>
        public string Method { get; set; } = null!;
        /// <summary>
        /// خاصية FailureReason.
        /// FailureReason property.
        /// </summary>
        public string FailureReason { get; set; } = null!;
        /// <summary>
        /// خاصية ErrorCode.
        /// ErrorCode property.
        /// </summary>
        public string? ErrorCode { get; set; }
                /// <summary>
                /// خاصية EventId.
                /// EventId property.
                /// </summary>
                public Guid EventId { get; set; }
        /// <summary>
        /// خاصية OccurredOn.
        /// OccurredOn property.
        /// </summary>
        public DateTime OccurredOn { get; set; }
        /// <summary>
        /// خاصية EventType.
        /// EventType property.
        /// </summary>
        public string EventType { get; set; }
        /// <summary>
        /// خاصية Version.
        /// Version property.
        /// </summary>
        public int Version { get; set; }
        /// <summary>
        /// خاصية CorrelationId.
        /// CorrelationId property.
        /// </summary>
        public string? CorrelationId { get; set; }

    }
} 