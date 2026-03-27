using System;
using System.Linq.Expressions;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Specifications
{
    /// <summary>
    /// معاملات البحث في الإشعارات
    /// Notification search parameters
    /// </summary>
    public class NotificationSearchParameters
    {
        /// <summary>
        /// خاصية RecipientId.
        /// RecipientId property.
        /// </summary>
        public Guid? RecipientId { get; set; }
        /// <summary>
        /// خاصية NotificationType.
        /// NotificationType property.
        /// </summary>
        public string? NotificationType { get; set; }
        /// <summary>
        /// خاصية Status.
        /// Status property.
        /// </summary>
        public string? Status { get; set; }
        /// <summary>
        /// خاصية SentAfter.
        /// SentAfter property.
        /// </summary>
        public DateTime? SentAfter { get; set; }
        /// <summary>
        /// خاصية SentBefore.
        /// SentBefore property.
        /// </summary>
        public DateTime? SentBefore { get; set; }
        /// <summary>
        /// خاصية SortBy.
        /// SortBy property.
        /// </summary>
        public string? SortBy { get; set; }
        /// <summary>
        /// خاصية PageNumber.
        /// PageNumber property.
        /// </summary>
        public int PageNumber { get; set; } = 1;
        /// <summary>
        /// خاصية PageSize.
        /// PageSize property.
        /// </summary>
        public int PageSize { get; set; } = 10;
    }

    /// <summary>
    /// مواصفة البحث في الإشعارات
    /// Specification for searching notifications
    /// </summary>
    public class NotificationSearchSpecification : BaseSpecification<Notification>
    {
        /// <summary>
        /// منشئ NotificationSearchSpecification.
        /// NotificationSearchSpecification constructor.
        /// </summary>
        public NotificationSearchSpecification(NotificationSearchParameters parameters)
            : base()
        {
            AddCriteria(n => true);

            if (parameters.RecipientId.HasValue)
                AddCriteria(n => n.RecipientId == parameters.RecipientId.Value);

            if (!string.IsNullOrWhiteSpace(parameters.NotificationType))
            {
                var type = parameters.NotificationType.Trim().ToLower();
                AddCriteria(n => n.Type.ToLower() == type);
            }

            if (!string.IsNullOrWhiteSpace(parameters.Status))
            {
                var st = parameters.Status.Trim().ToLower();
                AddCriteria(n => n.Status.ToLower() == st);
            }

            if (parameters.SentAfter.HasValue)
                AddCriteria(n => n.CreatedAt >= parameters.SentAfter.Value);

            if (parameters.SentBefore.HasValue)
                AddCriteria(n => n.CreatedAt <= parameters.SentBefore.Value);

            // الترتيب حسب المتغير المحدد
            if (!string.IsNullOrWhiteSpace(parameters.SortBy))
            {
                switch (parameters.SortBy.Trim().ToLower())
                {
                    case "sent_date": ApplyOrderBy(n => n.CreatedAt); break;
                    case "status": ApplyOrderBy(n => n.Status); break;
                    case "recipient_name": ApplyOrderBy(n => n.Recipient.Name); break;
                    default: ApplyOrderBy(n => n.CreatedAt); break;
                }
            }

            if (parameters.PageNumber > 0 && parameters.PageSize > 0)
                ApplyPaging(parameters.PageNumber, parameters.PageSize);

            ApplyNoTracking();
            ApplySplitQuery();
        }
    }
} 