using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع الإشعار repository.
/// Notification repository repository interface.
/// </summary>
public interface INotificationRepository : IRepository<Notification>
{
    /// <summary>
    /// ينشئ الإشعار.
    /// Creates notification.
    /// </summary>
    Task<bool> CreateNotificationAsync(
        Guid userId,
        string title,
        string message,
        string type = "INFO",
        CancellationToken cancellationToken = default);

    /// <summary>
    /// ينشئ الإشعار.
    /// Creates notification.
    /// </summary>
    Task<Notification> CreateNotificationAsync(
        Notification notification,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// ينشئ الإشعارات.
    /// Creates notifications.
    /// </summary>
    Task<IReadOnlyList<Notification>> CreateNotificationsAsync(
        IEnumerable<Notification> notifications,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب المستخدم الإشعارات.
    /// Gets user notifications.
    /// </summary>
    Task<IEnumerable<Notification>> GetUserNotificationsAsync(
        Guid userId,
        bool? isRead = null,
        int page = 1,
        int pageSize = 50,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// يعلّم الإشعار as read.
    /// Marks notification as read.
    /// </summary>
    Task<bool> MarkNotificationAsReadAsync(
        Guid notificationId,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// يعلّم جميع المستخدم الإشعارات as read.
    /// Marks all user notifications as read.
    /// </summary>
    Task<bool> MarkAllUserNotificationsAsReadAsync(
        Guid userId,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// يحذف الإشعار.
    /// Deletes notification.
    /// </summary>
    Task<bool> DeleteNotificationAsync(
        Guid notificationId,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث الإشعار.
    /// Updates notification.
    /// </summary>
    Task<Notification> UpdateNotificationAsync(
        Notification notification,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث الإشعارات.
    /// Updates notifications.
    /// </summary>
    Task<IReadOnlyList<Notification>> UpdateNotificationsAsync(
        IEnumerable<Notification> notifications,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// يتجاهل الإشعار.
    /// Dismisses notification.
    /// </summary>
    Task<bool> DismissNotificationAsync(
        Guid notificationId,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب غير المقروءة الإشعارات count.
    /// Gets unread notifications count.
    /// </summary>
    Task<int> GetUnreadNotificationsCountAsync(
        Guid userId,
        CancellationToken cancellationToken = default);
}
