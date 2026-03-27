namespace YemenBooking.Application.Features.Chat.DTOs {
    using System;

    /// <summary>
    /// DTO لتمثيل تفاعل على رسالة
    /// DTO for MessageReaction entity
    /// </summary>
    public class MessageReactionDto
    {
        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        public Guid Id { get; set; }
        /// <summary>
        /// خاصية MessageId.
        /// MessageId property.
        /// </summary>
        public Guid MessageId { get; set; }
        /// <summary>
        /// خاصية UserId.
        /// UserId property.
        /// </summary>
        public Guid UserId { get; set; }
        /// <summary>
        /// خاصية ReactionType.
        /// ReactionType property.
        /// </summary>
        public string ReactionType { get; set; } = string.Empty;
    }
} 