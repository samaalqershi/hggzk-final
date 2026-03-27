namespace YemenBooking.Application.Features.Chat.Commands.ArchiveConversation
{
    using System;
    using MediatR;
    using YemenBooking.Application.Common.Models;

    /// <summary>
    /// يمثل أمر أرشفة محادثة ضمن نطاق الدردشة.
    /// Represents a command to archive a chat conversation.
    /// </summary>
    public class ArchiveConversationCommand : IRequest<ResultDto>
    {
        /// <summary>
        /// معرّف المحادثة المطلوب أرشفتها.
        /// Conversation identifier to archive.
        /// </summary>
        public Guid ConversationId { get; set; }
    }
} 
