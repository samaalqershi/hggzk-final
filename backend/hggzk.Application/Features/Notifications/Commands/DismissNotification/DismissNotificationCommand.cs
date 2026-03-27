using MediatR;

namespace YemenBooking.Application.Features.Notifications.Commands.DismissNotification;

    /// <summary>
    /// يمثل طلب إخفاء إشعار للمستخدم.
    /// Represents a request to dismiss a notification for a user.
    /// </summary>
public class DismissNotificationCommand : IRequest<DismissNotificationResponse>
{
    /// <summary>
    /// معرّف الإشعار المراد إخفاؤه.
    /// Identifies the notification to dismiss.
    /// </summary>
    public Guid NotificationId { get; set; }
    /// <summary>
    /// معرّف المستخدم المرتبط بالإشعار.
    /// Identifies the user associated with the notification.
    /// </summary>
    public Guid UserId { get; set; }
}

    /// <summary>
    /// يمثل نتيجة تنفيذ إخفاء الإشعار.
    /// Represents the result of dismissing a notification.
    /// </summary>
public class DismissNotificationResponse
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
