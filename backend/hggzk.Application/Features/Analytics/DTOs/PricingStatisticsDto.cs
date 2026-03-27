using System.Collections.Generic;

namespace YemenBooking.Application.Features.Analytics.DTOs {
    /// <summary>
    /// فئة PricingStatisticsDto.
    /// PricingStatisticsDto class.
    /// </summary>
    public class PricingStatisticsDto
    {
        /// <summary>
        /// خاصية DateRange.
        /// DateRange property.
        /// </summary>
        public DateRangeRequestDto DateRange { get; set; }
        /// <summary>
        /// خاصية AveragePrice.
        /// AveragePrice property.
        /// </summary>
        public decimal AveragePrice { get; set; }
        /// <summary>
        /// خاصية MinPrice.
        /// MinPrice property.
        /// </summary>
        public decimal MinPrice { get; set; }
        /// <summary>
        /// خاصية MaxPrice.
        /// MaxPrice property.
        /// </summary>
        public decimal MaxPrice { get; set; }
        /// <summary>
        /// خاصية PriceVariance.
        /// PriceVariance property.
        /// </summary>
        public decimal PriceVariance { get; set; }
        /// <summary>
        /// خاصية SeasonalAdjustments.
        /// SeasonalAdjustments property.
        /// </summary>
        public IEnumerable<SeasonalAdjustmentDto> SeasonalAdjustments { get; set; }
        /// <summary>
        /// خاصية CompetitorComparison.
        /// CompetitorComparison property.
        /// </summary>
        public CompetitorComparisonDto? CompetitorComparison { get; set; }
    }
} 