using MediatR;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Notifications.Channels.Queries.GetChannelSubscribers;

    /// <summary>
    /// يمثل طلب جلب مشتركي القناة.
    /// Represents a request to retrieve channel subscribers.
    /// </summary>
public class GetChannelSubscribersQuery : IRequest<IEnumerable<UserChannel>>
{
    /// <summary>
    /// معرّف القناة المطلوبة.
    /// Identifies the channel to query.
    /// </summary>
    public Guid ChannelId { get; set; }
    /// <summary>
    /// يحدد إظهار المشتركين النشطين فقط.
    /// Indicates whether to return active subscribers only.
    /// </summary>
    public bool ActiveOnly { get; set; } = true;
}
