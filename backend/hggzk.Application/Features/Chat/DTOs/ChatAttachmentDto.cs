namespace YemenBooking.Application.Features.Chat.DTOs {
    using System;
    using System.Text.Json.Serialization;

    /// <summary>
    /// DTO لتمثيل مرفق المحادثة
    /// DTO for ChatAttachment entity
    /// </summary>
    public class ChatAttachmentDto
    {
        /// <summary>
        /// خاصية ConversationId.
        /// ConversationId property.
        /// </summary>
        [JsonPropertyName("conversation_id")]
        public Guid ConversationId { get; set; }

        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        [JsonPropertyName("attachment_id")]
        public Guid Id { get; set; }

        /// <summary>
        /// خاصية FileName.
        /// FileName property.
        /// </summary>
        [JsonPropertyName("file_name")]
        public string FileName { get; set; } = string.Empty;

        /// <summary>
        /// خاصية ContentType.
        /// ContentType property.
        /// </summary>
        [JsonPropertyName("mime_type")]
        public string ContentType { get; set; } = string.Empty;

        /// <summary>
        /// خاصية FileSize.
        /// FileSize property.
        /// </summary>
        [JsonPropertyName("file_size")]
        public long FileSize { get; set; }

        /// <summary>
        /// خاصية FilePath.
        /// FilePath property.
        /// </summary>
        [JsonIgnore]
        public string FilePath { get; set; } = string.Empty;

        /// <summary>
        /// خاصية UploadedBy.
        /// UploadedBy property.
        /// </summary>
        [JsonPropertyName("uploaded_by")]
        public Guid UploadedBy { get; set; }

        /// <summary>
        /// خاصية CreatedAt.
        /// CreatedAt property.
        /// </summary>
        [JsonPropertyName("uploaded_at")]
        public DateTime CreatedAt { get; set; }

        /// <summary>
        /// خاصية FileUrl.
        /// FileUrl property.
        /// </summary>
        [JsonPropertyName("file_url")]
        public string FileUrl => $"/api/common/chat/attachments/{Id}";
        /// <summary>
        /// خاصية ThumbnailUrl.
        /// ThumbnailUrl property.
        /// </summary>
        [JsonPropertyName("thumbnail_url")]
        public string? ThumbnailUrl { get; set; }
        /// <summary>
        /// خاصية Metadata.
        /// Metadata property.
        /// </summary>
        [JsonPropertyName("metadata")]
        public string? Metadata { get; set; }

        /// <summary>
        /// الرسالة المرتبط بها هذا المرفق (لتمكين التجميع الأمامي)
        /// </summary>
        [JsonPropertyName("message_id")]
        public Guid? MessageId { get; set; }

        /// <summary>
        /// مدة المرفق بالثواني (للصوت/الفيديو)
        /// Attachment duration in seconds (audio/video)
        /// </summary>
        [JsonPropertyName("duration")]
        public int? DurationSeconds { get; set; }
    }
}