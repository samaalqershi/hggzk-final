namespace YemenBooking.Core.Entities;

using System;
using System.ComponentModel.DataAnnotations;

/// <summary>
/// يمثل علاقة الإسناد بين مستخدم ودور.
/// Represents the assignment relationship between a user and a role.
/// </summary>
[Display(Name = "كيان دور المستخدم")]
public class UserRole : BaseEntity<Guid>
{
    /// <summary>
    /// معرّف المستخدم ضمن علاقة الإسناد.
    /// The user identifier within the assignment.
    /// </summary>
    [Display(Name = "معرف المستخدم")]
    public Guid UserId { get; set; }
    
    /// <summary>
    /// معرّف الدور الممنوح للمستخدم.
    /// The role identifier assigned to the user.
    /// </summary>
    [Display(Name = "معرف الدور")]
    public Guid RoleId { get; set; }
    
    /// <summary>
    /// وقت إسناد الدور للمستخدم.
    /// The time when the role was assigned.
    /// </summary>
    [Display(Name = "تاريخ التخصيص")]
    public DateTime AssignedAt { get; set; }
    
    /// <summary>
    /// مرجع التنقّل إلى المستخدم المرتبط.
    /// Navigation reference to the related user.
    /// </summary>
    [Display(Name = "المستخدم المرتبط بالدور")]
    public virtual User User { get; set; }
    
    /// <summary>
    /// مرجع التنقّل إلى الدور المرتبط.
    /// Navigation reference to the related role.
    /// </summary>
    [Display(Name = "الدور المرتبط بالمستخدم")]
    public virtual Role Role { get; set; }
}
