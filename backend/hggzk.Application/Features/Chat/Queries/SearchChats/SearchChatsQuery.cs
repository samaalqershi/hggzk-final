using YemenBooking.Application.Features.Chat.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Chat.Queries.SearchChats
{
    using System;
    using global::YemenBooking.Application.Common.Models;
    using MediatR;

    /// <summary>
    /// يمثل استعلامًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area query.
    /// </summary>
    public class SearchChatsQuery : IRequest<ResultDto<SearchChatsResultDto>>
    {
        /// <summary>
        /// نص البحث المطلوب استخدامه.
        /// Search text to use.
        /// </summary>
        public string Query { get; set; } = string.Empty;

        /// <summary>
        /// معرّف المحادثة المطلوب تضييق البحث ضمنها، إن وجد.
        /// Conversation identifier used to narrow the search, when provided.
        /// </summary>
        public Guid? ConversationId { get; set; }

        /// <summary>
        /// نوع الرسالة المطلوب تضمينه في البحث، إن وجد.
        /// Message type to include in the search, when provided.
        /// </summary>
        public string? MessageType { get; set; }

        /// <summary>
        /// معرّف المرسل المطلوب تصفية النتائج وفقًا له، إن وجد.
        /// Sender identifier used to filter results, when provided.
        /// </summary>
        public Guid? SenderId { get; set; }

        /// <summary>
        /// تاريخ بداية فترة البحث، إن وجد.
        /// Start date for the search window, when provided.
        /// </summary>
        public DateTime? DateFrom { get; set; }

        /// <summary>
        /// تاريخ نهاية فترة البحث، إن وجد.
        /// End date for the search window, when provided.
        /// </summary>
        public DateTime? DateTo { get; set; }

        /// <summary>
        /// رقم الصفحة المراد استرجاعها.
        /// Page number to retrieve.
        /// </summary>
        public int Page { get; set; } = 1;

        /// <summary>
        /// الحد الأقصى لعدد النتائج في الصفحة.
        /// Maximum number of results per page.
        /// </summary>
        public int Limit { get; set; } = 20;
    }
} 
