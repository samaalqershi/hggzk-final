using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Chat.DTOs {
    using System;
    using System.Collections.Generic;
    using System.Text.Json.Serialization;

    /// <summary>
    /// DTO لتمثيل رسالة المحادثة
    /// DTO for ChatMessage entity
    /// </summary>
    public class ChatMessageDto
    {
        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        [JsonPropertyName("message_id")]
        public Guid Id { get; set; }
        /// <summary>
        /// خاصية ConversationId.
        /// ConversationId property.
        /// </summary>
        public Guid ConversationId { get; set; }
        /// <summary>
        /// خاصية SenderId.
        /// SenderId property.
        /// </summary>
        public Guid SenderId { get; set; }
        /// <summary>
        /// خاصية MessageType.
        /// MessageType property.
        /// </summary>
        public string MessageType { get; set; } = string.Empty;
        /// <summary>
        /// خاصية Content.
        /// Content property.
        /// </summary>
        public string? Content { get; set; }
        /// <summary>
        /// خاصية Location.
        /// Location property.
        /// </summary>
        public LocationDto? Location { get; set; }
        /// <summary>
        /// خاصية ReplyToMessageId.
        /// ReplyToMessageId property.
        /// </summary>
        public Guid? ReplyToMessageId { get; set; }
        /// <summary>
        /// خاصية Reactions.
        /// Reactions property.
        /// </summary>
        public IEnumerable<MessageReactionDto> Reactions { get; set; } = new List<MessageReactionDto>();
        /// <summary>
        /// خاصية Attachments.
        /// Attachments property.
        /// </summary>
        public IEnumerable<ChatAttachmentDto> Attachments { get; set; } = new List<ChatAttachmentDto>();
        /// <summary>
        /// خاصية CreatedAt.
        /// CreatedAt property.
        /// </summary>
        public DateTime CreatedAt { get; set; }
        /// <summary>
        /// خاصية UpdatedAt.
        /// UpdatedAt property.
        /// </summary>
        public DateTime UpdatedAt { get; set; }
        /// <summary>
        /// حالة الرسالة (sent, delivered, read, failed)
        /// Message status
        /// </summary>
        public string Status { get; set; } = string.Empty;

        /// <summary>
        /// Indicates if the message was edited
        /// ما إذا كانت الرسالة معدلة
        /// </summary>
        public bool IsEdited { get; set; }

        /// <summary>
        /// Timestamp when the message was edited
        /// وقت تعديل الرسالة
        /// </summary>
        public DateTime? EditedAt { get; set; }

        /// <summary>
        /// إيصال التسليم والقراءة
        /// Delivery and read receipt
        /// </summary>
        public DeliveryReceiptDto? DeliveryReceipt { get; set; }
    }

    /// <summary>
    /// DTO لإيصال التسليم والقراءة
    /// DTO for delivery and read receipt
    /// </summary>
    public class DeliveryReceiptDto
    {
        /// <summary>
        /// وقت تسليم الرسالة
        /// Delivered timestamp
        /// </summary>
        public DateTime? DeliveredAt { get; set; }

        /// <summary>
        /// وقت قراءة الرسالة
        /// Read timestamp
        /// </summary>
        public DateTime? ReadAt { get; set; }

        /// <summary>
        /// قائمة معرفات المستخدمين الذين قرأوا الرسالة
        /// List of user IDs who read the message
        /// </summary>
        public IEnumerable<string>? ReadBy { get; set; }
    }
} 