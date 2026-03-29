namespace YemenBooking.Core.Entities;

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

/// <summary>
/// كيان نوع الوحدة
/// Represents a unit category such as a room, suite, chalet, or villa.
/// </summary>
[Display(Name = "كيان نوع الوحدة")]
public class UnitType : BaseEntity<Guid>
{
    /// <summary>
    /// وصف نوع الوحدة.
    /// Description of the unit type.
    /// </summary>
    [Display(Name = "وصف نوع الوحدة")]
    public string Description { get; set; }

    /// <summary>
    /// وصف نوع الوحدة باللغة الإنجليزية.
    /// English unit type description.
    /// </summary>
    [Display(Name = "وصف نوع الوحدة بالإنجليزية")]
    public string? DescriptionEn { get; set; }

    /// <summary>
    /// قواعد التسعير الافتراضية بصيغة JSON.
    /// Default pricing rules stored as JSON.
    /// </summary>
    [Display(Name = "قواعد التسعير الافتراضية")]
    public string DefaultPricingRules { get; set; }

    /// <summary>
    /// معرف نوع العقار المرتبط.
    /// Identifier of the associated property type.
    /// </summary>
    [Display(Name = "معرف نوع الكيان")]
    public Guid PropertyTypeId { get; set; }

    /// <summary>
    /// اسم نوع الوحدة.
    /// Name of the unit type, such as Double Room, Suite, Full Chalet, or Villa.
    /// </summary>
    [Display(Name = "اسم نوع الوحدة")]
    public string Name { get; set; }

    /// <summary>
    /// اسم نوع الوحدة باللغة الإنجليزية.
    /// English unit type name.
    /// </summary>
    [Display(Name = "اسم نوع الوحدة بالإنجليزية")]
    public string? NameEn { get; set; }

    /// <summary>
    /// الحد الأقصى للسعة.
    /// Maximum allowed capacity.
    /// </summary>
    [Display(Name = "الحد الأقصى للسعة")]
    public int MaxCapacity { get; set; }

    /// <summary>
    /// أيقونة نوع الوحدة.
    /// Icon for the unit type.
    /// </summary>
    public string Icon { get; set; } = string.Empty;

    /// <summary>
    /// يحدد ما إذا كان هذا النوع يدعم استيعاب البالغين.
    /// Indicates whether this type supports adults.
    /// </summary>
    public bool IsHasAdults { get; set; } = false;

    /// <summary>
    /// يحدد ما إذا كان هذا النوع يدعم استيعاب الأطفال.
    /// Indicates whether this type supports children.
    /// </summary>
    public bool IsHasChildren { get; set; } = false;

    /// <summary>
    /// يحدد ما إذا كان هذا النوع يدعم الإقامة متعددة الأيام.
    /// Indicates whether this type supports multi-day stays.
    /// </summary>
    public bool IsMultiDays { get; set; } = false;

    /// <summary>
    /// يحدد ما إذا كان هذا النوع يتطلب تحديد ساعة الحجز.
    /// Indicates whether this type requires an hour to be specified.
    /// </summary>
    public bool IsRequiredToDetermineTheHour { get; set; } = false;

    /// <summary>
    /// نسبة عمولة النظام لهذا النوع.
    /// System commission rate for this type as a percentage from 0 to 100.
    /// </summary>
    [Display(Name = "نسبة عمولة النظام")]
    public decimal? SystemCommissionRate { get; set; }

    /// <summary>
    /// نوع العقار المرتبط.
    /// Associated property type.
    /// </summary>
    [Display(Name = "نوع الكيان المرتبط")]
    public virtual PropertyType PropertyType { get; set; }

    /// <summary>
    /// الوحدات المرتبطة بهذا النوع.
    /// Units associated with this type.
    /// </summary>
    [Display(Name = "الوحدات المرتبطة بهذا النوع")]
    public virtual ICollection<Unit> Units { get; set; } = new List<Unit>();
    
    /// <summary>
    /// الحقول الديناميكية المرتبطة بنوع الوحدة.
    /// Dynamic fields associated with this unit type.
    /// </summary>
    [Display(Name = "الحقول الديناميكية لنوع الوحدة")]
    public virtual ICollection<UnitTypeField> UnitTypeFields { get; set; } = new List<UnitTypeField>();

    /// <summary>
    /// مجموعات الحقول المرتبطة بنوع الوحدة.
    /// Field groups associated with this unit type.
    /// </summary>
    [Display(Name = "مجموعات الحقول لنوع الوحدة")]
    public virtual ICollection<FieldGroup> FieldGroups { get; set; } = new List<FieldGroup>();

    /// <summary>
    /// فلاتر البحث المرتبطة بنوع الوحدة.
    /// Search filters associated with this unit type.
    /// </summary>
    [Display(Name = "الفلاتر المخصصة لنوع الوحدة")]
    public virtual ICollection<SearchFilter> SearchFilters { get; set; } = new List<SearchFilter>();

} 
