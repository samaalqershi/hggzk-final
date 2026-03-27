namespace YemenBooking.Application.Contracts.Services.Scheduling;

/// <summary>
/// نتيجة حساب السعر لفترة زمنية.
/// Result of pricing a date range.
/// </summary>
public class PricingCalculationResult
{
    /// <summary>
    /// السعر الإجمالي المحسوب للفترة.
    /// Total calculated price for the period.
    /// </summary>
    public decimal TotalPrice { get; set; }

    /// <summary>
    /// العملة التي تم بها الحساب.
    /// Currency used for the calculation.
    /// </summary>
    public string Currency { get; set; } = string.Empty;

    /// <summary>
    /// إجمالي عدد الأيام في الفترة.
    /// Total number of days in the period.
    /// </summary>
    public int TotalDays { get; set; }

    /// <summary>
    /// عدد الأيام التي استخدمت سعراً مخصصاً.
    /// Number of days that used custom pricing.
    /// </summary>
    public int DaysWithCustomPricing { get; set; }

    /// <summary>
    /// عدد الأيام التي استخدمت السعر الأساسي.
    /// Number of days that used base pricing.
    /// </summary>
    public int DaysWithBasePrice { get; set; }

    /// <summary>
    /// متوسط السعر لكل يوم.
    /// Average price per day.
    /// </summary>
    public decimal AveragePerDay { get; set; }

    /// <summary>
    /// تفصيل الأسعار اليومية المستخدمة في الحساب.
    /// Daily price breakdown used for the calculation.
    /// </summary>
    public List<DailyPriceInfo> DailyPrices { get; set; } = new();
}
