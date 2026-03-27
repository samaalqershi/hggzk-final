using System;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories
{
    /// <summary>
    /// واجهة مستودع إصدار التطبيق repository.
    /// App version repository repository interface.
    /// </summary>
    public interface IAppVersionRepository : IRepository<AppVersion>
    {
        /// <summary>
        /// يجلب أحدث الإصدار.
        /// Gets the latest version.
        /// </summary>
        /// <param name="platform">اسم المنصة مثل Android أو iOS. Platform name such as Android or iOS.</param>
        /// <returns>أحدث سجل إصدار أو `null` عند عدم توفره. The latest version row or `null` when none exists.</returns>
        Task<AppVersion?> GetLatestVersionAsync(string platform);
    }

    /// <summary>
    /// كيان إصدار التطبيق.
    /// App version entity.
    /// </summary>
    public class AppVersion : BaseEntity<Guid>
    {
        /// <summary>
        /// رقم الإصدار.
        /// Version number.
        /// </summary>
        public string Version { get; set; } = string.Empty;

        /// <summary>
        /// رقم البناء.
        /// Build number.
        /// </summary>
        public string BuildNumber { get; set; } = string.Empty;

        /// <summary>
        /// المنصة المستهدفة.
        /// Target platform.
        /// </summary>
        public string Platform { get; set; } = string.Empty;

        /// <summary>
        /// يحدد ما إذا كان التحديث مطلوبًا.
        /// Indicates whether an update is required.
        /// </summary>
        public bool IsUpdateRequired { get; set; }

        /// <summary>
        /// يحدد ما إذا كان التحديث إجباريًا.
        /// Indicates whether an update is mandatory.
        /// </summary>
        public bool IsForceUpdate { get; set; }

        /// <summary>
        /// رابط التحديث.
        /// Update URL.
        /// </summary>
        public string? UpdateUrl { get; set; }

        /// <summary>
        /// ملاحظات الإصدار.
        /// Release notes.
        /// </summary>
        public string? ReleaseNotes { get; set; }

        /// <summary>
        /// تاريخ الإصدار.
        /// Release date.
        /// </summary>
        public DateTime ReleaseDate { get; set; }

        /// <summary>
        /// يحدد ما إذا كان هذا السجل نشطًا.
        /// Indicates whether this record is active.
        /// </summary>
        public bool IsActive { get; set; } = true;

        /// <summary>
        /// رسالة التحديث.
        /// Update message.
        /// </summary>
        public string? UpdateMessage { get; set; }

        /// <summary>
        /// حجم التحديث بالميجابايت.
        /// Update size in megabytes.
        /// </summary>
        public decimal? UpdateSizeMB { get; set; }
    }
}
