using YemenBooking.Application.Features.Chat.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Chat.Queries.GetMessagesByConversation
{
    using System;
    using MediatR;
    using YemenBooking.Application.Common.Models;

    /// <summary>
    /// يمثل استعلامًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area query.
    /// </summary>
    public class GetMessagesByConversationQuery : IRequest<PaginatedResult<ChatMessageDto>>
    {
        /// <summary>
        /// معرّف المحادثة المراد استرجاع رسائلها.
        /// Conversation identifier whose messages will be retrieved.
        /// </summary>
        public Guid ConversationId { get; set; }

        /// <summary>
        /// رقم الصفحة المراد استرجاعها.
        /// Page number to retrieve.
        /// </summary>
        public int PageNumber { get; set; } = 1;

        /// <summary>
        /// حجم الصفحة المطلوبة.
        /// Requested page size.
        /// </summary>
        public int PageSize { get; set; } = 50;

        /// <summary>
        /// معرّف الرسالة التي يبدأ الاسترجاع من قبلها، إن وجد.
        /// Identifier of the message used as an upper bound, when present.
        /// </summary>
        public Guid? BeforeMessageId { get; set; }
    }
} 
