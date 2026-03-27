namespace YemenBooking.Application.Contracts.Services.Scheduling;

/// <summary>
/// تمثيل السعر اليومي المستخدم في تفاصيل التسعير.
/// Daily price record used in pricing breakdowns.
/// </summary>
public class DailyPriceInfo
{
    /// <summary>
    /// التاريخ الذي ينطبق عليه السعر.
    /// Date to which the price applies.
    /// </summary>
    public DateTime Date { get; set; }

    /// <summary>
    /// قيمة السعر في ذلك اليوم.
    /// Price amount for that day.
    /// </summary>
    public decimal Price { get; set; }

    /// <summary>
    /// نوع السعر إن وجد.
    /// Price type when available.
    /// </summary>
    public string? PriceType { get; set; }

    /// <summary>
    /// يحدد ما إذا كان السعر مخصصاً بدلاً من السعر الأساسي.
    /// Indicates whether the price is custom instead of base pricing.
    /// </summary>
    public bool IsCustomPrice { get; set; }
}
