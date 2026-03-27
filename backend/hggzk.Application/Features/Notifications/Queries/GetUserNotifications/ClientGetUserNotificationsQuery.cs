using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Notifications.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Notifications.Queries.GetUserNotifications;

    /// <summary>
    /// يمثل طلب جلب إشعارات المستخدم للعميل.
    /// Represents a client request to retrieve user notifications.
    /// </summary>
public class ClientGetUserNotificationsQuery : IRequest<ResultDto<PaginatedResult<ClientNotificationDto>>>
{
    /// <summary>
    /// معرّف المستخدم المطلوب جلب إشعاراته.
    /// Identifies the user whose notifications are requested.
    /// </summary>
    public Guid UserId { get; set; }
    /// <summary>
    /// رقم الصفحة المطلوبة.
    /// Specifies the requested page number.
    /// </summary>
    public int PageNumber { get; set; } = 1;
    /// <summary>
    /// عدد العناصر في الصفحة.
    /// Specifies the number of items per page.
    /// </summary>
    public int PageSize { get; set; } = 20;
    /// <summary>
    /// حالة الإشعار.
    /// Specifies the notification status.
    /// </summary>
    public string? Status { get; set; }
    /// <summary>
    /// نوع الإشعار.
    /// Specifies the notification type.
    /// </summary>
    public string? Type { get; set; }
    /// <summary>
    /// يحدد إظهار الإشعارات غير المقروءة فقط.
    /// Indicates whether to return unread notifications only.
    /// </summary>
    public bool? UnreadOnly { get; set; }
    /// <summary>
    /// بداية النطاق الزمني.
    /// Marks the start of the time range.
    /// </summary>
    public DateTime? FromDate { get; set; }
    /// <summary>
    /// نهاية النطاق الزمني.
    /// Marks the end of the time range.
    /// </summary>
    public DateTime? ToDate { get; set; }
}
