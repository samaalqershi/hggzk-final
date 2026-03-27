using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Notifications.Commands.ManageNotifications
{
    /// <summary>
    /// يمثل طلب إعادة إرسال إشعار.
    /// Represents a request to resend a notification.
    /// </summary>
    public class ResendNotificationCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// معرّف الإشعار المراد إعادة إرساله.
        /// Identifies the notification to resend.
        /// </summary>
        public Guid NotificationId { get; set; }
        /// <summary>
        /// القناة المستخدمة في إعادة الإرسال.
        /// Specifies the channel used for resending.
        /// </summary>
        public string? Channel { get; set; } // IN_APP/EMAIL/SMS/PUSH (optional)
    }
}
