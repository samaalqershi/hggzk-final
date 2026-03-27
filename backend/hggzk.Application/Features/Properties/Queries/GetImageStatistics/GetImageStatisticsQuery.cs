using MediatR;
using System;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Properties.Queries.GetImageStatistics
{
    /// <summary>
    /// استعلام للحصول على إحصاءات الصور.
    /// Query for retrieving image statistics.
    /// </summary>
    public class GetImageStatisticsQuery : IRequest<ResultDto<ImageStatisticsDto>>
    {
        /// <summary>
        /// معرّف العقار.
        /// property identifier.
        /// </summary>
        public Guid? PropertyId { get; set; }

        /// <summary>
        /// معرّف الوحدة.
        /// unit identifier.
        /// </summary>
        public Guid? UnitId { get; set; }
    }
} 
