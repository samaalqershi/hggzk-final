using System;

namespace YemenBooking.Application.Features.Analytics.DTOs {
    /// <summary>
    /// فئة PriceAlertDto.
    /// PriceAlertDto class.
    /// </summary>
    public class PriceAlertDto
    {
        /// <summary>
        /// خاصية UnitId.
        /// UnitId property.
        /// </summary>
        public Guid UnitId { get; set; }
        /// <summary>
        /// خاصية UnitName.
        /// UnitName property.
        /// </summary>
        public string UnitName { get; set; }
        /// <summary>
        /// خاصية AlertType.
        /// AlertType property.
        /// </summary>
        public string AlertType { get; set; }
        /// <summary>
        /// خاصية CurrentPrice.
        /// CurrentPrice property.
        /// </summary>
        public decimal? CurrentPrice { get; set; }
        /// <summary>
        /// خاصية SuggestedPrice.
        /// SuggestedPrice property.
        /// </summary>
        public decimal? SuggestedPrice { get; set; }
    }
} 