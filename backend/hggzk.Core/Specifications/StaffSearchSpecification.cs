using System;
using System.Linq.Expressions;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;

namespace YemenBooking.Core.Specifications
{
    /// <summary>
    /// معاملات البحث في بيانات الموظفين
    /// Staff search parameters
    /// </summary>
    public class StaffSearchParameters
    {
        /// <summary>
        /// خاصية Position.
        /// Position property.
        /// </summary>
        public string? Position { get; set; }
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
    /// مواصفة البحث في بيانات الموظفين
    /// Specification for searching staff data
    /// </summary>
    public class StaffSearchSpecification : BaseSpecification<Staff>
    {
        /// <summary>
        /// منشئ StaffSearchSpecification.
        /// StaffSearchSpecification constructor.
        /// </summary>
        public StaffSearchSpecification(StaffSearchParameters parameters)
            : base()
        {
            AddCriteria(st => true);

            if (!string.IsNullOrWhiteSpace(parameters.Position))
            {
                var pos = parameters.Position.Trim().ToLower();
                AddCriteria(st => st.Position.ToString().ToLower() == pos);
            }

            if (parameters.PropertyId.HasValue)
                AddCriteria(st => st.PropertyId == parameters.PropertyId.Value);

            if (parameters.PageNumber > 0 && parameters.PageSize > 0)
                ApplyPaging(parameters.PageNumber, parameters.PageSize);

            ApplyOrderBy(st => st.Position);
            ApplyNoTracking();
            ApplySplitQuery();
        }
    }
} 