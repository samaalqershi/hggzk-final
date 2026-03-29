using System;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Reviews.DTOs;
using YemenBooking.Core.Indexing.Models;

namespace YemenBooking.Application.Features.SearchAndFilters.DTOs {
    /// <summary>
    /// Represents a single property item returned by the search pipeline.
    /// يمثل عنصر عقار واحدًا معادًا من مسار البحث.
    /// </summary>
    public class PropertySearchResultDto
    {
        /// <summary>
        /// Gets or sets the property identifier.
        /// يحصل أو يعيّن معرف العقار.
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// Gets or sets the property name.
        /// يحصل أو يعيّن اسم العقار.
        /// </summary>
        public string Name { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the English property name.
        /// يحصل أو يعيّن الاسم الإنجليزي للعقار.
        /// </summary>
        public string? NameEn { get; set; }

        /// <summary>
        /// Gets or sets the property description.
        /// يحصل أو يعيّن وصف العقار.
        /// </summary>
        public string Description { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the English property description.
        /// يحصل أو يعيّن الوصف الإنجليزي للعقار.
        /// </summary>
        public string? DescriptionEn { get; set; }

        /// <summary>
        /// Gets or sets the address.
        /// يحصل أو يعيّن العنوان.
        /// </summary>
        public string Address { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the English address.
        /// يحصل أو يعيّن العنوان الإنجليزي.
        /// </summary>
        public string? AddressEn { get; set; }

        /// <summary>
        /// Gets or sets the city.
        /// يحصل أو يعيّن المدينة.
        /// </summary>
        public string City { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the English city.
        /// يحصل أو يعيّن المدينة بالإنجليزية.
        /// </summary>
        public string? CityEn { get; set; }

        /// <summary>
        /// Gets or sets the star rating.
        /// يحصل أو يعيّن تقييم النجوم.
        /// </summary>
        public int StarRating { get; set; }

        /// <summary>
        /// Gets or sets the average rating.
        /// يحصل أو يعيّن متوسط التقييم.
        /// </summary>
        public decimal AverageRating { get; set; }

        /// <summary>
        /// Gets or sets the reviews count.
        /// يحصل أو يعيّن عدد المراجعات.
        /// </summary>
        public int ReviewsCount { get; set; }

        /// <summary>
        /// Gets or sets the minimum available price.
        /// يحصل أو يعيّن أقل سعر متاح.
        /// </summary>
        public decimal MinPrice { get; set; }

        /// <summary>
        /// Gets or sets the discounted price when available.
        /// يحصل أو يعيّن السعر بعد الخصم عند توفره.
        /// </summary>
        public decimal DiscountedPrice { get; set; }

        /// <summary>
        /// Gets or sets the currency code.
        /// يحصل أو يعيّن رمز العملة.
        /// </summary>
        public string Currency { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the primary image URL.
        /// يحصل أو يعيّن رابط الصورة الرئيسية.
        /// </summary>
        public string? MainImageUrl { get; set; }

        /// <summary>
        /// Gets or sets whether the property is recommended.
        /// يحصل أو يعيّن ما إذا كان العقار موصى به.
        /// </summary>
        public bool IsRecommended { get; set; }

        /// <summary>
        /// Gets or sets the distance in kilometers for geographic searches.
        /// يحصل أو يعيّن المسافة بالكيلومتر عند استخدام البحث الجغرافي.
        /// </summary>
        public double? DistanceKm { get; set; }

        /// <summary>
        /// Gets or sets the latitude coordinate.
        /// يحصل أو يعيّن خط العرض.
        /// </summary>
        public decimal Latitude { get; set; }

        /// <summary>
        /// Gets or sets the longitude coordinate.
        /// يحصل أو يعيّن خط الطول.
        /// </summary>
        public decimal Longitude { get; set; }

        /// <summary>
        /// Gets or sets the first unit identifier that matched the applied filters.
        /// يحصل أو يعيّن معرف أول وحدة طابقت الفلاتر المطبقة.
        /// </summary>
        public Guid? UnitId { get; set; }

        /// <summary>
        /// Gets or sets the first matching unit name when availability filtering is applied.
        /// يحصل أو يعيّن اسم أول وحدة مطابقة عند تطبيق فلترة الإتاحة.
        /// </summary>
        public string? UnitName { get; set; }

        /// <summary>
        /// Gets or sets the first matching unit name in English when available.
        /// يحصل أو يعيّن اسم أول وحدة مطابقة بالإنجليزية عند توفره.
        /// </summary>
        public string? UnitNameEn { get; set; }

        /// <summary>
        /// Gets or sets the visible dynamic field values.
        /// يحصل أو يعيّن قيم الحقول الديناميكية القابلة للعرض.
        /// </summary>
        public Dictionary<string, object> DynamicFieldValues { get; set; } = new();

        /// <summary>
        /// Gets or sets whether the property is in the user's favorites.
        /// يحصل أو يعيّن ما إذا كان العقار ضمن المفضلة.
        /// </summary>
        public bool IsFavorite { get; set; }
        /// <summary>
        /// Gets or sets the match percentage against the search criteria.
        /// يحصل أو يعيّن نسبة التطابق مع معايير البحث.
        /// </summary>
        public int MatchPercentage { get; set; }

        /// <summary>
        /// Gets or sets whether the property is available for booking.
        /// يحصل أو يعيّن ما إذا كان العقار متاحًا للحجز.
        /// </summary>
        public bool IsAvailable { get; set; } = true;

        /// <summary>
        /// Gets or sets the number of available units.
        /// يحصل أو يعيّن عدد الوحدات المتاحة.
        /// </summary>
        public int AvailableUnitsCount { get; set; }

        /// <summary>
        /// Gets or sets the property type.
        /// يحصل أو يعيّن نوع العقار.
        /// </summary>
        public string PropertyType { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the English property type.
        /// يحصل أو يعيّن نوع العقار بالإنجليزية.
        /// </summary>
        public string? PropertyTypeEn { get; set; }

        /// <summary>
        /// Gets or sets whether the property is featured.
        /// يحصل أو يعيّن ما إذا كان العقار مميزًا.
        /// </summary>
        public bool IsFeatured { get; set; }

        /// <summary>
        /// Gets or sets the primary amenities.
        /// يحصل أو يعيّن وسائل الراحة الرئيسية.
        /// </summary>
        public List<string> MainAmenities { get; set; } = new();

        /// <summary>
        /// Gets or sets the primary amenities in English when available.
        /// يحصل أو يعيّن وسائل الراحة الرئيسية بالإنجليزية عند توفرها.
        /// </summary>
        public List<string> MainAmenitiesEn { get; set; } = new();

        /// <summary>
        /// Gets or sets the reviews including their responses.
        /// يحصل أو يعيّن المراجعات متضمنة الردود عليها.
        /// </summary>
        public List<ReviewDto> Reviews { get; set; } = new();
        /// <summary>
        /// Gets or sets the maximum capacity.
        /// يحصل أو يعيّن السعة القصوى.
        /// </summary>
        public int MaxCapacity { get; set; }
        /// <summary>
        /// Gets or sets the last updated timestamp.
        /// يحصل أو يعيّن وقت آخر تحديث.
        /// </summary>
        public DateTime LastUpdated { get; set; }
        /// <summary>
        /// Gets or sets the additional image URLs.
        /// يحصل أو يعيّن روابط الصور الإضافية.
        /// </summary>
        public List<string> ImageUrls { get; set; } = new();

        /// <summary>
        /// Gets or sets the mismatches between requested search criteria and the actual property.
        /// يحصل أو يعيّن الفروقات بين معايير البحث المطلوبة والعقار الفعلي.
        /// </summary>
        public List<PropertyFilterMismatch>? FilterMismatches { get; set; }

        /// <summary>
        /// Gets the number of mismatches.
        /// يحصل على عدد الفروقات.
        /// </summary>
        public int MismatchesCount => FilterMismatches?.Count ?? 0;

        /// <summary>
        /// Gets a value indicating whether any mismatches exist.
        /// يحصل على قيمة تشير إلى وجود فروقات من عدمه.
        /// </summary>
        public bool HasMismatches => MismatchesCount > 0;
    }
} 
