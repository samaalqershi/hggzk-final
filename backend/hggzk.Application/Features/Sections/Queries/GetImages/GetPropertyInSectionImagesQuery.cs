using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Sections.Queries.GetImages
{
    /// <summary>
    /// استعلام جلب العقار in القسم الصور.
    /// Get Property In Section Images query.
    /// </summary>
    public class GetPropertyInSectionImagesQuery : IRequest<ResultDto<PaginatedResultDto<ImageDto>>>
    {
        /// <summary>
        /// معرّف العقار in القسم.
        /// Property In Section identifier.
        /// </summary>
        public Guid? PropertyInSectionId { get; set; }
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