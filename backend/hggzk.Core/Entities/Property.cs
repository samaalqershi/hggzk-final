namespace YemenBooking.Core.Entities;

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

/// <summary>
/// يمثل الكيان العقاري الأساسي الذي ترتبط به الوحدات والخدمات والسياسات والحجوزات.
/// Represents the primary property aggregate that links units, services, policies, and bookings.
/// </summary>
[Display(Name = "كيان الكيان")]
public class Property : BaseEntity<Guid>
{
    /// <summary>
    /// معرّف المالك المسؤول عن هذا العقار.
    /// Identifier of the owner responsible for this property.
    /// </summary>
    [Display(Name = "معرف المالك")]
    public Guid OwnerId { get; set; }
    
    /// <summary>
    /// معرّف نوع العقار المستخدم للتصنيف والسلوك الافتراضي.
    /// Identifier of the property type used for classification and default behavior.
    /// </summary>
    [Display(Name = "معرف نوع الكيان")]
    public Guid TypeId { get; set; }
    
    /// <summary>
    /// الاسم المعروض للعقار في الواجهة والقوائم.
    /// Display name of the property in the UI and listings.
    /// </summary>
    [Display(Name = "اسم الكيان")]
    public string Name { get; set; }

    /// <summary>
    /// الاسم الإنجليزي المعروض للعقار.
    /// English display name of the property.
    /// </summary>
    [Display(Name = "اسم الكيان بالإنجليزية")]
    public string? NameEn { get; set; }
    
    /// <summary>
    /// وصف موجز يعرّف العقار بسرعة للمستخدم.
    /// Short summary used to introduce the property to users.
    /// </summary>
    [Display(Name = "وصف قصير للكيان")]
    public string? ShortDescription { get; set; }

    /// <summary>
    /// الوصف المختصر باللغة الإنجليزية.
    /// English short summary for the property.
    /// </summary>
    [Display(Name = "الوصف القصير للكيان بالإنجليزية")]
    public string? ShortDescriptionEn { get; set; }
    
    
    
    /// <summary>
    /// العنوان النصي الكامل للعقار.
    /// Full textual address of the property.
    /// </summary>
    [Display(Name = "عنوان الكيان")]
    public string Address { get; set; }

    /// <summary>
    /// العنوان النصي للعقار باللغة الإنجليزية.
    /// English textual address for the property.
    /// </summary>
    [Display(Name = "عنوان الكيان بالإنجليزية")]
    public string? AddressEn { get; set; }
    
    /// <summary>
    /// المدينة التي يقع فيها العقار.
    /// City where the property is located.
    /// </summary>
    [Display(Name = "المدينة")]
    public string City { get; set; }

    /// <summary>
    /// اسم المدينة باللغة الإنجليزية كما يظهر للمستخدم.
    /// English city label shown to users.
    /// </summary>
    [Display(Name = "المدينة بالإنجليزية")]
    public string? CityEn { get; set; }
    
    /// <summary>
    /// خط العرض الجغرافي لموقع العقار.
    /// Geographic latitude of the property location.
    /// </summary>
    [Display(Name = "خط العرض")]
    public decimal Latitude { get; set; }
    
    /// <summary>
    /// خط الطول الجغرافي لموقع العقار.
    /// Geographic longitude of the property location.
    /// </summary>
    [Display(Name = "خط الطول")]
    public decimal Longitude { get; set; }
    
    /// <summary>
    /// التقييم النجمي المعتمد للعقار.
    /// Official star rating assigned to the property.
    /// </summary>
    [Display(Name = "تصنيف النجوم")]
    public int StarRating { get; set; }
    
    /// <summary>
    /// الوصف التفصيلي للعقار ومميزاته.
    /// Detailed description of the property and its features.
    /// </summary>
    [Display(Name = "وصف الكيان")]
    public string Description { get; set; }

    /// <summary>
    /// الوصف التفصيلي باللغة الإنجليزية.
    /// English detailed description.
    /// </summary>
    [Display(Name = "وصف الكيان بالإنجليزية")]
    public string? DescriptionEn { get; set; }
    
    /// <summary>
    /// يحدد ما إذا كان العقار قد تمت الموافقة عليه للنشر.
    /// Indicates whether the property has been approved for publishing.
    /// </summary>
    [Display(Name = "حالة الموافقة على الكيان")]
    public bool IsApproved { get; set; } = true;
    
    /// <summary>
    /// يحدد ما إذا كانت بيانات العقار مفهرسة في Redis.
    /// Indicates whether this property's data is indexed in Redis.
    /// </summary>
    [Display(Name = "مفهرس في ريديس")]
    public bool IsIndexed { get; set; } = false;
    
    /// <summary>
    /// تاريخ إنشاء سجل العقار.
    /// Creation date of the property record.
    /// </summary>
    [Display(Name = "تاريخ إنشاء الكيان")]
    public DateTime CreatedAt { get; set; }

    /// <summary>
    /// إجمالي عدد مرات مشاهدة العقار.
    /// Total number of property views.
    /// </summary>
    [Display(Name = "عدد مرات المشاهدة")]
    public int ViewCount { get; set; } = 0;

    /// <summary>
    /// إجمالي عدد الحجوزات المرتبطة بالعقار.
    /// Total number of bookings associated with the property.
    /// </summary>
    [Display(Name = "عدد الحجوزات")]
    public int BookingCount { get; set; } = 0;
    
    /// <summary>
    /// متوسط التقييم الناتج عن مراجعات المستخدمين.
    /// Average rating derived from user reviews.
    /// </summary>
    [Display(Name = "متوسط التقييم")]
    public decimal AverageRating { get; set; } = 0m;

    /// <summary>
    /// رمز العملة المستخدم في التسعير والعرض.
    /// Currency code used for pricing and presentation.
    /// </summary>
    [Display(Name = "العملة")]
    public string Currency { get; set; }
    
    /// <summary>
    /// يحدد ما إذا كان العقار معروضًا كعنصر مميز.
    /// Indicates whether the property should be highlighted in listings.
    /// </summary>
    public bool IsFeatured { get; set; } = false;

    /// <summary>
    /// نسبة عمولة المنصة المخصصة لهذا العقار.
    /// Platform commission rate assigned to this property.
    /// </summary>
    [Display(Name = "نسبة عمولة المنصة")]
    public decimal? SystemCommissionRate { get; set; }
    
    /// <summary>
    /// المرجع الملاحي إلى المالك المرتبط بالعقار.
    /// Navigation reference to the owner associated with the property.
    /// </summary>
    [Display(Name = "المالك المرتبط بالكيان")]
    public virtual User Owner { get; set; }
    
    /// <summary>
    /// المرجع الملاحي إلى نوع العقار المرتبط.
    /// Navigation reference to the associated property type.
    /// </summary>
    [Display(Name = "نوع الكيان المرتبط")]
    public virtual PropertyType PropertyType { get; set; }
    
    /// <summary>
    /// المرجع الملاحي إلى كيان المدينة المرتبط بالعقار.
    /// Navigation reference to the city entity associated with the property.
    /// </summary>
    public virtual City? CityRef { get; set; }
    
    /// <summary>
    /// مجموعة الوحدات التابعة لهذا العقار.
    /// Collection of units that belong to this property.
    /// </summary>
    [Display(Name = "الوحدات المرتبطة بالكيان")]
    public virtual ICollection<Unit> Units { get; set; } = new List<Unit>();
    
    /// <summary>
    /// مجموعة الخدمات المتاحة لهذا العقار.
    /// Collection of services available for this property.
    /// </summary>
    [Display(Name = "الخدمات المرتبطة بالكيان")]
    public virtual ICollection<PropertyService> Services { get; set; } = new List<PropertyService>();
    
    /// <summary>
    /// مجموعة السياسات المطبقة على هذا العقار.
    /// Collection of policies applied to this property.
    /// </summary>
    [Display(Name = "السياسات المرتبطة بالكيان")]
    public virtual ICollection<PropertyPolicy> Policies { get; set; } = new List<PropertyPolicy>();
    
    /// <summary>
    /// مجموعة المراجعات الخاصة بالعقار.
    /// Collection of reviews submitted for the property.
    /// </summary>
    [Display(Name = "المراجعات المرتبطة بالكيان")]
    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
    
    /// <summary>
    /// مجموعة الموظفين المرتبطين بالعقار.
    /// Collection of staff members associated with the property.
    /// </summary>
    [Display(Name = "الموظفون المرتبطون بالكيان")]
    public virtual ICollection<Staff> Staff { get; set; } = new List<Staff>();
    
    /// <summary>
    /// مجموعة الصور الخاصة بالعقار.
    /// Collection of images for the property.
    /// </summary>
    [Display(Name = "الصور المرتبطة بالكيان")]
    public virtual ICollection<PropertyImage> Images { get; set; } = new List<PropertyImage>();
    
    /// <summary>
    /// مجموعة المرافق المرتبطة بالعقار.
    /// Collection of amenities associated with the property.
    /// </summary>
    [Display(Name = "الوسائل المرتبطة بالكيان")]
    public virtual ICollection<PropertyAmenity> Amenities { get; set; } = new List<PropertyAmenity>();

    /// <summary>
    /// مجموعة البلاغات المسجلة على العقار.
    /// Collection of reports filed against the property.
    /// </summary>
    [Display(Name = "البلاغات المرتبطة بالكيان")]
    public virtual ICollection<Report> Reports { get; set; } = new List<Report>();

    // Legacy SectionItems removed in favor of rich entities PropertyInSection and UnitInSection

    /// <summary>
    /// السجلات المخصصة لتمثيل العقار داخل الأقسام.
    /// Enriched records used to represent the property within sections.
    /// </summary>
    public virtual ICollection<PropertyInSection> PropertyInSections { get; set; } = new List<PropertyInSection>();

    /// <summary>
    /// السجلات المخصصة لتمثيل وحدات هذا العقار داخل الأقسام.
    /// Enriched records used to represent this property's units within sections.
    /// </summary>
    public virtual ICollection<UnitInSection> UnitInSections { get; set; } = new List<UnitInSection>();

} 
