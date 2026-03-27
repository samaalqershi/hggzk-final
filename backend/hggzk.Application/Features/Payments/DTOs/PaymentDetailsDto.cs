using System;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Bookings.DTOs;

namespace YemenBooking.Application.Features.Payments.DTOs
{
    /// <summary>
    /// تفاصيل الدفع
    /// Payment details DTO
    /// </summary>
    public class PaymentDetailsDto
    {
        /// <summary>
        /// بيانات الدفع
        /// Payment data
        /// </summary>
        public PaymentDto Payment { get; set; }

        /// <summary>
        /// قائمة الاستردادات
        /// List of refunds
        /// </summary>
        public List<RefundDto> Refunds { get; set; } = new List<RefundDto>();

        /// <summary>
        /// قائمة الأنشطة
        /// List of activities
        /// </summary>
        public List<PaymentActivityDto> Activities { get; set; } = new List<PaymentActivityDto>();

        /// <summary>
        /// معلومات الحجز
        /// BookingDto information
        /// </summary>
        public BookingInfoDto? BookingInfo { get; set; }

        /// <summary>
        /// معلومات بوابة الدفع
        /// Payment gateway information
        /// </summary>
        public PaymentGatewayInfoDto? GatewayInfo { get; set; }
    }

    /// <summary>
    /// معلومات نشاط الدفع
    /// Payment activity DTO
    /// </summary>
    public class PaymentActivityDto
    {
        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        public string Id { get; set; }
        /// <summary>
        /// خاصية Action.
        /// Action property.
        /// </summary>
        public string Action { get; set; }
        /// <summary>
        /// خاصية Description.
        /// Description property.
        /// </summary>
        public string Description { get; set; }
        /// <summary>
        /// خاصية Timestamp.
        /// Timestamp property.
        /// </summary>
        public DateTime Timestamp { get; set; }
        /// <summary>
        /// خاصية UserId.
        /// UserId property.
        /// </summary>
        public string? UserId { get; set; }
        /// <summary>
        /// خاصية UserName.
        /// UserName property.
        /// </summary>
        public string? UserName { get; set; }
        /// <summary>
        /// خاصية Data.
        /// Data property.
        /// </summary>
        public Dictionary<string, object>? Data { get; set; }
    }

    /// <summary>
    /// معلومات الاسترداد
    /// Refund DTO
    /// </summary>
    public class RefundDto
    {
        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        public string Id { get; set; }
        /// <summary>
        /// خاصية PaymentId.
        /// PaymentId property.
        /// </summary>
        public string PaymentId { get; set; }
        /// <summary>
        /// خاصية Amount.
        /// Amount property.
        /// </summary>
        public MoneyDto Amount { get; set; }
        /// <summary>
        /// خاصية Reason.
        /// Reason property.
        /// </summary>
        public string Reason { get; set; }
        /// <summary>
        /// خاصية Status.
        /// Status property.
        /// </summary>
        public string Status { get; set; }
        /// <summary>
        /// خاصية RequestedAt.
        /// RequestedAt property.
        /// </summary>
        public DateTime RequestedAt { get; set; }
        /// <summary>
        /// خاصية ProcessedAt.
        /// ProcessedAt property.
        /// </summary>
        public DateTime? ProcessedAt { get; set; }
        /// <summary>
        /// خاصية TransactionId.
        /// TransactionId property.
        /// </summary>
        public string? TransactionId { get; set; }
        /// <summary>
        /// خاصية ProcessedBy.
        /// ProcessedBy property.
        /// </summary>
        public string? ProcessedBy { get; set; }
        /// <summary>
        /// خاصية Notes.
        /// Notes property.
        /// </summary>
        public string? Notes { get; set; }
        /// <summary>
        /// خاصية Type.
        /// Type property.
        /// </summary>
        public string? Type { get; set; }
        /// <summary>
        /// خاصية Metadata.
        /// Metadata property.
        /// </summary>
        public Dictionary<string, object>? Metadata { get; set; }
    }

    /// <summary>
    /// معلومات الحجز
    /// BookingDto information DTO
    /// </summary>
    public class BookingInfoDto
    {
        /// <summary>
        /// خاصية BookingId.
        /// BookingId property.
        /// </summary>
        public string BookingId { get; set; }
        /// <summary>
        /// خاصية BookingReference.
        /// BookingReference property.
        /// </summary>
        public string BookingReference { get; set; }
        /// <summary>
        /// خاصية CheckIn.
        /// CheckIn property.
        /// </summary>
        public DateTime CheckIn { get; set; }
        /// <summary>
        /// خاصية CheckOut.
        /// CheckOut property.
        /// </summary>
        public DateTime CheckOut { get; set; }
        /// <summary>
        /// خاصية UnitName.
        /// UnitName property.
        /// </summary>
        public string UnitName { get; set; }
        /// <summary>
        /// خاصية PropertyName.
        /// PropertyName property.
        /// </summary>
        public string PropertyName { get; set; }
        /// <summary>
        /// خاصية GuestsCount.
        /// GuestsCount property.
        /// </summary>
        public int GuestsCount { get; set; }
    }

    /// <summary>
    /// معلومات بوابة الدفع
    /// Payment gateway information DTO
    /// </summary>
    public class PaymentGatewayInfoDto
    {
        /// <summary>
        /// خاصية GatewayName.
        /// GatewayName property.
        /// </summary>
        public string GatewayName { get; set; }
        /// <summary>
        /// خاصية GatewayTransactionId.
        /// GatewayTransactionId property.
        /// </summary>
        public string GatewayTransactionId { get; set; }
        /// <summary>
        /// خاصية AuthorizationCode.
        /// AuthorizationCode property.
        /// </summary>
        public string? AuthorizationCode { get; set; }
        /// <summary>
        /// خاصية ResponseCode.
        /// ResponseCode property.
        /// </summary>
        public string? ResponseCode { get; set; }
        /// <summary>
        /// خاصية ResponseMessage.
        /// ResponseMessage property.
        /// </summary>
        public string? ResponseMessage { get; set; }
        /// <summary>
        /// خاصية RawResponse.
        /// RawResponse property.
        /// </summary>
        public Dictionary<string, object>? RawResponse { get; set; }
    }
} 