using MediatR;

namespace YemenBooking.Application.Features.Notifications.Commands.MarkAllNotificationsAsRead;

    /// <summary>
    /// يمثل طلب تعليم جميع إشعارات المستخدم كمقروءة.
    /// Represents a request to mark all user notifications as read.
    /// </summary>
public class MarkAllNotificationsAsReadCommand : IRequest<MarkAllNotificationsAsReadResponse>
{
    /// <summary>
    /// معرّف المستخدم المطلوب تحديث إشعاراته.
    /// Identifies the user whose notifications will be updated.
    /// </summary>
    public Guid UserId { get; set; }
}

    /// <summary>
    /// يمثل نتيجة تعليم جميع الإشعارات كمقروءة.
    /// Represents the result of marking all notifications as read.
    /// </summary>
public class MarkAllNotificationsAsReadResponse
{
    /// <summary>
    /// عدد الإشعارات التي تم تحديثها.
    /// Indicates how many notifications were updated.
    /// </summary>
    public int UpdatedCount { get; set; }
    /// <summary>
    /// رسالة توضح نتيجة العملية.
    /// A message describing the operation outcome.
    /// </summary>
    public string Message { get; set; } = string.Empty;
}
