using System;

namespace YemenBooking.Application.Features.Notifications.DTOs {
    /// <summary>
    /// إحصائيات الإشعارات المعروضة في لوحة الإدارة
    /// Notifications statistics for admin dashboard
    /// </summary>
    public class NotificationsStatsDto
    {
        /// <summary>
        /// خاصية Total.
        /// Total property.
        /// </summary>
        public int Total { get; set; }
        /// <summary>
        /// خاصية Pending.
        /// Pending property.
        /// </summary>
        public int Pending { get; set; }
        /// <summary>
        /// خاصية Sent.
        /// Sent property.
        /// </summary>
        public int Sent { get; set; }
        /// <summary>
        /// خاصية Delivered.
        /// Delivered property.
        /// </summary>
        public int Delivered { get; set; }
        /// <summary>
        /// خاصية Read.
        /// Read property.
        /// </summary>
        public int Read { get; set; }
        /// <summary>
        /// خاصية Failed.
        /// Failed property.
        /// </summary>
        public int Failed { get; set; }

        /// <summary>
        /// خاصية Today.
        /// Today property.
        /// </summary>
        public int Today { get; set; }
        /// <summary>
        /// خاصية Last7Days.
        /// Last7Days property.
        /// </summary>
        public int Last7Days { get; set; }
        /// <summary>
        /// خاصية Last30Days.
        /// Last30Days property.
        /// </summary>
        public int Last30Days { get; set; }

        // Trends over [from,to] vs previous equal-length window (rounded %)
        /// <summary>
        /// خاصية TotalTrend.
        /// TotalTrend property.
        /// </summary>
        public int TotalTrend { get; set; }
        /// <summary>
        /// خاصية SentTrend.
        /// SentTrend property.
        /// </summary>
        public int SentTrend { get; set; }
        /// <summary>
        /// خاصية PendingTrend.
        /// PendingTrend property.
        /// </summary>
        public int PendingTrend { get; set; }
        /// <summary>
        /// خاصية FailedTrend.
        /// FailedTrend property.
        /// </summary>
        public int FailedTrend { get; set; }

        // Read rate in % for the window and its trend
        /// <summary>
        /// خاصية ReadRate.
        /// ReadRate property.
        /// </summary>
        public int ReadRate { get; set; }
        /// <summary>
        /// خاصية ReadRateTrend.
        /// ReadRateTrend property.
        /// </summary>
        public int ReadRateTrend { get; set; }
    }
}

