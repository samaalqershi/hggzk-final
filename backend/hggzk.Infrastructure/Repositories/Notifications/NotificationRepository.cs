using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Notifications
{
/// <summary>
/// يمثل مستودعًا للوصول إلى الإشعارات.
/// Represents a repository for accessing notifications.
/// </summary>
    public class NotificationRepository : BaseRepository<Notification>, INotificationRepository
    {
/// <summary>
/// ينشئ المستودع مع سياق قاعدة البيانات المشترك.
/// Creates the repository with the shared database context.
/// </summary>
        public NotificationRepository(YemenBookingDbContext context) : base(context) { }

/// <summary>
/// ينشئ سجلًا جديدًا في المستودع.
/// Creates a new record in the repository.
/// </summary>
        public async Task<bool> CreateNotificationAsync(Guid userId, string title, string message, string type = "INFO", CancellationToken cancellationToken = default)
        {
            var notif = new Notification { RecipientId = userId, Title = title, Message = message, Type = type, CreatedAt = DateTime.UtcNow };
            await _dbSet.AddAsync(notif, cancellationToken);
            return true;
        }

/// <summary>
/// ينشئ سجلًا جديدًا في المستودع.
/// Creates a new record in the repository.
/// </summary>
        public async Task<Notification> CreateNotificationAsync(Notification notification, CancellationToken cancellationToken = default)
        {
            await _dbSet.AddAsync(notification, cancellationToken);
            return notification;
        }

/// <summary>
/// ينشئ سجلًا جديدًا في المستودع.
/// Creates a new record in the repository.
/// </summary>
        public async Task<IReadOnlyList<Notification>> CreateNotificationsAsync(IEnumerable<Notification> notifications, CancellationToken cancellationToken = default)
        {
            var notificationList = notifications.ToList();
            if (notificationList.Count == 0)
            {
                return notificationList;
            }

            await _dbSet.AddRangeAsync(notificationList, cancellationToken);
            return notificationList;
        }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<IEnumerable<Notification>> GetUserNotificationsAsync(Guid userId, bool? isRead = null, int page = 1, int pageSize = 50, CancellationToken cancellationToken = default)
        {
            var query = _dbSet.Where(n => n.RecipientId == userId && !n.IsDismissed);
            if (isRead.HasValue) query = query.Where(n => n.IsRead == isRead.Value);
            var items = await query
                .OrderByDescending(n => n.CreatedAt)
                .Skip((page-1)*pageSize)
                .Take(pageSize)
                .ToListAsync(cancellationToken);
            return items;
        }

/// <summary>
/// ينفذ العملية المطلوبة على البيانات المخزنة.
/// Performs the requested operation on the persisted data.
/// </summary>
        public async Task<bool> MarkNotificationAsReadAsync(Guid notificationId, CancellationToken cancellationToken = default)
        {
            var notif = await GetByIdAsync(notificationId, cancellationToken);
            if (notif == null) return false;
            notif.IsRead = true;
            TrackForUpdate(_dbSet, notif);
            return true;
        }

/// <summary>
/// ينفذ العملية المطلوبة على البيانات المخزنة.
/// Performs the requested operation on the persisted data.
/// </summary>
        public async Task<bool> MarkAllUserNotificationsAsReadAsync(Guid userId, CancellationToken cancellationToken = default)
        {
            var list = await _dbSet.Where(n => n.RecipientId == userId && !n.IsRead).ToListAsync(cancellationToken);
            if (!list.Any()) return false;
            list.ForEach(n => n.IsRead = true);
            foreach (var notification in list)
            {
                TrackForUpdate(_dbSet, notification);
            }
            return true;
        }

/// <summary>
/// يحذف السجل المطلوب من المستودع.
/// Deletes the requested record from the repository.
/// </summary>
        public async Task<bool> DeleteNotificationAsync(Guid notificationId, CancellationToken cancellationToken = default)
        {
            var notif = await GetByIdAsync(notificationId, cancellationToken);
            if (notif == null) return false;
            _dbSet.Remove(notif);
            return true;
        }

/// <summary>
/// يحدّث السجل المطلوب في المستودع.
/// Updates the requested record in the repository.
/// </summary>
        public async Task<Notification> UpdateNotificationAsync(Notification notification, CancellationToken cancellationToken = default)
        {
            return TrackForUpdate(_dbSet, notification);
        }

/// <summary>
/// يحدّث السجل المطلوب في المستودع.
/// Updates the requested record in the repository.
/// </summary>
        public async Task<IReadOnlyList<Notification>> UpdateNotificationsAsync(IEnumerable<Notification> notifications, CancellationToken cancellationToken = default)
        {
            var notificationList = notifications.ToList();
            if (notificationList.Count == 0)
            {
                return notificationList;
            }

            foreach (var notification in notificationList)
            {
                TrackForUpdate(_dbSet, notification);
            }
            return notificationList;
        }

/// <summary>
/// ينفذ العملية المطلوبة على البيانات المخزنة.
/// Performs the requested operation on the persisted data.
/// </summary>
        public async Task<bool> DismissNotificationAsync(Guid notificationId, CancellationToken cancellationToken = default)
        {
            var notif = await GetByIdAsync(notificationId, cancellationToken);
            if (notif == null) return false;

            notif.IsDismissed = true;
            notif.DismissedAt = DateTime.UtcNow;

            TrackForUpdate(_dbSet, notif);
            return true;
        }

/// <summary>
/// يسترجع العناصر غير المقروءة.
/// Retrieves the unread items.
/// </summary>
        public async Task<int> GetUnreadNotificationsCountAsync(Guid userId, CancellationToken cancellationToken = default)
            => await _dbSet.CountAsync(n => n.RecipientId == userId && !n.IsRead && !n.IsDismissed, cancellationToken);
    }
} 
