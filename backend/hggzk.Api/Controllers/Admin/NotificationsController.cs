using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Notifications.Commands.ManageNotifications;
using YemenBooking.Application.Features.Notifications.Commands.BroadcastNotifications;
using YemenBooking.Application.Features.Notifications.Queries.GetUserNotifications;
using YemenBooking.Application.Features.Notifications.Queries.GetNotificationsStats;
using YemenBooking.Application.Features.Notifications.Queries.GetSystemNotifications;
using YemenBooking.Application.Features.Notifications.DTOs;
using System;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يوفّر إدارة إشعارات النظام من لوحة الإدارة.
    /// Provides system notification management for admins.
    /// </summary>
    public class NotificationsController : BaseAdminController
    {
    /// <summary>
    /// يهيئ المتحكم بالاعتماد على Mediator.
    /// Initializes the controller with Mediator.
    /// </summary>
        public NotificationsController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// ينشئ إشعارًا جديدًا.
        /// Creates a new notification.
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreateNotification([FromBody] CreateNotificationCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يبث إشعارًا إلى مجموعة من المستخدمين.
        /// Broadcasts a notification to a user group.
        /// </summary>
        [HttpPost("broadcast")]
        public async Task<ActionResult<ResultDto<int>>> Broadcast([FromBody] BroadcastNotificationCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يجلب إشعارات النظام.
        /// Retrieves system notifications.
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetSystemNotifications([FromQuery] GetSystemNotificationsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب إشعارات مستخدم محدد.
        /// Retrieves notifications for a specific user.
        /// </summary>
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUserNotifications(Guid userId, [FromQuery] GetUserNotificationsQuery query)
        {
            query.UserId = userId;
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يحذف إشعارًا.
        /// Deletes a notification.
        /// </summary>
        [HttpDelete("{notificationId}")]
        public async Task<ActionResult<ResultDto<bool>>> Delete(Guid notificationId)
        {
            var result = await _mediator.Send(new DeleteNotificationCommand { NotificationId = notificationId });
            return Ok(result);
        }

        /// <summary>
        /// يعيد إرسال إشعار تعذر تسليمه.
        /// Resends a notification that failed to deliver.
        /// </summary>
        [HttpPost("{notificationId}/resend")]
        public async Task<ActionResult<ResultDto<bool>>> Resend(Guid notificationId)
        {
            var result = await _mediator.Send(new ResendNotificationCommand { NotificationId = notificationId });
            return Ok(result);
        }

        /// <summary>
        /// يجلب إحصائيات الإشعارات.
        /// Retrieves notification statistics.
        /// </summary>
        [HttpGet("stats")]
        public async Task<ActionResult<NotificationsStatsDto>> GetStats([FromQuery] GetNotificationsStatsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
} 
