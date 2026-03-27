using MediatR;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Notifications.Channels.Queries.GetUserChannels;

    /// <summary>
    /// يمثل طلب جلب قنوات المستخدم.
    /// Represents a request to retrieve a user's channels.
    /// </summary>
public class GetUserChannelsQuery : IRequest<IEnumerable<NotificationChannel>>
{
    /// <summary>
    /// معرّف المستخدم المطلوب جلب قنواته.
    /// Identifies the user whose channels are requested.
    /// </summary>
    public Guid UserId { get; set; }
    /// <summary>
    /// يحدد إظهار القنوات النشطة فقط.
    /// Indicates whether to return active channels only.
    /// </summary>
    public bool ActiveOnly { get; set; } = true;
}
