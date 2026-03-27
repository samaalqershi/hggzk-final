using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Notifications.Commands.ManageNotifications;

    /// <summary>
    /// يمثل طلب إنشاء إشعار جديد.
    /// Represents a request to create a new notification.
    /// </summary>
public class CreateNotificationCommand : IRequest<ResultDto<Guid>>
{
    /// <summary>
    /// نوع الإشعار.
    /// Specifies the notification type.
    /// </summary>
    public string Type { get; set; } = string.Empty;
    /// <summary>
    /// عنوان الإشعار.
    /// Specifies the notification title.
    /// </summary>
    public string Title { get; set; } = string.Empty;
    /// <summary>
    /// نص الإشعار.
    /// Specifies the notification message.
    /// </summary>
    public string Message { get; set; } = string.Empty;
    /// <summary>
    /// معرّف المستلم.
    /// Identifies the notification recipient.
    /// </summary>
    public Guid RecipientId { get; set; }
    /// <summary>
    /// معرّف المرسل.
    /// Identifies the notification sender.
    /// </summary>
    public Guid? SenderId { get; set; }
} 
