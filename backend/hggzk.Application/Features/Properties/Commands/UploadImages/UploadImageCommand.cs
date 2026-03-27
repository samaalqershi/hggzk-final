using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Enums;
using System.Collections.Generic;
using YemenBooking.Application.Features.Properties.DTOs;

namespace YemenBooking.Application.Features.Properties.Commands.UploadImages
{
    /// <summary>
    /// طلب رفع الصورة.
    /// Request to upload image.
    /// </summary>
    public class UploadImageCommand : IRequest<ResultDto<ImageDto>>
    {
        /// <summary>
        /// المفتاح المؤقت.
        /// temporary key.
        /// </summary>
        public string? TempKey { get; set; }
        /// <summary>
        /// الملف.
        /// file.
        /// </summary>
        public FileUploadRequest File { get; set; } = null!;
        /// <summary>
        /// الصورة المصغرة للفيديو.
        /// video thumbnail.
        /// </summary>
        public FileUploadRequest? VideoThumbnail { get; set; }
        /// <summary>
        /// الاسم.
        /// name.
        /// </summary>
        public string Name { get; set; } = string.Empty;
        /// <summary>
        /// الامتداد.
        /// file extension.
        /// </summary>
        public string Extension { get; set; } = string.Empty;
        /// <summary>
        /// نوع الصورة.
        /// image type.
        /// </summary>
        public ImageType ImageType { get; set; }
        /// <summary>
        /// تحسين الصورة.
        /// optimize image.
        /// </summary>
        public bool OptimizeImage { get; set; } = false;
        /// <summary>
        /// الجودة.
        /// quality.
        /// </summary>
        public int? Quality { get; set; }
        /// <summary>
        /// إنشاء صورة مصغرة.
        /// generate thumbnail.
        /// </summary>
        public bool GenerateThumbnail { get; set; } = false;
        /// <summary>
        /// الفئة.
        /// category.
        /// </summary>
        public ImageCategory Category { get; set; }
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
        /// النص البديل.
        /// alternative text.
        /// </summary>
        public string? Alt { get; set; }
        /// <summary>
        /// أساسي.
        /// primary.
        /// </summary>
        public bool? IsPrimary { get; set; }
        /// <summary>
        /// الترتيب.
        /// order.
        /// </summary>
        public int? Order { get; set; }
        /// <summary>
        /// الوسوم.
        /// tags.
        /// </summary>
        public List<string>? Tags { get; set; }
        /// <summary>
        /// يحدد ما إذا كانت الصورة بزاوية 360 درجة.
        /// Indicates whether the image is a 360-degree asset.
        /// </summary>
        public bool? Is360 { get; set; }
    }
} 
