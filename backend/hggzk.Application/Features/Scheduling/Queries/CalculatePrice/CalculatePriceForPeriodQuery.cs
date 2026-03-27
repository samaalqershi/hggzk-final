using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Scheduling.Queries.CalculatePrice;

/// <summary>
/// استعلام حساب السعر for period.
/// Calculate Price For Period query.
/// </summary>
public class CalculatePriceForPeriodQuery : IRequest<ResultDto<PricingCalculationResultDto>>
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
    /// القيمة الخاصة بـ base السعر amount.
    /// Base Price Amount value.
    /// </summary>
    public decimal BasePriceAmount { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ base currency.
    /// Base Currency value.
    /// </summary>
    public string BaseCurrency { get; set; } = string.Empty;
}

/// <summary>
/// استعلام حساب السعر for period.
/// Calculate Price For Period query.
/// </summary>
public class PricingCalculationResultDto
{
    /// <summary>
    /// القيمة الخاصة بـ total السعر.
    /// Total Price value.
    /// </summary>
    public decimal TotalPrice { get; set; }
    /// <summary>
    /// العملة.
    /// Currency.
    /// </summary>
    public string Currency { get; set; } = string.Empty;
    /// <summary>
    /// القيمة الخاصة بـ total days.
    /// Total Days value.
    /// </summary>
    public int TotalDays { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ days with مخصص pricing.
    /// Days With Custom Pricing value.
    /// </summary>
    public int DaysWithCustomPricing { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ days with base السعر.
    /// Days With Base Price value.
    /// </summary>
    public int DaysWithBasePrice { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ المتوسط per day.
    /// Average Per Day value.
    /// </summary>
    public decimal AveragePerDay { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ اليومي prices.
    /// Daily Prices value.
    /// </summary>
    public List<DailyPriceInfoDto> DailyPrices { get; set; } = new();
}

/// <summary>
/// استعلام حساب السعر for period.
/// Calculate Price For Period query.
/// </summary>
public class DailyPriceInfoDto
{
    /// <summary>
    /// القيمة الخاصة بـ date.
    /// Date value.
    /// </summary>
    public DateTime Date { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ السعر.
    /// Price value.
    /// </summary>
    public decimal Price { get; set; }
    /// <summary>
    /// نوع السعر.
    /// Price type.
    /// </summary>
    public string? PriceType { get; set; }
    /// <summary>
    /// يشير إلى ما إذا كان مخصص السعر.
    /// Indicates whether custom price.
    /// </summary>
    public bool IsCustomPrice { get; set; }
}
