using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Staffs.DTOs;
using System;

namespace YemenBooking.Application.Features.Staffs.Queries.GetStaffByProperty
{
    /// <summary>
    /// استعلام جلب الموظف by العقار.
    /// Get Staff By Property query.
    /// </summary>
    public class GetStaffByPropertyQuery : IRequest<PaginatedResult<StaffDto>>
    {
        /// <summary>
        /// معرّف العقار.
        /// Property identifier.
        /// </summary>
        public Guid PropertyId { get; set; }

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