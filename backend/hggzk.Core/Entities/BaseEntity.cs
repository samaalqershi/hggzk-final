using YemenBooking.Core.Interfaces;
using System.ComponentModel.DataAnnotations;

namespace YemenBooking.Core.Entities;

/// <summary>
/// يمثل الأساس المشترك الذي ترث منه جميع الكيانات في النظام.
/// Represents the shared base for all entities in the system.
/// </summary>
[Display(Name = "الكيان الأساسي لجميع الكيانات")]
public abstract class BaseEntity<TId> : IBaseEntity<TId>
    where TId : struct
{
    /// <summary>
    /// المعرّف الفريد للكيان.
    /// The entity's unique identifier.
    /// </summary>
    [Display(Name = "المعرف الفريد للكيان")]
    public TId Id { get; set; } = default!;

    /// <summary>
    /// معرّف المستخدم الذي أنشأ الكيان.
    /// Identifies the user who created the entity.
    /// </summary>
    [Display(Name = "المستخدم الذي أنشأ الكيان")]
    public TId? CreatedBy { get; set; }

    /// <summary>
    /// تاريخ ووقت إنشاء الكيان.
    /// The date and time the entity was created.
    /// </summary>
    [Display(Name = "تاريخ إنشاء الكيان")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    /// <summary>
    /// معرّف المستخدم الذي أجرى آخر تعديل.
    /// Identifies the user who performed the last update.
    /// </summary>
    [Display(Name = "المستخدم الذي حدث الكيان")]
    public TId? UpdatedBy { get; set; }

    /// <summary>
    /// تاريخ ووقت آخر تعديل على الكيان.
    /// The date and time of the last update to the entity.
    /// </summary>
    [Display(Name = "تاريخ آخر تحديث")]
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    
    /// <summary>
    /// يشير إلى ما إذا كان الكيان نشطًا.
    /// Indicates whether the entity is active.
    /// </summary>
    [Display(Name = "حالة نشاط الكيان")]
    public bool IsActive { get; set; } = true;

    /// <summary>
    /// يشير إلى ما إذا كان الكيان محذوفًا حذفًا منطقيًا.
    /// Indicates whether the entity has been soft-deleted.
    /// </summary>
    [Display(Name = "حذف كاذب للكيان")]
    public bool IsDeleted { get; set; } = false;

    /// <summary>
    /// معرّف المستخدم الذي نفذ الحذف المنطقي.
    /// Identifies the user who soft-deleted the entity.
    /// </summary>
    [Display(Name = "المستخدم الذي حذف الكيان")]
    public TId? DeletedBy { get; set; }

    /// <summary>
    /// تاريخ ووقت تنفيذ الحذف المنطقي.
    /// The date and time the entity was soft-deleted.
    /// </summary>
    [Display(Name = "تاريخ حذف الكيان")]
    public DateTime? DeletedAt { get; set; }
}
