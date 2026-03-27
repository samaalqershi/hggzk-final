using MediatR;

namespace YemenBooking.Application.Features.Notifications.Commands.NotificationSettings;

    /// <summary>
    /// يمثل طلب تحديث إعدادات الإشعارات للمستخدم.
    /// Represents a request to update a user's notification settings.
    /// </summary>
public class UpdateNotificationSettingsCommand : IRequest<UpdateNotificationSettingsResponse>
{
    /// <summary>
    /// معرّف المستخدم المطلوب تحديث إعداداته.
    /// Identifies the user whose settings are being updated.
    /// </summary>
    public Guid UserId { get; set; }
    /// <summary>
    /// يحدد تشغيل إشعارات الحجوزات.
    /// Enables booking notifications.
    /// </summary>
    public bool BookingNotifications { get; set; } = true;
    /// <summary>
    /// يحدد تشغيل الإشعارات الترويجية.
    /// Enables promotional notifications.
    /// </summary>
    public bool PromotionalNotifications { get; set; } = true;
    /// <summary>
    /// يحدد تشغيل إشعارات الرد على المراجعات.
    /// Enables review response notifications.
    /// </summary>
    public bool ReviewResponseNotifications { get; set; } = true;
    /// <summary>
    /// يحدد تشغيل إشعارات البريد الإلكتروني.
    /// Enables email notifications.
    /// </summary>
    public bool EmailNotifications { get; set; } = true;
    /// <summary>
    /// يحدد تشغيل إشعارات الرسائل النصية.
    /// Enables SMS notifications.
    /// </summary>
    public bool SmsNotifications { get; set; } = false;
    /// <summary>
    /// يحدد تشغيل الإشعارات الفورية.
    /// Enables push notifications.
    /// </summary>
    public bool PushNotifications { get; set; } = true;
}

    /// <summary>
    /// يمثل نتيجة تحديث إعدادات الإشعارات.
    /// Represents the result of updating notification settings.
    /// </summary>
public class UpdateNotificationSettingsResponse
{
    /// <summary>
    /// يحدد ما إذا كانت العملية قد نجحت.
    /// Indicates whether the operation completed successfully.
    /// </summary>
    public bool Success { get; set; }
    /// <summary>
    /// رسالة توضح نتيجة العملية.
    /// A message describing the operation outcome.
    /// </summary>
    public string Message { get; set; } = string.Empty;
}
