using System;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties.DTOs;

namespace YemenBooking.Application.Features.Properties.DTOs
{
    /// <summary>
    /// Represents a compact property contract used in lists and summaries.
    /// يمثل عقدًا مختصرًا للعقار يُستخدم في القوائم والملخصات.
    /// </summary>
    public class PropertyDto
    {
        /// <summary>
        /// Gets or sets the property identifier.
        /// يحصل أو يعيّن معرف العقار.
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// Gets or sets the owner identifier.
        /// يحصل أو يعيّن معرف المالك.
        /// </summary>
        public Guid OwnerId { get; set; }

        /// <summary>
        /// Gets or sets the property-type identifier.
        /// يحصل أو يعيّن معرف نوع العقار.
        /// </summary>
        public Guid TypeId { get; set; }

        /// <summary>
        /// Gets or sets the property name.
        /// يحصل أو يعيّن اسم العقار.
        /// </summary>
        public string Name { get; set; }
        public string? NameEn { get; set; }

        /// <summary>
        /// Gets or sets the full address.
        /// يحصل أو يعيّن العنوان الكامل.
        /// </summary>
        public string Address { get; set; }
        public string? AddressEn { get; set; }

        /// <summary>
        /// Gets or sets the city.
        /// يحصل أو يعيّن المدينة.
        /// </summary>
        public string City { get; set; }
        public string? CityEn { get; set; }

        /// <summary>
        /// Gets or sets the latitude.
        /// يحصل أو يعيّن خط العرض.
        /// </summary>
        public decimal Latitude { get; set; }

        /// <summary>
        /// Gets or sets the longitude.
        /// يحصل أو يعيّن خط الطول.
        /// </summary>
        public decimal Longitude { get; set; }

        /// <summary>
        /// Gets or sets the star rating.
        /// يحصل أو يعيّن تقييم النجوم.
        /// </summary>
        public int StarRating { get; set; }

        /// <summary>
        /// Gets or sets the description.
        /// يحصل أو يعيّن الوصف.
        /// </summary>
        public string Description { get; set; }
        public string? DescriptionEn { get; set; }

        /// <summary>
        /// Gets or sets the short description.
        /// يحصل أو يعيّن الوصف المختصر.
        /// </summary>
        public string? ShortDescription { get; set; }
        public string? ShortDescriptionEn { get; set; }

        /// <summary>
        /// Gets or sets whether the property is approved.
        /// يحصل أو يعيّن ما إذا كان العقار معتمدًا.
        /// </summary>
        public bool IsApproved { get; set; }

        /// <summary>
        /// Gets or sets the creation date.
        /// يحصل أو يعيّن تاريخ الإنشاء.
        /// </summary>
        public DateTime CreatedAt { get; set; }

        /// <summary>
        /// Gets or sets the owner name.
        /// يحصل أو يعيّن اسم المالك.
        /// </summary>
        public string OwnerName { get; set; }

        /// <summary>
        /// Gets or sets the property-type name.
        /// يحصل أو يعيّن اسم نوع العقار.
        /// </summary>
        public string TypeName { get; set; }
        public string? TypeNameEn { get; set; }
        /// <summary>
        /// Gets or sets the property images.
        /// يحصل أو يعيّن صور العقار.
        /// </summary>
        public IEnumerable<PropertyImageDto> Images { get; set; } = new List<PropertyImageDto>();

        /// <summary>
        /// Gets or sets the distance from the current location in kilometers.
        /// يحصل أو يعيّن المسافة من الموقع الحالي بالكيلومترات.
        /// </summary>
        public double? DistanceKm { get; set; }

        /// <summary>
        /// Gets or sets the average rating.
        /// يحصل أو يعيّن متوسط التقييم.
        /// </summary>
        public decimal AverageRating { get; set; }

        /// <summary>
        /// Gets or sets the property currency code.
        /// يحصل أو يعيّن رمز عملة العقار.
        /// </summary>
        public string Currency { get; set; } = "YER";

        /// <summary>
        /// Gets or sets whether the property is featured.
        /// يحصل أو يعيّن ما إذا كان العقار مميزًا.
        /// </summary>
        public bool IsFeatured { get; set; }

        /// <summary>
        /// Gets or sets the property-specific commission rate percentage.
        /// يحصل أو يعيّن نسبة العمولة الخاصة بالعقار.
        /// </summary>
        public decimal? SystemCommissionRate { get; set; }
    }
}
 
