namespace YemenBooking.Core.Entities;

using System;
using System.ComponentModel.DataAnnotations;
using YemenBooking.Core.Enums;
using System.Collections.Generic;

/// <summary>
/// يمثل لقطة عرضية لعقار تم نشره داخل قسم واجهة معيّن مع بيانات منزوعة التطبيع لتحسين القراءة.
/// Represents a denormalized storefront snapshot of a property that is published inside a specific UI section.
/// </summary>
[Display(Name = "عقار في قسم")]
public class PropertyInSection : BaseEntity<Guid>
{
    // المعرفات
    /// <summary>
    /// يحدد القسم الذي يعرض هذا السجل ضمنه.
    /// Identifies the section that hosts this projected property record.
    /// </summary>
    [Display(Name = "معرف القسم")]
    public Guid SectionId { get; set; }

    /// <summary>
    /// يربط السجل بالعقار الأصلي الذي تم اشتقاق بيانات العرض منه.
    /// Links the record to the source property from which the display data was derived.
    /// </summary>
    [Display(Name = "معرف العقار")]
    public Guid PropertyId { get; set; }

    // بيانات العقار المخزنة
    /// <summary>
    /// يخزن اسم العقار كما سيظهر مباشرة داخل القسم دون الحاجة لقراءة الكيان الأصلي.
    /// Stores the property name exactly as it should appear inside the section without loading the source entity.
    /// </summary>
    [Display(Name = "اسم العقار")]
    public string PropertyName { get; set; } = string.Empty;

    /// <summary>
    /// يحتفظ بعنوان العقار المخصص للعرض والبحث السريع داخل واجهات الأقسام.
    /// Keeps the display-ready property address for quick rendering and filtering inside section views.
    /// </summary>
    [Display(Name = "العنوان")]
    public string Address { get; set; } = string.Empty;

    /// <summary>
    /// يحدد المدينة المرتبطة بالعقار كما تُعرض للمستخدم في هذا السياق.
    /// Specifies the property city as presented to the user in this section context.
    /// </summary>
    [Display(Name = "المدينة")]
    public string City { get; set; } = string.Empty;

    /// <summary>
    /// يمثل خط العرض المستخدم في الخرائط والترتيب الجغرافي داخل القسم.
    /// Represents the latitude used for maps and geo-based ordering within the section.
    /// </summary>
    [Display(Name = "خط العرض")]
    public decimal Latitude { get; set; }

    /// <summary>
    /// يمثل خط الطول المستخدم في الخرائط والترتيب الجغرافي داخل القسم.
    /// Represents the longitude used for maps and geo-based ordering within the section.
    /// </summary>
    [Display(Name = "خط الطول")]
    public decimal Longitude { get; set; }

    /// <summary>
    /// يخزن الاسم المقروء لنوع العقار لتقليل الحاجة إلى joins وقت العرض.
    /// Stores the human-readable property type name to reduce join-heavy lookups during presentation.
    /// </summary>
    [Display(Name = "نوع العقار")]
    public string PropertyType { get; set; } = string.Empty;

    /// <summary>
    /// يعكس التصنيف النجمي المعروض للعقار داخل القوائم والبطاقات.
    /// Reflects the star rating shown for the property in cards and list views.
    /// </summary>
    [Display(Name = "تصنيف النجوم")]
    public int StarRating { get; set; }

    /// <summary>
    /// يلتقط متوسط تقييم المستخدمين الحالي لإثراء البطاقة التسويقية.
    /// Captures the current average user rating to enrich the promotional card.
    /// </summary>
    [Display(Name = "متوسط التقييم")]
    public decimal AverageRating { get; set; }

    /// <summary>
    /// يوضح عدد المراجعات المستخدمة لدعم الثقة والسياق الإحصائي.
    /// Indicates the review count used to provide trust and rating context.
    /// </summary>
    [Display(Name = "عدد التقييمات")]
    public int ReviewsCount { get; set; }

    /// <summary>
    /// يخزن السعر المرجعي الأدنى أو الأساسي المستخدم عند بناء بطاقة القسم.
    /// Stores the baseline price used when composing the section card.
    /// </summary>
    [Display(Name = "السعر الأساسي")]
    public decimal BasePrice { get; set; }

    /// <summary>
    /// تحدد العملة التي يجب عرض السعر بها داخل هذا السياق.
    /// Defines the currency in which the projected price should be displayed.
    /// </summary>
    [Display(Name = "العملة")]
    public string Currency { get; set; } = string.Empty;

    /// <summary>
    /// يحتوي رابط الصورة الرئيسية المستخدمة كغلاف مختصر للعنصر داخل القسم.
    /// Holds the main image URL used as the concise cover asset for the item inside the section.
    /// </summary>
    [Display(Name = "الصورة الرئيسية")]
    public virtual string? MainImage { get; set; }

    /// <summary>
    /// يجمع الصور الإضافية المرتبطة بهذه النسخة العرضية للعقار داخل القسم.
    /// Collects the extra images attached specifically to this section-level property projection.
    /// </summary>
    [Display(Name = "صور إضافية")]
    public virtual ICollection<PropertyInSectionImage> AdditionalImages { get; set; } = new List<PropertyInSectionImage>();

    /// <summary>
    /// يوفر وصفًا مختصرًا ومهيأً للبطاقات السريعة ومساحات العرض المحدودة.
    /// Provides a concise description tailored for cards and other compact display surfaces.
    /// </summary>
    [Display(Name = "الوصف المختصر")]
    public string? ShortDescription { get; set; }

    // إعدادات العرض
    /// <summary>
    /// يحدد ترتيب ظهور العنصر بين بقية عناصر القسم.
    /// Controls the relative ordering of the item among other section entries.
    /// </summary>
    [Display(Name = "ترتيب العرض")]
    public int DisplayOrder { get; set; } = 0;

    /// <summary>
    /// يحدد ما إذا كان ينبغي إبراز هذا العقار بصريًا داخل القسم.
    /// Indicates whether this property should receive featured treatment within the section.
    /// </summary>
    [Display(Name = "مميز في القسم")]
    public bool IsFeatured { get; set; } = false;

    /// <summary>
    /// يخزن نسبة الخصم المعروضة للمستخدم عند وجود عرض ترويجي نشط.
    /// Stores the displayed discount percentage when an active promotion exists.
    /// </summary>
    [Display(Name = "نسبة الخصم")]
    public decimal? DiscountPercentage { get; set; }

    /// <summary>
    /// يحمل رسالة تسويقية قصيرة مرتبطة بهذا الظهور داخل القسم.
    /// Carries a short promotional message associated with this section placement.
    /// </summary>
    [Display(Name = "رسالة ترويجية")]
    public string? PromotionalText { get; set; }

    /// <summary>
    /// يحدد الشارة الدلالية التي تميز العنصر مثل جديد أو الأكثر حجزًا.
    /// Defines the semantic badge that highlights the item, such as new or most booked.
    /// </summary>
    [Display(Name = "شارة")]
    public Badge? Badge { get; set; }

    /// <summary>
    /// يخصص اللون المرئي المستخدم لعرض الشارة في الواجهة.
    /// Customizes the visual color used when rendering the badge in the UI.
    /// </summary>
    [Display(Name = "لون الشارة")]
    public string? BadgeColor { get; set; }

    // الفترة الزمنية
    /// <summary>
    /// يحدد بداية الفترة الزمنية التي يسمح فيها بإظهار هذا العنصر داخل القسم.
    /// Marks the start of the display window during which this item can appear in the section.
    /// </summary>
    [Display(Name = "عرض من تاريخ")]
    public DateTime? DisplayFrom { get; set; }

    /// <summary>
    /// يحدد نهاية الفترة الزمنية التي يتوقف بعدها ظهور هذا العنصر داخل القسم.
    /// Marks the end of the display window after which the item should stop appearing in the section.
    /// </summary>
    [Display(Name = "عرض حتى تاريخ")]
    public DateTime? DisplayUntil { get; set; }

    /// <summary>
    /// يضيف مستوى أولوية إضافيًا فوق الترتيب العادي عند بناء القوائم النهائية.
    /// Adds an extra priority signal on top of normal ordering when composing the final lists.
    /// </summary>
    [Display(Name = "أولوية العرض")]
    public int Priority { get; set; } = 0;

    // الإحصائيات
    /// <summary>
    /// يتتبع عدد مرات مشاهدة هذا العنصر من خلال القسم الذي يحتويه.
    /// Tracks how many views this item accumulated through the section that contains it.
    /// </summary>
    [Display(Name = "عدد المشاهدات من القسم")]
    public int ViewsFromSection { get; set; } = 0;

    /// <summary>
    /// يسجل عدد نقرات المستخدمين على هذا الإدراج داخل القسم.
    /// Records how many user clicks this listing received inside the section.
    /// </summary>
    [Display(Name = "عدد النقرات")]
    public int ClickCount { get; set; } = 0;

    /// <summary>
    /// يحتفظ بمعدل التحويل المحسوب من الظهور إلى التفاعل أو الحجز بحسب منطق التحليلات.
    /// Stores the conversion rate derived from impressions to engagement or bookings, depending on analytics rules.
    /// </summary>
    [Display(Name = "معدل التحويل")]
    public decimal? ConversionRate { get; set; }

    // البيانات الإضافية
    /// <summary>
    /// يوفر مساحة مرنة لبيانات إضافية خاصة بالعرض أو التجارب التسويقية بصيغة JSON.
    /// Provides a flexible JSON container for extra display or campaign-specific metadata.
    /// </summary>
    [Display(Name = "الميتاداتا (JSON)")]
    public string? Metadata { get; set; }

    // العلاقات
    /// <summary>
    /// يشير إلى القسم الأب الذي يضم هذا السجل العرضي.
    /// References the parent section that owns this projected record.
    /// </summary>
    [Display(Name = "القسم")]
    public virtual Section Section { get; set; }

    /// <summary>
    /// يشير إلى الكيان الأصلي للعقار الذي تم أخذ هذه البيانات المهيأة منه.
    /// References the original property entity from which this prepared projection was taken.
    /// </summary>
    [Display(Name = "العقار")]
    public virtual Property Property { get; set; }
}
