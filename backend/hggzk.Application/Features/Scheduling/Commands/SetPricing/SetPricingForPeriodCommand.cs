using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Scheduling.Commands.SetPricing;

/// <summary>
/// أمر تعيين pricing for period.
/// Set Pricing For Period command.
/// </summary>
public class SetPricingForPeriodCommand : IRequest<ResultDto<int>>
{
    /// <summary>
    /// معرّف الوحدة.
    /// Unit identifier.
    /// </summary>
    public Guid UnitId { get; set; }
    /// <summary>
    /// تاريخ البداية.
    /// Start date.
    /// </summary>
    public DateTime StartDate { get; set; }
    /// <summary>
    /// تاريخ النهاية.
    /// End date.
    /// </summary>
    public DateTime EndDate { get; set; }
    /// <summary>
    /// مبلغ السعر.
    /// Price amount.
    /// </summary>
    public decimal PriceAmount { get; set; }
    /// <summary>
    /// العملة.
    /// Currency.
    /// </summary>
    public string Currency { get; set; } = string.Empty;
    /// <summary>
    /// نوع السعر.
    /// Price type.
    /// </summary>
    public string? PriceType { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ pricing tier.
    /// Pricing Tier value.
    /// </summary>
    public string? PricingTier { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ percentage change.
    /// Percentage Change value.
    /// </summary>
    public decimal? PercentageChange { get; set; }
    /// <summary>
    /// الحد الأدنى للسعر.
    /// Minimum price.
    /// </summary>
    public decimal? MinPrice { get; set; }
    /// <summary>
    /// الحد الأقصى للسعر.
    /// Maximum price.
    /// </summary>
    public decimal? MaxPrice { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ overwrite existing.
    /// Overwrite Existing value.
    /// </summary>
    public bool OverwriteExisting { get; set; }
}
