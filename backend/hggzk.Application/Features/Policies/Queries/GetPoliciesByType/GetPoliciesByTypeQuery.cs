using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Features.Policies.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Policies.Queries.GetPoliciesByType
{
    /// <summary>
    /// يجلب السياسات بحسب نوعها.
    /// Retrieves policies by type.
    /// </summary>
    public class GetPoliciesByTypeQuery : IRequest<PaginatedResult<PolicyDto>>
    {
        /// <summary>
        /// نوع السياسة.
        /// Policy type.
        /// </summary>
        public PolicyType PolicyType { get; set; }

        /// <summary>
        /// رقم الصفحة المطلوبة.
        /// Requested page number.
        /// </summary>
        public int PageNumber { get; set; } = 1;

        /// <summary>
        /// عدد العناصر في الصفحة.
        /// Number of items per page.
        /// </summary>
        public int PageSize { get; set; } = 10;
    }
} 
