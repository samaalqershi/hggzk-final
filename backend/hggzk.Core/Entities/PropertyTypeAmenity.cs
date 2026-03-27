namespace YemenBooking.Core.Entities;

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

/// <summary>
/// يربط نوع العقار بالمرافق الافتراضية المتاحة له.
/// Links a property type to the amenities available by default.
/// </summary>
[Display(Name = "كيان وسيلة نوع الكيان")]
public class PropertyTypeAmenity : BaseEntity<Guid>
{
    /// <summary>
    /// معرّف نوع العقار.
    /// Identifier of the property type.
    /// </summary>
    [Display(Name = "معرف نوع الكيان")]
    public Guid PropertyTypeId { get; set; }
    
    /// <summary>
    /// معرّف المرفق.
    /// Identifier of the amenity.
    /// </summary>
    [Display(Name = "معرف الوسيلة")]
    public Guid AmenityId { get; set; }
    
    /// <summary>
    /// يحدد ما إذا كان المرفق ضمن المجموعة الافتراضية لهذا النوع.
    /// Indicates whether the amenity belongs to the default set for this type.
    /// </summary>
    [Display(Name = "هل هي وسيلة افتراضية")]
    public bool IsDefault { get; set; }
    
    /// <summary>
    /// المرجع الملاحي إلى نوع العقار.
    /// Navigation reference to the property type.
    /// </summary>
    [Display(Name = "نوع الكيان المرتبط")]
    public virtual PropertyType PropertyType { get; set; }
    
    /// <summary>
    /// المرجع الملاحي إلى المرفق.
    /// Navigation reference to the amenity.
    /// </summary>
    [Display(Name = "الوسيلة المرتبطة")]
    public virtual Amenity Amenity { get; set; }
    
    /// <summary>
    /// الارتباطات التفصيلية بين العقار والمرافق.
    /// Detailed property-to-amenity associations.
    /// </summary>
    [Display(Name = "وسائل الكيان المرتبطة")]
    public virtual ICollection<PropertyAmenity> PropertyAmenities { get; set; } = new List<PropertyAmenity>();
} 
