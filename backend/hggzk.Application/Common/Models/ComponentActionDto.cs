using System;

namespace YemenBooking.Application.Common.Models
{
    /// <summary>
    /// DTO لتعريف إجراء تفاعلي داخل مكوّن واجهة أو لوحة تحكم.
    /// DTO that describes an interactive action inside a UI or dashboard component.
    /// </summary>
    public class ComponentActionDto
    {
        /// <summary>
        /// المعرف الفريد للإجراء.
        /// Unique identifier of the action.
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// نوع الإجراء.
        /// Action type.
        /// </summary>
        public string ActionType { get; set; } = string.Empty;

        /// <summary>
        /// المشغل الذي يفعّل الإجراء.
        /// Trigger that activates the action.
        /// </summary>
        public string ActionTrigger { get; set; } = string.Empty;

        /// <summary>
        /// الهدف الذي يطبّق عليه الإجراء.
        /// Target affected by the action.
        /// </summary>
        public string ActionTarget { get; set; } = string.Empty;

        /// <summary>
        /// معلمات الإجراء المخزنة نصياً أو كـ JSON.
        /// Action parameters stored as plain text or JSON.
        /// </summary>
        public string ActionParams { get; set; } = string.Empty;

        /// <summary>
        /// شروط تنفيذ الإجراء.
        /// Conditions required for execution.
        /// </summary>
        public string Conditions { get; set; } = string.Empty;

        /// <summary>
        /// يحدد ما إذا كان الإجراء يتطلب مصادقة.
        /// Indicates whether the action requires authentication.
        /// </summary>
        public bool RequiresAuth { get; set; }

        /// <summary>
        /// نوع الحركة المصاحبة للإجراء.
        /// Animation type associated with the action.
        /// </summary>
        public string AnimationType { get; set; } = string.Empty;

        /// <summary>
        /// أولوية التنفيذ عند تزاحم أكثر من إجراء.
        /// Execution priority when multiple actions exist.
        /// </summary>
        public int Priority { get; set; }
    }
}
