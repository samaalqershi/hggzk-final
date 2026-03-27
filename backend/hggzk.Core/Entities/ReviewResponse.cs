namespace YemenBooking.Core.Entities;

using System;
using System.ComponentModel.DataAnnotations;

/// <summary>
/// رد إداري أو من المالك على مراجعة.
/// Response from an admin or owner to a review.
/// </summary>
[Display(Name = "رد على التقييم")]
public class ReviewResponse : BaseEntity<Guid>
{
    /// <summary>
    /// معرف المراجعة المرتبطة.
    /// Related review identifier.
    /// </summary>
    [Display(Name = "معرف التقييم")]
    public Guid ReviewId { get; set; }

    /// <summary>
    /// نص الرد.
    /// Response text.
    /// </summary>
    [Display(Name = "نص الرد")]
    public string Text { get; set; } = string.Empty;

    /// <summary>
    /// تاريخ الرد.
    /// Response date.
    /// </summary>
    [Display(Name = "تاريخ الرد")]
    public DateTime RespondedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// معرف المستخدم الذي قام بالرد.
    /// Identifier of the responding user.
    /// </summary>
    [Display(Name = "معرّف المُجيب")]
    public Guid RespondedBy { get; set; }

    /// <summary>
    /// اسم المستخدم الذي قام بالرد.
    /// Cached responder name for quick reads.
    /// </summary>
    [Display(Name = "اسم المُجيب")]
    public string RespondedByName { get; set; } = string.Empty;

    /// <summary>
    /// المراجعة المرتبطة.
    /// Related review navigation property.
    /// </summary>
    public virtual Review Review { get; set; } = null!;
}
