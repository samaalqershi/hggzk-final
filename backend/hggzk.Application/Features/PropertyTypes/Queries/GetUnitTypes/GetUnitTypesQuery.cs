using MediatR;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Units.DTOs;

namespace YemenBooking.Application.Features.PropertyTypes.Queries.GetUnitTypes;

/// <summary>
/// يجلب أنواع الوحدات لنوع عقار محدد.
/// Retrieves unit types for a specific property type.
/// </summary>
public class GetUnitTypesQuery : IRequest<ResultDto<List<UnitTypeDto>>>
{
    /// <summary>
    /// معرّف نوع العقار.
    /// Property type identifier.
    /// </summary>
    public Guid PropertyTypeId { get; set; }
}
