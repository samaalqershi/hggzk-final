using MediatR;
using System;
using YemenBooking.Application.Common.Models;
using System.Collections.Generic;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Properties.Queries.SearchImages
{
    /// <summary>
    /// يمثل استعلام بحث صور.
    /// Represents the search query for images.
    /// </summary>
    public class SearchImagesQuery : IRequest<ResultDto<PaginatedResultDto<ImageDto>>>
    {
        /// <summary>
        /// تاريخ البداية.
        /// start date.
        /// </summary>
        public DateTime? DateFrom { get; set; }
        /// <summary>
        /// تاريخ النهاية.
        /// end date.
        /// </summary>
        public DateTime? DateTo { get; set; }
        /// <summary>
        /// الحد الأدنى للحجم.
        /// minimum size.
        /// </summary>
        public long? MinSize { get; set; }
        /// <summary>
        /// الحد الأقصى للحجم.
        /// maximum size.
        /// </summary>
        public long? MaxSize { get; set; }
        /// <summary>
        /// الحد الأدنى لعرض الصورة بالبكسل.
        /// Minimum image width in pixels.
        /// </summary>
        public int? MinWidth { get; set; }
        /// <summary>
        /// الحد الأقصى لعرض الصورة بالبكسل.
        /// Maximum image width in pixels.
        /// </summary>
        public int? MaxWidth { get; set; }
        /// <summary>
        /// الحد الأدنى لارتفاع الصورة بالبكسل.
        /// Minimum image height in pixels.
        /// </summary>
        public int? MinHeight { get; set; }
        /// <summary>
        /// الحد الأقصى لارتفاع الصورة بالبكسل.
        /// Maximum image height in pixels.
        /// </summary>
        public int? MaxHeight { get; set; }
        /// <summary>
        /// أنواع MIME المسموح بتضمينها.
        /// Allowed MIME types.
        /// </summary>
        public List<string>? MimeTypes { get; set; }
        /// <summary>
        /// معرّفات المستخدمين الذين رفعوا الصور.
        /// Identifiers of the users who uploaded the images.
        /// </summary>
        public List<Guid>? UploadedBy { get; set; }
        /// <summary>
        /// الوسوم.
        /// tags.
        /// </summary>
        public List<string>? Tags { get; set; }
        /// <summary>
        /// العناصر الأساسية فقط.
        /// primary items only.
        /// </summary>
        public bool? PrimaryOnly { get; set; }
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
    }
} 
