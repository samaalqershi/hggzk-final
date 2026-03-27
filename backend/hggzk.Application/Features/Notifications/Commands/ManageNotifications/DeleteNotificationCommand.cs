using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Notifications.Commands.ManageNotifications
{
    /// <summary>
    /// يمثل أمرًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area command.
    /// </summary>
    public class DeleteNotificationCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// معرّف الإشعار.
        /// Notification identifier.
        /// </summary>
        public Guid NotificationId { get; set; }
    }
}

