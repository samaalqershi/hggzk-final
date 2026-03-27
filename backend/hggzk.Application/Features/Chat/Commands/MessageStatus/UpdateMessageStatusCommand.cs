namespace YemenBooking.Application.Features.Chat.Commands.MessageStatus
{
    using System;
    using MediatR;
    using YemenBooking.Application.Common.Models;

    /// <summary>
    /// يمثل أمرًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area command.
    /// </summary>
    public class UpdateMessageStatusCommand : IRequest<ResultDto>
    {
        /// <summary>
        /// معرّف الرسالة التي سيتم تحديث حالتها.
        /// Message identifier whose status will be updated.
        /// </summary>
        public Guid MessageId { get; set; }

        /// <summary>
        /// الحالة الجديدة للرسالة.
        /// New message status.
        /// </summary>
        public string Status { get; set; } = string.Empty;

        /// <summary>
        /// معرّف المستخدم الذي قام بقراءة الرسالة، إن وجد.
        /// Identifier of the user who read the message, when available.
        /// </summary>
        public Guid? ReadBy { get; set; }
    }
} 
