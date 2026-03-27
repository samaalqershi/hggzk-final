using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Staffs.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Staffs.Queries.GetStaffByPosition
{
    /// <summary>
    /// استعلام جلب الموظف by position.
    /// Get Staff By Position query.
    /// </summary>
    public class GetStaffByPositionQuery : IRequest<PaginatedResult<StaffDto>>
    {
        /// <summary>
        /// القيمة الخاصة بـ position.
        /// Position value.
        /// </summary>
        public string Position { get; set; }

        /// <summary>
        /// معرّف العقار.
        /// Property identifier.
        /// </summary>
        public Guid? PropertyId { get; set; }

        /// <summary>
        /// رقم الصفحة.
        /// Page number.
        /// </summary>
        public int PageNumber { get; set; } = 1;

        /// <summary>
        /// حجم الصفحة.
        /// Page size.
        /// </summary>
        public int PageSize { get; set; } = 10;
    }
} 