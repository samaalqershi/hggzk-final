using MediatR;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Notifications.Channels.Commands.CreateChannel;

    /// <summary>
    /// يمثل طلب إنشاء قناة إشعارات جديدة.
    /// Represents a request to create a new notification channel.
    /// </summary>
public class CreateChannelCommand : IRequest<NotificationChannel>
{
    /// <summary>
    /// اسم القناة الظاهر للمستخدمين.
    /// Displays the channel name to users.
    /// </summary>
    public string Name { get; set; } = null!;
    /// <summary>
    /// المعرّف الفريد الثابت للقناة.
    /// Provides the stable unique identifier for the channel.
    /// </summary>
    public string Identifier { get; set; } = null!;
    /// <summary>
    /// وصف مختصر للقناة.
    /// Provides a short description of the channel.
    /// </summary>
    public string? Description { get; set; }
    /// <summary>
    /// نوع القناة أو تصنيفها.
    /// Specifies the channel type or category.
    /// </summary>
    public string? Type { get; set; }
    /// <summary>
    /// رمز أيقونة القناة.
    /// Defines the channel icon.
    /// </summary>
    public string? Icon { get; set; }
    /// <summary>
    /// اللون المرتبط بالقناة.
    /// Defines the color associated with the channel.
    /// </summary>
    public string? Color { get; set; }
    /// <summary>
    /// معرّف المستخدم الذي أنشأ القناة.
    /// Identifies the user who created the channel.
    /// </summary>
    public Guid? CreatedBy { get; set; }
}
