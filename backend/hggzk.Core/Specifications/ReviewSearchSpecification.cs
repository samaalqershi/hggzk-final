using System;
using System.Linq;
using System.Linq.Expressions;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Specifications
{
    /// <summary>
    /// معاملات البحث في المراجعات
    /// Review search parameters
    /// </summary>
    public class ReviewSearchParameters
    {
        /// <summary>
        /// خاصية UserId.
        /// UserId property.
        /// </summary>
        public Guid? UserId { get; set; }
        /// <summary>
        /// خاصية PropertyId.
        /// PropertyId property.
        /// </summary>
        public Guid? PropertyId { get; set; }
        /// <summary>
        /// خاصية MinRating.
        /// MinRating property.
        /// </summary>
        public int? MinRating { get; set; }
        /// <summary>
        /// خاصية MaxRating.
        /// MaxRating property.
        /// </summary>
        public int? MaxRating { get; set; }
        /// <summary>
        /// خاصية IsPendingApproval.
        /// IsPendingApproval property.
        /// </summary>
        public bool? IsPendingApproval { get; set; }
        /// <summary>
        /// خاصية HasResponse.
        /// HasResponse property.
        /// </summary>
        public bool? HasResponse { get; set; }
        /// <summary>
        /// خاصية ReviewedAfter.
        /// ReviewedAfter property.
        /// </summary>
        public DateTime? ReviewedAfter { get; set; }
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
    /// مواصفة البحث في المراجعات
    /// Specification for searching reviews
    /// </summary>
    public class ReviewSearchSpecification : BaseSpecification<Review>
    {
        /// <summary>
        /// منشئ ReviewSearchSpecification.
        /// ReviewSearchSpecification constructor.
        /// </summary>
        public ReviewSearchSpecification(ReviewSearchParameters parameters)
            : base()
        {
            AddCriteria(r => true);

            if (parameters.UserId.HasValue)
                AddCriteria(r => r.Booking.UserId == parameters.UserId.Value);

            if (parameters.PropertyId.HasValue)
                AddCriteria(r => r.Property.Id == parameters.PropertyId.Value);

            if (parameters.MinRating.HasValue)
                AddCriteria(r => (r.Cleanliness + r.Service + r.Location + r.Value) / 4.0 >= parameters.MinRating.Value);

            if (parameters.MaxRating.HasValue)
                AddCriteria(r => (r.Cleanliness + r.Service + r.Location + r.Value) / 4.0 <= parameters.MaxRating.Value);

            if (parameters.IsPendingApproval.HasValue)
                AddCriteria(r => r.IsPendingApproval == parameters.IsPendingApproval.Value);

            if (parameters.HasResponse.HasValue)
                AddCriteria(r => (parameters.HasResponse.Value ? r.ResponseText != null : r.ResponseText == null));

            if (parameters.ReviewedAfter.HasValue)
                AddCriteria(r => r.CreatedAt >= parameters.ReviewedAfter.Value);

            if (!string.IsNullOrWhiteSpace(parameters.SortBy))
            {
                // ترتيب حسب معايير محددة
                var sort = parameters.SortBy.Trim().ToLower();
                switch (sort)
                {
                    case "cleanliness": ApplyOrderBy(r => r.Cleanliness); break;
                    case "service": ApplyOrderBy(r => r.Service); break;
                    case "location": ApplyOrderBy(r => r.Location); break;
                    case "value": ApplyOrderBy(r => r.Value); break;
                    case "date": ApplyOrderBy(r => r.CreatedAt); break;
                    default: ApplyOrderBy(r => r.CreatedAt); break;
                }
            }

            if (parameters.PageNumber > 0 && parameters.PageSize > 0)
                ApplyPaging(parameters.PageNumber, parameters.PageSize);

            ApplyNoTracking();
            ApplySplitQuery();
        }
    }
} 