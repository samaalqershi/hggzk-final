using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Properties.Commands.CreateProperty;

/// <summary>
/// طلب إنشاء العقار.
/// Request to create property.
/// </summary>
public class CreatePropertyCommand : IRequest<ResultDto<Guid>>
{
    /// <summary>
    /// المفتاح المؤقت المستخدم لربط الملفات قبل الحفظ.
    /// Temporary key used to associate files before persistence.
    /// </summary>
    public string? TempKey { get; set; }
    /// <summary>
    /// اسم العقار.
    /// Property name.
    /// </summary>
    public string Name { get; set; } = string.Empty;
    /// <summary>
    /// عنوان العقار.
    /// Property address.
    /// </summary>
    public string Address { get; set; } = string.Empty;
    /// <summary>
    /// معرّف نوع العقار.
    /// Property type identifier.
    /// </summary>
    public Guid PropertyTypeId { get; set; }
    /// <summary>
    /// معرّف المالك.
    /// Owner identifier.
    /// </summary>
    public Guid OwnerId { get; set; }
    /// <summary>
    /// وصف العقار.
    /// Property description.
    /// </summary>
    public string Description { get; set; } = string.Empty;
    /// <summary>
    /// خط العرض لموقع العقار.
    /// Property latitude.
    /// </summary>
    public double Latitude { get; set; }
    /// <summary>
    /// خط الطول لموقع العقار.
    /// Property longitude.
    /// </summary>
    public double Longitude { get; set; }
    /// <summary>
    /// اسم المدينة.
    /// City name.
    /// </summary>
    public string City { get; set; }
    /// <summary>
    /// التقييم بالنجوم.
    /// Star rating.
    /// </summary>
    public int StarRating { get; set; }

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
    /// معدل عمولة النظام المطبق على العقار.
    /// System commission rate applied to the property.
    /// </summary>
    public decimal? SystemCommissionRate { get; set; }
}
