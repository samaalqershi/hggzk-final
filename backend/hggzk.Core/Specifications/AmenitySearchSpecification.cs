using System;
using System.Linq;
using System.Linq.Expressions;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Specifications
{
    /// <summary>
    /// معاملات البحث في المرافق
    /// Amenity search parameters
    /// </summary>
    public class AmenitySearchParameters
    {
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
        /// <summary>
        /// خاصية SearchTerm.
        /// SearchTerm property.
        /// </summary>
        public string? SearchTerm { get; set; }
        /// <summary>
        /// خاصية PropertyTypeId.
        /// PropertyTypeId property.
        /// </summary>
        public Guid? PropertyTypeId { get; set; }
    }

    /// <summary>
    /// مواصفة البحث في المرافق
    /// Specification for searching amenities
    /// </summary>
    public class AmenitySearchSpecification : BaseSpecification<Amenity>
    {
        /// <summary>
        /// منشئ AmenitySearchSpecification.
        /// AmenitySearchSpecification constructor.
        /// </summary>
        public AmenitySearchSpecification(AmenitySearchParameters parameters)
            : base()
        {
            // فلترة المرافق غير المحذوفة
            AddCriteria(a => !a.IsDeleted);

            // البحث النصي بالاسم أو الوصف
            if (!string.IsNullOrWhiteSpace(parameters.SearchTerm))
            {
                var term = parameters.SearchTerm.Trim().ToLower();
                AddCriteria(a => a.Name.ToLower().Contains(term)
                                 || a.Description.ToLower().Contains(term));
            }

            // فلترة حسب نوع الكيان
            if (parameters.PropertyTypeId.HasValue)
                AddCriteria(a => a.PropertyTypeAmenities
                    .Any(pta => pta.PropertyTypeId == parameters.PropertyTypeId.Value));

            // التطبيق التصفح
            if (parameters.PageNumber > 0 && parameters.PageSize > 0)
                ApplyPaging(parameters.PageNumber, parameters.PageSize);

            // ترتيب افتراضي بالاسم
            ApplyOrderBy(a => a.Name);
            ApplyNoTracking();
            ApplySplitQuery();
        }
    }
} 