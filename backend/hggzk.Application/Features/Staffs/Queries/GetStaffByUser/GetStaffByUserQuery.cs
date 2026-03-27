using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Staffs.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Staffs.Queries.GetStaffByUser
{
    /// <summary>
    /// استعلام جلب الموظف by المستخدم.
    /// Get Staff By User query.
    /// </summary>
    public class GetStaffByUserQuery : IRequest<ResultDto<StaffDto>>
    {
        /// <summary>
        /// معرّف المستخدم.
        /// User identifier.
        /// </summary>
        public Guid UserId { get; set; }
    }
} 