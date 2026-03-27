using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Analytics.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.SearchAndFilters.Queries.SearchAnalytics
{
    /// <summary>
    /// استعلام جلب البحث التحليلات.
    /// Get Search Analytics query.
    /// </summary>
    public class GetSearchAnalyticsQuery : IRequest<ResultDto<SearchAnalyticsDto>>
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