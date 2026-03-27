using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Chat.Commands.Conversation
{
    /// <summary>
    /// يمثل أمرًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area command.
    /// </summary>
    public class DeleteConversationCommand : IRequest<ResultDto>
    {
        /// <summary>
        /// معرّف المحادثة المطلوب حذفها.
        /// Conversation identifier to delete.
        /// </summary>
        public Guid ConversationId { get; set; }
    }
} 
