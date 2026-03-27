using MediatR;
using YemenBooking.Application.Features.Notifications.Commands;
using YemenBooking.Application.Features.Notifications.DTOs;

namespace YemenBooking.Application.Features.Notifications.Commands.ManageNotifications;

    /// <summary>
    /// يمثل طلب تعليم إشعار كمقروء.
    /// Represents a request to mark a notification as read.
    /// </summary>
public class MarkNotificationAsReadCommand : IRequest<MarkNotificationAsReadResponse>
{
    /// <summary>
    /// معرّف الإشعار المراد تعليمه كمقروء.
    /// Identifies the notification to mark as read.
    /// </summary>
    public Guid NotificationId { get; set; }
    /// <summary>
    /// معرّف المستخدم المرتبط بالإشعار.
    /// Identifies the user associated with the notification.
    /// </summary>
    public Guid UserId { get; set; }
}

    /// <summary>
    /// يمثل نتيجة تعليم الإشعار كمقروء.
    /// Represents the result of marking a notification as read.
    /// </summary>
public class MarkNotificationAsReadResponse
{
    /// <summary>
    /// يحدد ما إذا كانت العملية قد نجحت.
    /// Indicates whether the operation completed successfully.
    /// </summary>
    public bool Success { get; set; }
    /// <summary>
    /// رسالة توضح نتيجة العملية.
    /// A message describing the operation outcome.
    /// </summary>
    public string Message { get; set; } = string.Empty;
}
