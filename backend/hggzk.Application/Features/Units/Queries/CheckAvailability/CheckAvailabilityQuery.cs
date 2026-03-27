using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Enums;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Units.Queries.CheckAvailability;

/// <summary>
/// استعلام التحقق من التوفر.
/// Check Availability query.
/// </summary>
public class CheckAvailabilityQuery : IRequest<ResultDto<CheckAvailabilityResponse>>
{
    /// <summary>
    /// معرّف الوحدة.
    /// Unit identifier.
    /// </summary>
    public Guid UnitId { get; set; }
    /// <summary>
    /// تاريخ الوصول.
    /// Check-in date.
    /// </summary>
    public DateTime CheckIn { get; set; }
    /// <summary>
    /// تاريخ المغادرة.
    /// Check-out date.
    /// </summary>
    public DateTime CheckOut { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ adults.
    /// Adults value.
    /// </summary>
    public int? Adults { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ children.
    /// Children value.
    /// </summary>
    public int? Children { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ include pricing.
    /// Include Pricing value.
    /// </summary>
    public bool IncludePricing { get; set; } = false;
}

/// <summary>
/// استعلام التحقق من التوفر.
/// Check Availability query.
/// </summary>
public class CheckAvailabilityResponse
{
    /// <summary>
    /// يشير إلى ما إذا كان المتاح.
    /// Indicates whether available.
    /// </summary>
    public bool IsAvailable { get; set; }
    /// <summary>
    /// الحالة.
    /// Status.
    /// </summary>
    public string Status { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ blocked periods.
    /// Blocked Periods value.
    /// </summary>
    public List<BlockedPeriodDto> BlockedPeriods { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ المتاح periods.
    /// Available Periods value.
    /// </summary>
    public List<AvailablePeriodDto> AvailablePeriods { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ التفاصيل.
    /// Details value.
    /// </summary>
    public AvailabilityDetailsDto Details { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ pricing summary.
    /// Pricing Summary value.
    /// </summary>
    public PricingSummaryDto PricingSummary { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ messages.
    /// Messages value.
    /// </summary>
    public List<string> Messages { get; set; }
}

/// <summary>
/// استعلام التحقق من التوفر.
/// Check Availability query.
/// </summary>
public class BlockedPeriodDto
{
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
    /// الحالة.
    /// Status.
    /// </summary>
    public string Status { get; set; }
    /// <summary>
    /// السبب.
    /// Reason.
    /// </summary>
    public string Reason { get; set; }
    /// <summary>
    /// الملاحظات.
    /// Notes.
    /// </summary>
    public string Notes { get; set; }
}

/// <summary>
/// استعلام التحقق من التوفر.
/// Check Availability query.
/// </summary>
public class AvailablePeriodDto
{
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
    /// القيمة الخاصة بـ السعر.
    /// Price value.
    /// </summary>
    public decimal? Price { get; set; }
    /// <summary>
    /// العملة.
    /// Currency.
    /// </summary>
    public string Currency { get; set; }
}

/// <summary>
/// استعلام التحقق من التوفر.
/// Check Availability query.
/// </summary>
public class AvailabilityDetailsDto
{
    /// <summary>
    /// معرّف الوحدة.
    /// Unit identifier.
    /// </summary>
    public Guid UnitId { get; set; }
    /// <summary>
    /// اسم الوحدة.
    /// Unit name.
    /// </summary>
    public string UnitName { get; set; }
    /// <summary>
    /// نوع الوحدة.
    /// Unit type.
    /// </summary>
    public string UnitType { get; set; }
    /// <summary>
    /// الحد الأقصى لـ adults.
    /// Maximum adults.
    /// </summary>
    public int MaxAdults { get; set; }
    /// <summary>
    /// الحد الأقصى لـ children.
    /// Maximum children.
    /// </summary>
    public int MaxChildren { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ total nights.
    /// Total Nights value.
    /// </summary>
    public int TotalNights { get; set; }
    /// <summary>
    /// يشير إلى ما إذا كان multi days.
    /// Indicates whether multi days.
    /// </summary>
    public bool IsMultiDays { get; set; }
    /// <summary>
    /// يشير إلى ما إذا كان required to determine the hour.
    /// Indicates whether required to determine the hour.
    /// </summary>
    public bool IsRequiredToDetermineTheHour { get; set; }
}

/// <summary>
/// استعلام التحقق من التوفر.
/// Check Availability query.
/// </summary>
public class PricingSummaryDto
{
    /// <summary>
    /// القيمة الخاصة بـ total السعر.
    /// Total Price value.
    /// </summary>
    public decimal TotalPrice { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ المتوسط nightly السعر.
    /// Average Nightly Price value.
    /// </summary>
    public decimal AverageNightlyPrice { get; set; }
    /// <summary>
    /// العملة.
    /// Currency.
    /// </summary>
    public string Currency { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ اليومي prices.
    /// Daily Prices value.
    /// </summary>
    public List<DailyPriceDto> DailyPrices { get; set; }
}

/// <summary>
/// استعلام التحقق من التوفر.
/// Check Availability query.
/// </summary>
public class DailyPriceDto
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
    public string PriceType { get; set; }
}
