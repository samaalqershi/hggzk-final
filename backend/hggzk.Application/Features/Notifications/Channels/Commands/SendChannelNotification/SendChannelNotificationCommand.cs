using MediatR;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Notifications.Channels.Commands.SendChannelNotification;

    /// <summary>
    /// يمثل طلب إرسال إشعار عبر قناة.
    /// Represents a request to send a notification through a channel.
    /// </summary>
public class SendChannelNotificationCommand : IRequest<NotificationChannelHistory>
{
    /// <summary>
    /// معرّف القناة التي سيُرسل عبرها الإشعار.
    /// Identifies the channel used to send the notification.
    /// </summary>
    public Guid ChannelId { get; set; }
    /// <summary>
    /// عنوان الإشعار.
    /// Specifies the notification title.
    /// </summary>
    public string Title { get; set; } = null!;
    /// <summary>
    /// محتوى الإشعار.
    /// Specifies the notification body content.
    /// </summary>
    public string Content { get; set; } = null!;
    /// <summary>
    /// نوع الإشعار.
    /// Specifies the notification type.
    /// </summary>
    public string? Type { get; set; }
    /// <summary>
    /// معرّف المرسل.
    /// Identifies the sender of the notification.
    /// </summary>
    public Guid? SenderId { get; set; }
    /// <summary>
    /// بيانات إضافية مرافقة للإشعار.
    /// Carries additional notification data.
    /// </summary>
    public Dictionary<string, string>? Data { get; set; }
}
