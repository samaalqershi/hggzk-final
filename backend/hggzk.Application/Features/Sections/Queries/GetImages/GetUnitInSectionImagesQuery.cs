using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Sections.Queries.GetImages
{
    /// <summary>
    /// استعلام جلب الوحدة in القسم الصور.
    /// Get Unit In Section Images query.
    /// </summary>
    public class GetUnitInSectionImagesQuery : IRequest<ResultDto<PaginatedResultDto<ImageDto>>>
    {
        /// <summary>
        /// معرّف الوحدة in القسم.
        /// Unit In Section identifier.
        /// </summary>
        public Guid? UnitInSectionId { get; set; }
        /// <summary>
        /// المفتاح المؤقت.
        /// Temporary key.
        /// </summary>
        public string? TempKey { get; set; }
        /// <summary>
        /// معيار الفرز.
        /// Sort by value.
        /// </summary>
        public string? SortBy { get; set; } = "order";
        /// <summary>
        /// ترتيب الفرز.
        /// Sort order.
        /// </summary>
        public string? SortOrder { get; set; } = "asc";
        /// <summary>
        /// القيمة الخاصة بـ الصفحة.
        /// Page value.
        /// </summary>
        public int Page { get; set; } = 1;
        /// <summary>
        /// القيمة الخاصة بـ limit.
        /// Limit value.
        /// </summary>
        public int Limit { get; set; } = 50;
    }
}