using YemenBooking.Application.Features.Chat.DTOs;

namespace YemenBooking.Application.Features.Chat.Commands.Conversation
{
    using System;
    using System.Collections.Generic;
    using MediatR;
    using YemenBooking.Application.Common.Models;

    /// <summary>
    /// يمثل أمرًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area command.
    /// </summary>
    public class CreateConversationCommand : IRequest<ResultDto<ChatConversationDto>>
    {
        /// <summary>
        /// معرّفات المشاركين في المحادثة.
        /// Participant identifiers included in the conversation.
        /// </summary>
        public List<Guid> ParticipantIds { get; set; } = new List<Guid>();

        /// <summary>
        /// نوع المحادثة المراد إنشاؤها.
        /// Type of conversation to create.
        /// </summary>
        public string ConversationType { get; set; } = string.Empty;

        /// <summary>
        /// عنوان المحادثة عند الحاجة.
        /// Optional conversation title.
        /// </summary>
        public string? Title { get; set; }

        /// <summary>
        /// وصف اختياري للمحادثة.
        /// Optional conversation description.
        /// </summary>
        public string? Description { get; set; }

        /// <summary>
        /// معرّف العقار المرتبط بالمحادثة عند الحاجة.
        /// Optional property identifier associated with the conversation.
        /// </summary>
        public Guid? PropertyId { get; set; }
    }
} 
