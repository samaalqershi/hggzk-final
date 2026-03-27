namespace YemenBooking.Core.Interfaces.Repositories
{
    using YemenBooking.Core.Entities;
    using System;
    using System.Threading;
    using System.Threading.Tasks;

    /// <summary>
    /// واجهة مستودع الدردشة الإعدادات repository.
    /// Chat settings repository repository interface.
    /// </summary>
    public interface IChatSettingsRepository : IRepository<ChatSettings>
    {
        /// <summary>
        /// ينفذ save الإعدادات.
        /// Performs save settings.
        /// </summary>
        Task<ChatSettings> SaveSettingsAsync(ChatSettings settings, CancellationToken cancellationToken = default);

        /// <summary>
        /// يجلب العنصر حسب المستخدم المعرّف.
        /// Gets the item by user id.
        /// </summary>
        Task<ChatSettings?> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
    }
} 
