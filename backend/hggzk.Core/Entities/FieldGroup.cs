using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace YemenBooking.Core.Entities;

/// <summary>
/// مجموعة من الحقول تُستخدم لتنظيم بيانات النوع.
/// Group of fields used to organize type-specific data.
/// </summary>
[Display(Name = "كيان مجموعات الحقول")]
public class FieldGroup : BaseEntity<Guid>
{
    /// <summary>
    /// معرف نوع الوحدة.
    /// Unit type identifier.
    /// </summary>
    [Display(Name = "معرف نوع الو​​​​حدة")]
    public Guid UnitTypeId { get; set; }

    /// <summary>
    /// اسم المجموعة.
    /// Group name.
    /// </summary>
    [Display(Name = "اسم المجموعة")]
    public string GroupName { get; set; }

    /// <summary>
    /// الاسم المعروض للمجموعة.
    /// Display name of the group.
    /// </summary>
    [Display(Name = "الاسم المعروض للمجموعة")]
    public string DisplayName { get; set; }

    /// <summary>
    /// وصف المجموعة.
    /// Group description.
    /// </summary>
    [Display(Name = "وصف المجموعة")]
    public string Description { get; set; }

    /// <summary>
    /// ترتيب العرض.
    /// Display sort order.
    /// </summary>
    [Display(Name = "ترتيب العرض")]
    public int SortOrder { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت المجموعة قابلة للطي.
    /// Indicates whether the group is collapsible.
    /// </summary>
    [Display(Name = "هل يمكن طي المجموعة")]
    public bool IsCollapsible { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت المجموعة موسعة افتراضيًا.
    /// Indicates whether the group is expanded by default.
    /// </summary>
    [Display(Name = "هل تكون المجموعة موسعة افتراضيًا")]
    public bool IsExpandedByDefault { get; set; }

    /// <summary>
    /// نوع الوحدة المرتبط.
    /// Related unit type.
    /// </summary>
    [Display(Name = "نوع الوحدة المرتبطة")]
    public virtual UnitType UnitType { get; set; }

    /// <summary>
    /// روابط الحقول ضمن هذه المجموعة.
    /// Field links within this group.
    /// </summary>
    [Display(Name = "روابط الحقول ضمن هذه المجموعة")]
    public virtual ICollection<FieldGroupField> FieldGroupFields { get; set; } = new List<FieldGroupField>();
} 
