namespace YemenBooking.Core.Entities;

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

/// <summary>
/// يمثل فئة العقار التي تُستخدم لتجميع العقارات وتحديد خصائصها الافتراضية.
/// Represents the property category used to group properties and define defaults.
/// </summary>
[Display(Name = "كيان نوع الكيان")]
public class PropertyType : BaseEntity<Guid>
{
    /// <summary>
    /// اسم فئة العقار كما يظهر للمستخدم.
    /// Display name of the property category.
    /// </summary>
    [Display(Name = "اسم نوع الكيان")]
    public string Name { get; set; }

    /// <summary>
    /// اسم نوع العقار باللغة الإنجليزية.
    /// English property type name.
    /// </summary>
    [Display(Name = "اسم نوع الكيان بالإنجليزية")]
    public string? NameEn { get; set; }
    
    /// <summary>
    /// وصف يوضح طبيعة هذا النوع من العقارات.
    /// Description explaining the nature of this property type.
    /// </summary>
    [Display(Name = "وصف نوع الكيان")]
    public string Description { get; set; }

    /// <summary>
    /// وصف نوع العقار باللغة الإنجليزية.
    /// English property type description.
    /// </summary>
    [Display(Name = "وصف نوع الكيان بالإنجليزية")]
    public string? DescriptionEn { get; set; }
    
    /// <summary>
    /// المرافق الافتراضية المقترحة لهذا النوع بصيغة JSON.
    /// Default amenities suggested for this type in JSON format.
    /// </summary>
    [Display(Name = "المرافق الافتراضية لنوع الكيان")]
    public string DefaultAmenities { get; set; }

    /// <summary>
    /// الأيقونة المستخدمة لتمثيل نوع العقار.
    /// Icon used to represent the property type.
    /// </summary>
    public string Icon { get; set; } = string.Empty;

    
    /// <summary>
    /// العقارات المصنفة ضمن هذا النوع.
    /// Properties classified under this type.
    /// </summary>
    [Display(Name = "الكيانات المرتبطة بهذا النوع")]
    public virtual ICollection<Property> Properties { get; set; } = new List<Property>();
    
    /// <summary>
    /// أنواع الوحدات المرتبطة بهذا النوع من العقارات.
    /// Unit types associated with this property type.
    /// </summary>
    [Display(Name = "أنواع الوحدات المرتبطة بهذا النوع")]
    public virtual ICollection<UnitType> UnitTypes { get; set; } = new List<UnitType>();
    
    /// <summary>
    /// المرافق المرتبطة افتراضيًا بهذا النوع.
    /// Amenities associated by default with this property type.
    /// </summary>
    [Display(Name = "الوسائل المرتبطة بنوع الكيان")]
    public virtual ICollection<PropertyTypeAmenity> PropertyTypeAmenities { get; set; } = new List<PropertyTypeAmenity>();

} 
