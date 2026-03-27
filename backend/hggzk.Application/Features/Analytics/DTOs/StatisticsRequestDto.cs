using System;
using System.Collections.Generic;

namespace YemenBooking.Application.Features.Analytics.DTOs {
    /// <summary>
    /// فئة StatisticsRequestDto.
    /// StatisticsRequestDto class.
    /// </summary>
    public class StatisticsRequestDto
    {
        /// <summary>
        /// خاصية UnitIds.
        /// UnitIds property.
        /// </summary>
        public IEnumerable<Guid> UnitIds { get; set; }
        /// <summary>
        /// خاصية DateRange.
        /// DateRange property.
        /// </summary>
        public DateRangeRequestDto DateRange { get; set; }
    }
} 