namespace YemenBooking.Core.Entities
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;

    /// <summary>
    /// محادثة بين مستخدمين أو مجموعة.
    /// Conversation between users or in a group.
    /// </summary>
    [Display(Name = "المحادثة")]
    public class ChatConversation : BaseEntity<Guid>
    {
        /// <summary>
        /// نوع المحادثة، مثل المباشرة أو الجماعية.
        /// Conversation type, such as direct or group.
        /// </summary>
        [Display(Name = "نوع المحادثة")]
        public string ConversationType { get; set; } = string.Empty;

        /// <summary>
        /// عنوان المحادثة للمجموعات.
        /// Conversation title for group chats.
        /// </summary>
        [Display(Name = "عنوان المحادثة")]
        public string? Title { get; set; }

        /// <summary>
        /// وصف المحادثة عند الحاجة.
        /// Optional conversation description.
        /// </summary>
        [Display(Name = "وصف المحادثة")]
        public string? Description { get; set; }

        /// <summary>
        /// مسار الصورة الرمزية للمحادثة.
        /// Conversation avatar path.
        /// </summary>
        [Display(Name = "الصورة الرمزية")]
        public string? Avatar { get; set; }

        /// <summary>
        /// يحدد ما إذا كانت المحادثة مؤرشفة.
        /// Indicates whether the conversation is archived.
        /// </summary>
        [Display(Name = "مؤرشفة")]
        public bool IsArchived { get; set; } = false;

        /// <summary>
        /// يحدد ما إذا كانت تنبيهات المحادثة مكتومة.
        /// Indicates whether notifications are muted for this conversation.
        /// </summary>
        [Display(Name = "صامتة")]
        public bool IsMuted { get; set; } = false;

        /// <summary>
        /// المعرف المرتبط بالمرفق أو الفندق.
        /// Identifier of the related property or hotel.
        /// </summary>
        [Display(Name = "معرف الفندق")]
        public Guid? PropertyId { get; set; }

        /// <summary>
        /// الكيان المرتبط بالمحادثة.
        /// Related property entity.
        /// </summary>
        public virtual Property? Property { get; set; }

        /// <summary>
        /// مرفقات هذه المحادثة.
        /// Attachments in this conversation.
        /// </summary>
        public virtual ICollection<ChatAttachment> Attachments { get; set; } = new List<ChatAttachment>();

        /// <summary>
        /// رسائل هذه المحادثة.
        /// Messages in this conversation.
        /// </summary>
        public virtual ICollection<ChatMessage> Messages { get; set; } = new List<ChatMessage>();

        /// <summary>
        /// المشاركون في المحادثة.
        /// Conversation participants.
        /// </summary>
        public virtual ICollection<User> Participants { get; set; } = new List<User>();
    }
} 
