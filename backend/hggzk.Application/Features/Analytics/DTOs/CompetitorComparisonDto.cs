namespace YemenBooking.Application.Features.Analytics.DTOs {
    /// <summary>
    /// فئة CompetitorComparisonDto.
    /// CompetitorComparisonDto class.
    /// </summary>
    public class CompetitorComparisonDto
    {
        /// <summary>
        /// خاصية OurAverage.
        /// OurAverage property.
        /// </summary>
        public decimal OurAverage { get; set; }
        /// <summary>
        /// خاصية MarketAverage.
        /// MarketAverage property.
        /// </summary>
        public decimal MarketAverage { get; set; }
        /// <summary>
        /// خاصية PricePosition.
        /// PricePosition property.
        /// </summary>
        public string PricePosition { get; set; }
        /// <summary>
        /// خاصية SuggestedAdjustment.
        /// SuggestedAdjustment property.
        /// </summary>
        public decimal SuggestedAdjustment { get; set; }
    }
} 