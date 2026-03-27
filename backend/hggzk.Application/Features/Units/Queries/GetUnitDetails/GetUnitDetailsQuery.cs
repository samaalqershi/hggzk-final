using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Units;
using YemenBooking.Application.Features.Units.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Units.Queries.GetUnitDetails;

/// <summary>
/// استعلام جلب الوحدة التفاصيل.
/// Get Unit Details query.
/// </summary>
public class GetUnitDetailsQuery : IRequest<ResultDto<UnitDetailsDto>>
{
    /// <summary>
    /// معرّف الوحدة.
    /// Unit identifier.
    /// </summary>
    public Guid UnitId { get; set; }
    
    /// <summary>
    /// تاريخ الوصول.
    /// Check-in date.
    /// </summary>
    public DateTime? CheckIn { get; set; }
    
    /// <summary>
    /// تاريخ المغادرة.
    /// Check-out date.
    /// </summary>
    public DateTime? CheckOut { get; set; }
}