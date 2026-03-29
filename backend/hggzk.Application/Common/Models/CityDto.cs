using System;
using System.Collections.Generic;

namespace YemenBooking.Application.Common.Models
{
    /// <summary>
    /// DTO لإعدادات المدينة.
    /// DTO for city settings.
    /// </summary>
    public class CityDto
    {
        /// <summary>
        /// اسم المدينة الفريد.
        /// Unique city name.
        /// </summary>
        public string Name { get; set; } = string.Empty;
        public string? NameEn { get; set; }

        /// <summary>
        /// اسم الدولة التابعة لها المدينة.
        /// Country name.
        /// </summary>
        public string Country { get; set; } = string.Empty;
        public string? CountryEn { get; set; }

        /// <summary>
        /// روابط الصور المرتبطة بالمدينة.
        /// Image URLs associated with the city.
        /// </summary>
        public List<string> Images { get; set; } = new List<string>();

        /// <summary>
        /// حالة النشاط الاختيارية للاستخدام في لوحة التحكم.
        /// Optional active flag used in the control-panel UI.
        /// </summary>
        public bool? IsActive { get; set; }
    }
}
