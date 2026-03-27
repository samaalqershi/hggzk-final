using System.ComponentModel.DataAnnotations;
using YemenBooking.Core.Enums;

namespace YemenBooking.Core.Entities;

/// <summary>
/// مستند قانوني معتمد للنظام.
/// Legal document maintained by the system.
/// </summary>
public class LegalDocument
{
    /// <summary>
    /// معرف المستند.
    /// Document identifier.
    /// </summary>
    [Key]
    public Guid Id { get; set; }

    /// <summary>
    /// نوع المستند القانوني.
    /// Legal document type.
    /// </summary>
    [Required]
    public LegalDocumentType Type { get; set; }

    /// <summary>
    /// لغة المستند.
    /// Document language.
    /// </summary>
    [Required]
    [MaxLength(10)]
    public string Language { get; set; } = "ar";

    /// <summary>
    /// عنوان المستند.
    /// Document title.
    /// </summary>
    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    /// <summary>
    /// محتوى المستند.
    /// Document content.
    /// </summary>
    [Required]
    public string Content { get; set; } = string.Empty;

    /// <summary>
    /// إصدار المستند.
    /// Document version.
    /// </summary>
    [Required]
    [MaxLength(20)]
    public string Version { get; set; } = "1.0";

    /// <summary>
    /// تاريخ النفاذ.
    /// Effective date.
    /// </summary>
    public DateTime EffectiveDate { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// يحدد ما إذا كان المستند نشطًا.
    /// Indicates whether the document is active.
    /// </summary>
    public bool IsActive { get; set; } = true;

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
