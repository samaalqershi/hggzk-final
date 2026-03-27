using System;

namespace YemenBooking.Application.Features.Units.DTOs {
    /// <summary>
    /// DTO لإنشاء إتاحة جديدة
    /// Create new unit availability request DTO
    /// </summary>
    public class CreateAvailabilityRequestDto
    {
        /// <summary>
        /// خاصية UnitId.
        /// UnitId property.
        /// </summary>
        public Guid UnitId { get; set; }
        /// <summary>
        /// خاصية StartDate.
        /// StartDate property.
        /// </summary>
        public DateTime StartDate { get; set; }
        /// <summary>
        /// خاصية EndDate.
        /// EndDate property.
        /// </summary>
        public DateTime EndDate { get; set; }
        /// <summary>
        /// خاصية StartTime.
        /// StartTime property.
        /// </summary>
        public TimeSpan? StartTime { get; set; }
        /// <summary>
        /// خاصية EndTime.
        /// EndTime property.
        /// </summary>
        public TimeSpan? EndTime { get; set; }
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
        /// خاصية Notes.
        /// Notes property.
        /// </summary>
        public string? Notes { get; set; }
        /// <summary>
        /// خاصية OverrideConflicts.
        /// OverrideConflicts property.
        /// </summary>
        public bool? OverrideConflicts { get; set; }
    }
} 