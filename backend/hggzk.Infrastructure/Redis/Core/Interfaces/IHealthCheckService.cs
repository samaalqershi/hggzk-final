using System;
using System.Threading;
using System.Threading.Tasks;

namespace YemenBooking.Infrastructure.Redis.Core.Interfaces
{
    /// <summary>
    /// واجهة فحص صحة النظام
    /// </summary>
    public interface IHealthCheckService
    {
        /// <summary>
        /// فحص صحة النظام
        /// </summary>
        Task<HealthCheckResult> CheckHealthAsync(CancellationToken cancellationToken = default);

        /// <summary>
        /// فحص صحة Redis
        /// </summary>
        Task<ComponentHealthResult> CheckRedisHealthAsync(CancellationToken cancellationToken = default);

        /// <summary>
        /// فحص صحة قاعدة البيانات
        /// </summary>
        Task<ComponentHealthResult> CheckDatabaseHealthAsync(CancellationToken cancellationToken = default);

        /// <summary>
        /// فحص معدل الأداء
        /// </summary>
        Task<PerformanceMetrics> GetPerformanceMetricsAsync(CancellationToken cancellationToken = default);
    }

    /// <summary>
    /// نتيجة فحص الصحة
    /// </summary>
    public class HealthCheckResult
    {
        /// <summary>
        /// خاصية Status.
        /// Status property.
        /// </summary>
        public HealthStatus Status { get; set; }
        /// <summary>
        /// خاصية Description.
        /// Description property.
        /// </summary>
        public string Description { get; set; }
        /// <summary>
        /// خاصية Components.
        /// Components property.
        /// </summary>
        public Dictionary<string, ComponentHealthResult> Components { get; set; } = new();
        /// <summary>
        /// خاصية ResponseTime.
        /// ResponseTime property.
        /// </summary>
        public TimeSpan ResponseTime { get; set; }
        /// <summary>
        /// خاصية CheckTime.
        /// CheckTime property.
        /// </summary>
        public DateTime CheckTime { get; set; }
    }

    /// <summary>
    /// حالة الصحة
    /// </summary>
    public enum HealthStatus
    {
        /// <summary>
        /// قيمة تعداد Healthy.
        /// Healthy enum value.
        /// </summary>
        Healthy,
        /// <summary>
        /// قيمة تعداد Degraded.
        /// Degraded enum value.
        /// </summary>
        Degraded,
        /// <summary>
        /// قيمة تعداد Unhealthy.
        /// Unhealthy enum value.
        /// </summary>
        Unhealthy
    }

    /// <summary>
    /// نتيجة فحص مكون
    /// </summary>
    public class ComponentHealthResult
    {
        /// <summary>
        /// خاصية ComponentName.
        /// ComponentName property.
        /// </summary>
        public string ComponentName { get; set; }
        /// <summary>
        /// خاصية Status.
        /// Status property.
        /// </summary>
        public HealthStatus Status { get; set; }
        /// <summary>
        /// خاصية Message.
        /// Message property.
        /// </summary>
        public string Message { get; set; }
        /// <summary>
        /// خاصية ResponseTime.
        /// ResponseTime property.
        /// </summary>
        public TimeSpan ResponseTime { get; set; }
        /// <summary>
        /// خاصية Metadata.
        /// Metadata property.
        /// </summary>
        public Dictionary<string, object> Metadata { get; set; } = new();
    }

    /// <summary>
    /// مقاييس الأداء
    /// </summary>
    public class PerformanceMetrics
    {
        /// <summary>
        /// خاصية IndexingRate.
        /// IndexingRate property.
        /// </summary>
        public double IndexingRate { get; set; } // عمليات في الثانية
        /// <summary>
        /// خاصية SearchRate.
        /// SearchRate property.
        /// </summary>
        public double SearchRate { get; set; } // بحث في الثانية
        /// <summary>
        /// خاصية ErrorRate.
        /// ErrorRate property.
        /// </summary>
        public double ErrorRate { get; set; } // نسبة الأخطاء
        /// <summary>
        /// خاصية AverageResponseTime.
        /// AverageResponseTime property.
        /// </summary>
        public double AverageResponseTime { get; set; } // بالميلي ثانية
        /// <summary>
        /// خاصية TotalOperations.
        /// TotalOperations property.
        /// </summary>
        public long TotalOperations { get; set; }
        /// <summary>
        /// خاصية FailedOperations.
        /// FailedOperations property.
        /// </summary>
        public long FailedOperations { get; set; }
        /// <summary>
        /// خاصية OperationDurations.
        /// OperationDurations property.
        /// </summary>
        public Dictionary<string, double> OperationDurations { get; set; } = new();
        /// <summary>
        /// خاصية MeasurementTime.
        /// MeasurementTime property.
        /// </summary>
        public DateTime MeasurementTime { get; set; }
    }
}
