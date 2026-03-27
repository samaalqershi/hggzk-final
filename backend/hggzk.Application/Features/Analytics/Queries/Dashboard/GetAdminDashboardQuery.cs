using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Analytics.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Analytics.Queries.Dashboard
{
    /// <summary>
    /// يمثل استعلامًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area query.
    /// </summary>
    public class GetAdminDashboardQuery : IRequest<AdminDashboardDto>
    {
        /// <summary>
        /// النطاق الزمني
        /// Date range for the dashboard data
        /// </summary>
        public DateRangeDto Range { get; set; }

        /// <summary>
        /// يُهيِّئ هذا الاستعلام بالقيم الأساسية المطلوبة.
        /// Initializes this query with the required values.
        /// </summary>
        public GetAdminDashboardQuery(DateRangeDto range)
        {
            Range = range;
        }
    }
} 