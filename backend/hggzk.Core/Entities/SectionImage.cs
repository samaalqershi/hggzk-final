namespace YemenBooking.Core.Entities;

using System;
using System.ComponentModel.DataAnnotations;
using YemenBooking.Core.Enums;

/// <summary>
/// يمثل صورة مرتبطة بالقسم.
/// Represents an image linked to a section.
/// </summary>
[Display(Name = "صورة قسم")]
public class SectionImage : BaseEntity<Guid>
{
    /// <summary>
    /// مفتاح مؤقت لتجميع الرفع قبل ربط الصورة بالقسم.
    /// Temporary key used before the image is linked to a section.
    /// </summary>
    [Display(Name = "المفتاح المؤقت")]
    public string? TempKey { get; set; }

    /// <summary>
    /// معرف القسم المرتبط.
    /// Linked section identifier.
    /// </summary>
    [Display(Name = "معرف القسم")]
    public Guid? SectionId { get; set; }

    /// <summary>
    /// القسم المرتبط.
    /// Linked section.
    /// </summary>
    [Display(Name = "القسم")]
    public virtual Section? Section { get; set; }

    // Common media fields (mirrors PropertyImage where applicable)
    /// <summary>
    /// اسم الصورة أو الملف.
    /// Image or file name.
    /// </summary>
    [Display(Name = "اسم الصورة")]
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// رابط الصورة.
    /// Image URL.
    /// </summary>
    [Display(Name = "رابط الصورة")]
    public string Url { get; set; } = string.Empty;

    /// <summary>
    /// حجم الصورة بالبايت.
    /// Image size in bytes.
    /// </summary>
    [Display(Name = "حجم الصورة بالبايت")]
    public long SizeBytes { get; set; }

    /// <summary>
    /// نوع الملف.
    /// File type.
    /// </summary>
    [Display(Name = "نوع الصورة")]
    public string Type { get; set; } = string.Empty;

    /// <summary>
    /// فئة الصورة.
    /// Image category.
    /// </summary>
    [Display(Name = "فئة الصورة")]
    public ImageCategory Category { get; set; }

    /// <summary>
    /// النص التوضيحي للصورة.
    /// Image caption.
    /// </summary>
    [Display(Name = "تسمية توضيحية")]
    public string Caption { get; set; } = string.Empty;

    /// <summary>
    /// النص البديل للصورة.
    /// Alternative text for the image.
    /// </summary>
    [Display(Name = "نص بديل")]
    public string AltText { get; set; } = string.Empty;

    /// <summary>
    /// أحجام الصورة أو روابطها بصيغة JSON.
    /// Image sizes or URLs in JSON.
    /// </summary>
    [Display(Name = "أحجام الصورة")]
    public string? Sizes { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت هذه هي الصورة الرئيسية.
    /// Whether this is the main image.
    /// </summary>
    [Display(Name = "هل هي الصورة الرئيسية")]
    public bool IsMainImage { get; set; }

    /// <summary>
    /// يحدد دعم عرض 360 درجة.
    /// Whether the image supports 360 view.
    /// </summary>
    [Display(Name = "صورة 360 درجة")]
    public bool Is360 { get; set; }

    /// <summary>
    /// ترتيب ظهور الصورة.
    /// Display order.
    /// </summary>
    [Display(Name = "ترتيب العرض")]
    public int DisplayOrder { get; set; }

    /// <summary>
    /// وقت رفع الصورة.
    /// Upload timestamp.
    /// </summary>
    [Display(Name = "تاريخ الرفع")]
    public DateTime UploadedAt { get; set; }

    /// <summary>
    /// حالة معالجة الصورة.
    /// Image processing status.
    /// </summary>
    [Display(Name = "حالة المعالجة")]
    public ImageStatus Status { get; set; }

    // Media extras
    /// <summary>
    /// نوع الوسائط المرتبطة.
    /// Media type.
    /// </summary>
    [Display(Name = "نوع الوسائط")]
    public string MediaType { get; set; } = "image";

    /// <summary>
    /// مدة الفيديو بالثواني عند وجوده.
    /// Video duration in seconds when applicable.
    /// </summary>
    [Display(Name = "مدة الفيديو بالثواني")]
    public int? DurationSeconds { get; set; }

    /// <summary>
    /// رابط الصورة المصغرة للفيديو.
    /// Video thumbnail URL.
    /// </summary>
    [Display(Name = "مصغّرة الفيديو")]
    public string? VideoThumbnailUrl { get; set; }

    /// <summary>
    /// وسوم مرتبطة بالصورة.
    /// Tags associated with the image.
    /// </summary>
    [Display(Name = "وسوم")]
    public string Tags { get; set; } = string.Empty;
}
