namespace YemenBooking.Application.Features.Scheduling.DTOs;

/// <summary>
/// فئة DailyScheduleDto.
/// DailyScheduleDto class.
/// </summary>
public class DailyScheduleDto
{
    /// <summary>
    /// خاصية Id.
    /// Id property.
    /// </summary>
    public Guid Id { get; set; }
    /// <summary>
    /// خاصية UnitId.
    /// UnitId property.
    /// </summary>
    public Guid UnitId { get; set; }
    /// <summary>
    /// خاصية Date.
    /// Date property.
    /// </summary>
    public DateTime Date { get; set; }
    /// <summary>
    /// خاصية Status.
    /// Status property.
    /// </summary>
    public string Status { get; set; } = string.Empty;
    /// <summary>
    /// خاصية Reason.
    /// Reason property.
    /// </summary>
    public string? Reason { get; set; }
    /// <summary>
    /// خاصية Notes.
    /// Notes property.
    /// </summary>
    public string? Notes { get; set; }
    /// <summary>
    /// خاصية BookingId.
    /// BookingId property.
    /// </summary>
    public Guid? BookingId { get; set; }
    /// <summary>
    /// خاصية PriceAmount.
    /// PriceAmount property.
    /// </summary>
    public decimal? PriceAmount { get; set; }
    /// <summary>
    /// خاصية Currency.
    /// Currency property.
    /// </summary>
    public string? Currency { get; set; }
    /// <summary>
    /// خاصية PriceType.
    /// PriceType property.
    /// </summary>
    public string? PriceType { get; set; }
    /// <summary>
    /// خاصية PricingTier.
    /// PricingTier property.
    /// </summary>
    public string? PricingTier { get; set; }
    /// <summary>
    /// خاصية PercentageChange.
    /// PercentageChange property.
    /// </summary>
    public decimal? PercentageChange { get; set; }
    /// <summary>
    /// خاصية MinPrice.
    /// MinPrice property.
    /// </summary>
    public decimal? MinPrice { get; set; }
    /// <summary>
    /// خاصية MaxPrice.
    /// MaxPrice property.
    /// </summary>
    public decimal? MaxPrice { get; set; }
    /// <summary>
    /// خاصية StartTime.
    /// StartTime property.
    /// </summary>
    public TimeSpan? StartTime { get; set; }
    /// <summary>
    /// خاصية EndTime.
    /// EndTime property.
    /// </summary>
    public TimeSpan? EndTime { get; set; }
    /// <summary>
    /// خاصية CreatedBy.
    /// CreatedBy property.
    /// </summary>
    public string? CreatedBy { get; set; }
    /// <summary>
    /// خاصية ModifiedBy.
    /// ModifiedBy property.
    /// </summary>
    public string? ModifiedBy { get; set; }
    /// <summary>
    /// خاصية CreatedAt.
    /// CreatedAt property.
    /// </summary>
    public DateTime CreatedAt { get; set; }
    /// <summary>
    /// خاصية UpdatedAt.
    /// UpdatedAt property.
    /// </summary>
    public DateTime? UpdatedAt { get; set; }
}
