namespace YemenBooking.Core.Entities;

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

/// <summary>
/// يمثل دورًا يمكن إسناده للمستخدمين داخل النظام.
/// Represents a role that can be assigned to users in the system.
/// </summary>
[Display(Name = "كيان الدور")]
public class Role : BaseEntity<Guid>
{
    /// <summary>
    /// اسم الدور المستخدم داخل النظام، مثل admin أو owner.
    /// The role name used in the system, such as admin or owner.
    /// </summary>
    [Display(Name = "اسم الدور")]
    public string Name { get; set; }
    
    /// <summary>
    /// علاقات الربط بين هذا الدور والمستخدمين المعيّنين به.
    /// The link records between this role and its assigned users.
    /// </summary>
    [Display(Name = "المستخدمون المرتبطون بهذا الدور")]
    public virtual ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
}
