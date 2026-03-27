using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Scheduling.Commands.SetAvailability;

/// <summary>
/// أمر تعيين التوفر for period.
/// Set Availability For Period command.
/// </summary>
public class SetAvailabilityForPeriodCommand : IRequest<ResultDto<int>>
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
    /// الحالة.
    /// Status.
    /// </summary>
    public string Status { get; set; } = string.Empty;
    /// <summary>
    /// السبب.
    /// Reason.
    /// </summary>
    public string? Reason { get; set; }
    /// <summary>
    /// الملاحظات.
    /// Notes.
    /// </summary>
    public string? Notes { get; set; }
    /// <summary>
    /// معرّف الحجز.
    /// Booking identifier.
    /// </summary>
    public Guid? BookingId { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ overwrite existing.
    /// Overwrite Existing value.
    /// </summary>
    public bool OverwriteExisting { get; set; }
}
