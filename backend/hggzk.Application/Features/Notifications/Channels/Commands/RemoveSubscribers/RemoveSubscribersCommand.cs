using MediatR;

namespace YemenBooking.Application.Features.Notifications.Channels.Commands.RemoveSubscribers;

    /// <summary>
    /// يمثل طلب إزالة مستخدمين من القناة.
    /// Represents a request to remove subscribers from a channel.
    /// </summary>
public class RemoveSubscribersCommand : IRequest<int>
{
    /// <summary>
    /// معرّف القناة المستهدفة.
    /// Identifies the target channel.
    /// </summary>
    public Guid ChannelId { get; set; }
    /// <summary>
    /// معرّفات المستخدمين المراد إزالتهم.
    /// Identifies the users to remove from the channel.
    /// </summary>
    public List<Guid> UserIds { get; set; } = new();
}
