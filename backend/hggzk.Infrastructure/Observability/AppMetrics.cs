using System.Diagnostics.Metrics;

namespace YemenBooking.Infrastructure.Observability
{
    /// <summary>
    /// Centralized application metrics for search, caching, and infrastructure observability.
    /// المقاييس المركزية للتطبيق الخاصة بالبحث والتخزين المؤقت والمراقبة التشغيلية.
    /// </summary>
    public static class AppMetrics
    {
        /// <summary>
        /// حقل Meter.
        /// Meter field.
        /// </summary>
        private static readonly Meter Meter = new("YemenBooking.Metrics", "1.0.0");

        /// <summary>
        /// Total number of incoming search requests.
        /// إجمالي طلبات البحث الواردة.
        /// </summary>
        public static readonly Counter<long> SearchRequests = Meter.CreateCounter<long>("search_requests");
        /// <summary>
        /// Total number of search requests that completed with an error.
        /// إجمالي طلبات البحث التي انتهت بخطأ.
        /// </summary>
        public static readonly Counter<long> SearchErrors = Meter.CreateCounter<long>("search_errors");
        /// <summary>
        /// Search latency histogram in milliseconds.
        /// مخطط توزيع زمن استجابة البحث بالملي ثانية.
        /// </summary>
        public static readonly Histogram<double> SearchLatencyMs = Meter.CreateHistogram<double>("search_latency_ms");

        /// <summary>
        /// Number of foreign-exchange cache hits.
        /// عدد مرات إصابة كاش أسعار الصرف.
        /// </summary>
        public static readonly Counter<long> FxCacheHits = Meter.CreateCounter<long>("fx_cache_hits");
        /// <summary>
        /// Number of foreign-exchange cache misses.
        /// عدد مرات تفويت كاش أسعار الصرف.
        /// </summary>
        public static readonly Counter<long> FxCacheMisses = Meter.CreateCounter<long>("fx_cache_misses");

        /// <summary>
        /// Number of pricing cache hits.
        /// عدد مرات إصابة كاش التسعير.
        /// </summary>
        public static readonly Counter<long> PriceCacheHits = Meter.CreateCounter<long>("price_cache_hits");
        /// <summary>
        /// Number of pricing cache misses.
        /// عدد مرات تفويت كاش التسعير.
        /// </summary>
        public static readonly Counter<long> PriceCacheMisses = Meter.CreateCounter<long>("price_cache_misses");

        /// <summary>
        /// Records the outcome and latency of a search request in the shared metric set.
        /// يسجل نتيجة طلب البحث وزمنه ضمن مجموعة المقاييس المشتركة.
        /// </summary>
        public static void RecordSearch(double elapsedMs, bool isError = false)
        {
            SearchRequests.Add(1);
            if (isError) SearchErrors.Add(1);
            SearchLatencyMs.Record(elapsedMs);
        }

        /// <summary>
        /// Records a foreign-exchange cache hit or miss.
        /// يسجل نتيجة إصابة أو تفويت كاش أسعار الصرف.
        /// </summary>
        public static void RecordFxHit(bool hit)
        {
            if (hit) FxCacheHits.Add(1); else FxCacheMisses.Add(1);
        }

        /// <summary>
        /// Records a pricing cache hit or miss.
        /// يسجل نتيجة إصابة أو تفويت كاش التسعير.
        /// </summary>
        public static void RecordPriceHit(bool hit)
        {
            if (hit) PriceCacheHits.Add(1); else PriceCacheMisses.Add(1);
        }
    }
}
