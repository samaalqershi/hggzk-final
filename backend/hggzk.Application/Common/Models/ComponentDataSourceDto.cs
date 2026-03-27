using System;

namespace YemenBooking.Application.Common.Models
{
    /// <summary>
    /// DTO يصف مصدر البيانات المرتبط بمكوّن قابل للتهيئة.
    /// DTO that describes the data source attached to a configurable component.
    /// </summary>
    public class ComponentDataSourceDto
    {
        /// <summary>
        /// المعرف الفريد لمصدر البيانات.
        /// Unique identifier of the data source.
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// نوع مصدر البيانات.
        /// Data source type.
        /// </summary>
        public string SourceType { get; set; } = string.Empty;

        /// <summary>
        /// نقطة النهاية التي يتم جلب البيانات منها.
        /// Endpoint used to retrieve data.
        /// </summary>
        public string DataEndpoint { get; set; } = string.Empty;

        /// <summary>
        /// طريقة HTTP المستخدمة.
        /// HTTP method used for retrieval.
        /// </summary>
        public string HttpMethod { get; set; } = string.Empty;

        /// <summary>
        /// الرؤوس الإضافية.
        /// Additional request headers.
        /// </summary>
        public string Headers { get; set; } = string.Empty;

        /// <summary>
        /// معاملات الاستعلام.
        /// Query-string parameters.
        /// </summary>
        public string QueryParams { get; set; } = string.Empty;

        /// <summary>
        /// جسم الطلب عند الحاجة.
        /// Request body when needed.
        /// </summary>
        public string RequestBody { get; set; } = string.Empty;

        /// <summary>
        /// تعريف أو إعدادات تحويل البيانات.
        /// Data mapping definition or configuration.
        /// </summary>
        public string DataMapping { get; set; } = string.Empty;

        /// <summary>
        /// مفتاح التخزين المؤقت.
        /// Cache key.
        /// </summary>
        public string CacheKey { get; set; } = string.Empty;

        /// <summary>
        /// مدة التخزين المؤقت بالثواني.
        /// Cache duration in seconds.
        /// </summary>
        public int CacheDuration { get; set; }

        /// <summary>
        /// المشغّل الذي يفرض إعادة الجلب.
        /// Trigger that forces a refresh.
        /// </summary>
        public string RefreshTrigger { get; set; } = string.Empty;

        /// <summary>
        /// فترة التحديث الدوري.
        /// Scheduled refresh interval.
        /// </summary>
        public int RefreshInterval { get; set; }

        /// <summary>
        /// استراتيجية معالجة الأخطاء.
        /// Error handling strategy.
        /// </summary>
        public string ErrorHandling { get; set; } = string.Empty;

        /// <summary>
        /// بيانات وهمية للاختبار أو التطوير.
        /// Mock data used during development or testing.
        /// </summary>
        public string MockData { get; set; } = string.Empty;

        /// <summary>
        /// يحدد ما إذا كان يجب استخدام البيانات الوهمية في بيئة التطوير.
        /// Indicates whether mock data should be used in development.
        /// </summary>
        public bool UseMockInDev { get; set; }
    }
}
