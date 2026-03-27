using System;
using System.Collections.Generic;

namespace YemenBooking.Application.Common.Models
{
    /// <summary>
    /// DTO يصف مصدراً عاماً للبيانات القابلة للربط بالمكوّنات.
    /// DTO that describes a reusable data source for configurable components.
    /// </summary>
    public class DataSourceDto
    {
        /// <summary>
        /// المعرّف المنطقي للمصدر.
        /// Logical identifier of the source.
        /// </summary>
        public string Id { get; set; } = string.Empty;

        /// <summary>
        /// الاسم المقروء للمصدر.
        /// Human-readable source name.
        /// </summary>
        public string Name { get; set; } = string.Empty;

        /// <summary>
        /// نوع المصدر.
        /// Source type.
        /// </summary>
        public string Type { get; set; } = string.Empty;

        /// <summary>
        /// وصف مختصر للمصدر.
        /// Short source description.
        /// </summary>
        public string Description { get; set; } = string.Empty;

        /// <summary>
        /// نقطة النهاية أو المرجع المستخدم للوصول للبيانات.
        /// Endpoint or reference used to access the data.
        /// </summary>
        public string Endpoint { get; set; } = string.Empty;

        /// <summary>
        /// يحدد ما إذا كان المصدر متاحاً حالياً.
        /// Indicates whether the source is currently available.
        /// </summary>
        public bool IsAvailable { get; set; }

        /// <summary>
        /// يحدد ما إذا كان المصدر يتطلب مصادقة.
        /// Indicates whether the source requires authentication.
        /// </summary>
        public bool RequiresAuth { get; set; }

        /// <summary>
        /// أنواع المكوّنات المدعومة.
        /// Supported component types.
        /// </summary>
        public string[] SupportedComponents { get; set; } = Array.Empty<string>();

        /// <summary>
        /// المعلمات المتاحة للمصدر.
        /// Available source parameters.
        /// </summary>
        public List<DataSourceParameter> Parameters { get; set; } = new();

        /// <summary>
        /// مدة التخزين المؤقت الاختيارية.
        /// Optional cache duration.
        /// </summary>
        public int? CacheDuration { get; set; }
    }

    /// <summary>
    /// DTO يصف معلمة قابلة للإرسال إلى مصدر البيانات.
    /// DTO that describes a parameter accepted by a data source.
    /// </summary>
    public class DataSourceParameter
    {
        /// <summary>
        /// المفتاح البرمجي للمعلمة.
        /// Parameter key.
        /// </summary>
        public string Key { get; set; } = string.Empty;

        /// <summary>
        /// الاسم المقروء للمعلمة.
        /// Human-readable parameter name.
        /// </summary>
        public string Name { get; set; } = string.Empty;

        /// <summary>
        /// نوع بيانات المعلمة.
        /// Parameter data type.
        /// </summary>
        public string Type { get; set; } = string.Empty;

        /// <summary>
        /// القيمة الافتراضية للمعلمة.
        /// Default parameter value.
        /// </summary>
        public string DefaultValue { get; set; } = string.Empty;

        /// <summary>
        /// يحدد ما إذا كانت المعلمة مطلوبة.
        /// Indicates whether the parameter is required.
        /// </summary>
        public bool IsRequired { get; set; }

        /// <summary>
        /// وصف المعلمة.
        /// Parameter description.
        /// </summary>
        public string Description { get; set; } = string.Empty;

        /// <summary>
        /// القيم المسموحة عند وجود قائمة خيارات.
        /// Allowed options when the parameter is selectable.
        /// </summary>
        public string[] Options { get; set; } = Array.Empty<string>();
    }
}
