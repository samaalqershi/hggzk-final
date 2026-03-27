using System;
using System.Collections.Generic;

namespace YemenBooking.Application.Common.Models
{
    /// <summary>
    /// إحصائيات المدن مع مؤشرات اتجاه اختيارية.
    /// City statistics with optional trend indicators over a date window.
    /// </summary>
    public class CityStatsDto
    {
        /// <summary>
        /// العدد الكلي للمدن.
        /// Total number of cities.
        /// </summary>
        public int TotalCities { get; set; }

        /// <summary>
        /// عدد المدن النشطة.
        /// Total number of active cities.
        /// </summary>
        public int ActiveCities { get; set; }

        /// <summary>
        /// توزيع المدن حسب الدولة.
        /// City distribution grouped by country.
        /// </summary>
        public Dictionary<string, int> ByCountry { get; set; } = new();

        /// <summary>
        /// إجمالي عدد الصور المرتبطة.
        /// Total associated images.
        /// </summary>
        public int TotalImages { get; set; }

        /// <summary>
        /// اتجاه تغير عدد الصور.
        /// Trend for image count changes.
        /// </summary>
        public double? ImagesTrend { get; set; }

        /// <summary>
        /// عدد التحديثات خلال الفترة.
        /// Number of updates during the selected period.
        /// </summary>
        public int UpdatesCount { get; set; }

        /// <summary>
        /// نسبة اتجاه التحديثات مقارنة بالفترة السابقة.
        /// Update trend percentage compared with the previous period.
        /// </summary>
        public double? UpdatesTrendPct { get; set; }
    }
}
