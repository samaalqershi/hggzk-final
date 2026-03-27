using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Scheduling.DTOs;

namespace YemenBooking.Application.Features.Scheduling.Queries.GetSchedule;

/// <summary>
/// استعلام جلب الجدول for period.
/// Get Schedule For Period query.
/// </summary>
public class GetScheduleForPeriodQuery : IRequest<ResultDto<List<DailyScheduleDto>>>
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
    /// القيمة الخاصة بـ include الوحدة.
    /// Include Unit value.
    /// </summary>
    public bool IncludeUnit { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ include الحجز.
    /// Include Booking value.
    /// </summary>
    public bool IncludeBooking { get; set; }
}
