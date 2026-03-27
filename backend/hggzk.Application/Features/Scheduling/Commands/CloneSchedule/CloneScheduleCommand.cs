using MediatR;
using System;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Scheduling.Commands.CloneSchedule;

/// <summary>
/// أمر نسخ الجدول.
/// Clone Schedule command.
/// </summary>
public class CloneScheduleCommand : IRequest<ResultDto<int>>
{
    /// <summary>
    /// معرّف الوحدة.
    /// Unit identifier.
    /// </summary>
    public Guid UnitId { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ source البداية date.
    /// Source Start Date value.
    /// </summary>
    public DateTime SourceStartDate { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ source النهاية date.
    /// Source End Date value.
    /// </summary>
    public DateTime SourceEndDate { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ target البداية date.
    /// Target Start Date value.
    /// </summary>
    public DateTime TargetStartDate { get; set; }
    /// <summary>
    /// القيمة الخاصة بـ overwrite.
    /// Overwrite value.
    /// </summary>
    public bool Overwrite { get; set; } = false;
}
