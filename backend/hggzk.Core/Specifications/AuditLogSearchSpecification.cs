using System;
using System.Linq.Expressions;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Specifications
{
    /// <summary>
    /// معاملات البحث في سجلات التدقيق
    /// Audit log search parameters
    /// </summary>
    public class AuditLogSearchParameters
    {
        /// <summary>
        /// خاصية UserId.
        /// UserId property.
        /// </summary>
        public Guid? UserId { get; set; }
        /// <summary>
        /// خاصية From.
        /// From property.
        /// </summary>
        public DateTime? From { get; set; }
        /// <summary>
        /// خاصية To.
        /// To property.
        /// </summary>
        public DateTime? To { get; set; }
        /// <summary>
        /// خاصية SearchTerm.
        /// SearchTerm property.
        /// </summary>
        public string? SearchTerm { get; set; }
        /// <summary>
        /// خاصية OperationType.
        /// OperationType property.
        /// </summary>
        public string? OperationType { get; set; }
    }

    /// <summary>
    /// مواصفة البحث في سجلات التدقيق
    /// Specification for searching audit logs
    /// </summary>
    public class AuditLogSearchSpecification : BaseSpecification<AuditLog>
    {
        /// <summary>
        /// منشئ AuditLogSearchSpecification.
        /// AuditLogSearchSpecification constructor.
        /// </summary>
        public AuditLogSearchSpecification(AuditLogSearchParameters parameters)
            : base()
        {
            // يمكن إضافة فلاتر متعددة حسب المعلمات
            AddCriteria(al => true);

            if (parameters.UserId.HasValue)
                AddCriteria(al => al.PerformedBy == parameters.UserId.Value);

            if (parameters.From.HasValue)
                AddCriteria(al => al.CreatedAt >= parameters.From.Value);

            if (parameters.To.HasValue)
                AddCriteria(al => al.CreatedAt <= parameters.To.Value);

            if (!string.IsNullOrWhiteSpace(parameters.SearchTerm))
            {
                var term = parameters.SearchTerm.Trim().ToLower();
                AddCriteria(al => (al.EntityType != null && al.EntityType.ToLower().Contains(term))
                                 || (al.OldValues != null && al.OldValues.ToLower().Contains(term))
                                 || (al.NewValues != null && al.NewValues.ToLower().Contains(term))
                                 || (al.Notes != null && al.Notes.ToLower().Contains(term)));
            }

            if (!string.IsNullOrWhiteSpace(parameters.OperationType))
            {
                var op = parameters.OperationType.Trim().ToLower();
                AddCriteria(al => al.Action.ToString().ToLower() == op);
            }

            ApplyNoTracking();
            ApplySplitQuery();
        }
    }
} 