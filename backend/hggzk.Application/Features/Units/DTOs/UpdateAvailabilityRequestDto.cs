using System;

namespace YemenBooking.Application.Features.Units.DTOs {
    /// <summary>
    /// DTO لتحديث إتاحة موجودة
    /// Update unit availability request DTO
    /// </summary>
    public class UpdateAvailabilityRequestDto : CreateAvailabilityRequestDto
    {
        /// <summary>
        /// خاصية AvailabilityId.
        /// AvailabilityId property.
        /// </summary>
        public Guid AvailabilityId { get; set; }
    }
} 