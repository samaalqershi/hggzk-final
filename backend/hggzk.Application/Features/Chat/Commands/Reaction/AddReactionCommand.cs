namespace YemenBooking.Application.Features.Chat.Commands.Reaction
{
    using System;
    using MediatR;
    using YemenBooking.Application.Common.Models;

    /// <summary>
    /// يمثل أمرًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area command.
    /// </summary>
    public class AddReactionCommand : IRequest<ResultDto>
    {
        /// <summary>
        /// معرّف الرسالة التي ستُضاف إليها الإشارة.
        /// Message identifier that will receive the reaction.
        /// </summary>
        public Guid MessageId { get; set; }

        /// <summary>
        /// نوع الإشارة العاطفية أو التفاعل.
        /// Reaction type to apply.
        /// </summary>
        public string ReactionType { get; set; } = string.Empty;
    }
} 
