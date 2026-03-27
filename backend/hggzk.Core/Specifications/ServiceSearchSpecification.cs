using System;
using System.Linq.Expressions;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Specifications
{
    /// <summary>
    /// معاملات البحث في خدمات الكيان
    /// Service search parameters
    /// </summary>
    public class ServiceSearchParameters
    {
        /// <summary>
        /// خاصية ServiceType.
        /// ServiceType property.
        /// </summary>
        public string? ServiceType { get; set; }
        /// <summary>
        /// خاصية PropertyId.
        /// PropertyId property.
        /// </summary>
        public Guid? PropertyId { get; set; }
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
    /// مواصفة البحث في خدمات الكيان
    /// Specification for searching property services
    /// </summary>
    public class ServiceSearchSpecification : BaseSpecification<PropertyService>
    {
        /// <summary>
        /// منشئ ServiceSearchSpecification.
        /// ServiceSearchSpecification constructor.
        /// </summary>
        public ServiceSearchSpecification(ServiceSearchParameters parameters)
            : base()
        {
            AddCriteria(s => true);

            if (!string.IsNullOrWhiteSpace(parameters.ServiceType))
            {
                var term = parameters.ServiceType.Trim().ToLower();
                AddCriteria(s => s.Name.ToLower().Contains(term));
            }

            if (parameters.PropertyId.HasValue)
                AddCriteria(s => s.PropertyId == parameters.PropertyId.Value);

            if (parameters.PageNumber > 0 && parameters.PageSize > 0)
                ApplyPaging(parameters.PageNumber, parameters.PageSize);

            ApplyOrderBy(s => s.Name);
            ApplyNoTracking();
            ApplySplitQuery();
        }
    }
} 