using System;
using System.Collections.Generic;
using YemenBooking.Core.Enums;

namespace YemenBooking.Application.Features.Bookings.DTOs {
    /// <summary>
    /// استجابة حجوزات المستخدم.
    /// User bookings response.
    /// </summary>
    public class UserBookingsResponse
    {
        /// <summary>
        /// قائمة الحجوزات.
        /// Booking list.
        /// </summary>
        public List<UserBookingDto> Bookings { get; set; } = new();

        /// <summary>
        /// إجمالي الحجوزات.
        /// Total bookings count.
        /// </summary>
        public int TotalCount { get; set; }

        /// <summary>
        /// رقم الصفحة الحالية.
        /// Current page number.
        /// </summary>
        public int CurrentPage { get; set; }

        /// <summary>
        /// حجم الصفحة.
        /// Page size.
        /// </summary>
        public int PageSize { get; set; }

        /// <summary>
        /// إجمالي الصفحات.
        /// Total pages count.
        /// </summary>
        public int TotalPages { get; set; }

        /// <summary>
        /// هل توجد صفحة سابقة.
        /// Indicates whether a previous page exists.
        /// </summary>
        public bool HasPreviousPage { get; set; }

        /// <summary>
        /// هل توجد صفحة تالية.
        /// Indicates whether a next page exists.
        /// </summary>
        public bool HasNextPage { get; set; }
    }

    /// <summary>
    /// بيانات حجز المستخدم.
    /// User booking data.
    /// </summary>
    public class UserBookingDto
    {
        /// <summary>
        /// معرف الحجز.
        /// Booking identifier.
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// رقم الحجز.
        /// Booking number.
        /// </summary>
        public string BookingNumber { get; set; } = string.Empty;

        /// <summary>
        /// اسم العقار
        /// Property name
        /// </summary>
        public string PropertyName { get; set; } = string.Empty;

        /// <summary>
        /// صورة العقار.
        /// Property image.
        /// </summary>
        public string PropertyImage { get; set; } = string.Empty;

        /// <summary>
        /// موقع العقار.
        /// Property location.
        /// </summary>
        public string PropertyLocation { get; set; } = string.Empty;

        /// <summary>
        /// تاريخ الوصول.
        /// Check-in date.
        /// </summary>
        public DateTime CheckInDate { get; set; }

        /// <summary>
        /// تاريخ المغادرة.
        /// Check-out date.
        /// </summary>
        public DateTime CheckOutDate { get; set; }

        /// <summary>
        /// عدد الليالي.
        /// Number of nights.
        /// </summary>
        public int NumberOfNights { get; set; }

        /// <summary>
        /// عدد الضيوف.
        /// Number of guests.
        /// </summary>
        public int TotalGuests { get; set; }

        /// <summary>
        /// المبلغ الإجمالي.
        /// Total amount.
        /// </summary>
        public decimal TotalAmount { get; set; }

        /// <summary>
        /// العملة.
        /// Currency.
        /// </summary>
        public string Currency { get; set; } = "YER";

        /// <summary>
        /// حالة الحجز.
        /// Booking status.
        /// </summary>
        public BookingStatus Status { get; set; }

        /// <summary>
        /// نص حالة الحجز.
        /// Booking status text.
        /// </summary>
        public string StatusText { get; set; } = string.Empty;

        /// <summary>
        /// تاريخ الحجز.
        /// Booking date.
        /// </summary>
        public DateTime BookingDate { get; set; }

        /// <summary>
        /// هل يمكن إلغاء الحجز.
        /// Indicates whether the booking can be cancelled.
        /// </summary>
        public bool CanCancel { get; set; }

        /// <summary>
        /// هل يمكن تعديل الحجز.
        /// Indicates whether the booking can be modified.
        /// </summary>
        public bool CanModify { get; set; }

        /// <summary>
        /// تقييم العقار إن وجد.
        /// Property rating, if available.
        /// </summary>
        public int? Rating { get; set; }

        /// <summary>
        /// هل كُتبت مراجعة.
        /// Indicates whether a review was written.
        /// </summary>
        public bool HasReview { get; set; }
    }
}
