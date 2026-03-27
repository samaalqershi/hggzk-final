using MediatR;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Notifications.Channels.Queries.SearchChannels;

    /// <summary>
    /// يمثل طلب البحث في قنوات الإشعارات.
    /// Represents a request to search notification channels.
    /// </summary>
public class SearchChannelsQuery : IRequest<IEnumerable<NotificationChannel>>
{
    /// <summary>
    /// نص البحث المستخدم في التصفية.
    /// Contains the search text used for filtering.
    /// </summary>
    public string? Search { get; set; }
    /// <summary>
    /// نوع القناة المراد البحث عنه.
    /// Specifies the channel type to match.
    /// </summary>
    public string? Type { get; set; }
    /// <summary>
    /// يحدد ما إذا كانت القناة نشطة.
    /// Indicates whether the channel is active.
    /// </summary>
    public bool? IsActive { get; set; }
    /// <summary>
    /// رقم الصفحة المطلوبة.
    /// Specifies the requested page number.
    /// </summary>
    public int Page { get; set; } = 1;
    /// <summary>
    /// عدد العناصر في الصفحة.
    /// Specifies the number of items per page.
    /// </summary>
    public int PageSize { get; set; } = 20;
}
