using System;
using System.Collections.Generic;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Features.Properties.DTOs;

namespace YemenBooking.Application.Features.Sections.Commands.ManageImages
{
    /// <summary>
    /// أمر upload الوحدة in القسم الصورة.
    /// Upload Unit In Section Image command.
    /// </summary>
    public class UploadUnitInSectionImageCommand : IRequest<ResultDto<ImageDto>>
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
        /// <summary>
        /// يشير إلى ما إذا كان 360.
        /// Indicates whether 360.
        /// </summary>
        public bool? Is360 { get; set; }
    }
}

