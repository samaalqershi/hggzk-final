using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace YemenBooking.Application.Contracts.Services.Configuration
{
    /// <summary>
    /// خدمة لإدارة إعدادات النظام.
    /// Service for managing system settings.
    /// </summary>
    public interface ISystemSettingsService
    {
        /// <summary>
        /// يجلب إعدادات النظام كمجموعة مفاتيح وقيم.
        /// Gets system settings as a key-value set.
        /// </summary>
        Task<Dictionary<string, string>> GetSettingsAsync(CancellationToken cancellationToken = default);
        /// <summary>
        /// يحفظ إعدادات النظام المرسلة.
        /// Saves the provided system settings.
        /// </summary>
        Task SaveSettingsAsync(Dictionary<string, string> settings, CancellationToken cancellationToken = default);
    }
} 
