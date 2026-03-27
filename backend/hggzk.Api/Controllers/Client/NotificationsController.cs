using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Notifications.Commands.NotificationSettings;
using YemenBooking.Application.Features.Notifications.Commands.MarkAllNotificationsAsRead;
using YemenBooking.Application.Features.Notifications.Commands.ManageNotifications;
using YemenBooking.Application.Features.Notifications.Commands.DismissNotification;
using YemenBooking.Application.Features.Notifications.Queries.GetUserNotifications;
using YemenBooking.Application.Features.Notifications.Queries.GetNotificationsSummary;
using YemenBooking.Application.Features.Notifications.DTOs;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// متحكم إدارة إشعارات العميل.
    /// Client notifications controller.
    /// </summary>
    public class NotificationsController : BaseClientController
    {
        /// <summary>
        /// يهيئ نسخة جديدة من [NotificationsController].
        /// Initializes a new instance of [NotificationsController].
        /// </summary>
        /// <param name="mediator">وسيط MediatR المستخدم لمعالجة الطلبات. MediatR mediator used to handle requests.</param>
        public NotificationsController(IMediator mediator) : base(mediator)
        {
        }

        /// <summary>
        /// يحدّث إعدادات الإشعارات.
        /// Updates notification settings.
        /// </summary>
        /// <param name="command">إعدادات الإشعارات الجديدة. New notification settings.</param>
        /// <returns>نتيجة التحديث. Update result.</returns>
        [HttpPut("settings")]
        public async Task<ActionResult<ResultDto<UpdateNotificationSettingsResponse>>> UpdateNotificationSettings([FromBody] UpdateNotificationSettingsCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يميّز إشعارًا كمقروء.
        /// Marks a notification as read.
        /// </summary>
        /// <param name="command">بيانات الإشعار. Notification details.</param>
        /// <returns>نتيجة التمييز. Marking result.</returns>
        [HttpPut("mark-as-read")]
        public async Task<ActionResult<ResultDto<MarkNotificationAsReadResponse>>> MarkAsRead([FromBody] MarkNotificationAsReadCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يميّز جميع الإشعارات كمقروءة.
        /// Marks all notifications as read.
        /// </summary>
        /// <param name="command">بيانات المستخدم. User details.</param>
        /// <returns>نتيجة التمييز. Marking result.</returns>
        [HttpPut("mark-all-as-read")]
        public async Task<ActionResult<ResultDto<MarkAllNotificationsAsReadResponse>>> MarkAllAsRead([FromBody] MarkAllNotificationsAsReadCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يغلق إشعارًا.
        /// Dismisses a notification.
        /// </summary>
        /// <param name="command">بيانات الإشعار. Notification details.</param>
        /// <returns>نتيجة الإغلاق. Dismiss result.</returns>
        [HttpDelete("dismiss")]
        public async Task<ActionResult<ResultDto<DismissNotificationResponse>>> DismissNotification([FromBody] DismissNotificationCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعيد إشعارات المستخدم.
        /// Returns the user's notifications.
        /// </summary>
        /// <param name="query">معايير البحث. Query parameters.</param>
        /// <returns>قائمة الإشعارات. Notifications list.</returns>
        [HttpGet]
        public async Task<ActionResult<ResultDto<PaginatedResult<ClientNotificationDto>>>> GetUserNotifications([FromQuery] ClientGetUserNotificationsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعيد ملخص إشعارات المستخدم.
        /// Returns a summary of the user's notifications.
        /// </summary>
        /// <param name="query">معايير الملخص. Summary parameters.</param>
        /// <returns>ملخص الإشعارات. Notifications summary.</returns>
        [HttpGet("summary")]
        public async Task<ActionResult<ResultDto<ClientNotificationsSummaryDto>>> GetNotificationsSummary([FromQuery] ClientGetNotificationsSummaryQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
}
