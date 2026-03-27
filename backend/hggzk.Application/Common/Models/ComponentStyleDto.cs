using System;

namespace YemenBooking.Application.Common.Models
{
    /// <summary>
    /// DTO يصف خاصية تنسيق قابلة للتهيئة لمكوّن.
    /// DTO that describes a configurable style attribute for a component.
    /// </summary>
    public class ComponentStyleDto
    {
        /// <summary>
        /// المعرف الفريد لسجل التنسيق.
        /// Unique identifier of the style record.
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// اسم خاصية التنسيق.
        /// Style property key.
        /// </summary>
        public string StyleKey { get; set; } = string.Empty;

        /// <summary>
        /// قيمة خاصية التنسيق.
        /// Style property value.
        /// </summary>
        public string StyleValue { get; set; } = string.Empty;

        /// <summary>
        /// وحدة القياس المرتبطة بالقيمة.
        /// Measurement unit for the value.
        /// </summary>
        public string Unit { get; set; } = string.Empty;

        /// <summary>
        /// يحدد ما إذا كانت الخاصية مهمّة.
        /// Indicates whether the style should be marked as important.
        /// </summary>
        public bool IsImportant { get; set; }

        /// <summary>
        /// شرط الاستجابة أو الوسائط.
        /// Responsive media query condition.
        /// </summary>
        public string MediaQuery { get; set; } = string.Empty;

        /// <summary>
        /// الحالة المرئية المستهدفة.
        /// Visual state targeted by the style.
        /// </summary>
        public string State { get; set; } = string.Empty;

        /// <summary>
        /// المنصة أو القناة المستهدفة.
        /// Target platform or channel.
        /// </summary>
        public string Platform { get; set; } = string.Empty;
    }
}
