namespace YemenBooking.Application.Features.Chat.Commands.Reaction
{
    using System;
    using MediatR;
    using YemenBooking.Application.Common.Models;

    /// <summary>
    /// يمثل أمرًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area command.
    /// </summary>
    public class RemoveReactionCommand : IRequest<ResultDto>
    {
        /// <summary>
        /// معرّف الرسالة التي ستُزال منها الإشارة.
        /// Message identifier from which the reaction will be removed.
        /// </summary>
        public Guid MessageId { get; set; }

        /// <summary>
        /// نوع الإشارة المطلوب إزالتها.
        /// Reaction type to remove.
        /// </summary>
        public string ReactionType { get; set; } = string.Empty;
    }
} 
