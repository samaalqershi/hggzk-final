namespace YemenBooking.Core.Entities;

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using YemenBooking.Core.Enums;

/// <summary>
/// يمثل صورة مرفقة بتقييم المستخدم.
/// Represents an image attached to a user review.
/// </summary>
[Display(Name = "كيان صورة التقييم")]
public class ReviewImage : BaseEntity<Guid>
{
    /// <summary>
    /// معرّف التقييم الذي ترتبط به هذه الصورة.
    /// Identifies the review this image belongs to.
    /// </summary>
    [Display(Name = "معرف التقييم المرتبط")]
    public Guid ReviewId { get; set; }

    /// <summary>
    /// الاسم الأصلي للملف كما تم رفعه أو تخزينه.
    /// Stores the original file name used at upload or persistence time.
    /// </summary>
    [Display(Name = "اسم الملف")]
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// الرابط أو المسار الذي يتيح الوصول إلى الصورة.
    /// The URL or path used to access the image.
    /// </summary>
    [Display(Name = "مسار الصورة")]
    public string Url { get; set; } = string.Empty;

    /// <summary>
    /// حجم الصورة بالبايت.
    /// The image size in bytes.
    /// </summary>
    [Display(Name = "حجم الملف بالبايت")]
    public long SizeBytes { get; set; }

    /// <summary>
    /// نوع المحتوى الخاص بالملف، مثل MIME type.
    /// The file content type, such as a MIME type.
    /// </summary>
    [Display(Name = "نوع المحتوى")]
    public string Type { get; set; } = string.Empty;

    /// <summary>
    /// تصنيف الصورة داخل سياق التقييم.
    /// The image category within the review context.
    /// </summary>
    [Display(Name = "فئة الصورة")]
    public ImageCategory Category { get; set; }

    /// <summary>
    /// وصف قصير يوضح محتوى الصورة.
    /// A short description that clarifies the image content.
    /// </summary>
    [Display(Name = "تعليق توضيحي للصورة")]
    public string Caption { get; set; } = string.Empty;

    /// <summary>
    /// نص بديل يُستخدم عند تعذّر عرض الصورة.
    /// Alternative text used when the image cannot be displayed.
    /// </summary>
    [Display(Name = "نص بديل للصورة")]
    public string AltText { get; set; } = string.Empty;

    /// <summary>
    /// الوسوم المرتبطة بالصورة بصيغة JSON.
    /// Tags associated with the image, stored as JSON.
    /// </summary>
    [Display(Name = "وسوم الصورة")]
    public string Tags { get; set; } = string.Empty;

    /// <summary>
    /// يشير إلى ما إذا كانت هذه الصورة هي الصورة الأساسية.
    /// Indicates whether this is the primary image.
    /// </summary>
    [Display(Name = "هل هي الصورة الرئيسية")]
    public bool IsMain { get; set; } = false;

    /// <summary>
    /// الترتيب المستخدم عند عرض الصور.
    /// The ordering value used when displaying images.
    /// </summary>
    [Display(Name = "ترتيب العرض")]
    public int DisplayOrder { get; set; } = 0;

    /// <summary>
    /// التاريخ والوقت الذي أُضيفت فيه الصورة.
    /// The date and time when the image was uploaded.
    /// </summary>
    [Display(Name = "تاريخ الرفع")]
    public DateTime UploadedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// حالة اعتماد الصورة أو مراجعتها.
    /// The approval or moderation status of the image.
    /// </summary>
    [Display(Name = "حالة الموافقة")]
    public ImageStatus Status { get; set; } = ImageStatus.Pending;

    /// <summary>
    /// مرجع تنقّل إلى التقييم المرتبط بهذه الصورة.
    /// Navigation reference to the related review.
    /// </summary>
    [Display(Name = "الكيان التابع للتقييم")]
    public virtual Review Review { get; set; }
} 
