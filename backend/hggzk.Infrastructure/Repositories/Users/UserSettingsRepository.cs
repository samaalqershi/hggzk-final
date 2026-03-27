using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Users
{
    /// <summary>
    /// مستودع إعدادات المستخدم.
    /// User settings repository.
    /// </summary>
    public class UserSettingsRepository : IUserSettingsRepository
    {
        private readonly YemenBookingDbContext _context;
        private readonly DbSet<UserSettings> _userSettings;

        /// <summary>
        /// ينشئ مثيلاً جديداً من UserSettingsRepository.
        /// Initializes a new instance of UserSettingsRepository.
        /// </summary>
        public UserSettingsRepository(YemenBookingDbContext context)
        {
            _context = context;
            _userSettings = context.Set<UserSettings>();
        }

        /// <summary>
        /// ينشئ الكيان.
        /// Creates the entity.
        /// </summary>
        public async Task<UserSettings> CreateAsync(UserSettings userSettings, CancellationToken cancellationToken = default)
        {
            await _userSettings.AddAsync(userSettings, cancellationToken);
            return userSettings;
        }

        /// <summary>
        /// يجلب الإعدادات حسب المستخدم.
        /// Gets settings by user.
        /// </summary>
        public async Task<UserSettings?> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default)
        {
            return await _userSettings.FirstOrDefaultAsync(settings => settings.UserId == userId, cancellationToken);
        }

        /// <summary>
        /// يحدّث الكيان.
        /// Updates the entity.
        /// </summary>
        public async Task<UserSettings> UpdateAsync(UserSettings userSettings, CancellationToken cancellationToken = default)
        {
            return TrackForUpdate(_userSettings, userSettings);
        }

        /// <summary>
        /// يحفظ التغييرات.
        /// Saves changes.
        /// </summary>
        public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
            => _context.SaveChangesAsync(cancellationToken);

        private TEntity TrackForUpdate<TEntity>(DbSet<TEntity> dbSet, TEntity entity) where TEntity : class
        {
            var entry = _context.Entry(entity);
            if (entry.State == EntityState.Detached)
            {
                dbSet.Attach(entity);
                entry = _context.Entry(entity);
            }

            if (entry.State != EntityState.Added)
            {
                entry.State = EntityState.Modified;
            }

            return entity;
        }
    }
}
