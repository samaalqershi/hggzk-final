using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Notifications.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Notifications.Queries.GetNotificationsStats
{
    /// <summary>
    /// يمثل طلب جلب إحصاءات الإشعارات.
    /// Represents a request to retrieve notification statistics.
    /// </summary>
    public class GetNotificationsStatsQuery : IRequest<NotificationsStatsDto>
    {
        /// <summary>
        /// نوع الإحصاء المطلوب.
        /// Specifies the requested statistics type.
        /// </summary>
        public string? Type { get; set; }
        /// <summary>
        /// بداية النطاق الزمني.
        /// Marks the start of the time range.
        /// </summary>
        public DateTime? From { get; set; }
        /// <summary>
        /// نهاية النطاق الزمني.
        /// Marks the end of the time range.
        /// </summary>
        public DateTime? To { get; set; }
    }
}
