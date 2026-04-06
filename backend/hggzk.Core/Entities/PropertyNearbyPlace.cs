using System;
using System.ComponentModel.DataAnnotations;

namespace YemenBooking.Core.Entities;

/// <summary>
/// Represents a real nearby place managed for a property and exposed to client apps.
/// يمثل مكانًا قريبًا حقيقيًا يُدار للعقار ويُعرض في تطبيقات العميل.
/// </summary>
[Display(Name = "مكان قريب للعقار")]
public class PropertyNearbyPlace : BaseEntity<Guid>
{
    /// <summary>
    /// Associated property identifier.
    /// معرّف العقار المرتبط.
    /// </summary>
    [Display(Name = "معرف العقار")]
    public Guid PropertyId { get; set; }

    /// <summary>
    /// Place display name in Arabic.
    /// اسم المكان بالعربية.
    /// </summary>
    [Display(Name = "اسم المكان")]
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Place display name in English.
    /// اسم المكان بالإنجليزية.
    /// </summary>
    [Display(Name = "اسم المكان بالإنجليزية")]
    public string? NameEn { get; set; }

    /// <summary>
    /// Optional descriptive text in Arabic.
    /// وصف اختياري بالعربية.
    /// </summary>
    [Display(Name = "الوصف")]
    public string? Description { get; set; }

    /// <summary>
    /// Optional descriptive text in English.
    /// وصف اختياري بالإنجليزية.
    /// </summary>
    [Display(Name = "الوصف بالإنجليزية")]
    public string? DescriptionEn { get; set; }

    /// <summary>
    /// Place category such as restaurant, hospital, mall, or mosque.
    /// تصنيف المكان مثل مطعم أو مستشفى أو سوق أو مسجد.
    /// </summary>
    [Display(Name = "التصنيف")]
    public string Category { get; set; } = string.Empty;

    /// <summary>
    /// Icon key used by the client and portal to render the place.
    /// مفتاح الأيقونة المستخدم في العميل والبورتال.
    /// </summary>
    [Display(Name = "الأيقونة")]
    public string Icon { get; set; } = string.Empty;

    /// <summary>
    /// Geographic latitude of the nearby place when available.
    /// خط العرض للمكان القريب عند توفره.
    /// </summary>
    [Display(Name = "خط العرض")]
    public decimal? Latitude { get; set; }

    /// <summary>
    /// Geographic longitude of the nearby place when available.
    /// خط الطول للمكان القريب عند توفره.
    /// </summary>
    [Display(Name = "خط الطول")]
    public decimal? Longitude { get; set; }

    /// <summary>
    /// Distance from the property in meters.
    /// المسافة عن العقار بالمتر.
    /// </summary>
    [Display(Name = "المسافة بالمتر")]
    public int DistanceInMeters { get; set; }

    /// <summary>
    /// Walking duration in minutes when known.
    /// مدة المشي بالدقائق عند توفرها.
    /// </summary>
    [Display(Name = "مدة المشي بالدقائق")]
    public int? WalkingMinutes { get; set; }

    /// <summary>
    /// Driving duration in minutes when known.
    /// مدة القيادة بالدقائق عند توفرها.
    /// </summary>
    [Display(Name = "مدة القيادة بالدقائق")]
    public int? DrivingMinutes { get; set; }

    /// <summary>
    /// Sort order within the property details page.
    /// ترتيب العرض داخل صفحة تفاصيل العقار.
    /// </summary>
    [Display(Name = "ترتيب العرض")]
    public int DisplayOrder { get; set; }

    /// <summary>
    /// Navigation reference to the owning property.
    /// المرجع الملاحي إلى العقار المالك.
    /// </summary>
    [Display(Name = "العقار المرتبط")]
    public virtual Property Property { get; set; } = null!;
}
