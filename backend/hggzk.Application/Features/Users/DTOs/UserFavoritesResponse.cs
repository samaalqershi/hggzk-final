using System.Collections.Generic;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Amenities.DTOs;
using YemenBooking.Application.Features.Analytics.DTOs;
using YemenBooking.Application.Features.Properties.DTOs;

namespace YemenBooking.Application.Features.Users.DTOs;

/// <summary>
/// استجابة قائمة المفضلات.
/// User favorites response.
/// </summary>
public class UserFavoritesResponse
{
    /// <summary>
    /// قائمة العقارات المفضلة.
    /// Favorite properties list.
    /// </summary>
    public List<FavoritePropertyDto> Favorites { get; set; } = new();
    
    /// <summary>
    /// إجمالي عدد المفضلات.
    /// Total favorites count.
    /// </summary>
    public int TotalCount { get; set; }
}

/// <summary>
/// بيانات العقار المفضل.
/// Expanded favorite property data.
/// </summary>
public class FavoritePropertyDto
{
    /// <summary>
    /// معرف سجل المفضلة.
    /// Favorite record identifier.
    /// </summary>
    public Guid FavoriteId { get; set; }

    /// <summary>
    /// معرف المستخدم.
    /// User identifier.
    /// </summary>
    public Guid UserId { get; set; }

    /// <summary>
    /// معرف العقار.
    /// Property identifier.
    /// </summary>
    public Guid PropertyId { get; set; }
    
    /// <summary>
    /// اسم العقار.
    /// Property name.
    /// </summary>
    public string PropertyName { get; set; } = string.Empty;
    
    /// <summary>
    /// رابط الصورة الرئيسية.
    /// Main image URL.
    /// </summary>
    public string PropertyImage { get; set; } = string.Empty;

    /// <summary>
    /// موقع العقار.
    /// Property location.
    /// </summary>
    public string PropertyLocation { get; set; } = string.Empty;

    /// <summary>
    /// معرف نوع العقار.
    /// Property type identifier.
    /// </summary>
    public Guid TypeId { get; set; }

    /// <summary>
    /// اسم نوع العقار.
    /// Property type name.
    /// </summary>
    public string TypeName { get; set; } = string.Empty;

    /// <summary>
    /// اسم المالك.
    /// Owner name.
    /// </summary>
    public string OwnerName { get; set; } = string.Empty;

    /// <summary>
    /// العنوان.
    /// Address.
    /// </summary>
    public string Address { get; set; } = string.Empty;
    
    /// <summary>
    /// المدينة.
    /// City.
    /// </summary>
    public string City { get; set; } = string.Empty;

    /// <summary>
    /// خط العرض.
    /// Latitude.
    /// </summary>
    public decimal Latitude { get; set; }

    /// <summary>
    /// خط الطول.
    /// Longitude.
    /// </summary>
    public decimal Longitude { get; set; }

    /// <summary>
    /// تصنيف النجوم.
    /// Star rating.
    /// </summary>
    public int StarRating { get; set; }
    
    /// <summary>
    /// متوسط التقييم.
    /// Average rating.
    /// </summary>
    public decimal AverageRating { get; set; }

    /// <summary>
    /// عدد المراجعات.
    /// Reviews count.
    /// </summary>
    public int ReviewsCount { get; set; }

    /// <summary>
    /// أقل سعر.
    /// Minimum price.
    /// </summary>
    public decimal MinPrice { get; set; }

    /// <summary>
    /// العملة.
    /// Currency.
    /// </summary>
    public string Currency { get; set; } = string.Empty;

    /// <summary>
    /// الصور.
    /// Images.
    /// </summary>
    public List<FavoritePropertyImageDto> Images { get; set; } = new();

    /// <summary>
    /// المرافق.
    /// Amenities.
    /// </summary>
    public List<FavoriteAmenityDto> Amenities { get; set; } = new();

    /// <summary>
    /// تاريخ إنشاء سجل المفضلة.
    /// Favorite creation date.
    /// </summary>
    public DateTime CreatedAt { get; set; }
}

/// <summary>
/// صورة لعقار مفضل.
/// Favorite property image.
/// </summary>
public class FavoritePropertyImageDto
{
    /// <summary>
    /// المعرف.
    /// Identifier.
    /// </summary>
    public Guid Id { get; set; }

    /// <summary>
    /// معرف العقار.
    /// Property identifier.
    /// </summary>
    public Guid? PropertyId { get; set; }

    /// <summary>
    /// معرف الوحدة.
    /// Unit identifier.
    /// </summary>
    public Guid? UnitId { get; set; }

    /// <summary>
    /// الاسم.
    /// Name.
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// الرابط.
    /// URL.
    /// </summary>
    public string Url { get; set; } = string.Empty;

    /// <summary>
    /// الحجم بالبايت.
    /// Size in bytes.
    /// </summary>
    public long SizeBytes { get; set; }

    /// <summary>
    /// النوع.
    /// Type.
    /// </summary>
    public string Type { get; set; } = string.Empty;

    /// <summary>
    /// الفئة.
    /// Category.
    /// </summary>
    public string Category { get; set; } = string.Empty;

    /// <summary>
    /// الوصف المختصر.
    /// Caption.
    /// </summary>
    public string Caption { get; set; } = string.Empty;

    /// <summary>
    /// النص البديل.
    /// Alt text.
    /// </summary>
    public string AltText { get; set; } = string.Empty;

    /// <summary>
    /// الوسوم.
    /// Tags.
    /// </summary>
    public string Tags { get; set; } = string.Empty;

    /// <summary>
    /// الأحجام.
    /// Sizes.
    /// </summary>
    public string Sizes { get; set; } = string.Empty;

    /// <summary>
    /// هل هي رئيسية.
    /// Indicates whether this is the main image.
    /// </summary>
    public bool IsMain { get; set; }

    /// <summary>
    /// ترتيب العرض.
    /// Display order.
    /// </summary>
    public int DisplayOrder { get; set; }

    /// <summary>
    /// تاريخ الرفع.
    /// Upload date.
    /// </summary>
    public DateTime UploadedAt { get; set; }

    /// <summary>
    /// الحالة.
    /// Status.
    /// </summary>
    public string Status { get; set; } = string.Empty;

    /// <summary>
    /// نوع الارتباط.
    /// Association type.
    /// </summary>
    public string AssociationType { get; set; } = string.Empty;
}

/// <summary>
/// مرفق لعقار مفضل.
/// Amenity for a favorite property.
/// </summary>
public class FavoriteAmenityDto
{
    /// <summary>
    /// المعرف.
    /// Identifier.
    /// </summary>
    public Guid Id { get; set; }

    /// <summary>
    /// الاسم.
    /// Name.
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// الوصف.
    /// Description.
    /// </summary>
    public string Description { get; set; } = string.Empty;

    /// <summary>
    /// رابط الأيقونة.
    /// Icon URL.
    /// </summary>
    public string IconUrl { get; set; } = string.Empty;

    /// <summary>
    /// الفئة.
    /// Category.
    /// </summary>
    public string Category { get; set; } = string.Empty;

    /// <summary>
    /// هل هو نشط.
    /// Indicates whether it is active.
    /// </summary>
    public bool IsActive { get; set; } = true;

    /// <summary>
    /// ترتيب العرض.
    /// Display order.
    /// </summary>
    public int DisplayOrder { get; set; } = 0;

    /// <summary>
    /// تاريخ الإنشاء.
    /// Creation date.
    /// </summary>
    public DateTime CreatedAt { get; set; }
}
