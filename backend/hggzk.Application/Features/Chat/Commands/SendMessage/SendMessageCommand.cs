using YemenBooking.Application.Features.Chat.DTOs;

namespace YemenBooking.Application.Features.Chat.Commands.SendMessage
{
    using System;
    using System.Collections.Generic;
    using Microsoft.AspNetCore.Http;
    using MediatR;
    using YemenBooking.Application.Common.Models;

    /// <summary>
    /// يمثل أمر إرسال رسالة ضمن نطاق الدردشة.
    /// Represents a command to send a chat message.
    /// </summary>
    public class SendMessageCommand : IRequest<ResultDto<ChatMessageDto>>
    {
        /// <summary>
        /// معرّف المحادثة المستهدفة.
        /// Target conversation identifier.
        /// </summary>
        public Guid ConversationId { get; set; }

        /// <summary>
        /// نوع الرسالة المراد إرسالها.
        /// Message type to send.
        /// </summary>
        public string MessageType { get; set; } = string.Empty;

        /// <summary>
        /// محتوى الرسالة عند الحاجة.
        /// Message content when applicable.
        /// </summary>
        public string? Content { get; set; }

        /// <summary>
        /// بيانات الموقع بصيغة JSON عند إرسال موقع.
        /// Location payload as JSON when sending a location.
        /// </summary>
        public string? LocationJson { get; set; }

        /// <summary>
        /// معرّف الرسالة الأصلية في حالة الرد، إن وجد.
        /// Identifier of the original message when replying, if any.
        /// </summary>
        public Guid? ReplyToMessageId { get; set; }

        /// <summary>
        /// الملفات المرفقة مع الرسالة.
        /// Files attached to the message.
        /// </summary>
        public List<IFormFile>? Attachments { get; set; }

        /// <summary>
        /// معرّفات المرفقات المخزنة مسبقًا، إن وجدت.
        /// Identifiers of pre-stored attachments, if any.
        /// </summary>
        public List<Guid>? AttachmentIds { get; set; }
    }
} 
