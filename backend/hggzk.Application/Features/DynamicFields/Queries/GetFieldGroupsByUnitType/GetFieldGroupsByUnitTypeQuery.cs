using YemenBooking.Application.Features;
namespace YemenBooking.Application.Features.DynamicFields.Queries.GetFieldGroupsByUnitType;
using YemenBooking.Application.Features.DynamicFields.DTOs;

using MediatR;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;

/// <summary>
/// يجلب مجموعات الحقول لنوع وحدة محدد.
/// Retrieves field groups for a specific unit type.
/// </summary>
public class GetFieldGroupsByUnitTypeQuery : IRequest<List<FieldGroupDto>>
{
    /// <summary>
    /// معرف نوع الوحدة المستهدف.
    /// Target unit type identifier.
    /// </summary>
    public string UnitTypeId { get; set; }
}
