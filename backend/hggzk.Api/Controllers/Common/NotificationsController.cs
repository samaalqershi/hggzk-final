using System;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Notifications.Commands.MarkAllNotificationsAsRead;
using YemenBooking.Application.Features.Notifications.Commands.ManageNotifications;
using YemenBooking.Application.Features.Notifications.Queries.GetUserNotifications;

namespace YemenBooking.Api.Controllers.Common
{
    /// <summary>
    /// عمليات الإشعارات المشتركة على مستوى النظام.
    /// Shared system notification operations.
    /// </summary>
    public class NotificationsController : BaseCommonController
    {
        /// <summary>
        /// ينشئ متحكم الإشعارات مع المرسل الوسيط.
        /// Creates the notifications controller with the mediator.
        /// </summary>
        public NotificationsController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// يعلّم جميع الإشعارات على أنها مقروءة.
        /// Marks all notifications as read.
        /// </summary>
        [HttpPost("mark-all-read")]
        public async Task<IActionResult> MarkAllNotificationsRead()
        {
            var command = new MarkAllNotificationsReadCommand();
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعلّم إشعارًا محددًا على أنه مقروء.
        /// Marks a single notification as read.
        /// </summary>
        [HttpPost("{notificationId}/read")]
        public async Task<IActionResult> MarkNotificationAsRead(Guid notificationId)
        {
            var command = new MarkNotificationAsReadCommand { NotificationId = notificationId };
            var result = await _mediator.Send(command);
            return Ok(result);
        }
    }
} 
