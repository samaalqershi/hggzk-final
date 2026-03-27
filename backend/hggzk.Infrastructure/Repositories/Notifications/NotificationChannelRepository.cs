using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Notifications;

/// <summary>
/// يمثل مستودعًا للوصول إلى قنوات الإشعارات.
/// Represents a repository for accessing notification channels.
/// </summary>
public class NotificationChannelRepository : BaseRepository<NotificationChannel>, INotificationChannelRepository
{
/// <summary>
/// ينشئ المستودع مع سياق قاعدة البيانات المشترك.
/// Creates the repository with the shared database context.
/// </summary>
    public NotificationChannelRepository(YemenBookingDbContext context) : base(context)
    {
    }
    
/// <summary>
/// يسترجع العناصر النشطة.
/// Retrieves the active items.
/// </summary>
    public async Task<IEnumerable<NotificationChannel>> GetActiveChannelsAsync(CancellationToken cancellationToken = default)
    {
        return await _context.NotificationChannels
            .Where(c => c.IsActive)
            .Include(c => c.UserChannels)
            .OrderBy(c => c.Name)
            .ToListAsync(cancellationToken);
    }
    
/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<NotificationChannel?> GetByIdentifierAsync(string identifier, CancellationToken cancellationToken = default)
    {
        return await _context.NotificationChannels
            .FirstOrDefaultAsync(c => c.Identifier == identifier, cancellationToken);
    }
    
/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<IEnumerable<NotificationChannel>> GetUserChannelsAsync(Guid userId, bool activeOnly = true, CancellationToken cancellationToken = default)
    {
        var query = _context.UserChannels
            .Where(uc => uc.UserId == userId);
            
        if (activeOnly)
        {
            query = query.Where(uc => uc.IsActive && uc.Channel.IsActive);
        }
        
        return await query
            .Include(uc => uc.Channel)
            .Select(uc => uc.Channel)
            .Distinct()
            .OrderBy(c => c.Name)
            .ToListAsync(cancellationToken);
    }
    
/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<NotificationChannel?> GetChannelWithSubscribersAsync(Guid channelId, CancellationToken cancellationToken = default)
    {
        return await _context.NotificationChannels
            .Include(c => c.UserChannels)
                .ThenInclude(uc => uc.User)
            .FirstOrDefaultAsync(c => c.Id == channelId, cancellationToken);
    }
    
    /// <summary>
    /// يسترجع إحصائيات القنوات والاشتراكات والأنشطة المرتبطة بها.
    /// Retrieves channel, subscription, and activity statistics.
    /// </summary>
    public async Task<Dictionary<string, object>> GetChannelsStatisticsAsync(CancellationToken cancellationToken = default)
    {
        var stats = new Dictionary<string, object>();
        
        stats["total_channels"] = await _context.NotificationChannels.CountAsync(cancellationToken);
        stats["active_channels"] = await _context.NotificationChannels.CountAsync(c => c.IsActive, cancellationToken);
        stats["total_subscriptions"] = await _context.UserChannels.CountAsync(cancellationToken);
        stats["active_subscriptions"] = await _context.UserChannels.CountAsync(uc => uc.IsActive, cancellationToken);
        stats["total_notifications_sent"] = await _context.NotificationChannelHistories.CountAsync(cancellationToken);
        
        // إحصائيات حسب نوع القناة
        var channelsByType = await _context.NotificationChannels
            .GroupBy(c => c.Type)
            .Select(g => new { Type = g.Key, Count = g.Count() })
            .ToDictionaryAsync(x => x.Type, x => x.Count, cancellationToken);
        stats["channels_by_type"] = channelsByType;
        
        // أكثر القنوات نشاطًا
        var topChannels = await _context.NotificationChannels
            .OrderByDescending(c => c.NotificationsSentCount)
            .Take(5)
            .Select(c => new { c.Id, c.Name, c.NotificationsSentCount, c.SubscribersCount })
            .ToListAsync(cancellationToken);
        stats["top_active_channels"] = topChannels;
        
        return stats;
    }
    
/// <summary>
/// ينفذ العملية المطلوبة على البيانات المخزنة.
/// Performs the requested operation on the persisted data.
/// </summary>
    public async Task<UserChannel> SubscribeUserAsync(Guid userId, Guid channelId, CancellationToken cancellationToken = default)
    {
        // التحقق من وجود اشتراك سابق
        var existingSubscription = await _context.UserChannels
            .FirstOrDefaultAsync(uc => uc.UserId == userId && uc.ChannelId == channelId, cancellationToken);
            
        if (existingSubscription != null)
        {
            var wasActive = existingSubscription.IsActive;
            // إعادة تفعيل الاشتراك إذا كان موجودًا
            existingSubscription.Activate();
            
            // تحديث عدد المشتركين
            var channel = await _context.NotificationChannels.FindAsync(new object[] { channelId }, cancellationToken);
            if (channel != null && !wasActive)
            {
                channel.AddSubscriber();
            }
            
            return existingSubscription;
        }
        
        // إنشاء اشتراك جديد
        var subscription = new UserChannel
        {
            UserId = userId,
            ChannelId = channelId,
            IsActive = true,
            SubscribedAt = DateTime.UtcNow
        };
        
        _context.UserChannels.Add(subscription);
        
        // تحديث عدد المشتركين
        var channelEntity = await _context.NotificationChannels.FindAsync(new object[] { channelId }, cancellationToken);
        if (channelEntity != null)
        {
            channelEntity.AddSubscriber();
        }

        return subscription;
    }
    
/// <summary>
/// ينفذ العملية المطلوبة على البيانات المخزنة.
/// Performs the requested operation on the persisted data.
/// </summary>
    public async Task<bool> UnsubscribeUserAsync(Guid userId, Guid channelId, CancellationToken cancellationToken = default)
    {
        var subscription = await _context.UserChannels
            .FirstOrDefaultAsync(uc => uc.UserId == userId && uc.ChannelId == channelId, cancellationToken);
            
        if (subscription == null)
        {
            return false;
        }
        
        subscription.Deactivate();
        
        // تحديث عدد المشتركين
        var channel = await _context.NotificationChannels.FindAsync(new object[] { channelId }, cancellationToken);
        if (channel != null)
        {
            channel.RemoveSubscriber();
        }

        return true;
    }
    
/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<UserChannel?> GetUserChannelAsync(Guid userId, Guid channelId, CancellationToken cancellationToken = default)
    {
        return await _context.UserChannels
            .Include(uc => uc.Channel)
            .Include(uc => uc.User)
            .FirstOrDefaultAsync(uc => uc.UserId == userId && uc.ChannelId == channelId, cancellationToken);
    }
    
/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<IEnumerable<UserChannel>> GetChannelSubscribersAsync(Guid channelId, bool activeOnly = true, CancellationToken cancellationToken = default)
    {
        var query = _context.UserChannels
            .Include(uc => uc.User)
            .Where(uc => uc.ChannelId == channelId);
            
        if (activeOnly)
        {
            query = query.Where(uc => uc.IsActive);
        }
        
        return await query
            .OrderBy(uc => uc.User.Name)
            .ToListAsync(cancellationToken);
    }
    
/// <summary>
/// يحدّث السجل المطلوب في المستودع.
/// Updates the requested record in the repository.
/// </summary>
    public async Task<UserChannel> UpdateUserSubscriptionAsync(UserChannel subscription, CancellationToken cancellationToken = default)
    {
        return TrackForUpdate(_context.UserChannels, subscription);
    }
    
/// <summary>
/// يضيف السجل المطلوب إلى المستودع.
/// Adds the requested record to the repository.
/// </summary>
    public async Task<NotificationChannelHistory> AddChannelNotificationHistoryAsync(NotificationChannelHistory history, CancellationToken cancellationToken = default)
    {
        _context.NotificationChannelHistories.Add(history);
        
        // تحديث إحصائيات القناة
        var channel = await _context.NotificationChannels.FindAsync(new object[] { history.ChannelId }, cancellationToken);
        if (channel != null)
        {
            channel.RecordNotificationSent();
        }

        return history;
    }
    
/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<IEnumerable<NotificationChannelHistory>> GetChannelNotificationHistoryAsync(Guid channelId, int page = 1, int pageSize = 20, CancellationToken cancellationToken = default)
    {
        return await _context.NotificationChannelHistories
            .Where(h => h.ChannelId == channelId)
            .Include(h => h.Sender)
            .OrderByDescending(h => h.SentAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(cancellationToken);
    }
    
/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<IEnumerable<Guid>> GetChannelSubscriberIdsAsync(Guid channelId, bool activeOnly = true, CancellationToken cancellationToken = default)
    {
        var query = _context.UserChannels
            .Where(uc => uc.ChannelId == channelId);
            
        if (activeOnly)
        {
            query = query.Where(uc => uc.IsActive && !uc.IsMuted);
        }
        
        return await query
            .Select(uc => uc.UserId)
            .Distinct()
            .ToListAsync(cancellationToken);
    }
    
/// <summary>
/// يبحث ضمن البيانات المخزنة ويعيد النتائج المطابقة.
/// Searches the persisted data and returns matching results.
/// </summary>
    public async Task<IEnumerable<NotificationChannel>> SearchChannelsAsync(string? searchTerm = null, string? type = null, bool? isActive = null, int page = 1, int pageSize = 20, CancellationToken cancellationToken = default)
    {
        var query = _context.NotificationChannels.AsQueryable();
        
        if (!string.IsNullOrWhiteSpace(searchTerm))
        {
            query = query.Where(c => 
                c.Name.Contains(searchTerm) || 
                c.Description!.Contains(searchTerm) ||
                c.Identifier.Contains(searchTerm)
            );
        }
        
        if (!string.IsNullOrWhiteSpace(type))
        {
            query = query.Where(c => c.Type == type);
        }
        
        if (isActive.HasValue)
        {
            query = query.Where(c => c.IsActive == isActive.Value);
        }
        
        return await query
            .OrderBy(c => c.Name)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(cancellationToken);
    }
    
/// <summary>
/// ينفذ عملية جماعية على العناصر المحددة.
/// Performs a bulk operation on the selected items.
/// </summary>
    public async Task<int> BulkSubscribeUsersAsync(Guid channelId, IEnumerable<Guid> userIds, CancellationToken cancellationToken = default)
    {
        var count = 0;
        var channel = await _context.NotificationChannels.FindAsync(new object[] { channelId }, cancellationToken);
        
        if (channel == null)
        {
            return 0;
        }
        
        foreach (var userId in userIds)
        {
            // التحقق من عدم وجود اشتراك
            var exists = await _context.UserChannels
                .AnyAsync(uc => uc.UserId == userId && uc.ChannelId == channelId, cancellationToken);
                
            if (!exists)
            {
                var subscription = new UserChannel
                {
                    UserId = userId,
                    ChannelId = channelId,
                    IsActive = true,
                    SubscribedAt = DateTime.UtcNow
                };
                
                _context.UserChannels.Add(subscription);
                count++;
            }
        }
        
        if (count > 0)
        {
            var trackedChannel = await _context.NotificationChannels.FindAsync(new object[] { channelId }, cancellationToken);
            if (trackedChannel != null)
            {
                trackedChannel.SubscribersCount += count;
            }
        }
        
        return count;
    }
    
/// <summary>
/// ينفذ عملية جماعية على العناصر المحددة.
/// Performs a bulk operation on the selected items.
/// </summary>
    public async Task<int> BulkUnsubscribeUsersAsync(Guid channelId, IEnumerable<Guid> userIds, CancellationToken cancellationToken = default)
    {
        var subscriptions = await _context.UserChannels
            .Where(uc => uc.ChannelId == channelId && userIds.Contains(uc.UserId) && uc.IsActive)
            .ToListAsync(cancellationToken);
            
        var count = subscriptions.Count;
        
        if (count > 0)
        {
            foreach (var subscription in subscriptions)
            {
                subscription.Deactivate();
            }
            
            var channel = await _context.NotificationChannels.FindAsync(new object[] { channelId }, cancellationToken);
            if (channel != null)
            {
                channel.SubscribersCount = Math.Max(0, channel.SubscribersCount - count);
            }
        }
        
        return count;
    }
    
}
