namespace YemenBooking.Core.Entities;

using System;
using System.ComponentModel.DataAnnotations;
using YemenBooking.Core.Enums;

/// <summary>
/// يمثل أصلًا وسائطيًا مخصصًا لبطاقة وحدة منشورة داخل قسم واجهة معيّن.
/// Represents a media asset dedicated to a unit card that is published inside a specific section.
/// </summary>
[Display(Name = "صورة وحدة في قسم")]
public class UnitInSectionImage : BaseEntity<Guid>
{
    /// <summary>
    /// يجمع الملفات المرفوعة مؤقتًا قبل ربطها النهائي بسجل الوحدة داخل القسم.
    /// Groups temporarily uploaded files before they are permanently attached to a unit-in-section record.
    /// </summary>
    [Display(Name = "المفتاح المؤقت")]
    public string? TempKey { get; set; }

    /// <summary>
    /// يربط الصورة بسجل الوحدة المعروض داخل القسم.
    /// Links the image to the projected unit record displayed inside the section.
    /// </summary>
    [Display(Name = "معرف وحدة في قسم")]
    public Guid? UnitInSectionId { get; set; }

    /// <summary>
    /// يوفر الانتقال إلى سجل الوحدة داخل القسم الذي يملك هذه الصورة.
    /// Provides navigation to the unit-in-section record that owns this image.
    /// </summary>
    [Display(Name = "وحدة في قسم")]
    public virtual UnitInSection? UnitInSection { get; set; }

    // Common fields
    /// <summary>
    /// يخزن الاسم المنطقي أو اسم الملف المستخدم لتعريف الأصل الوسائطي.
    /// Stores the logical or file name used to identify the media asset.
    /// </summary>
    [Display(Name = "اسم الصورة")]
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// يحتوي العنوان الذي تُحمّل منه الصورة أو الفيديو في الواجهات المختلفة.
    /// Holds the address from which the image or video is loaded across clients.
    /// </summary>
    [Display(Name = "رابط الصورة")]
    public string Url { get; set; } = string.Empty;

    /// <summary>
    /// يحدد حجم الملف الخام بالبايت لأغراض القياس والتحقق والتحسين.
    /// Captures the raw file size in bytes for validation, optimization, and reporting.
    /// </summary>
    [Display(Name = "الحجم بالبايت")]
    public long SizeBytes { get; set; }

    /// <summary>
    /// يصف نوع الملف أو الامتداد المنطقي للأصل المرفوع.
    /// Describes the file type or logical extension of the uploaded asset.
    /// </summary>
    [Display(Name = "النوع")]
    public string Type { get; set; } = string.Empty;

    /// <summary>
    /// يصنف الصورة بحسب الغرض الوظيفي أو السياق البصري داخل النظام.
    /// Classifies the asset by its functional purpose or visual context in the system.
    /// </summary>
    [Display(Name = "الفئة")]
    public ImageCategory Category { get; set; }

    /// <summary>
    /// يوفر عنوانًا أو شرحًا قصيرًا يُعرض للمستخدم مع الوسيط عند الحاجة.
    /// Provides a short title or caption that can be shown to the user when needed.
    /// </summary>
    [Display(Name = "عنوان")]
    public string Caption { get; set; } = string.Empty;

    /// <summary>
    /// يخزن النص البديل الداعم للوصول وتحسين الفهرسة والوصف النصي.
    /// Stores alternative text for accessibility, indexing, and textual description.
    /// </summary>
    [Display(Name = "بديل")]
    public string AltText { get; set; } = string.Empty;

    /// <summary>
    /// يحتفظ بتمثيل JSON لأحجام أو نسخ مشتقة مثل المصغرات والنسخ المحسنة.
    /// Keeps a JSON representation of derived sizes such as thumbnails and optimized variants.
    /// </summary>
    [Display(Name = "أحجام/مصغرات")]
    public string? Sizes { get; set; }

    /// <summary>
    /// يحدد ما إذا كان هذا الأصل هو الغلاف الرئيسي للوحدة داخل القسم.
    /// Indicates whether this asset acts as the primary cover for the unit inside the section.
    /// </summary>
    [Display(Name = "صورة رئيسية")]
    public bool IsMainImage { get; set; }

    /// <summary>
    /// يحدد ما إذا كان الملف يمثل تجربة عرض 360 درجة.
    /// Indicates whether the asset represents a 360-degree viewing experience.
    /// </summary>
    [Display(Name = "صورة 360 درجة")]
    public bool Is360 { get; set; }

    /// <summary>
    /// يتحكم في ترتيب عرض الوسيط ضمن معرض صور الوحدة داخل القسم.
    /// Controls the render order of the asset within the unit gallery shown in the section.
    /// </summary>
    [Display(Name = "ترتيب")]
    public int DisplayOrder { get; set; }

    /// <summary>
    /// يسجل وقت رفع الأصل الوسائطي أو اعتماده داخل هذا السياق.
    /// Records when the media asset was uploaded or registered in this context.
    /// </summary>
    [Display(Name = "تاريخ الرفع")]
    public DateTime UploadedAt { get; set; }

    /// <summary>
    /// يعكس حالة الأصل مثل المعلق أو النشط أو المحذوف منطقيًا.
    /// Reflects the asset lifecycle state such as pending, active, or soft-deleted.
    /// </summary>
    [Display(Name = "الحالة")]
    public ImageStatus Status { get; set; }

    // Media extras
    /// <summary>
    /// يحدد طبيعة الوسيط مثل صورة أو فيديو لتوجيه تجربة العرض الصحيحة.
    /// Specifies the media nature, such as image or video, to drive the correct presentation flow.
    /// </summary>
    [Display(Name = "نوع الوسائط")]
    public string MediaType { get; set; } = "image";

    /// <summary>
    /// يخزن مدة الفيديو بالثواني عندما يكون الأصل من نوع فيديو.
    /// Stores the video duration in seconds when the asset is video-based.
    /// </summary>
    [Display(Name = "مدة الفيديو")]
    public int? DurationSeconds { get; set; }

    /// <summary>
    /// يشير إلى صورة معاينة بديلة تستخدم لتمثيل الفيديو في القوائم والبطاقات.
    /// Points to a preview thumbnail used to represent the video in cards and listings.
    /// </summary>
    [Display(Name = "مصغّرة الفيديو")]
    public string? VideoThumbnailUrl { get; set; }

    /// <summary>
    /// يحتفظ بوسوم وصفية تساعد على التصنيف والبحث وإدارة الأصول.
    /// Stores descriptive tags that support categorization, search, and asset management.
    /// </summary>
    [Display(Name = "وسوم")]
    public string Tags { get; set; } = string.Empty;
}
