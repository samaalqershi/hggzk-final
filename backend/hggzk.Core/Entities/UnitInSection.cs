namespace YemenBooking.Core.Entities;

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using YemenBooking.Core.Enums;

/// <summary>
/// يمثل لقطة بيانات للوحدة داخل القسم مع الحقول الأساسية اللازمة للعرض والفرز والتحليلات.
/// Represents a section-scoped unit snapshot with the core fields needed for display, sorting, and analytics.
/// </summary>
[Display(Name = "وحدة في قسم")]
public class UnitInSection : BaseEntity<Guid>
{
    // المعرفات
    /// <summary>
    /// معرّف القسم المرتبط بهذه الوحدة داخل السياق المعروض.
    /// Identifier of the section this unit belongs to in the current context.
    /// </summary>
    [Display(Name = "معرف القسم")]
    public Guid SectionId { get; set; }

    /// <summary>
    /// معرّف الوحدة الأصلية التي تم تمثيلها داخل هذا القسم.
    /// Identifier of the source unit represented within this section.
    /// </summary>
    [Display(Name = "معرف الوحدة")]
    public Guid UnitId { get; set; }

    /// <summary>
    /// معرّف العقار الذي تتبع له الوحدة.
    /// Identifier of the property that owns the unit.
    /// </summary>
    [Display(Name = "معرف العقار")]
    public Guid PropertyId { get; set; }

    // بيانات الوحدة المخزنة
    /// <summary>
    /// اسم الوحدة كما يظهر للمستخدم في سياق القسم.
    /// Display name of the unit within the section context.
    /// </summary>
    [Display(Name = "اسم الوحدة")]
    public string UnitName { get; set; } = string.Empty;

    /// <summary>
    /// اسم العقار المرتبط بهذه الوحدة.
    /// Display name of the property associated with this unit.
    /// </summary>
    [Display(Name = "اسم العقار")]
    public string PropertyName { get; set; } = string.Empty;

    /// <summary>
    /// معرّف نوع الوحدة لأغراض التصنيف والربط.
    /// Identifier of the unit type used for classification and lookup.
    /// </summary>
    [Display(Name = "نوع الوحدة - المعرف")]
    public Guid UnitTypeId { get; set; }

    /// <summary>
    /// الاسم المعروض لنوع الوحدة.
    /// Display name of the unit type.
    /// </summary>
    [Display(Name = "نوع الوحدة - الاسم")]
    public string UnitTypeName { get; set; } = string.Empty;

    /// <summary>
    /// رمز أو أيقونة نوع الوحدة عند توفرها.
    /// Icon or glyph representing the unit type when available.
    /// </summary>
    [Display(Name = "أيقونة نوع الوحدة")]
    public string? UnitTypeIcon { get; set; }

    /// <summary>
    /// السعة القصوى الإجمالية التي تستوعبها الوحدة.
    /// Maximum total capacity the unit can accommodate.
    /// </summary>
    [Display(Name = "السعة القصوى")]
    public int MaxCapacity { get; set; }

    // ملاحظة: تم حذف BasePrice - نعتمد على DailySchedules من العقار/الوحدة
    
    /// <summary>
    /// رمز العملة المستخدم في التسعير والعرض.
    /// Currency code used for pricing and presentation.
    /// </summary>
    [Display(Name = "العملة")]
    public string Currency { get; set; } = string.Empty;

    /// <summary>
    /// آلية التسعير المعتمدة لهذه الوحدة.
    /// Pricing approach applied to this unit.
    /// </summary>
    [Display(Name = "طريقة التسعير")]
    public PricingMethod PricingMethod { get; set; }

    /// <summary>
    /// السعة المخصصة للبالغين إن كانت محددة.
    /// Adult capacity when explicitly defined.
    /// </summary>
    [Display(Name = "سعة البالغين")]
    public int? AdultsCapacity { get; set; }

    /// <summary>
    /// السعة المخصصة للأطفال إن كانت محددة.
    /// Child capacity when explicitly defined.
    /// </summary>
    [Display(Name = "سعة الأطفال")]
    public int? ChildrenCapacity { get; set; }

    /// <summary>
    /// الصورة الرئيسية المعتمدة لعرض الوحدة.
    /// Primary image used to represent the unit.
    /// </summary>
    [Display(Name = "الصورة الرئيسية")]
    public virtual string? MainImage { get; set; }

    /// <summary>
    /// مجموعة الصور الإضافية المرتبطة بهذه الوحدة ضمن القسم.
    /// Collection of supplementary images associated with this unit in the section.
    /// </summary>
    [Display(Name = "صور إضافية")]
    public virtual ICollection<UnitInSectionImage> AdditionalImages { get; set; } = new List<UnitInSectionImage>();

    // الحقول الديناميكية المهمة للعرض
    /// <summary>
    /// القيم المجمعة للحقول الأساسية بصيغة JSON للاستهلاك السريع في الواجهة.
    /// Aggregated primary field values in JSON for fast UI consumption.
    /// </summary>
    [Display(Name = "قيم الحقول الأساسية (JSON)")]
    public string? PrimaryFieldValues { get; set; }

    // معلومات العقار الأساسية
    /// <summary>
    /// عنوان العقار كما يعرض للمستخدم.
    /// Property address shown to the user.
    /// </summary>
    [Display(Name = "عنوان العقار")]
    public string PropertyAddress { get; set; } = string.Empty;

    /// <summary>
    /// المدينة التي يقع فيها العقار.
    /// City where the property is located.
    /// </summary>
    [Display(Name = "مدينة العقار")]
    public string PropertyCity { get; set; } = string.Empty;

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
    /// تقييم العقار بالنجوم كما هو معتمد في النظام.
    /// Property star rating as maintained by the system.
    /// </summary>
    [Display(Name = "تصنيف نجوم العقار")]
    public int PropertyStarRating { get; set; }

    /// <summary>
    /// متوسط تقييم العقار المجمّع من آراء المستخدمين.
    /// Aggregated average rating for the property from user feedback.
    /// </summary>
    [Display(Name = "متوسط تقييم العقار")]
    public decimal PropertyAverageRating { get; set; }

    // الميزات والمرافق
    /// <summary>
    /// قائمة المرافق الرئيسية بصيغة JSON لسهولة العرض والفلترة.
    /// Core amenities stored as JSON for rendering and filtering.
    /// </summary>
    [Display(Name = "المرافق الرئيسية (JSON)")]
    public string? MainAmenities { get; set; }

    /// <summary>
    /// الميزات المخصصة الخاصة بهذه الوحدة بصيغة JSON.
    /// Custom unit-specific features stored as JSON.
    /// </summary>
    [Display(Name = "ميزات مخصصة (JSON)")]
    public string? CustomFeatures { get; set; }

    // إعدادات العرض
    /// <summary>
    /// ترتيب الظهور داخل القسم مقارنة بالوحدات الأخرى.
    /// Relative display order within the section.
    /// </summary>
    [Display(Name = "ترتيب العرض")]
    public int DisplayOrder { get; set; } = 0;

    /// <summary>
    /// يحدد ما إذا كانت الوحدة مميزة ضمن هذا القسم.
    /// Indicates whether the unit is highlighted in this section.
    /// </summary>
    [Display(Name = "مميز في القسم")]
    public bool IsFeatured { get; set; } = false;

    /// <summary>
    /// نسبة الخصم المطبقة على السعر الأساسي عند توفرها.
    /// Discount percentage applied to the base price when available.
    /// </summary>
    [Display(Name = "نسبة الخصم")]
    public decimal? DiscountPercentage { get; set; }

    /// <summary>
    /// السعر النهائي بعد احتساب الخصم.
    /// Final price after discount is applied.
    /// </summary>
    [Display(Name = "السعر بعد الخصم")]
    public decimal? DiscountedPrice { get; set; }

    /// <summary>
    /// نص ترويجي قصير يظهر مع الوحدة في الواجهة.
    /// Short promotional copy shown alongside the unit.
    /// </summary>
    [Display(Name = "رسالة ترويجية")]
    public string? PromotionalText { get; set; }

    /// <summary>
    /// الشارة التسويقية أو الوصفية المرتبطة بالوحدة.
    /// Marketing or descriptive badge associated with the unit.
    /// </summary>
    [Display(Name = "شارة")]
    public Badge? Badge { get; set; }

    /// <summary>
    /// لون الشارة المستخدم في العرض البصري.
    /// Visual color used for the badge.
    /// </summary>
    [Display(Name = "لون الشارة")]
    public string? BadgeColor { get; set; }

    // ملاحظة: تم حذف IsAvailable - يُحسب من DailySchedules
    
    /// <summary>
    /// تواريخ الإتاحة القادمة المتاحة للعرض السريع.
    /// Upcoming availability dates exposed for quick display.
    /// </summary>
    [Display(Name = "تواريخ التوفر القادمة (JSON)")]
    public string? NextAvailableDates { get; set; }

    /// <summary>
    /// رسالة مختصرة تشرح حالة التوفر الحالية.
    /// Short message describing the current availability state.
    /// </summary>
    [Display(Name = "رسالة التوفر")]
    public string? AvailabilityMessage { get; set; }

    // الفترة الزمنية
    /// <summary>
    /// تاريخ بدء إظهار هذه الوحدة في القوائم أو الحملات.
    /// Date from which the unit should appear in listings or campaigns.
    /// </summary>
    [Display(Name = "عرض من تاريخ")]
    public DateTime? DisplayFrom { get; set; }

    /// <summary>
    /// تاريخ انتهاء عرض هذه الوحدة في القوائم أو الحملات.
    /// Date until which the unit should appear in listings or campaigns.
    /// </summary>
    [Display(Name = "عرض حتى تاريخ")]
    public DateTime? DisplayUntil { get; set; }

    /// <summary>
    /// أولوية العرض عند مقارنة هذه الوحدة بوحدات أخرى.
    /// Display priority when compared with other units.
    /// </summary>
    [Display(Name = "أولوية العرض")]
    public int Priority { get; set; } = 0;

    // إعدادات الحجز
    /// <summary>
    /// يحدد ما إذا كان الإلغاء مسموحًا ضمن هذه السياسة.
    /// Indicates whether cancellation is allowed under this policy.
    /// </summary>
    [Display(Name = "يقبل الإلغاء")]
    public bool AllowsCancellation { get; set; } = true;

    /// <summary>
    /// عدد الأيام المتاحة للإلغاء قبل تاريخ الوصول.
    /// Number of days before arrival during which cancellation remains allowed.
    /// </summary>
    [Display(Name = "أيام نافذة الإلغاء")]
    public int? CancellationWindowDays { get; set; }

    /// <summary>
    /// الحد الأدنى لعدد أيام الإقامة المسموح بها.
    /// Minimum number of stay days allowed.
    /// </summary>
    [Display(Name = "الحد الأدنى للإقامة")]
    public int? MinStayDays { get; set; }

    /// <summary>
    /// الحد الأقصى لعدد أيام الإقامة المسموح بها.
    /// Maximum number of stay days allowed.
    /// </summary>
    [Display(Name = "الحد الأقصى للإقامة")]
    public int? MaxStayDays { get; set; }

    // الإحصائيات
    /// <summary>
    /// إجمالي مرات المشاهدة من داخل القسم.
    /// Total views originating from the section.
    /// </summary>
    [Display(Name = "عدد المشاهدات من القسم")]
    public int ViewsFromSection { get; set; } = 0;

    /// <summary>
    /// إجمالي مرات النقر على بطاقة الوحدة.
    /// Total clicks on the unit card.
    /// </summary>
    [Display(Name = "عدد النقرات")]
    public int ClickCount { get; set; } = 0;

    /// <summary>
    /// معدل التحويل المرتبط بتفاعل المستخدم مع الوحدة.
    /// Conversion rate associated with user interaction on the unit.
    /// </summary>
    [Display(Name = "معدل التحويل")]
    public decimal? ConversionRate { get; set; }

    /// <summary>
    /// عدد الحجوزات الحديثة المرتبطة بهذه الوحدة.
    /// Number of recent bookings associated with this unit.
    /// </summary>
    [Display(Name = "عدد الحجوزات الأخيرة")]
    public int RecentBookingsCount { get; set; } = 0;

    // البيانات الإضافية
    /// <summary>
    /// بيانات وصفية إضافية بصيغة JSON لدعم التكامل أو التخصيص.
    /// Additional metadata stored as JSON for integration or customization.
    /// </summary>
    [Display(Name = "الميتاداتا (JSON)")]
    public string? Metadata { get; set; }

    // العلاقات
    /// <summary>
    /// الكيان المرتبط بالقسم الذي تحتويه هذه اللقطة.
    /// Navigation reference to the section entity that contains this snapshot.
    /// </summary>
    [Display(Name = "القسم")]
    public virtual Section Section { get; set; }

    /// <summary>
    /// الكيان الأصلي للوحدة المرتبطة بهذه اللقطة.
    /// Navigation reference to the original unit entity.
    /// </summary>
    [Display(Name = "الوحدة")]
    public virtual Unit Unit { get; set; }

    /// <summary>
    /// الكيان الأصلي للعقار المرتبط بهذه اللقطة.
    /// Navigation reference to the original property entity.
    /// </summary>
    [Display(Name = "العقار")]
    public virtual Property Property { get; set; }
}
