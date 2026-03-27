using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Specifications
{
    /// <summary>
    /// معاملات البحث في المستخدمين
    /// User search parameters
    /// </summary>
    public class UserSearchParameters
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
        /// خاصية SortBy.
        /// SortBy property.
        /// </summary>
        public string? SortBy { get; set; }
        /// <summary>
        /// خاصية IsAscending.
        /// IsAscending property.
        /// </summary>
        public bool IsAscending { get; set; } = true;
        /// <summary>
        /// خاصية RoleId.
        /// RoleId property.
        /// </summary>
        public Guid? RoleId { get; set; }
        /// <summary>
        /// خاصية IsActive.
        /// IsActive property.
        /// </summary>
        public bool? IsActive { get; set; }
        /// <summary>
        /// خاصية CreatedAfter.
        /// CreatedAfter property.
        /// </summary>
        public DateTime? CreatedAfter { get; set; }
        /// <summary>
        /// خاصية CreatedBefore.
        /// CreatedBefore property.
        /// </summary>
        public DateTime? CreatedBefore { get; set; }
        /// <summary>
        /// خاصية LastLoginAfter.
        /// LastLoginAfter property.
        /// </summary>
        public DateTime? LastLoginAfter { get; set; }
        /// <summary>
        /// خاصية LoyaltyTier.
        /// LoyaltyTier property.
        /// </summary>
        public string? LoyaltyTier { get; set; }
        /// <summary>
        /// خاصية MinTotalSpent.
        /// MinTotalSpent property.
        /// </summary>
        public decimal? MinTotalSpent { get; set; }
    }

    /// <summary>
    /// مواصفة البحث في المستخدمين
    /// Specification for searching users
    /// </summary>
    public class UserSearchSpecification : BaseSpecification<User>
    {
        /// <summary>
        /// منشئ UserSearchSpecification.
        /// UserSearchSpecification constructor.
        /// </summary>
        public UserSearchSpecification(UserSearchParameters parameters)
            : base()
        {
            // المعايير الأساسية: المستخدمين غير المحذوفين
            AddCriteria(u => !u.IsDeleted);

            // البحث النصي بالاسم أو البريد الإلكتروني
            if (!string.IsNullOrWhiteSpace(parameters.SearchTerm))
            {
                var term = parameters.SearchTerm.Trim().ToLower();
                AddCriteria(u => u.Name.ToLower().Contains(term) || u.Email.ToLower().Contains(term));
            }

            // فلترة بالدور
            if (parameters.RoleId.HasValue)
                AddCriteria(u => u.UserRoles.Any(ur => ur.RoleId == parameters.RoleId.Value));

            // حالة التفعيل
            if (parameters.IsActive.HasValue)
                AddCriteria(u => u.IsActive == parameters.IsActive.Value);

            // فلترة بتاريخ الإنشاء
            if (parameters.CreatedAfter.HasValue)
                AddCriteria(u => u.CreatedAt >= parameters.CreatedAfter.Value);
            if (parameters.CreatedBefore.HasValue)
                AddCriteria(u => u.CreatedAt <= parameters.CreatedBefore.Value);

            // فلترة بآخر تسجيل دخول
            if (parameters.LastLoginAfter.HasValue)
                AddCriteria(u => u.LastLoginDate.HasValue && u.LastLoginDate.Value >= parameters.LastLoginAfter.Value);

            // فئة الولاء
            if (!string.IsNullOrWhiteSpace(parameters.LoyaltyTier))
                AddCriteria(u => u.LoyaltyTier == parameters.LoyaltyTier);

            // الحد الأدنى للإنفاق الكلي
            if (parameters.MinTotalSpent.HasValue)
                AddCriteria(u => u.TotalSpent >= parameters.MinTotalSpent.Value);

            // تضمينات
            AddInclude(u => u.UserRoles);
            AddInclude("UserRoles.Role");

            // الترتيب
            if (!string.IsNullOrWhiteSpace(parameters.SortBy))
            {
                switch (parameters.SortBy.ToLower())
                {
                    case "name":
                        if (parameters.IsAscending) ApplyOrderBy(u => u.Name);
                        else ApplyOrderByDescending(u => u.Name);
                        break;
                    case "email":
                        if (parameters.IsAscending) ApplyOrderBy(u => u.Email);
                        else ApplyOrderByDescending(u => u.Email);
                        break;
                    case "created":
                        if (parameters.IsAscending) ApplyOrderBy(u => u.CreatedAt);
                        else ApplyOrderByDescending(u => u.CreatedAt);
                        break;
                    case "spent":
                        if (parameters.IsAscending) ApplyOrderBy(u => u.TotalSpent);
                        else ApplyOrderByDescending(u => u.TotalSpent);
                        break;
                    case "lastlogin":
                        if (parameters.IsAscending) ApplyOrderBy(u => u.LastLoginDate);
                        else ApplyOrderByDescending(u => u.LastLoginDate);
                        break;
                    default:
                        if (parameters.IsAscending) ApplyOrderBy(u => u.Name);
                        else ApplyOrderByDescending(u => u.Name);
                        break;
                }
            }

            // التصفح
            if (parameters.PageNumber > 0 && parameters.PageSize > 0)
                ApplyPaging(parameters.PageNumber, parameters.PageSize);

            // تحسين الأداء
            ApplyNoTracking();
            ApplySplitQuery();
        }
    }
} 