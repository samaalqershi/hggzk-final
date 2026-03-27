using System.ComponentModel.DataAnnotations;

namespace YemenBooking.Core.Entities;

/// <summary>
/// يمثل عنصرًا مفضلاً أضافه المستخدم.
/// Represents a favorite item added by a user.
/// </summary>
[Display(Name = "المفضلة")]
public class Favorite : BaseEntity<Guid>
{
    /// <summary>
    /// معرّف المستخدم الذي أضاف العنصر إلى المفضلة.
    /// Identifies the user who added the item to favorites.
    /// </summary>
    [Display(Name = "معرف المستخدم")]
    public Guid UserId { get; set; }

    /// <summary>
    /// معرّف العقار المضاف إلى المفضلة.
    /// Identifies the property saved as a favorite.
    /// </summary>
    [Display(Name = "معرف العقار")]
    public Guid PropertyId { get; set; }

    /// <summary>
    /// وقت إضافة العنصر إلى المفضلة.
    /// The time the item was added to favorites.
    /// </summary>
    [Display(Name = "تاريخ الإضافة")]
    public DateTime DateAdded { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// ملاحظات اختيارية يضيفها المستخدم على هذا العنصر.
    /// Optional notes the user attaches to this item.
    /// </summary>
    [Display(Name = "الملاحظات")]
    [MaxLength(500)]
    public string? Notes { get; set; }

    /// <summary>
    /// أولوية التفضيل من 1 إلى 5.
    /// The favorite priority on a 1-to-5 scale.
    /// </summary>
    [Display(Name = "الأولوية")]
    [Range(1, 5)]
    public int Priority { get; set; } = 3;

    /// <summary>
    /// مرجع التنقّل إلى المستخدم المرتبط.
    /// Navigation reference to the related user.
    /// </summary>
    public virtual User? User { get; set; }

    /// <summary>
    /// مرجع التنقّل إلى العقار المرتبط.
    /// Navigation reference to the related property.
    /// </summary>
    public virtual Property? Property { get; set; }
}
