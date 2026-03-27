using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Notifications.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Notifications.Queries.GetSystemNotifications
{
    /// <summary>
    /// يمثل طلب جلب إشعارات النظام.
    /// Represents a request to retrieve system notifications.
    /// </summary>
    public class GetSystemNotificationsQuery : IRequest<PaginatedResult<NotificationDto>>
    {
        /// <summary>
        /// نوع الإشعار.
        /// Specifies the notification type.
        /// </summary>
        public string? NotificationType { get; set; }
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
        /// معرّف المستلم.
        /// Identifies the notification recipient.
        /// </summary>
        public Guid? RecipientId { get; set; }
        /// <summary>
        /// حالة الإشعار.
        /// Specifies the notification status.
        /// </summary>
        public string? Status { get; set; }
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
