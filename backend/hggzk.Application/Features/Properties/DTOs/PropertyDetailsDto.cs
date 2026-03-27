using System.Collections.Generic;
using YemenBooking.Application.Features.Units;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Amenities.DTOs;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features.PropertyServices.DTOs;
using YemenBooking.Application.Features.Units.DTOs;

namespace YemenBooking.Application.Features.Properties.DTOs;

/// <summary>
/// Represents the detailed view of a property, including media, policies, and units.
/// يمثل العرض التفصيلي للعقار بما في ذلك الوسائط والسياسات والوحدات.
/// </summary>
public class PropertyDetailsDto
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
    /// Gets or sets the property type.
    /// يحصل أو يعيّن نوع العقار.
    /// </summary>
    public PropertyTypeDto PropertyType { get; set; } = null!;
    
    /// <summary>
    /// Gets or sets the address.
    /// يحصل أو يعيّن العنوان.
    /// </summary>
    public string Address { get; set; } = string.Empty;
    
    /// <summary>
    /// Gets or sets the city.
    /// يحصل أو يعيّن المدينة.
    /// </summary>
    public string City { get; set; } = string.Empty;
    
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
    /// يحصل أو يعيّن تصنيف النجوم.
    /// </summary>
    public int StarRating { get; set; }
    
    /// <summary>
    /// Gets or sets the description.
    /// يحصل أو يعيّن الوصف.
    /// </summary>
    public string Description { get; set; } = string.Empty;

    /// <summary>
    /// Gets or sets the short description.
    /// يحصل أو يعيّن الوصف المختصر.
    /// </summary>
    public string? ShortDescription { get; set; }
    
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
    /// Gets or sets the view count.
    /// يحصل أو يعيّن عدد المشاهدات.
    /// </summary>
    public int ViewCount { get; set; }
    
    /// <summary>
    /// Gets or sets the bookings count.
    /// يحصل أو يعيّن عدد الحجوزات.
    /// </summary>
    public int BookingCount { get; set; }
    
    /// <summary>
    /// Gets or sets whether the property is in favorites.
    /// يحصل أو يعيّن ما إذا كان العقار في المفضلة.
    /// </summary>
    public bool IsFavorite { get; set; }
    
    /// <summary>
    /// Gets or sets the property images.
    /// يحصل أو يعيّن صور العقار.
    /// </summary>
    public List<PropertyImageDto> Images { get; set; } = new();
    
    /// <summary>
    /// Gets or sets the amenities.
    /// يحصل أو يعيّن وسائل الراحة.
    /// </summary>
    public List<PropertyAmenityDto> Amenities { get; set; } = new();
    
    /// <summary>
    /// Gets or sets the services.
    /// يحصل أو يعيّن الخدمات.
    /// </summary>
    public List<PropertyServiceDto> Services { get; set; } = new();
    
    /// <summary>
    /// Gets or sets the property policies.
    /// يحصل أو يعيّن سياسات العقار.
    /// </summary>
    public List<PropertyPolicyDto> Policies { get; set; } = new();
    
    /// <summary>
    /// Gets or sets the available units.
    /// يحصل أو يعيّن الوحدات المتاحة.
    /// </summary>
    public List<UnitDetailsDto> Units { get; set; } = new();

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
    /// Gets or sets whether the property is approved.
    /// يحصل أو يعيّن ما إذا كان العقار معتمدًا.
    /// </summary>
    public bool IsApproved { get; set; }

    /// <summary>
    /// Gets or sets the creation timestamp.
    /// يحصل أو يعيّن وقت الإنشاء.
    /// </summary>
    public DateTime CreatedAt { get; set; }

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
    /// Gets or sets the property-specific platform commission rate percentage.
    /// يحصل أو يعيّن نسبة عمولة المنصة الخاصة بالعقار.
    /// </summary>
    public decimal? SystemCommissionRate { get; set; }

    /// <summary>
    /// Gets or sets the owner name.
    /// يحصل أو يعيّن اسم المالك.
    /// </summary>
    public string OwnerName { get; set; } = string.Empty;

    /// <summary>
    /// Gets or sets the property-type name.
    /// يحصل أو يعيّن اسم نوع العقار.
    /// </summary>
    public string TypeName { get; set; } = string.Empty;

    /// <summary>
    /// Gets or sets the count of units attached to the property.
    /// يحصل أو يعيّن عدد الوحدات المرتبطة بالعقار.
    /// </summary>
    public int UnitsCount { get; set; }

    /// <summary>
    /// Gets or sets the count of services attached to the property.
    /// يحصل أو يعيّن عدد الخدمات المرتبطة بالعقار.
    /// </summary>
    public int ServicesCount { get; set; }

    /// <summary>
    /// Gets or sets the count of amenities attached to the property.
    /// يحصل أو يعيّن عدد وسائل الراحة المرتبطة بالعقار.
    /// </summary>
    public int AmenitiesCount { get; set; }

    /// <summary>
    /// Gets or sets the count of payments attached to the property.
    /// يحصل أو يعيّن عدد المدفوعات المرتبطة بالعقار.
    /// </summary>
    public int PaymentsCount { get; set; }
}





/// <summary>
/// Represents a service attached to a property.
/// يمثل خدمة مرتبطة بعقار.
/// </summary>
public class PropertyServiceDto
{
    /// <summary>
    /// Gets or sets the service identifier.
    /// يحصل أو يعيّن معرف الخدمة.
    /// </summary>
    public Guid Id { get; set; }
    
    /// <summary>
    /// Gets or sets the service name.
    /// يحصل أو يعيّن اسم الخدمة.
    /// </summary>
    public string Name { get; set; } = string.Empty;
    
    /// <summary>
    /// Gets or sets the service price.
    /// يحصل أو يعيّن سعر الخدمة.
    /// </summary>
    public decimal Price { get; set; }
    
    /// <summary>
    /// Gets or sets the currency code.
    /// يحصل أو يعيّن رمز العملة.
    /// </summary>
    public string Currency { get; set; } = string.Empty;
    
    /// <summary>
    /// Gets or sets the pricing model.
    /// يحصل أو يعيّن نموذج التسعير.
    /// </summary>
    public string PricingModel { get; set; } = string.Empty;

    /// <summary>
    /// Gets or sets the optional description.
    /// يحصل أو يعيّن الوصف الاختياري.
    /// </summary>
    public string? Description { get; set; }

    /// <summary>
    /// Gets or sets the optional icon reference.
    /// يحصل أو يعيّن مرجع الأيقونة الاختياري.
    /// </summary>
    public string? Icon { get; set; }
}
