using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Reports.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Analytics.Queries.FinancialAnalytics
{
    /// <summary>
    /// يمثل استعلامًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area query.
    /// </summary>
    public class GetRevenueReportQuery : IRequest<ResultDto<RevenueReportDto>>
    {
        /// <summary>
        /// تاريخ البداية
        /// </summary>
        public DateTime StartDate { get; set; }

        /// <summary>
        /// تاريخ النهاية
        /// </summary>
        public DateTime EndDate { get; set; }

        /// <summary>
        /// معرف الكيان (اختياري)
        /// </summary>
        public Guid? PropertyId { get; set; }
    }
} 