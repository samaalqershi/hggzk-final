using System;
using System.Collections.Generic;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Analytics.Queries {
    /// <summary>
    /// يمثل استعلامًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area query.
    /// </summary>
    public class GetTopPerformingPropertiesQuery : IRequest<IEnumerable<YemenBooking.Application.Features.Properties.DTOs.PropertyDto>>
    {
        /// <summary>
        /// عدد الكيانات المطلوب جلبها
        /// Number of top properties to retrieve
        /// </summary>
        public int Count { get; set; }

        /// <summary>
        /// يُهيِّئ هذا الاستعلام بالقيم الأساسية المطلوبة.
        /// Initializes this query with the required values.
        /// </summary>
        public GetTopPerformingPropertiesQuery(int count)
        {
            Count = count;
        }
    }
} 