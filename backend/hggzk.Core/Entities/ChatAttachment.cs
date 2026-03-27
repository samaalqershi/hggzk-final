namespace YemenBooking.Core.Entities
{
    using System;
    using System.ComponentModel.DataAnnotations;

    /// <summary>
    /// مرفق مرتبط برسالة أو محادثة.
    /// Attachment linked to a message or conversation.
    /// </summary>
    [Display(Name = "مرفق المحادثة")]
    public class ChatAttachment : BaseEntity<Guid>
    {
        /// <summary>
        /// معرف المحادثة المرتبطة بالمرفق.
        /// Conversation identifier for this attachment.
        /// </summary>
        [Display(Name = "معرف المحادثة")]
        public Guid ConversationId { get; set; }

        /// <summary>
        /// اسم الملف الأصلي.
        /// Original file name.
        /// </summary>
        [Display(Name = "اسم الملف الأصلي")]
        public string FileName { get; set; } = string.Empty;

        /// <summary>
        /// نوع المحتوى للملف.
        /// File content type.
        /// </summary>
        [Display(Name = "نوع المحتوى")]
        public string ContentType { get; set; } = string.Empty;

        /// <summary>
        /// حجم الملف بالبايت.
        /// File size in bytes.
        /// </summary>
        [Display(Name = "حجم الملف (بايت)")]
        public long FileSize { get; set; }

        /// <summary>
        /// مسار الملف على الخادم.
        /// File path on the server.
        /// </summary>
        [Display(Name = "مسار الملف على الخادم")]
        public string FilePath { get; set; } = string.Empty;
        /// <summary>
        /// رابط الصورة المصغرة إن وُجد.
        /// Thumbnail URL, if available.
        /// </summary>
        public string? ThumbnailUrl { get; set; }
        /// <summary>
        /// بيانات وصفية إضافية بصيغة JSON عند الحاجة.
        /// Additional metadata as JSON, when present.
        /// </summary>
        public string? Metadata { get; set; }

        /// <summary>
        /// معرف الرسالة المرتبط بها المرفق.
        /// Message identifier associated with this attachment.
        /// </summary>
        public Guid? MessageId { get; set; }

        /// <summary>
        /// الرسالة المرتبط بها المرفق.
        /// Related message for this attachment.
        /// </summary>
        public virtual ChatMessage? Message { get; set; }

        /// <summary>
        /// مدة المرفق بالثواني للوسائط الصوتية أو المرئية.
        /// Attachment duration in seconds for audio or video.
        /// </summary>
        public int? DurationSeconds { get; set; }

        /// <summary>
        /// المستخدم الذي رفع الملف.
        /// User who uploaded the file.
        /// </summary>
        [Display(Name = "رفعه بواسطة")]
        public Guid UploadedBy { get; set; }

        /// <summary>
        /// تاريخ رفع الملف.
        /// File upload date.
        /// </summary>
        [Display(Name = "تاريخ الرفع")]
        public new DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
