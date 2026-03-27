using System;

namespace YemenBooking.Application.Features.Analytics.DTOs {
    /// <summary>
    /// فئة AvailabilityCalendarDto.
    /// AvailabilityCalendarDto class.
    /// </summary>
    public class AvailabilityCalendarDto
    {
        /// <summary>
        /// خاصية Date.
        /// Date property.
        /// </summary>
        public DateTime Date { get; set; }
        /// <summary>
        /// خاصية Status.
        /// Status property.
        /// </summary>
        public string Status { get; set; }
        /// <summary>
        /// خاصية Reason.
        /// Reason property.
        /// </summary>
        public string? Reason { get; set; }
        /// <summary>
        /// خاصية PricingTier.
        /// PricingTier property.
        /// </summary>
        public string? PricingTier { get; set; }
        /// <summary>
        /// خاصية CurrentPrice.
        /// CurrentPrice property.
        /// </summary>
        public decimal? CurrentPrice { get; set; }
        // Currency code for the calendar entry
        /// <summary>
        /// خاصية Currency.
        /// Currency property.
        /// </summary>
        public string Currency { get; set; }
    }
} 