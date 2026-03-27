namespace YemenBooking.Application.Features.Analytics.DTOs {
    /// <summary>
    /// فئة SeasonalAdjustmentDto.
    /// SeasonalAdjustmentDto class.
    /// </summary>
    public class SeasonalAdjustmentDto
    {
        /// <summary>
        /// خاصية Period.
        /// Period property.
        /// </summary>
        public string Period { get; set; }
        /// <summary>
        /// خاصية AverageAdjustment.
        /// AverageAdjustment property.
        /// </summary>
        public decimal AverageAdjustment { get; set; }
        /// <summary>
        /// خاصية RevenueImpact.
        /// RevenueImpact property.
        /// </summary>
        public decimal RevenueImpact { get; set; }
    }
} 