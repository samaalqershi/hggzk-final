using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Core.Notifications;

namespace YemenBooking.Application.Features.Notifications.Services;

/// <summary>
/// خدمة الإشعارات
/// Notification service interface
/// </summary>
public interface INotificationService
{
    /// <summary>
    /// إرسال إشعار عام
    /// Send a generic notification request
    /// </summary>
    Task SendAsync(NotificationRequest request, CancellationToken cancellationToken = default);
}
