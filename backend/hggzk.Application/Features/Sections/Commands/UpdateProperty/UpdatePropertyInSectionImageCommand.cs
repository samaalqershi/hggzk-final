using System;
using System.Collections.Generic;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Features.Properties.DTOs;

namespace YemenBooking.Application.Features.Sections.Commands.UpdateProperty
{
    /// <summary>
    /// أمر تحديث العقار in القسم الصورة.
    /// Update Property In Section Image command.
    /// </summary>
    public class UpdatePropertyInSectionImageCommand : IRequest<ResultDto<ImageDto>>
    {
        /// <summary>
        /// معرّف الصورة.
        /// Image identifier.
        /// </summary>
        public Guid ImageId { get; set; }
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
        /// القيمة الخاصة بـ category.
        /// Category value.
        /// </summary>
        public ImageCategory? Category { get; set; }
    }
}

