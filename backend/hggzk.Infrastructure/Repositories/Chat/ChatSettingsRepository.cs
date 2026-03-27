using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Chat
{
/// <summary>
/// يمثل مستودعًا للوصول إلى إعدادات الدردشة.
/// Represents a repository for accessing chat settings.
/// </summary>
    public class ChatSettingsRepository : BaseRepository<ChatSettings>, IChatSettingsRepository
    {
/// <summary>
/// ينشئ المستودع مع سياق قاعدة البيانات المشترك.
/// Creates the repository with the shared database context.
/// </summary>
        public ChatSettingsRepository(YemenBookingDbContext context) : base(context) { }

/// <summary>
/// يحفظ التغييرات المعلقة.
/// Saves the pending changes.
/// </summary>
        public async Task<ChatSettings> SaveSettingsAsync(ChatSettings settings, CancellationToken cancellationToken = default)
        {
            if (settings.Id == Guid.Empty)
            {
                await _dbSet.AddAsync(settings, cancellationToken);
            }
            else
            {
                TrackForUpdate(_dbSet, settings);
            }

            return settings;
        }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<ChatSettings?> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default)
            => await _context.Set<ChatSettings>().FirstOrDefaultAsync(s => s.UserId == userId, cancellationToken);
    }
} 
