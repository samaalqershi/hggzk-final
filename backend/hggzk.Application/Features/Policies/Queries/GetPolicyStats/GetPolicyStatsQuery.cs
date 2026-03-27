using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Policies.DTOs;
using YemenBooking.Application.Features;
using System;

namespace YemenBooking.Application.Features.Policies.Queries.GetPolicyStats
{
    /// <summary>
    /// يجلب إحصاءات السياسات.
    /// Retrieves policy statistics.
    /// </summary>
    public class GetPolicyStatsQuery : IRequest<ResultDto<PolicyStatsDto>>
    {
        /// <summary>
        /// معرّف العقار.
        /// Property identifier.
        /// </summary>
        public Guid? PropertyId { get; set; }
    }
}
