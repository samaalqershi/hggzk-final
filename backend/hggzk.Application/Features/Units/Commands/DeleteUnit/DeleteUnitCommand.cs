using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Units.Commands.DeleteUnit;

/// <summary>
/// أمر حذف الوحدة.
/// Delete Unit command.
/// </summary>
public class DeleteUnitCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف الوحدة.
    /// Unit identifier.
    /// </summary>
    public Guid UnitId { get; set; }
} 