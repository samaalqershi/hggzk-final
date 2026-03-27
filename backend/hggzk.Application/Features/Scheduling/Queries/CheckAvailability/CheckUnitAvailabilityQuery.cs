using MediatR;
using YemenBooking.Application.Common.Models;
using System.Text.Json.Serialization;

namespace YemenBooking.Application.Features.Scheduling.Queries.CheckAvailability;

/// <summary>
/// استعلام التحقق من الوحدة التوفر.
/// Check Unit Availability query.
/// </summary>
public class CheckUnitAvailabilityQuery : IRequest<ResultDto<AvailabilityCheckResultDto>>
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
    [JsonPropertyName("checkInDate")]
    public DateTime StartDate { get; set; }

    /// <summary>
    /// تاريخ النهاية.
    /// End date.
    /// </summary>
    [JsonPropertyName("checkOutDate")]
    public DateTime EndDate { get; set; }

    /// <summary>
    /// معرّف exclude الحجز.
    /// Exclude Booking identifier.
    /// </summary>
    [JsonPropertyName("excludeBookingId")]
    public Guid? ExcludeBookingId { get; set; }
}

/// <summary>
/// استعلام التحقق من الوحدة التوفر.
/// Check Unit Availability query.
/// </summary>
public class AvailabilityCheckResultDto
{
    /// <summary>
    /// يشير إلى ما إذا كان المتاح.
    /// Indicates whether available.
    /// </summary>
    public bool IsAvailable { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ total days.
    /// Total Days value.
    /// </summary>
    public int TotalDays { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ المتاح days.
    /// Available Days value.
    /// </summary>
    public int AvailableDays { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ unavailable days.
    /// Unavailable Days value.
    /// </summary>
    public int UnavailableDays { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ unavailable dates.
    /// Unavailable Dates value.
    /// </summary>
    public List<DateTime> UnavailableDates { get; set; } = new();
    /// <summary>
    /// القيمة الخاصة بـ message.
    /// Message value.
    /// </summary>
    public string? Message { get; set; }

    /// <summary>
    /// القيمة الخاصة بـ total السعر.
    /// Total Price value.
    /// </summary>
    public decimal? TotalPrice { get; set; }

    /// <summary>
    /// القيمة الخاصة بـ السعر per night.
    /// Price Per Night value.
    /// </summary>
    public decimal? PricePerNight { get; set; }

    /// <summary>
    /// العملة.
    /// Currency.
    /// </summary>
    public string? Currency { get; set; }
}
