using System.Collections.Generic;

namespace YemenBooking.Application.Features.Analytics.DTOs {
    /// <summary>
    /// فئة ManagementSummaryDto.
    /// ManagementSummaryDto class.
    /// </summary>
    public class ManagementSummaryDto
    {
        /// <summary>
        /// خاصية TotalUnits.
        /// TotalUnits property.
        /// </summary>
        public int TotalUnits { get; set; }
        /// <summary>
        /// خاصية AvailableUnits.
        /// AvailableUnits property.
        /// </summary>
        public int AvailableUnits { get; set; }
        /// <summary>
        /// خاصية UnavailableUnits.
        /// UnavailableUnits property.
        /// </summary>
        public int UnavailableUnits { get; set; }
        /// <summary>
        /// خاصية MaintenanceUnits.
        /// MaintenanceUnits property.
        /// </summary>
        public int MaintenanceUnits { get; set; }
        /// <summary>
        /// خاصية BookedUnits.
        /// BookedUnits property.
        /// </summary>
        public int BookedUnits { get; set; }
        /// <summary>
        /// خاصية TotalRevenueToday.
        /// TotalRevenueToday property.
        /// </summary>
        public decimal TotalRevenueToday { get; set; }
        /// <summary>
        /// خاصية AvgOccupancyRate.
        /// AvgOccupancyRate property.
        /// </summary>
        public double AvgOccupancyRate { get; set; }
        /// <summary>
        /// خاصية PriceAlerts.
        /// PriceAlerts property.
        /// </summary>
        public IEnumerable<PriceAlertDto> PriceAlerts { get; set; }
    }
} 