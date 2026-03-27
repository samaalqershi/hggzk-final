using MediatR;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Notifications.Channels.Queries.GetChannelHistory;

    /// <summary>
    /// يمثل طلب جلب سجل القناة.
    /// Represents a request to retrieve channel history.
    /// </summary>
public class GetChannelHistoryQuery : IRequest<IEnumerable<NotificationChannelHistory>>
{
    /// <summary>
    /// معرّف القناة المطلوب جلب سجلها.
    /// Identifies the channel whose history is requested.
    /// </summary>
    public Guid ChannelId { get; set; }
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
