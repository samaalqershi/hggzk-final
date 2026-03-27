using System;

namespace YemenBooking.Application.Common.Models
{
    /// <summary>
    /// DTO لتحديث سريع لحالة الإتاحة
    /// Quick update availability request DTO
    /// </summary>
    public class QuickUpdateRequestDto
    {
        /// <summary>
        /// تاريخ بداية التحديث السريع.
        /// Start date of the quick update window.
        /// </summary>
        public DateTime StartDate { get; set; }

        /// <summary>
        /// تاريخ نهاية التحديث السريع.
        /// End date of the quick update window.
        /// </summary>
        public DateTime EndDate { get; set; }

        /// <summary>
        /// الحالة المطلوب تطبيقها.
        /// Availability status to apply.
        /// </summary>
        public string Status { get; set; } = string.Empty;
    }
}
