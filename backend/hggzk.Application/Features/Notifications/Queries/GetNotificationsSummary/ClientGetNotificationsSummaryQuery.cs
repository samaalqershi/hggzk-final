using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Notifications.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Notifications.Queries.GetNotificationsSummary;

    /// <summary>
    /// يمثل طلب جلب ملخص إشعارات العميل.
    /// Represents a request to retrieve the client's notification summary.
    /// </summary>
public class ClientGetNotificationsSummaryQuery : IRequest<ResultDto<ClientNotificationsSummaryDto>>
{
    /// <summary>
    /// معرّف المستخدم المطلوب جلب ملخص إشعاراته.
    /// Identifies the user whose notification summary is requested.
    /// </summary>
    public Guid UserId { get; set; }
}

    /// <summary>
    /// يمثل ملخصًا مجمعًا لإشعارات العميل.
    /// Represents an aggregated summary of client notifications.
    /// </summary>
public class ClientNotificationsSummaryDto
{
    /// <summary>
    /// إجمالي عدد الإشعارات.
    /// Indicates the total number of notifications.
    /// </summary>
    public int TotalCount { get; set; }
    /// <summary>
    /// عدد الإشعارات غير المقروءة.
    /// Indicates the number of unread notifications.
    /// </summary>
    public int UnreadCount { get; set; }
    /// <summary>
    /// عدد الإشعارات المقروءة.
    /// Indicates the number of read notifications.
    /// </summary>
    public int ReadCount { get; set; }
    /// <summary>
    /// توزيع الإشعارات حسب النوع.
    /// Groups notifications by type and count.
    /// </summary>
    public Dictionary<string, int> CountByType { get; set; } = new();
    /// <summary>
    /// توزيع الإشعارات حسب الأولوية.
    /// Groups notifications by priority and count.
    /// </summary>
    public Dictionary<string, int> CountByPriority { get; set; } = new();
    /// <summary>
    /// أحدث إشعار متاح.
    /// Contains the most recent notification.
    /// </summary>
    public ClientNotificationDto? LastNotification { get; set; }
    /// <summary>
    /// الإشعارات غير المقروءة ذات الأولوية العالية.
    /// Contains unread notifications with high priority.
    /// </summary>
    public List<ClientNotificationDto> HighPriorityUnread { get; set; } = new();
}
