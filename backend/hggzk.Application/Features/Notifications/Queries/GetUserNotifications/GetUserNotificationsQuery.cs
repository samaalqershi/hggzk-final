using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Notifications.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Notifications.Queries.GetUserNotifications
{
    /// <summary>
    /// يمثل طلب جلب إشعارات المستخدم.
    /// Represents a request to retrieve user notifications.
    /// </summary>
    public class GetUserNotificationsQuery : IRequest<PaginatedResult<NotificationDto>>
    {
        /// <summary>
        /// معرّف المستخدم المطلوب جلب إشعاراته.
        /// Identifies the user whose notifications are requested.
        /// </summary>
        public Guid UserId { get; set; }
        /// <summary>
        /// يحدد ما إذا كان الإشعار مقروءًا.
        /// Indicates whether to return read notifications.
        /// </summary>
        public bool? IsRead { get; set; }
        /// <summary>
        /// رقم الصفحة المطلوبة.
        /// Specifies the requested page number.
        /// </summary>
        public int PageNumber { get; set; } = 1;
        /// <summary>
        /// عدد العناصر في الصفحة.
        /// Specifies the number of items per page.
        /// </summary>
        public int PageSize { get; set; } = 10;
        /// <summary>
        /// نوع الإشعار.
        /// Specifies the notification type.
        /// </summary>
        public string? NotificationType { get; set; }
        /// <summary>
        /// الإشعارات المرسلة بعد هذا التاريخ.
        /// Filters notifications sent after this date.
        /// </summary>
        public DateTime? SentAfter { get; set; }
        /// <summary>
        /// الإشعارات المرسلة قبل هذا التاريخ.
        /// Filters notifications sent before this date.
        /// </summary>
        public DateTime? SentBefore { get; set; }
        /// <summary>
        /// الحقل المستخدم لفرز نتائج الإشعارات.
        /// Specifies the sort field.
        /// </summary>
        public string? SortBy { get; set; }
    }
} 
