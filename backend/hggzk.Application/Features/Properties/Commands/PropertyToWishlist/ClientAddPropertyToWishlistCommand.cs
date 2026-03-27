using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Properties.Commands.PropertyToWishlist;

/// <summary>
/// طلب إضافة عقار إلى قائمة الأمنيات.
/// Request to add a property to the wishlist.
/// </summary>
public class ClientAddPropertyToWishlistCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف العقار.
    /// property identifier.
    /// </summary>
    public Guid PropertyId { get; set; }
    /// <summary>
    /// معرّف المستخدم.
    /// user identifier.
    /// </summary>
    public Guid UserId { get; set; }
    /// <summary>
    /// الملاحظات.
    /// notes.
    /// </summary>
    public string? Notes { get; set; }
    /// <summary>
    /// تاريخ الزيارة المرغوب.
    /// desired visit date.
    /// </summary>
    public DateTime? DesiredVisitDate { get; set; }
    /// <summary>
    /// الميزانية المتوقعة.
    /// expected budget.
    /// </summary>
    public decimal? ExpectedBudget { get; set; }
    /// <summary>
    /// العملة.
    /// currency.
    /// </summary>
    public string Currency { get; set; } = "YER";
}
