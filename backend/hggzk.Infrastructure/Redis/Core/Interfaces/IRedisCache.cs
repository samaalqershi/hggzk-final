using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace YemenBooking.Infrastructure.Redis.Core.Interfaces
{
    /// <summary>
    /// واجهة التخزين المؤقت
    /// </summary>
    public interface IRedisCache
    {
        /// <summary>
        /// الحصول على قيمة من الكاش
        /// </summary>
        Task<T> GetAsync<T>(string key, CancellationToken cancellationToken = default) where T : class;

        /// <summary>
        /// تخزين قيمة في الكاش
        /// </summary>
        Task<bool> SetAsync<T>(string key, T value, TimeSpan? expiry = null, CancellationToken cancellationToken = default) where T : class;

        /// <summary>
        /// حذف قيمة من الكاش
        /// </summary>
        Task<bool> RemoveAsync(string key, CancellationToken cancellationToken = default);

        /// <summary>
        /// التحقق من وجود مفتاح
        /// </summary>
        Task<bool> ExistsAsync(string key, CancellationToken cancellationToken = default);

        /// <summary>
        /// الحصول على قيمة أو إنشاؤها
        /// </summary>
        Task<T> GetOrCreateAsync<T>(string key, Func<Task<T>> factory, TimeSpan? expiry = null, CancellationToken cancellationToken = default) where T : class;

        /// <summary>
        /// تحديث وقت انتهاء الصلاحية
        /// </summary>
        Task<bool> RefreshAsync(string key, TimeSpan expiry, CancellationToken cancellationToken = default);

        /// <summary>
        /// مسح الكاش بالكامل
        /// </summary>
        Task FlushAsync(CancellationToken cancellationToken = default);

        /// <summary>
        /// الحصول على إحصائيات الكاش
        /// </summary>
        Task<CacheStatistics> GetStatisticsAsync(CancellationToken cancellationToken = default);
    }

    /// <summary>
    /// إحصائيات الكاش
    /// </summary>
    public class CacheStatistics
    {
        /// <summary>
        /// خاصية TotalKeys.
        /// TotalKeys property.
        /// </summary>
        public long TotalKeys { get; set; }
        /// <summary>
        /// خاصية Hits.
        /// Hits property.
        /// </summary>
        public long Hits { get; set; }
        /// <summary>
        /// خاصية Misses.
        /// Misses property.
        /// </summary>
        public long Misses { get; set; }
        /// <summary>
        /// خاصية HitRate.
        /// HitRate property.
        /// </summary>
        public double HitRate => TotalRequests > 0 ? (double)Hits / TotalRequests : 0;
        /// <summary>
        /// خاصية TotalRequests.
        /// TotalRequests property.
        /// </summary>
        public long TotalRequests => Hits + Misses;
        /// <summary>
        /// خاصية MemoryUsage.
        /// MemoryUsage property.
        /// </summary>
        public long MemoryUsage { get; set; }
        /// <summary>
        /// خاصية LastFlush.
        /// LastFlush property.
        /// </summary>
        public DateTime LastFlush { get; set; }
    }
}
