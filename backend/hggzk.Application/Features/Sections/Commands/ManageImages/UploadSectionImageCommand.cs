using System;
using System.Collections.Generic;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Features.Properties.DTOs;

namespace YemenBooking.Application.Features.Sections.Commands.ManageImages
{
    /// <summary>
    /// أمر upload القسم الصورة.
    /// Upload Section Image command.
    /// </summary>
    public class UploadSectionImageCommand : IRequest<ResultDto<ImageDto>>
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
        /// القيمة الخاصة بـ الملف.
        /// File value.
        /// </summary>
        public FileUploadRequest File { get; set; } = null!;
        /// <summary>
        /// القيمة الخاصة بـ video thumbnail.
        /// Video Thumbnail value.
        /// </summary>
        public FileUploadRequest? VideoThumbnail { get; set; }
        /// <summary>
        /// الاسم.
        /// Name.
        /// </summary>
        public string Name { get; set; } = string.Empty;
        /// <summary>
        /// القيمة الخاصة بـ extension.
        /// Extension value.
        /// </summary>
        public string Extension { get; set; } = string.Empty;
        /// <summary>
        /// القيمة الخاصة بـ category.
        /// Category value.
        /// </summary>
        public ImageCategory Category { get; set; } = ImageCategory.Gallery;
        /// <summary>
        /// القيمة الخاصة بـ alt.
        /// Alt value.
        /// </summary>
        public string? Alt { get; set; }
        /// <summary>
        /// يشير إلى ما إذا كان primary.
        /// Indicates whether primary.
        /// </summary>
        public bool? IsPrimary { get; set; }
        /// <summary>
        /// الترتيب.
        /// Order.
        /// </summary>
        public int? Order { get; set; }
        /// <summary>
        /// القيمة الخاصة بـ tags.
        /// Tags value.
        /// </summary>
        public List<string>? Tags { get; set; }
    }
}

