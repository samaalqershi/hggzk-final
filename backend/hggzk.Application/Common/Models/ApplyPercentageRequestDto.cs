using System;
using System.Collections.Generic;

namespace YemenBooking.Application.Common.Models
{
    /// <summary>
    /// DTO لطلب تطبيق نسبة مئوية على الأسعار
    /// Apply percentage change request DTO
    /// </summary>
    public class ApplyPercentageRequestDto
    {
        /// <summary>
        /// معرفات الوحدات المستهدفة بالتحديث.
        /// Identifiers of the units targeted by the update.
        /// </summary>
        public IEnumerable<Guid> UnitIds { get; set; } = Array.Empty<Guid>();

        /// <summary>
        /// نسبة التغيير المطلوبة.
        /// Requested percentage delta.
        /// </summary>
        public decimal PercentageChange { get; set; }

        /// <summary>
        /// بداية نطاق التطبيق.
        /// Start of the application range.
        /// </summary>
        public DateTime StartDate { get; set; }

        /// <summary>
        /// نهاية نطاق التطبيق.
        /// End of the application range.
        /// </summary>
        public DateTime EndDate { get; set; }
    }
}
