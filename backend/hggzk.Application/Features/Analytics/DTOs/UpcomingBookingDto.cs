using System;

namespace YemenBooking.Application.Features.Analytics.DTOs {
    /// <summary>
    /// فئة UpcomingBookingDto.
    /// UpcomingBookingDto class.
    /// </summary>
    public class UpcomingBookingDto
    {
        /// <summary>
        /// خاصية BookingId.
        /// BookingId property.
        /// </summary>
        public Guid BookingId { get; set; }
        /// <summary>
        /// خاصية GuestName.
        /// GuestName property.
        /// </summary>
        public string GuestName { get; set; }
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
        /// خاصية Status.
        /// Status property.
        /// </summary>
        public string Status { get; set; }
        /// <summary>
        /// خاصية TotalAmount.
        /// TotalAmount property.
        /// </summary>
        public decimal TotalAmount { get; set; }
    }
} 