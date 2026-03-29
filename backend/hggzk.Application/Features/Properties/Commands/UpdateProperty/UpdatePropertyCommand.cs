using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Properties.Commands.UpdateProperty;

/// <summary>
/// طلب تحديث العقار.
/// Request to update property.
/// </summary>
public class UpdatePropertyCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف العقار.
    /// Property identifier.
    /// </summary>
    public Guid PropertyId { get; set; }
    /// <summary>
    /// اسم العقار.
    /// Property name.
    /// </summary>
    public string? Name { get; set; }
    /// <summary>
    /// اسم العقار بالإنجليزية.
    /// Property name in English.
    /// </summary>
    public string? NameEn { get; set; }
    /// <summary>
    /// عنوان العقار.
    /// Property address.
    /// </summary>
    public string? Address { get; set; }
    /// <summary>
    /// عنوان العقار بالإنجليزية.
    /// Property address in English.
    /// </summary>
    public string? AddressEn { get; set; }
    /// <summary>
    /// وصف العقار.
    /// Property description.
    /// </summary>
    public string? Description { get; set; }
    /// <summary>
    /// وصف العقار بالإنجليزية.
    /// Property description in English.
    /// </summary>
    public string? DescriptionEn { get; set; }
    /// <summary>
    /// خط العرض لموقع العقار.
    /// Property latitude.
    /// </summary>
    public double? Latitude { get; set; }
    /// <summary>
    /// خط الطول لموقع العقار.
    /// Property longitude.
    /// </summary>
    public double? Longitude { get; set; }
    /// <summary>
    /// اسم المدينة.
    /// City name.
    /// </summary>
    public string? City { get; set; }
    /// <summary>
    /// اسم المدينة بالإنجليزية.
    /// City name in English.
    /// </summary>
    public string? CityEn { get; set; }
    /// <summary>
    /// التقييم بالنجوم.
    /// Star rating.
    /// </summary>
    public int? StarRating { get; set; }

    /// <summary>
    /// مسارات الصور أو مراجعها المرتبطة بالعقار.
    /// Image paths or references associated with the property.
    /// </summary>
    public List<string> Images { get; set; } = new List<string>();
    /// <summary>
    /// وصف قصير موجز للعقار.
    /// Short property description.
    /// </summary>
    public string? ShortDescription { get; set; }
    /// <summary>
    /// وصف قصير موجز للعقار بالإنجليزية.
    /// Short property description in English.
    /// </summary>
    public string? ShortDescriptionEn { get; set; }
    /// <summary>
    /// رمز العملة المستخدم في التسعير.
    /// Currency code used for pricing.
    /// </summary>
    public string? Currency { get; set; }
    /// <summary>
    /// يحدد ما إذا كان العقار مميزًا.
    /// Indicates whether the property is featured.
    /// </summary>
    public bool? IsFeatured { get; set; }
    /// <summary>
    /// معرّف المالك.
    /// Owner identifier.
    /// </summary>
    public Guid? OwnerId { get; set; }
    /// <summary>
    /// معرّفات المزايا المرتبطة بالعقار.
    /// Identifiers of amenities linked to the property.
    /// </summary>
    public List<Guid>? AmenityIds { get; set; }
    /// <summary>
    /// معدل عمولة النظام المطبق على العقار.
    /// System commission rate applied to the property.
    /// </summary>
    public decimal? SystemCommissionRate { get; set; }

}
