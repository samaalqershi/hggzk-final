using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Analytics.Queries.PropertyAnalytics
{
    /// <summary>
    /// يجلب مؤشرات أداء العقار ضمن نطاق زمني محدد.
    /// Retrieves property performance metrics for a specific date range.
    /// </summary>
    public class GetPropertyPerformanceQuery : IRequest<ResultDto<PropertyPerformanceDto>>
    {
        /// <summary>
        /// معرف العقار المستهدف.
        /// Target property identifier.
        /// </summary>
        public Guid PropertyId { get; set; }

        /// <summary>
        /// تاريخ البداية.
        /// Start date.
        /// </summary>
        public DateTime StartDate { get; set; }

        /// <summary>
        /// تاريخ النهاية.
        /// End date.
        /// </summary>
        public DateTime EndDate { get; set; }
    }
} 
