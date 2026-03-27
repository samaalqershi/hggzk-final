using System;
using System.Collections.Generic;

namespace YemenBooking.Application.Features.SearchAndFilters.DTOs {
    /// <summary>
    /// عنصر في نتائج البحث.
    /// Search result item.
    /// </summary>
    public class PropertySearchItemDto
    {
        /// <summary>
        /// معرف الكيان.
        /// Entity identifier.
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// اسم الكيان.
        /// Entity name.
        /// </summary>
        public string Name { get; set; } = string.Empty;

        /// <summary>
        /// وصف الكيان.
        /// Entity description.
        /// </summary>
        public string? Description { get; set; }

        /// <summary>
        /// المدينة.
        /// City.
        /// </summary>
        public string City { get; set; } = string.Empty;

        /// <summary>
        /// العنوان.
        /// Address.
        /// </summary>
        public string Address { get; set; } = string.Empty;

        /// <summary>
        /// تقييم النجوم.
        /// Star rating.
        /// </summary>
        public int StarRating { get; set; }

        /// <summary>
        /// متوسط التقييم.
        /// Average rating.
        /// </summary>
        public decimal? AverageRating { get; set; }

        /// <summary>
        /// عدد المراجعات.
        /// Review count.
        /// </summary>
        public int ReviewCount { get; set; }

        /// <summary>
        /// الحد الأدنى للسعر.
        /// Minimum price.
        /// </summary>
        public decimal MinPrice { get; set; }

        /// <summary>
        /// عملة السعر.
        /// Price currency.
        /// </summary>
        public string Currency { get; set; } = string.Empty;

        /// <summary>
        /// الصورة الرئيسية.
        /// Main image.
        /// </summary>
        public string? MainImageUrl { get; set; }

        /// <summary>
        /// قائمة الصور.
        /// Image list.
        /// </summary>
        public List<string> ImageUrls { get; set; } = new List<string>();

        /// <summary>
        /// المرافق المتاحة.
        /// Available amenities.
        /// </summary>
        public List<string> Amenities { get; set; } = new List<string>();

        /// <summary>
        /// نوع الكيان.
        /// Entity type.
        /// </summary>
        public string PropertyType { get; set; } = string.Empty;

        /// <summary>
        /// المسافة من نقطة البحث بالكيلومتر.
        /// Distance from the search point in kilometers.
        /// </summary>
        public double? DistanceKm { get; set; }

        /// <summary>
        /// حالة التوفر.
        /// Availability status.
        /// </summary>
        public bool IsAvailable { get; set; }

        /// <summary>
        /// عدد الوحدات المتاحة.
        /// Available units count.
        /// </summary>
        public int AvailableUnitsCount { get; set; }

        /// <summary>
        /// السعة القصوى.
        /// Maximum capacity.
        /// </summary>
        public int MaxCapacity { get; set; }

        /// <summary>
        /// هل هو مميز.
        /// Indicates whether it is featured.
        /// </summary>
        public bool IsFeatured { get; set; }

        /// <summary>
        /// تاريخ آخر تحديث.
        /// Last update date.
        /// </summary>
        public DateTime LastUpdated { get; set; }
    }
} 
