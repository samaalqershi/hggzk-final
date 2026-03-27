using System;
using System.Collections.Generic;

namespace YemenBooking.Application.Common.Models
{
    /// <summary>
    /// توصية التحسين
    /// Validation recommendation
    /// </summary>
    public class ValidationRecommendationDto
    {
        /// <summary>
        /// نوع التوصية
        /// Recommendation type
        /// </summary>
        public RecommendationType Type { get; set; }

        /// <summary>
        /// عنوان التوصية
        /// Recommendation title
        /// </summary>
        public string Title { get; set; } = string.Empty;

        /// <summary>
        /// وصف التوصية
        /// Recommendation description
        /// </summary>
        public string Description { get; set; } = string.Empty;

        /// <summary>
        /// أولوية التوصية
        /// Recommendation priority
        /// </summary>
        public RecommendationPriority Priority { get; set; }

        /// <summary>
        /// الحقول المتأثرة
        /// Affected fields
        /// </summary>
        public List<Guid> AffectedFieldIds { get; set; } = new List<Guid>();

        /// <summary>
        /// الخطوات المقترحة للتنفيذ
        /// Suggested implementation steps
        /// </summary>
        public List<string> ImplementationSteps { get; set; } = new List<string>();
    }
} 
