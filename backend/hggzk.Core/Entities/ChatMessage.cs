namespace YemenBooking.Core.Entities
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;

    /// <summary>
    /// رسالة مرسلة ضمن محادثة.
    /// Message sent within a conversation.
    /// </summary>
    [Display(Name = "رسالة المحادثة")]
    public class ChatMessage : BaseEntity<Guid>
    {
        /// <summary>
        /// معرف المحادثة التي تنتمي إليها الرسالة.
        /// Conversation identifier for this message.
        /// </summary>
        [Display(Name = "معرف المحادثة")]
        public Guid ConversationId { get; set; }

        /// <summary>
        /// معرف المستخدم المرسل للرسالة.
        /// Identifier of the user who sent the message.
        /// </summary>
        [Display(Name = "مرسل الرسالة")]
        public Guid SenderId { get; set; }

        /// <summary>
        /// المستخدم المرسل.
        /// Sender user.
        /// </summary>
        [ForeignKey(nameof(SenderId))]
        public virtual User? Sender { get; set; }

        /// <summary>
        /// المحادثة المرتبطة بالرسالة.
        /// Related conversation.
        /// </summary>
        [ForeignKey(nameof(ConversationId))]
        public virtual ChatConversation? Conversation { get; set; }

        /// <summary>
        /// نوع الرسالة.
        /// Message type.
        /// </summary>
        [Display(Name = "نوع الرسالة")]
        public string MessageType { get; set; } = string.Empty;

        /// <summary>
        /// محتوى الرسالة للنصوص.
        /// Message content for text messages.
        /// </summary>
        [Display(Name = "محتوى الرسالة")]
        public string? Content { get; set; }

        /// <summary>
        /// بيانات الموقع عند كون الرسالة من نوع موقع.
        /// Location data when the message is a location message.
        /// </summary>
        public string? LocationJson { get; set; }

        /// <summary>
        /// معرف الرسالة الأصلية عند كونها ردًا.
        /// Identifier of the parent message when this is a reply.
        /// </summary>
        [Display(Name = "معرّف الرسالة المرد عليها")]
        public Guid? ReplyToMessageId { get; set; }

        /// <summary>
        /// الرسالة الأصلية التي جرى الرد عليها.
        /// Original message being replied to.
        /// </summary>
        [ForeignKey(nameof(ReplyToMessageId))]
        public virtual ChatMessage? ReplyToMessage { get; set; }

        /// <summary>
        /// حالة الرسالة الحالية.
        /// Current message status.
        /// </summary>
        public string Status { get; set; } = string.Empty;

        /// <summary>
        /// يحدد ما إذا كانت الرسالة قد عُدلت.
        /// Indicates whether the message was edited.
        /// </summary>
        public bool IsEdited { get; set; }

        /// <summary>
        /// وقت تعديل الرسالة.
        /// Message edit time.
        /// </summary>
        public DateTime? EditedAt { get; set; }

        /// <summary>
        /// وقت تسليم الرسالة.
        /// Message delivery time.
        /// </summary>
        public DateTime? DeliveredAt { get; set; }

        /// <summary>
        /// وقت قراءة الرسالة.
        /// Message read time.
        /// </summary>
        public DateTime? ReadAt { get; set; }

        /// <summary>
        /// تفاعلات هذه الرسالة.
        /// Reactions to this message.
        /// </summary>
        public virtual ICollection<MessageReaction> Reactions { get; set; } = new List<MessageReaction>();

        /// <summary>
        /// مرفقات هذه الرسالة.
        /// Attachments for this message.
        /// </summary>
        public virtual ICollection<ChatAttachment> Attachments { get; set; } = new List<ChatAttachment>();
    }
}
