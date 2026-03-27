using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع قناة الإشعارات repository.
/// Notification channel repository repository interface.
/// </summary>
public interface INotificationChannelRepository : IRepository<NotificationChannel>
{
    /// <summary>
    /// يجلب النشط القنوات.
    /// Gets active channels.
    /// </summary>
    Task<IEnumerable<NotificationChannel>> GetActiveChannelsAsync(CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب العنصر حسب المعرّف.
    /// Gets the item by identifier.
    /// </summary>
    Task<NotificationChannel?> GetByIdentifierAsync(string identifier, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب المستخدم القنوات.
    /// Gets user channels.
    /// </summary>
    Task<IEnumerable<NotificationChannel>> GetUserChannelsAsync(Guid userId, bool activeOnly = true, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب القناة مع المشتركون.
    /// Gets channel with subscribers.
    /// </summary>
    Task<NotificationChannel?> GetChannelWithSubscribersAsync(Guid channelId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب القنوات الإحصاءات.
    /// Gets channels statistics.
    /// </summary>
    Task<Dictionary<string, object>> GetChannelsStatisticsAsync(CancellationToken cancellationToken = default);
    /// <summary>
    /// يشترك في المستخدم.
    /// Subscribes to user.
    /// </summary>
    Task<UserChannel> SubscribeUserAsync(Guid userId, Guid channelId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يلغي الاشتراك في المستخدم.
    /// Unsubscribes from user.
    /// </summary>
    Task<bool> UnsubscribeUserAsync(Guid userId, Guid channelId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب المستخدم القناة.
    /// Gets user channel.
    /// </summary>
    Task<UserChannel?> GetUserChannelAsync(Guid userId, Guid channelId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب القناة المشتركون.
    /// Gets channel subscribers.
    /// </summary>
    Task<IEnumerable<UserChannel>> GetChannelSubscribersAsync(Guid channelId, bool activeOnly = true, CancellationToken cancellationToken = default);
    /// <summary>
    /// يحدّث المستخدم subscription.
    /// Updates user subscription.
    /// </summary>
    Task<UserChannel> UpdateUserSubscriptionAsync(UserChannel subscription, CancellationToken cancellationToken = default);
    /// <summary>
    /// يضيف القناة الإشعار السجل.
    /// Adds channel notification history.
    /// </summary>
    Task<NotificationChannelHistory> AddChannelNotificationHistoryAsync(NotificationChannelHistory history, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب القناة الإشعار السجل.
    /// Gets channel notification history.
    /// </summary>
    Task<IEnumerable<NotificationChannelHistory>> GetChannelNotificationHistoryAsync(Guid channelId, int page = 1, int pageSize = 20, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب القناة المشترك ids.
    /// Gets channel subscriber ids.
    /// </summary>
    Task<IEnumerable<Guid>> GetChannelSubscriberIdsAsync(Guid channelId, bool activeOnly = true, CancellationToken cancellationToken = default);
    /// <summary>
    /// يبحث عن القنوات.
    /// Searches channels.
    /// </summary>
    Task<IEnumerable<NotificationChannel>> SearchChannelsAsync(string? searchTerm = null, string? type = null, bool? isActive = null, int page = 1, int pageSize = 20, CancellationToken cancellationToken = default);
    /// <summary>
    /// ينفذ عملية جماعية على subscribe المستخدمين.
    /// Performs a bulk operation on subscribe users.
    /// </summary>
    Task<int> BulkSubscribeUsersAsync(Guid channelId, IEnumerable<Guid> userIds, CancellationToken cancellationToken = default);
    /// <summary>
    /// ينفذ عملية جماعية على unsubscribe المستخدمين.
    /// Performs a bulk operation on unsubscribe users.
    /// </summary>
    Task<int> BulkUnsubscribeUsersAsync(Guid channelId, IEnumerable<Guid> userIds, CancellationToken cancellationToken = default);
}
