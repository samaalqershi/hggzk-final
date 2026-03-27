using System;
using System.Collections.Generic;

namespace YemenBooking.Application.Features.Properties.DTOs
{
    /// <summary>
    /// كائن نقل بيانات سياسة العقار
    /// Property policy data transfer object
    /// </summary>
    public class PropertyPolicyDto
    {
        /// <summary>
        /// نوع السياسة
        /// Policy type
        /// </summary>
        public string PolicyType { get; set; } = string.Empty;

        /// <summary>
        /// محتوى السياسة
        /// Policy content
        /// </summary>
        public string PolicyContent { get; set; } = string.Empty;

        /// <summary>
        /// هل نشطة
        /// Is active
        /// </summary>
        public bool IsActive { get; set; } = true;

        // Mobile application compatibility fields.
        /// <summary>
        /// معرف السياسة
        /// Policy identifier
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// نوع السياسة (check_in, check_out, cancellation, etc.)
        /// Policy type
        /// </summary>
        public string Type { get; set; } = string.Empty;

        /// <summary>
        /// وصف السياسة
        /// Policy description
        /// </summary>
        public string Description { get; set; } = string.Empty;

        /// <summary>
        /// قواعد السياسة بصيغة قابلة للتسلسل إلى JSON
        /// Policy rules in a JSON-serialisable shape
        /// </summary>
        public Dictionary<string, object> Rules { get; set; } = new();
    }
}
