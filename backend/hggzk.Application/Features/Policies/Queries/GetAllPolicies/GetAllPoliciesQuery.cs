using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Features.Policies.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Policies.Queries.GetAllPolicies
{
    /// <summary>
    /// يجلب السياسات مع التصفح والتصفية.
    /// Retrieves policies with paging and filtering.
    /// </summary>
    public class GetAllPoliciesQuery : IRequest<PaginatedResult<PolicyDto>>
    {
        /// <summary>
        /// رقم الصفحة المطلوبة.
        /// Requested page number.
        /// </summary>
        public int PageNumber { get; set; } = 1;

        /// <summary>
        /// عدد العناصر في الصفحة.
        /// Number of items per page.
        /// </summary>
        public int PageSize { get; set; } = 20;

        /// <summary>
        /// عبارة البحث.
        /// Search term.
        /// </summary>
        public string? SearchTerm { get; set; }

        /// <summary>
        /// معرّف العقار.
        /// Property identifier.
        /// </summary>
        public Guid? PropertyId { get; set; }

        /// <summary>
        /// نوع السياسة.
        /// Policy type.
        /// </summary>
        public PolicyType? PolicyType { get; set; }
    }
}
