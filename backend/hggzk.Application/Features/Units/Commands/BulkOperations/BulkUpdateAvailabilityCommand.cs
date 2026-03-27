using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Units.Commands.BulkOperations;

/// <summary>
/// أمر معالجة مجمعة لـ تحديث التوفر.
/// Bulk Update Availability command.
/// </summary>
public class BulkUpdateAvailabilityCommand : IRequest<ResultDto>
{
    /// <summary>
    /// معرّف الوحدة.
    /// Unit identifier.
    /// </summary>
    public Guid UnitId { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ periods.
    /// Periods value.
    /// </summary>
    public List<AvailabilityPeriodDto> Periods { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ overwrite existing.
    /// Overwrite Existing value.
    /// </summary>
    public bool OverwriteExisting { get; set; }
}

/// <summary>
/// أمر معالجة مجمعة لـ تحديث التوفر.
/// Bulk Update Availability command.
/// </summary>
public class AvailabilityPeriodDto
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
    public string? Reason { get; set; }
    /// <summary>
    /// الملاحظات.
    /// Notes.
    /// </summary>
    public string? Notes { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ overwrite existing.
    /// Overwrite Existing value.
    /// </summary>
    public bool OverwriteExisting { get; set; }
}
