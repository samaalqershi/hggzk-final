namespace YemenBooking.Core.Entities;

using System;
using System.ComponentModel.DataAnnotations;
using YemenBooking.Core.Enums;

/// <summary>
/// يمثل صورة مرتبطة بسجل "عقار في قسم".
/// Represents an image linked to a PropertyInSection record.
/// </summary>
[Display(Name = "صورة عقار في قسم")]
public class PropertyInSectionImage : BaseEntity<Guid>
{
    /// <summary>
    /// مفتاح مؤقت لتجميع الرفع قبل ربط الصورة بالسجل.
    /// Temporary key used before the image is linked to the record.
    /// </summary>
    [Display(Name = "المفتاح المؤقت")]
    public string? TempKey { get; set; }

    /// <summary>
    /// معرف سجل "عقار في قسم" المرتبط.
    /// Linked PropertyInSection identifier.
    /// </summary>
    [Display(Name = "معرف عقار في قسم")]
    public Guid? PropertyInSectionId { get; set; }

    /// <summary>
    /// سجل "عقار في قسم" المرتبط.
    /// Linked PropertyInSection record.
    /// </summary>
    [Display(Name = "عقار في قسم")]
    public virtual PropertyInSection? PropertyInSection { get; set; }

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
    [Display(Name = "الحجم بالبايت")]
    public long SizeBytes { get; set; }

    /// <summary>
    /// نوع الملف.
    /// File type.
    /// </summary>
    [Display(Name = "النوع")]
    public string Type { get; set; } = string.Empty;

    /// <summary>
    /// فئة الصورة.
    /// Image category.
    /// </summary>
    [Display(Name = "الفئة")]
    public ImageCategory Category { get; set; }

    /// <summary>
    /// النص التوضيحي للصورة.
    /// Image caption.
    /// </summary>
    [Display(Name = "عنوان")]
    public string Caption { get; set; } = string.Empty;

    /// <summary>
    /// النص البديل للصورة.
    /// Alternative text for the image.
    /// </summary>
    [Display(Name = "بديل")]
    public string AltText { get; set; } = string.Empty;

    /// <summary>
    /// أحجام الصورة أو روابطها بصيغة JSON.
    /// Image sizes or URLs in JSON.
    /// </summary>
    [Display(Name = "أحجام/مصغرات")]
    public string? Sizes { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت هذه هي الصورة الرئيسية.
    /// Whether this is the main image.
    /// </summary>
    [Display(Name = "صورة رئيسية")]
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
    [Display(Name = "ترتيب")]
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
    [Display(Name = "الحالة")]
    public ImageStatus Status { get; set; }

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
    [Display(Name = "مدة الفيديو")]
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
