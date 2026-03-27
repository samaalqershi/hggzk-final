using System;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Properties.DTOs
{
    /// <summary>
    /// Represents image metadata for a property, unit, or section.
    /// يمثل بيانات وصفية للصورة الخاصة بعقار أو وحدة أو قسم.
    /// </summary>
    public class PropertyImageDto
    {
        /// <summary>
        /// Gets or sets the image identifier.
        /// يحصل أو يعيّن معرف الصورة.
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// Gets or sets the property identifier when assigned.
        /// يحصل أو يعيّن معرف العقار عند توفره.
        /// </summary>
        public Guid? PropertyId { get; set; }

        /// <summary>
        /// Gets or sets the unit identifier when assigned.
        /// يحصل أو يعيّن معرف الوحدة عند توفره.
        /// </summary>
        public Guid? UnitId { get; set; }

        /// <summary>
        /// Gets or sets the section identifier when assigned.
        /// يحصل أو يعيّن معرف القسم عند توفره.
        /// </summary>
        public Guid? SectionId { get; set; }

        /// <summary>
        /// Gets or sets the property-in-section relation identifier when available.
        /// يحصل أو يعيّن معرف الربط للعقار داخل القسم عند توفره.
        /// </summary>
        public Guid? PropertyInSectionId { get; set; }

        /// <summary>
        /// Gets or sets the unit-in-section relation identifier when available.
        /// يحصل أو يعيّن معرف الربط للوحدة داخل القسم عند توفره.
        /// </summary>
        public Guid? UnitInSectionId { get; set; }

        /// <summary>
        /// Gets or sets the city name when available.
        /// يحصل أو يعيّن اسم المدينة عند توفره.
        /// </summary>
        public string? CityName { get; set; }

        /// <summary>
        /// Gets or sets the file name.
        /// يحصل أو يعيّن اسم الملف.
        /// </summary>
        public string Name { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the image URL.
        /// يحصل أو يعيّن رابط الصورة.
        /// </summary>
        public string Url { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the file size in bytes.
        /// يحصل أو يعيّن حجم الملف بالبايت.
        /// </summary>
        public long SizeBytes { get; set; }

        /// <summary>
        /// Gets or sets the content type.
        /// يحصل أو يعيّن نوع المحتوى.
        /// </summary>
        public string Type { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the image category.
        /// يحصل أو يعيّن فئة الصورة.
        /// </summary>
        public ImageCategory Category { get; set; }

        /// <summary>
        /// Gets or sets the image caption.
        /// يحصل أو يعيّن تعليق الصورة.
        /// </summary>
        public string Caption { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the alternate text.
        /// يحصل أو يعيّن النص البديل.
        /// </summary>
        public string AltText { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the image tags payload.
        /// يحصل أو يعيّن حمولة وسوم الصورة.
        /// </summary>
        public string Tags { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the image size map as JSON.
        /// يحصل أو يعيّن خريطة أحجام الصورة بصيغة JSON.
        /// </summary>
        public string Sizes { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets whether the image is the main image.
        /// يحصل أو يعيّن ما إذا كانت الصورة الرئيسية.
        /// </summary>
        public bool IsMain { get; set; }

        /// <summary>
        /// Gets or sets the display order.
        /// يحصل أو يعيّن ترتيب العرض.
        /// </summary>
        public int DisplayOrder { get; set; }

        /// <summary>
        /// Gets or sets the upload date.
        /// يحصل أو يعيّن تاريخ الرفع.
        /// </summary>
        public DateTime UploadedAt { get; set; }

        /// <summary>
        /// Gets or sets the image status.
        /// يحصل أو يعيّن حالة الصورة.
        /// </summary>
        public ImageStatus Status { get; set; }

        /// <summary>
        /// Gets or sets whether the image is 360 degrees.
        /// يحصل أو يعيّن ما إذا كانت الصورة بزاوية 360 درجة.
        /// </summary>
        public bool Is360 { get; set; }

        /// <summary>
        /// Gets or sets the association type.
        /// يحصل أو يعيّن نوع الارتباط.
        /// </summary>
        public string AssociationType { get; set; } = string.Empty;
    }
}
