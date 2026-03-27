using MediatR;

namespace YemenBooking.Application.Features.Notifications.Channels.Commands.AddSubscribers;

    /// <summary>
    /// يمثل طلب إضافة مستخدمين إلى القناة.
    /// Represents a request to add subscribers to a channel.
    /// </summary>
public class AddSubscribersCommand : IRequest<int>
{
    /// <summary>
    /// معرّف القناة المستهدفة.
    /// Identifies the target channel.
    /// </summary>
    public Guid ChannelId { get; set; }
    /// <summary>
    /// معرّفات المستخدمين المراد إضافتهم.
    /// Identifies the users to add as subscribers.
    /// </summary>
    public List<Guid> UserIds { get; set; } = new();
}
