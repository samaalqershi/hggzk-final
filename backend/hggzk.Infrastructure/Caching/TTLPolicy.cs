using System;

namespace YemenBooking.Infrastructure.Caching
{
    /// <summary>
    /// Standard cache lifetimes used across the infrastructure layer.
    /// مدد التخزين المؤقت القياسية المستخدمة عبر طبقة البنية التحتية.
    /// </summary>
    public static class TTLPolicy
    {
        /// <summary>Cache lifetime for search result payloads. / مدة حفظ نتائج البحث.</summary>
        public static readonly TimeSpan SearchResults = TimeSpan.FromMinutes(10); // 5-15m
        /// <summary>Cache lifetime for pricing lookups. / مدة حفظ استعلامات التسعير.</summary>
        public static readonly TimeSpan PriceCache = TimeSpan.FromHours(1);       // 1h
        /// <summary>Cache lifetime for visit counters. / مدة حفظ عدادات الزيارات.</summary>
        public static readonly TimeSpan Visits = TimeSpan.FromHours(24);          // 24h
        /// <summary>Cache lifetime for user sessions. / مدة حفظ جلسات المستخدم.</summary>
        public static readonly TimeSpan Sessions = TimeSpan.FromMinutes(30);      // 30m
        /// <summary>Cache lifetime for one-time passwords. / مدة حفظ رموز التحقق لمرة واحدة.</summary>
        public static readonly TimeSpan OTP = TimeSpan.FromMinutes(5);            // 5m
    }
}
