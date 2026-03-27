using System.ComponentModel.DataAnnotations;

namespace YemenBooking.Core.Entities;

/// <summary>
/// سؤال شائع وإجابته.
/// Frequently asked question and its answer.
/// </summary>
public class FAQ
{
    /// <summary>
    /// معرف السؤال.
    /// FAQ identifier.
    /// </summary>
    [Key]
    public Guid Id { get; set; }

    /// <summary>
    /// نص السؤال.
    /// Question text.
    /// </summary>
    [Required]
    [MaxLength(500)]
    public string Question { get; set; } = string.Empty;

    /// <summary>
    /// نص الإجابة.
    /// Answer text.
    /// </summary>
    [Required]
    public string Answer { get; set; } = string.Empty;

    /// <summary>
    /// فئة السؤال.
    /// Question category.
    /// </summary>
    [MaxLength(100)]
    public string? Category { get; set; }

    /// <summary>
    /// لغة السؤال.
    /// FAQ language.
    /// </summary>
    [Required]
    [MaxLength(10)]
    public string Language { get; set; } = "ar";

    /// <summary>
    /// ترتيب العرض.
    /// Display order.
    /// </summary>
    public int DisplayOrder { get; set; }

    /// <summary>
    /// يحدد ما إذا كان السؤال نشطًا.
    /// Indicates whether the FAQ is active.
    /// </summary>
    public bool IsActive { get; set; } = true;

    /// <summary>
    /// عدد المشاهدات.
    /// View count.
    /// </summary>
    public int ViewCount { get; set; } = 0;

    /// <summary>
    /// تاريخ الإنشاء.
    /// Creation date.
    /// </summary>
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// تاريخ آخر تحديث.
    /// Last update date.
    /// </summary>
    public DateTime? UpdatedAt { get; set; }

    /// <summary>
    /// معرف المستخدم المنشئ.
    /// Creator user identifier.
    /// </summary>
    public Guid? CreatedBy { get; set; }

    /// <summary>
    /// معرف المستخدم الذي حدّث السجل.
    /// Identifier of the user who updated the record.
    /// </summary>
    public Guid? UpdatedBy { get; set; }
}
