using System.Collections.Generic;

namespace YemenBooking.Application.Features.Analytics.DTOs {
    /// <summary>
    /// فئة ManagementPageResponseDto.
    /// ManagementPageResponseDto class.
    /// </summary>
    public class ManagementPageResponseDto
    {
        /// <summary>
        /// خاصية Units.
        /// Units property.
        /// </summary>
        public IEnumerable<UnitManagementDataDto> Units { get; set; }
        /// <summary>
        /// خاصية Summary.
        /// Summary property.
        /// </summary>
        public ManagementSummaryDto Summary { get; set; }
    }
} 