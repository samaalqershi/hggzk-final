using YemenBooking.Application.Features.Chat.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Chat.Queries.GetConversationsByParticipant
{
    using MediatR;
    using YemenBooking.Application.Common.Models;

    /// <summary>
    /// يمثل استعلامًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area query.
    /// </summary>
    public class GetConversationsByParticipantQuery : IRequest<PaginatedResult<ChatConversationDto>>
    {
        /// <summary>
        /// رقم الصفحة المراد استرجاعها.
        /// Page number to retrieve.
        /// </summary>
        public int PageNumber { get; set; } = 1;

        /// <summary>
        /// حجم الصفحة المطلوبة.
        /// Requested page size.
        /// </summary>
        public int PageSize { get; set; } = 20;
    }
} 
