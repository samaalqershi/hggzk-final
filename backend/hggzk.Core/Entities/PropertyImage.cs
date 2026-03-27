namespace YemenBooking.Core.Entities;

using System;
using System.ComponentModel.DataAnnotations;
using YemenBooking.Core.Enums;

/// <summary>
/// يمثل صورة مرتبطة بعقار أو وحدة أو قسم.
/// Represents an image linked to a property, unit, or section.
/// </summary>
[Display(Name = "كيان صورة الكيان")]
public class PropertyImage : BaseEntity<Guid>
{
    /// <summary>
    /// مفتاح مؤقت لتجميع الرفع قبل إنشاء السجل المرتبط.
    /// Temporary key used before the linked record is created.
    /// </summary>
    [Display(Name = "المفتاح المؤقت")]
    public string? TempKey { get; set; }

    /// <summary>
    /// معرف العقار المرتبط.
    /// Linked property identifier.
    /// </summary>
    [Display(Name = "معرف الكيان")]
    public Guid? PropertyId { get; set; }
    
    /// <summary>
    /// معرف الوحدة المرتبطة.
    /// Linked unit identifier.
    /// </summary>
    [Display(Name = "معرف الوحدة")]
    public Guid? UnitId { get; set; }
        
        /// <summary>
        /// معرف القسم المرتبط.
        /// Linked section identifier.
        /// </summary>
        [Display(Name = "معرف القسم")]
        public Guid? SectionId { get; set; }

        /// <summary>
        /// معرف سجل "عقار في قسم" المرتبط.
        /// Linked PropertyInSection identifier.
        /// </summary>
        [Display(Name = "معرف عقار في قسم")]
        public Guid? PropertyInSectionId { get; set; }

        /// <summary>
        /// معرف سجل "وحدة في قسم" المرتبط.
        /// Linked UnitInSection identifier.
        /// </summary>
        [Display(Name = "معرف وحدة في قسم")]
        public Guid? UnitInSectionId { get; set; }

        /// <summary>
        /// اسم المدينة المرتبطة.
        /// Linked city name.
        /// </summary>
        [Display(Name = "اسم المدينة")]
        public string? CityName { get; set; }
    
    /// <summary>
    /// اسم الصورة.
    /// Image name.
    /// </summary>
    [Display(Name = "اسم الصورة")]
    public string Name { get; set; }
    
    /// <summary>
    /// رابط الصورة.
    /// Image URL.
    /// </summary>
    [Display(Name = "رابط الصورة")]
    public string Url { get; set; }
    
    /// <summary>
    /// حجم الصورة بالبايت.
    /// Image size in bytes.
    /// </summary>
    [Display(Name = "حجم الصورة بالبايت")]
    public long SizeBytes { get; set; }
    
    /// <summary>
    /// نوع الصورة.
    /// Image type.
    /// </summary>
    [Display(Name = "نوع الصورة")]
    public string Type { get; set; }
    
    /// <summary>
    /// فئة الصورة.
    /// Image category.
    /// </summary>
    [Display(Name = "فئة الصورة")]
    public ImageCategory Category { get; set; }
    
    /// <summary>
    /// التسمية التوضيحية للصورة.
    /// Image caption.
    /// </summary>
    [Display(Name = "تسمية توضيحية للصورة")]
    public string Caption { get; set; }
    
    /// <summary>
    /// النص البديل للصورة.
    /// Alternative text for the image.
    /// </summary>
    [Display(Name = "نص بديل للصورة")]
    public string AltText { get; set; }
    
    /// <summary>
    /// وسوم الصورة بصيغة JSON.
    /// Image tags in JSON.
    /// </summary>
    [Display(Name = "وسوم الصورة")]
    public string Tags { get; set; }

    /// <summary>
    /// أحجام الصورة بصيغة JSON.
    /// Image sizes in JSON.
    /// </summary>
    [Display(Name = "أحجام الصورة")]
    public string Sizes { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت الصورة الرئيسية.
    /// Whether this is the main image.
    /// </summary>
    [Display(Name = "هل هي الصورة الرئيسية")]
    public bool IsMain { get; set; }
    
    /// <summary>
    /// ترتيب العرض.
    /// Display order.
    /// </summary>
    [Display(Name = "ترتيب العرض")]
    public int SortOrder { get; set; }
    
    /// <summary>
    /// عدد المشاهدات.
    /// Number of views.
    /// </summary>
    [Display(Name = "عدد المشاهدات")]
    public int Views { get; set; }
    
    /// <summary>
    /// عدد التنزيلات.
    /// Number of downloads.
    /// </summary>
    [Display(Name = "عدد التنزيلات")]
    public int Downloads { get; set; }
    
    /// <summary>
    /// تاريخ الرفع.
    /// Upload date.
    /// </summary>
    [Display(Name = "تاريخ الرفع")]
    public DateTime UploadedAt { get; set; }
    
    /// <summary>
    /// ترتيب العرض.
    /// Display order.
    /// </summary>
    [Display(Name = "ترتيب العرض")]
    public int DisplayOrder { get; set; }
    
    /// <summary>
    /// حالة الصورة.
    /// Image status.
    /// </summary>
    [Display(Name = "حالة الصورة")]
    public ImageStatus Status { get; set; }
    
    /// <summary>
    /// يحدد دعم صورة 360 درجة.
    /// Whether the image supports 360 view.
    /// </summary>
    [Display(Name = "صورة 360 درجة")]
    public bool Is360 { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت هذه هي الصورة الرئيسية.
    /// Whether this is the main image.
    /// </summary>
    [Display(Name = "هل هي الصورة الرئيسية")]
    public bool IsMainImage { get; set; }

    /// <summary>
    /// نوع الوسائط.
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
    [Display(Name = "مصغرة الفيديو")]
    public string? VideoThumbnailUrl { get; set; }
    
    /// <summary>
    /// العقار المرتبط بالصورة.
    /// Linked property.
    /// </summary>
    [Display(Name = "الكيان المرتبط بالصورة")]
    public virtual Property? Property { get; set; }
    
    /// <summary>
    /// الوحدة المرتبطة بالصورة.
    /// Linked unit.
    /// </summary>
    [Display(Name = "الوحدة المرتبطة بالصورة")]
    public virtual Unit? Unit { get; set; }
        
        /// <summary>
        /// المدينة المرتبطة بالصورة.
        /// Linked city.
        /// </summary>
        [Display(Name = "المدينة المرتبطة بالصورة")]
        public virtual City? City { get; set; }

        /// <summary>
        /// القسم المرتبط بالصورة.
        /// Linked section.
        /// </summary>
        [Display(Name = "القسم المرتبط بالصورة")]
        public virtual Section? Section { get; set; }

        /// <summary>
        /// سجل "عقار في قسم" المرتبط بالصورة.
        /// Linked PropertyInSection record.
        /// </summary>
        [Display(Name = "عقار في قسم المرتبط بالصورة")]
        public virtual PropertyInSection? PropertyInSection { get; set; }

        /// <summary>
        /// سجل "وحدة في قسم" المرتبط بالصورة.
        /// Linked UnitInSection record.
        /// </summary>
        [Display(Name = "وحدة في قسم المرتبطة بالصورة")]
        public virtual UnitInSection? UnitInSection { get; set; }
}
