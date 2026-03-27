using MediatR;
using System;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Chat.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Chat.Queries.GetConversationById
{
    /// <summary>
    /// يمثل استعلامًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area query.
    /// </summary>
    public class GetConversationByIdQuery : IRequest<ResultDto<ChatConversationDto>>
    {
        /// <summary>
        /// معرّف المحادثة المطلوب استرجاعها.
        /// Conversation identifier to retrieve.
        /// </summary>
        public Guid ConversationId { get; set; }
    }
} 
