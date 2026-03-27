using System;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Analytics.DTOs {
    /// <summary>
    /// فئة AnalyticsExportRequestDto.
    /// AnalyticsExportRequestDto class.
    /// </summary>
    public class AnalyticsExportRequestDto
    {
        /// <summary>
        /// خاصية Type.
        /// Type property.
        /// </summary>
        public string Type { get; set; } = string.Empty;
        /// <summary>
        /// خاصية UnitIds.
        /// UnitIds property.
        /// </summary>
        public IEnumerable<Guid>? UnitIds { get; set; }
        /// <summary>
        /// خاصية DateRange.
        /// DateRange property.
        /// </summary>
        public DateRangeRequestDto DateRange { get; set; } = null!;
    }
} 
