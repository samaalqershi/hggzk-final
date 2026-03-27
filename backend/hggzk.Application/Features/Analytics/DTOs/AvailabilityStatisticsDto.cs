using System;

namespace YemenBooking.Application.Features.Analytics.DTOs {
    /// <summary>
    /// فئة AvailabilityStatisticsDto.
    /// AvailabilityStatisticsDto class.
    /// </summary>
    public class AvailabilityStatisticsDto
    {
        /// <summary>
        /// خاصية DateRange.
        /// DateRange property.
        /// </summary>
        public DateRangeRequestDto DateRange { get; set; }
        /// <summary>
        /// خاصية TotalDays.
        /// TotalDays property.
        /// </summary>
        public int TotalDays { get; set; }
        /// <summary>
        /// خاصية AvailableDays.
        /// AvailableDays property.
        /// </summary>
        public int AvailableDays { get; set; }
        /// <summary>
        /// خاصية UnavailableDays.
        /// UnavailableDays property.
        /// </summary>
        public int UnavailableDays { get; set; }
        /// <summary>
        /// خاصية MaintenanceDays.
        /// MaintenanceDays property.
        /// </summary>
        public int MaintenanceDays { get; set; }
        /// <summary>
        /// خاصية BookedDays.
        /// BookedDays property.
        /// </summary>
        public int BookedDays { get; set; }
        /// <summary>
        /// خاصية OccupancyRate.
        /// OccupancyRate property.
        /// </summary>
        public double OccupancyRate { get; set; }
        /// <summary>
        /// خاصية RevenueLostDueToUnavailability.
        /// RevenueLostDueToUnavailability property.
        /// </summary>
        public decimal RevenueLostDueToUnavailability { get; set; }
        /// <summary>
        /// خاصية AverageDailyRate.
        /// AverageDailyRate property.
        /// </summary>
        public decimal AverageDailyRate { get; set; }
        /// <summary>
        /// خاصية RevenuePerAvailableUnit.
        /// RevenuePerAvailableUnit property.
        /// </summary>
        public decimal RevenuePerAvailableUnit { get; set; }
    }
} 