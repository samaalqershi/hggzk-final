using System;

namespace YemenBooking.Application.Common.Models
{
    /// <summary>
    /// إحصائيات العملات مع مؤشرات اتجاه اختيارية ضمن نافذة زمنية.
    /// Currency statistics with optional trend indicators over a date window.
    /// </summary>
    public class CurrencyStatsDto
    {
        /// <summary>
        /// إجمالي عدد العملات المعرفة في النظام.
        /// Total number of currencies defined in the system.
        /// </summary>
        public int TotalCurrencies { get; set; }

        /// <summary>
        /// رمز العملة الافتراضية إن وجد.
        /// Default currency code when available.
        /// </summary>
        public string? DefaultCurrencyCode { get; set; }

        /// <summary>
        /// عدد العملات التي تملك سعر صرف متاحاً.
        /// Number of currencies that have an available exchange rate.
        /// </summary>
        public int CurrenciesWithExchangeRate { get; set; }

        /// <summary>
        /// متوسط أسعار الصرف الحالية.
        /// Average of the current exchange rates.
        /// </summary>
        public double AverageExchangeRate { get; set; }

        /// <summary>
        /// آخر وقت تم فيه تحديث بيانات الصرف.
        /// Last time exchange-rate data was updated.
        /// </summary>
        public DateTime? LastUpdated { get; set; }

        /// <summary>
        /// عدد عمليات التحديث داخل النافذة الزمنية الحالية.
        /// Number of updates inside the current date window.
        /// </summary>
        public int UpdatesCount { get; set; }

        /// <summary>
        /// نسبة تغير عدد التحديثات مقارنة بالفترة السابقة المماثلة.
        /// Percentage change in update count compared with the previous equal-length window.
        /// </summary>
        public double? UpdatesTrendPct { get; set; }

        /// <summary>
        /// متوسط أسعار الصرف التي تم تحديثها في الفترة.
        /// Average updated exchange rate within the period.
        /// </summary>
        public double? AverageUpdatedRate { get; set; }

        /// <summary>
        /// نسبة تغير متوسط السعر المحدث مقارنة بالفترة السابقة.
        /// Percentage change in the average updated rate versus the previous period.
        /// </summary>
        public double? AverageUpdatedRateTrendPct { get; set; }
    }
}
