namespace YemenBooking.Core.Entities;

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

/// <summary>
/// يمثل مرفقًا أو وسيلة عامة يمكن ربطها بأنواع العقارات المختلفة.
/// Represents a generic amenity that can be attached to multiple property types.
/// </summary>
[Display(Name = "كيان المرفق")]
public class Amenity : BaseEntity<Guid>
{
    /// <summary>
    /// اسم المرفق كما يظهر في القوائم والواجهات.
    /// Display name of the amenity in listings and interfaces.
    /// </summary>
    [Display(Name = "اسم المرفق")]
    public string Name { get; set; }
    
    /// <summary>
    /// وصف يوضح وظيفة المرفق أو فائدته.
    /// Description explaining the amenity's purpose or value.
    /// </summary>
    [Display(Name = "وصف المرفق")]
    public string Description { get; set; }
    
    /// <summary>
    /// الأيقونة المستخدمة لتمثيل المرفق.
    /// Icon used to represent the amenity.
    /// </summary>
    public string Icon { get; set; } = string.Empty;

    /// <summary>
    /// أنواع العقارات التي تستخدم هذا المرفق.
    /// Property types that use this amenity.
    /// </summary>
    [Display(Name = "أنواع الكيانات المرتبطة بهذا المرفق")]
    public virtual ICollection<PropertyTypeAmenity> PropertyTypeAmenities { get; set; } = new List<PropertyTypeAmenity>();
} 
