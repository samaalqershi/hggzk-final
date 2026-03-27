using MediatR;

namespace YemenBooking.Application.Features.Notifications.Channels.Commands.UpdateUserSubscriptions;

    /// <summary>
    /// يمثل طلب تحديث اشتراكات المستخدم في القنوات.
    /// Represents a request to update a user's channel subscriptions.
    /// </summary>
public class UpdateUserSubscriptionsCommand : IRequest<bool>
{
    /// <summary>
    /// معرّف المستخدم المطلوب تحديث اشتراكاته.
    /// Identifies the user whose subscriptions are being updated.
    /// </summary>
    public Guid UserId { get; set; }
    /// <summary>
    /// القنوات المراد إضافتها إلى اشتراكات المستخدم.
    /// Lists the channels to add to the user's subscriptions.
    /// </summary>
    public List<Guid>? ChannelsToAdd { get; set; }
    /// <summary>
    /// القنوات المراد إزالتها من اشتراكات المستخدم.
    /// Lists the channels to remove from the user's subscriptions.
    /// </summary>
    public List<Guid>? ChannelsToRemove { get; set; }
}
