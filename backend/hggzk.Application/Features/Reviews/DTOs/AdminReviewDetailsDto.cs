using System;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties.DTOs;

namespace YemenBooking.Application.Features.Reviews.DTOs {
    /// <summary>
    /// تفاصيل تقييم شاملة للوحة التحكم الإدارية
    /// Admin review details DTO
    /// </summary>
    public class AdminReviewDetailsDto
    {
        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        public Guid Id { get; set; }
        /// <summary>
        /// خاصية BookingId.
        /// BookingId property.
        /// </summary>
        public Guid BookingId { get; set; }
        /// <summary>
        /// خاصية PropertyId.
        /// PropertyId property.
        /// </summary>
        public Guid PropertyId { get; set; }
        /// <summary>
        /// خاصية UnitId.
        /// UnitId property.
        /// </summary>
        public Guid? UnitId { get; set; }

        // Ratings
        /// <summary>
        /// خاصية Cleanliness.
        /// Cleanliness property.
        /// </summary>
        public int Cleanliness { get; set; }
        /// <summary>
        /// خاصية Service.
        /// Service property.
        /// </summary>
        public int Service { get; set; }
        /// <summary>
        /// خاصية Location.
        /// Location property.
        /// </summary>
        public int Location { get; set; }
        /// <summary>
        /// خاصية Value.
        /// Value property.
        /// </summary>
        public int Value { get; set; }
        /// <summary>
        /// خاصية AverageRating.
        /// AverageRating property.
        /// </summary>
        public decimal AverageRating { get; set; }

        // Review content
        /// <summary>
        /// خاصية Comment.
        /// Comment property.
        /// </summary>
        public string Comment { get; set; } = string.Empty;
        /// <summary>
        /// خاصية CreatedAt.
        /// CreatedAt property.
        /// </summary>
        public DateTime CreatedAt { get; set; }
        /// <summary>
        /// خاصية IsApproved.
        /// IsApproved property.
        /// </summary>
        public bool IsApproved { get; set; }
        /// <summary>
        /// خاصية IsPending.
        /// IsPending property.
        /// </summary>
        public bool IsPending { get; set; }
        /// <summary>
        /// خاصية IsDisabled.
        /// IsDisabled property.
        /// </summary>
        public bool IsDisabled { get; set; }
        /// <summary>
        /// خاصية ResponseText.
        /// ResponseText property.
        /// </summary>
        public string? ResponseText { get; set; }
        /// <summary>
        /// خاصية ResponseDate.
        /// ResponseDate property.
        /// </summary>
        public DateTime? ResponseDate { get; set; }
        /// <summary>
        /// خاصية RespondedBy.
        /// RespondedBy property.
        /// </summary>
        public Guid? RespondedBy { get; set; }

        // Images
        /// <summary>
        /// خاصية Images.
        /// Images property.
        /// </summary>
        public List<ReviewImageDto> Images { get; set; } = new List<ReviewImageDto>();

        // Linked names
        /// <summary>
        /// خاصية PropertyName.
        /// PropertyName property.
        /// </summary>
        public string PropertyName { get; set; } = string.Empty;
        /// <summary>
        /// خاصية UnitName.
        /// UnitName property.
        /// </summary>
        public string? UnitName { get; set; }

        // Property location
        /// <summary>
        /// خاصية PropertyCity.
        /// PropertyCity property.
        /// </summary>
        public string? PropertyCity { get; set; }
        /// <summary>
        /// خاصية PropertyAddress.
        /// PropertyAddress property.
        /// </summary>
        public string? PropertyAddress { get; set; }

        // Reviewer
        /// <summary>
        /// خاصية UserName.
        /// UserName property.
        /// </summary>
        public string UserName { get; set; } = string.Empty;
        /// <summary>
        /// خاصية UserEmail.
        /// UserEmail property.
        /// </summary>
        public string? UserEmail { get; set; }
        /// <summary>
        /// خاصية UserPhone.
        /// UserPhone property.
        /// </summary>
        public string? UserPhone { get; set; }

        // BookingDto details
        /// <summary>
        /// خاصية BookingCheckIn.
        /// BookingCheckIn property.
        /// </summary>
        public DateTime? BookingCheckIn { get; set; }
        /// <summary>
        /// خاصية BookingCheckOut.
        /// BookingCheckOut property.
        /// </summary>
        public DateTime? BookingCheckOut { get; set; }
        /// <summary>
        /// خاصية GuestsCount.
        /// GuestsCount property.
        /// </summary>
        public int? GuestsCount { get; set; }
        /// <summary>
        /// خاصية BookingStatus.
        /// BookingStatus property.
        /// </summary>
        public string? BookingStatus { get; set; }
        /// <summary>
        /// خاصية BookingSource.
        /// BookingSource property.
        /// </summary>
        public string? BookingSource { get; set; }
    }
}

