namespace YemenBooking.Core.Entities;

using System;
using System.ComponentModel.DataAnnotations;
using YemenBooking.Core.ValueObjects;

/// <summary>
/// يربط بين عقار محدد ومرفق محدد مع حالة الإتاحة والتكلفة الإضافية.
/// Links a specific property to an amenity with availability and extra cost details.
/// </summary>
[Display(Name = "كيان وسيلة الكيان")]
public class PropertyAmenity : BaseEntity<Guid>
{
    /// <summary>
    /// معرّف العقار المرتبط بهذا المرفق.
    /// Identifier of the property linked to this amenity.
    /// </summary>
    [Display(Name = "معرف الكيان")]
    public Guid PropertyId { get; set; }
    
    /// <summary>
    /// معرّف المرفق الموروث من نوع العقار.
    /// Identifier of the amenity inherited from the property type.
    /// </summary>
    [Display(Name = "معرف وسيلة نوع الكيان")]
    public Guid PtaId { get; set; }
    
    /// <summary>
    /// يحدد ما إذا كان المرفق متاحًا فعليًا لهذا العقار.
    /// Indicates whether the amenity is actually available for this property.
    /// </summary>
    [Display(Name = "هل الوسيلة متاحة")]
    public bool IsAvailable { get; set; }
    
    /// <summary>
    /// التكلفة الإضافية المرتبطة بتفعيل هذا المرفق.
    /// Additional cost associated with enabling this amenity.
    /// </summary>
    [Display(Name = "التكلفة الإضافية للوسيلة")]
    public Money ExtraCost { get; set; }
    
    /// <summary>
    /// المرجع الملاحي إلى العقار المرتبط.
    /// Navigation reference to the associated property.
    /// </summary>
    [Display(Name = "الكيان المرتبط")]
    public virtual Property Property { get; set; }
    
    /// <summary>
    /// المرجع الملاحي إلى المرفق المعرّف على مستوى نوع العقار.
    /// Navigation reference to the amenity defined at the property-type level.
    /// </summary>
    [Display(Name = "وسيلة نوع الكيان المرتبطة")]
    public virtual PropertyTypeAmenity PropertyTypeAmenity { get; set; }
} 
