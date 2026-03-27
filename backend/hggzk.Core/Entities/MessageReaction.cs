namespace YemenBooking.Core.Entities
{
    using System;
    using System.ComponentModel.DataAnnotations;

    /// <summary>
    /// تفاعل يضيفه المستخدم على رسالة.
    /// User reaction applied to a message.
    /// </summary>
    [Display(Name = "تفاعل الرسالة")]
    public class MessageReaction : BaseEntity<Guid>
    {
        /// <summary>
        /// معرف الرسالة المرتبط بالتفاعل.
        /// Message identifier for this reaction.
        /// </summary>
        [Display(Name = "معرف الرسالة")]
        public Guid MessageId { get; set; }

        /// <summary>
        /// معرف المستخدم الذي قام بالتفاعل.
        /// Identifier of the reacting user.
        /// </summary>
        [Display(Name = "معرف المستخدم")]
        public Guid UserId { get; set; }

        /// <summary>
        /// نوع التفاعل.
        /// Reaction type.
        /// </summary>
        [Display(Name = "نوع التفاعل")]
        public string ReactionType { get; set; } = string.Empty;
    }
} 
