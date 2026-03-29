using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace YemenBooking.Core.Entities;

/// <summary>
/// كيان حقول نوع الوحدة.
/// Represents a dynamic field defined for a unit type.
/// </summary>
[Display(Name = "كيان حقول نوع الكيان")]
public class UnitTypeField : BaseEntity<Guid>
{
    /// <summary>
    /// معرف نوع الوحدة.
    /// Identifier of the unit type.
    /// </summary>
    [Display(Name = "معرف نوع الكيان")]
    public Guid UnitTypeId { get; set; }

    /// <summary>
    /// معرف نوع الحقل.
    /// Identifier of the field type.
    /// </summary>
    [Display(Name = "معرف نوع الحقل")]
    public string FieldTypeId { get; set; }

    /// <summary>
    /// اسم الحقل.
    /// Field name.
    /// </summary>
    [Display(Name = "اسم الحقل")]
    public string FieldName { get; set; }

    /// <summary>
    /// الاسم المعروض للحقل.
    /// Display name of the field.
    /// </summary>
    [Display(Name = "الاسم المعروض للحقل")]
    public string DisplayName { get; set; }

    /// <summary>
    /// الاسم المعروض للحقل باللغة الإنجليزية.
    /// English display name of the field.
    /// </summary>
    [Display(Name = "الاسم المعروض للحقل بالإنجليزية")]
    public string? DisplayNameEn { get; set; }

    /// <summary>
    /// وصف الحقل.
    /// Field description.
    /// </summary>
    [Display(Name = "وصف الحقل")]
    public string Description { get; set; }

    /// <summary>
    /// وصف الحقل باللغة الإنجليزية.
    /// English field description.
    /// </summary>
    [Display(Name = "وصف الحقل بالإنجليزية")]
    public string? DescriptionEn { get; set; }

    /// <summary>
    /// خيارات الحقل بصيغة JSON عند استخدام select أو multi_select.
    /// Field options in JSON format for select or multi-select fields.
    /// </summary>
    [Display(Name = "خيارات الحقل")]
    public string FieldOptions { get; set; }

    /// <summary>
    /// خيارات الحقل المترجمة إلى الإنجليزية بصيغة JSON.
    /// English-translated field options stored as JSON.
    /// </summary>
    [Display(Name = "خيارات الحقل بالإنجليزية")]
    public string? FieldOptionsEn { get; set; }

    /// <summary>
    /// قواعد التحقق المخصصة بصيغة JSON.
    /// Custom validation rules stored as JSON.
    /// </summary>
    [Display(Name = "قواعد التحقق المخصصة")]
    public string ValidationRules { get; set; }

    /// <summary>
    /// يحدد ما إذا كان الحقل إلزاميًا.
    /// Indicates whether the field is required.
    /// </summary>
    [Display(Name = "هل الحقل إلزامي")]
    public bool IsRequired { get; set; }

    /// <summary>
    /// يحدد ما إذا كان الحقل يظهر في الفلترة.
    /// Indicates whether the field is searchable.
    /// </summary>
    [Display(Name = "هل يظهر في الفلترة")]
    public bool IsSearchable { get; set; }

    /// <summary>
    /// يحدد ما إذا كان الحقل ظاهرًا للعملاء.
    /// Indicates whether the field is visible to customers.
    /// </summary>
    [Display(Name = "هل يظهر للعملاء")]
    public bool IsPublic { get; set; }

    /// <summary>
    /// ترتيب الحقل.
    /// Sort order of the field.
    /// </summary>
    [Display(Name = "ترتيب الحقل")]
    public int SortOrder { get; set; }

    /// <summary>
    /// فئة الحقل.
    /// Category of the field, such as basic, amenities, location, or pricing.
    /// </summary>
    [Display(Name = "فئة الحقل")]
    public string Category { get; set; }

    /// <summary>
    /// فئة الحقل باللغة الإنجليزية.
    /// English field category.
    /// </summary>
    [Display(Name = "فئة الحقل بالإنجليزية")]
    public string? CategoryEn { get; set; }

    /// <summary>
    /// نوع الوحدة المرتبط.
    /// Associated unit type.
    /// </summary>
    [Display(Name = "نوع الوحدة المرتبط")]
    public virtual UnitType UnitType { get; set; }

    /// <summary>
    /// قيم الحقل المرتبطة بالوحدات.
    /// Field values associated with units.
    /// </summary>
    [Display(Name = "قيم الحقل للوحدات")]
    public virtual ICollection<UnitFieldValue> UnitFieldValues { get; set; } = new List<UnitFieldValue>();

    /// <summary>
    /// روابط مجموعات الحقول.
    /// Links to field groups.
    /// </summary>
    [Display(Name = "انضمامات مجموعات الحقول")]
    public virtual ICollection<FieldGroupField> FieldGroupFields { get; set; } = new List<FieldGroupField>();

    /// <summary>
    /// فلاتر البحث المرتبطة بهذا الحقل.
    /// Search filters associated with this field.
    /// </summary>
    [Display(Name = "الفلاتر المرتبطة بهذا الحقل")]
    public virtual ICollection<SearchFilter> SearchFilters { get; set; } = new List<SearchFilter>();

    /// <summary>
    /// يحدد ما إذا كان الحقل مخصصًا للوحدات.
    /// Indicates whether the field applies to units.
    /// </summary>
    [Display(Name = "مخصص للوحدات")]
    public bool IsForUnits { get; set; }
    /// <summary>
    /// يحدد ما إذا كان الحقل يظهر في البطاقات.
    /// Indicates whether the field appears in cards.
    /// </summary>
    [Display(Name = "هل يظهر في الكروت؟")]
    public bool ShowInCards { get; set; }

    /// <summary>
    /// يحدد ما إذا كان الحقل فلترًا أساسيًا.
    /// Indicates whether the field is a primary filter.
    /// </summary>
    [Display(Name = "هل الحقل فلترة أساسية؟")]
    public bool IsPrimaryFilter { get; set; }

    /// <summary>
    /// أولوية الترتيب.
    /// Sort priority.
    /// </summary>
    [Display(Name = "أولوية الترتيب")]
    public int Priority { get; set; }
} 
