namespace YemenBooking.Core.Entities;

using System;
using System.ComponentModel.DataAnnotations;
using YemenBooking.Core.Enums;

/// <summary>
/// يمثل موظفًا مرتبطًا بعقار أو منشأة داخل النظام.
/// Represents a staff member linked to a property within the system.
/// </summary>
[Display(Name = "كيان الموظف")]
public class Staff : BaseEntity<Guid>
{
    /// <summary>
    /// معرّف المستخدم المرتبط بملف الموظف.
    /// Identifies the user linked to the staff record.
    /// </summary>
    [Display(Name = "معرف المستخدم")]
    public Guid UserId { get; set; }
    
    /// <summary>
    /// معرّف العقار أو المنشأة التي يعمل بها الموظف.
    /// Identifies the property or facility the staff member belongs to.
    /// </summary>
    [Display(Name = "معرف الكيان")]
    public Guid PropertyId { get; set; }
    
    /// <summary>
    /// المنصب الوظيفي للموظف داخل العقار.
    /// The staff member's role within the property.
    /// </summary>
    [Display(Name = "منصب الموظف")]
    public StaffPosition Position { get; set; }
    
    /// <summary>
    /// الصلاحيات الممنوحة للموظف بصيغة JSON.
    /// The permissions granted to the staff member, stored as JSON.
    /// </summary>
    [Display(Name = "الصلاحيات")]
    public string Permissions { get; set; }
    
    /// <summary>
    /// مرجع التنقّل إلى المستخدم المرتبط.
    /// Navigation reference to the related user.
    /// </summary>
    [Display(Name = "المستخدم المرتبط بالموظف")]
    public virtual User User { get; set; }
    
    /// <summary>
    /// مرجع التنقّل إلى العقار المرتبط.
    /// Navigation reference to the related property.
    /// </summary>
    [Display(Name = "الكيان المرتبط بالموظف")]
    public virtual Property Property { get; set; }
}
