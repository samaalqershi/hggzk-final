using MediatR;
using System;
using YemenBooking.Application.Common.Models;
using System.Collections.Generic;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Properties.Queries.GetImages
{
    /// <summary>
    /// استعلام للحصول على صور العقارات مع التصفية والصفحات.
    /// Query for retrieving property images with filtering and pagination.
    /// </summary>
    public class GetImagesQuery : IRequest<ResultDto<PaginatedResultDto<ImageDto>>>
    {
        /// <summary>
        /// المفتاح المؤقت.
        /// temporary key.
        /// </summary>
        public string? TempKey { get; set; }

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

        /// <summary>
        /// معرّف القسم.
        /// section identifier.
        /// </summary>
        public Guid? SectionId { get; set; }

        /// <summary>
        /// معرّف العقار داخل القسم.
        /// property-in-section identifier.
        /// </summary>
        public Guid? PropertyInSectionId { get; set; }

        /// <summary>
        /// معرّف الوحدة داخل القسم.
        /// unit-in-section identifier.
        /// </summary>
        public Guid? UnitInSectionId { get; set; }

        /// <summary>
        /// اسم المدينة.
        /// city name.
        /// </summary>
        public string? CityName { get; set; }

        /// <summary>
        /// الفئة.
        /// category.
        /// </summary>
        public ImageCategory? Category { get; set; }

        /// <summary>
        /// الصفحة.
        /// page.
        /// </summary>
        public int? Page { get; set; }

        /// <summary>
        /// الحد.
        /// limit.
        /// </summary>
        public int? Limit { get; set; }

        /// <summary>
        /// الفرز حسب.
        /// sort by.
        /// </summary>
        public string? SortBy { get; set; }

        /// <summary>
        /// ترتيب الفرز.
        /// sort order.
        /// </summary>
        public string? SortOrder { get; set; }

        /// <summary>
        /// البحث.
        /// search.
        /// </summary>
        public string? Search { get; set; }
    }
} 
