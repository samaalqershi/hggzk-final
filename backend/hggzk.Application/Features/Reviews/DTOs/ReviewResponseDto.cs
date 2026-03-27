using System;

namespace YemenBooking.Application.Features.Reviews.DTOs {
    /// <summary>
    /// DTO لردود التقييمات
    /// Review response DTO
    /// </summary>
    public class ReviewResponseDto
    {
        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        public Guid Id { get; set; }
        /// <summary>
        /// خاصية ReviewId.
        /// ReviewId property.
        /// </summary>
        public Guid ReviewId { get; set; }
        /// <summary>
        /// خاصية ResponseText.
        /// ResponseText property.
        /// </summary>
        public string ResponseText { get; set; } = string.Empty;
        /// <summary>
        /// خاصية RespondedBy.
        /// RespondedBy property.
        /// </summary>
        public Guid RespondedBy { get; set; }
        /// <summary>
        /// خاصية RespondedByName.
        /// RespondedByName property.
        /// </summary>
        public string RespondedByName { get; set; } = string.Empty;
        /// <summary>
        /// خاصية CreatedAt.
        /// CreatedAt property.
        /// </summary>
        public DateTime CreatedAt { get; set; }
        /// <summary>
        /// خاصية UpdatedAt.
        /// UpdatedAt property.
        /// </summary>
        public DateTime? UpdatedAt { get; set; }
    }
}

