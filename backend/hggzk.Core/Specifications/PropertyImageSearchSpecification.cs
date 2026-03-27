using System;
using System.Linq.Expressions;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Specifications
{
    /// <summary>
    /// معاملات البحث في صور الكيانات والوحدات
    /// Property image search parameters
    /// </summary>
    public class PropertyImageSearchParameters
    {
        /// <summary>
        /// خاصية PropertyId.
        /// PropertyId property.
        /// </summary>
        public Guid? PropertyId { get; set; }
        /// <summary>
        /// خاصية UnitId.
        /// UnitId property.
        /// </summary>
        public Guid? UnitId { get; set; }
    }

    /// <summary>
    /// مواصفة البحث في صور الكيانات والوحدات
    /// Specification for searching property images
    /// </summary>
    public class PropertyImageSearchSpecification : BaseSpecification<PropertyImage>
    {
        /// <summary>
        /// منشئ PropertyImageSearchSpecification.
        /// PropertyImageSearchSpecification constructor.
        /// </summary>
        public PropertyImageSearchSpecification(PropertyImageSearchParameters parameters)
            : base()
        {
            AddCriteria(pi => true);

            if (parameters.PropertyId.HasValue)
                AddCriteria(pi => pi.PropertyId == parameters.PropertyId.Value);

            if (parameters.UnitId.HasValue)
                AddCriteria(pi => pi.UnitId == parameters.UnitId.Value);

            ApplyNoTracking();
            ApplySplitQuery();
        }
    }
} 