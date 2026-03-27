using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Users;
using YemenBooking.Application.Features.Users.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Users.Queries.SearchUsers
{
    /// <summary>
    /// استعلام البحث في المستخدمين.
    /// user search query.
    /// </summary>
    public class SearchUsersQuery : IRequest<PaginatedResult<UserDto>>
    {
        /// <summary>
        /// مصطلح البحث
        /// search term
        /// </summary>
        public string SearchTerm { get; set; }

        /// <summary>
        /// معايير الفلترة
        /// filter criteria
        /// </summary>
        public string? FilterCriteria { get; set; }

        /// <summary>
        /// رقم الصفحة
        /// page number
        /// </summary>
        public int PageNumber { get; set; } = 1;

        /// <summary>
        /// حجم الصفحة
        /// page size
        /// </summary>
        public int PageSize { get; set; } = 10;

        /// <summary>
        /// معرّف الدور
        /// role ID
        /// </summary>
        public Guid? RoleId { get; set; }

        /// <summary>
        /// اسم الدور
        /// role name
        /// </summary>
        public string? RoleName { get; set; }

        /// <summary>
        /// كونه نشطًا
        /// active status
        /// </summary>
        public bool? IsActive { get; set; }

        /// <summary>
        /// تاريخ الإنشاء بعد
        /// created after date
        /// </summary>
        public DateTime? CreatedAfter { get; set; }

        /// <summary>
        /// تاريخ الإنشاء قبل
        /// created before date
        /// </summary>
        public DateTime? CreatedBefore { get; set; }

        /// <summary>
        /// آخر تسجيل دخول بعد
        /// last login after date
        /// </summary>
        public DateTime? LastLoginAfter { get; set; }

        /// <summary>
        /// فئة الولاء
        /// loyalty tier
        /// </summary>
        public string? LoyaltyTier { get; set; }

        /// <summary>
        /// الحد الأدنى للإنفاق الكلي
        /// minimum total spent
        /// </summary>
        public decimal? MinTotalSpent { get; set; }

        /// <summary>
        /// معيار الفرز
        /// sort key
        /// </summary>
        public string? SortBy { get; set; }
    }
} 