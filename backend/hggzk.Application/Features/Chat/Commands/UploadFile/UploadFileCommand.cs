using System;
using System.Text.Json.Serialization;
using MediatR;
using Microsoft.AspNetCore.Http;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Chat.DTOs;

namespace YemenBooking.Application.Features.Chat.Commands.UploadFile
{
    /// <summary>
    /// يمثل أمرًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area command.
    /// </summary>
    public class UploadFileCommand : IRequest<ResultDto<ChatAttachmentDto>>
    {
        /// <summary>
        /// الملف المراد رفعه.
        /// File to upload.
        /// </summary>
        [JsonPropertyName("file")]
        public IFormFile File { get; set; } = default!;

        /// <summary>
        /// صورة مصغرة اختيارية، وتُستخدم غالبًا مع ملفات الفيديو.
        /// Optional thumbnail image, usually used for video files.
        /// </summary>
        [JsonPropertyName("thumbnail")]
        public IFormFile? Thumbnail { get; set; }

        /// <summary>
        /// نوع الرسالة الذي يحدد فئة المرفق.
        /// Message type used to categorize the attachment.
        /// </summary>
        [JsonPropertyName("message_type")]
        public string MessageType { get; set; } = string.Empty;

        /// <summary>
        /// معرّف المحادثة المرتبط بالمرفق.
        /// Conversation identifier associated with the attachment.
        /// </summary>
        public Guid ConversationId { get; set; }

        /// <summary>
        /// مدة المرفق الصوتي القادمة من العميل عندما تكون معروفة.
        /// Client-reported audio duration when the recorder already knows it.
        /// </summary>
        public int? DurationSeconds { get; set; }
    }
}
