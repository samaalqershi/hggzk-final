using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Sections.Queries.GetImages
{
    /// <summary>
    /// استعلام جلب القسم الصور.
    /// Get Section Images query.
    /// </summary>
    public class GetSectionImagesQuery : IRequest<ResultDto<PaginatedResultDto<ImageDto>>>
    {
        /// <summary>
        /// معرّف القسم.
        /// Section identifier.
        /// </summary>
        public Guid? SectionId { get; set; }
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