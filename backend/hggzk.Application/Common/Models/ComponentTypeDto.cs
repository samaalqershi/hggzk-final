using System;
using System.Collections.Generic;

namespace YemenBooking.Application.Common.Models
{
    /// <summary>
    /// DTO يصف نوع المكوّن وقابلياته الأساسية.
    /// DTO that describes a component type and its core capabilities.
    /// </summary>
    public class ComponentTypeDto
    {
        /// <summary>
        /// المعرّف المنطقي لنوع المكوّن.
        /// Logical component type identifier.
        /// </summary>
        public string Type { get; set; } = string.Empty;

        /// <summary>
        /// الاسم المقروء للمكوّن.
        /// Human-readable component name.
        /// </summary>
        public string Name { get; set; } = string.Empty;

        /// <summary>
        /// وصف مختصر للمكوّن.
        /// Short component description.
        /// </summary>
        public string Description { get; set; } = string.Empty;

        /// <summary>
        /// اسم الأيقونة أو مسارها.
        /// Icon name or asset path.
        /// </summary>
        public string Icon { get; set; } = string.Empty;

        /// <summary>
        /// الفئة أو التصنيف العام.
        /// Category or grouping name.
        /// </summary>
        public string Category { get; set; } = string.Empty;

        /// <summary>
        /// الامتداد الافتراضي للأعمدة.
        /// Default column span.
        /// </summary>
        public int DefaultColSpan { get; set; }

        /// <summary>
        /// الامتداد الافتراضي للصفوف.
        /// Default row span.
        /// </summary>
        public int DefaultRowSpan { get; set; }

        /// <summary>
        /// يحدد ما إذا كان المكوّن يقبل إعادة التحجيم.
        /// Indicates whether the component supports resizing.
        /// </summary>
        public bool AllowResize { get; set; }

        /// <summary>
        /// تعريفات الخصائص القابلة للضبط.
        /// Definitions for configurable properties.
        /// </summary>
        public List<ComponentPropertyMetadata> PropertyDto { get; set; } = new();

        /// <summary>
        /// المنصات المدعومة.
        /// Supported platforms.
        /// </summary>
        public List<string> SupportedPlatforms { get; set; } = new();

        /// <summary>
        /// أنماط افتراضية للمكوّن.
        /// Default style values for the component.
        /// </summary>
        public Dictionary<string, object> DefaultStyles { get; set; } = new();
    }

    /// <summary>
    /// بيانات وصفية لخاصية قابلة للتهيئة داخل نوع مكوّن.
    /// Metadata describing a configurable property within a component type.
    /// </summary>
    public class ComponentPropertyMetadata
    {
        /// <summary>
        /// المفتاح البرمجي للخاصية.
        /// Property key.
        /// </summary>
        public string Key { get; set; } = string.Empty;

        /// <summary>
        /// الاسم المقروء للخاصية.
        /// Human-readable property name.
        /// </summary>
        public string Name { get; set; } = string.Empty;

        /// <summary>
        /// نوع بيانات الخاصية.
        /// Property data type.
        /// </summary>
        public string Type { get; set; } = string.Empty;

        /// <summary>
        /// يحدد ما إذا كانت الخاصية مطلوبة.
        /// Indicates whether the property is required.
        /// </summary>
        public bool IsRequired { get; set; }

        /// <summary>
        /// القيمة الافتراضية.
        /// Default value.
        /// </summary>
        public string DefaultValue { get; set; } = string.Empty;

        /// <summary>
        /// الخيارات المسموحة عند وجود قائمة اختيار.
        /// Allowed options when the property is selectable.
        /// </summary>
        public string[] Options { get; set; } = Array.Empty<string>();

        /// <summary>
        /// وصف الخاصية.
        /// Property description.
        /// </summary>
        public string Description { get; set; } = string.Empty;

        /// <summary>
        /// نمط التحقق عند الحاجة.
        /// Validation pattern when applicable.
        /// </summary>
        public string ValidationPattern { get; set; } = string.Empty;
    }
}
