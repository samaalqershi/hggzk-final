using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Units.Queries.GetUnitAvailableDays;

/// <summary>
/// استعلام جلب الوحدة المتاح days.
/// Get Unit Available Days query.
/// </summary>
public class GetUnitAvailableDaysQuery : IRequest<ResultDto<UnitAvailableDaysResponseDto>>
{
    /// <summary>
    /// معرّف الوحدة.
    /// Unit identifier.
    /// </summary>
    public Guid UnitId { get; set; }

    /// <summary>
    /// القيمة الخاصة بـ months.
    /// Months value.
    /// </summary>
    public int Months { get; set; } = 3;

    /// <summary>
    /// معرّف exclude الحجز.
    /// Exclude Booking identifier.
    /// </summary>
    public Guid? ExcludeBookingId { get; set; }
}

/// <summary>
/// استعلام جلب الوحدة المتاح days.
/// Get Unit Available Days query.
/// </summary>
public class UnitAvailableDaysResponseDto
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
    /// القيمة الخاصة بـ المتاح dates.
    /// Available Dates value.
    /// </summary>
    public List<DateTime> AvailableDates { get; set; } = new();

    /// <summary>
    /// القيمة الخاصة بـ unpriced dates.
    /// Unpriced Dates value.
    /// </summary>
    public List<DateTime> UnpricedDates { get; set; } = new();
}
