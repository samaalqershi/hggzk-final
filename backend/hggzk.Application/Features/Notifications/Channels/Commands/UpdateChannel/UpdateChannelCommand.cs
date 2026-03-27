using MediatR;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Notifications.Channels.Commands.UpdateChannel;

    /// <summary>
    /// يمثل طلب تحديث بيانات قناة إشعارات.
    /// Represents a request to update a notification channel.
    /// </summary>
public class UpdateChannelCommand : IRequest<NotificationChannel>
{
    /// <summary>
    /// معرّف القناة المراد تحديثها.
    /// Identifies the channel to update.
    /// </summary>
    public Guid ChannelId { get; set; }
    /// <summary>
    /// اسم القناة بعد التحديث.
    /// Provides the updated channel name.
    /// </summary>
    public string? Name { get; set; }
    /// <summary>
    /// وصف القناة بعد التحديث.
    /// Provides the updated channel description.
    /// </summary>
    public string? Description { get; set; }
    /// <summary>
    /// يحدد ما إذا كانت القناة نشطة.
    /// Indicates whether the channel is active.
    /// </summary>
    public bool? IsActive { get; set; }
    /// <summary>
    /// أيقونة القناة.
    /// Provides the updated channel icon.
    /// </summary>
    public string? Icon { get; set; }
    /// <summary>
    /// لون القناة.
    /// Provides the updated channel color.
    /// </summary>
    public string? Color { get; set; }
}
