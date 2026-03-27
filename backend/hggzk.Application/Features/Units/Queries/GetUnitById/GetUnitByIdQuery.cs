using MediatR;
using System;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Units;
using YemenBooking.Application.Features.Units.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Units.Queries.GetUnitById;

/// <summary>
/// استعلام جلب الوحدة by المعرف.
/// Get Unit By Id query.
/// </summary>
public class GetUnitByIdQuery : IRequest<ResultDto<UnitDetailsDto>>
{
    /// <summary>
    /// معرّف الوحدة.
    /// Unit identifier.
    /// </summary>
    public Guid UnitId { get; set; }

    /// <summary>
    /// القيمة الخاصة بـ include الديناميكي الحقول.
    /// Include Dynamic Fields value.
    /// </summary>
    public bool IncludeDynamicFields { get; set; } = true;

} 