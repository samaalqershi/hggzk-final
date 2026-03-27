using System;

namespace YemenBooking.Application.Features.Units.DTOs {
    /// <summary>
    /// DTO للتحديث السريع لحالة الإتاحة
    /// Quick update unit availability request DTO
    /// </summary>
    public class QuickUpdateAvailabilityRequestDto
    {
        /// <summary>
        /// خاصية Status.
        /// Status property.
        /// </summary>
        public string Status { get; set; }
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
    }
} 