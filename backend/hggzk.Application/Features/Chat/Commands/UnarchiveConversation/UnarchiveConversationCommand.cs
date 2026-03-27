namespace YemenBooking.Application.Features.Chat.Commands.UnarchiveConversation
{
    using System;
    using MediatR;
    using YemenBooking.Application.Common.Models;

    /// <summary>
    /// يمثل أمرًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area command.
    /// </summary>
    public class UnarchiveConversationCommand : IRequest<ResultDto>
    {
        /// <summary>
        /// معرّف المحادثة المطلوب إلغاء أرشفتها.
        /// Conversation identifier to restore from archive.
        /// </summary>
        public Guid ConversationId { get; set; }
    }
} 
