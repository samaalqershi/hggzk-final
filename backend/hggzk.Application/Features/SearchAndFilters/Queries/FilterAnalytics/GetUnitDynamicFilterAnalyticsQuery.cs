using System;
using System.Collections.Generic;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Analytics.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.SearchAndFilters.Queries.FilterAnalytics
{
    /// <summary>
    /// استعلام جلب الوحدة الديناميكي تصفية التحليلات.
    /// Get Unit Dynamic Filter Analytics query.
    /// </summary>
    public class GetUnitDynamicFilterAnalyticsQuery : IRequest<ResultDto<List<FieldFilterAnalyticsDto>>>
    {
        /// <summary>
        /// القيمة الخاصة بـ from.
        /// From value.
        /// </summary>
        public DateTime? From { get; set; }

        /// <summary>
        /// القيمة الخاصة بـ to.
        /// To value.
        /// </summary>
        public DateTime? To { get; set; }
    }
} 