using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Units;
using YemenBooking.Application.Features.Units.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Units.Queries.GetAvailableUnits;

/// <summary>
/// استعلام جلب المتاح الوحدات.
/// Get Available Units query.
/// </summary>
public class GetAvailableUnitsQuery : IRequest<ResultDto<AvailableUnitsResponse>>
{
    /// <summary>
    /// معرّف العقار.
    /// Property identifier.
    /// </summary>
    public Guid PropertyId { get; set; }
    
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
    
    /// <summary>
    /// عدد الضيوف.
    /// Guests count.
    /// </summary>
    public int GuestsCount { get; set; }

    /// <summary>
    /// معرّف نوع الوحدة.
    /// Unit type identifier.
    /// </summary>
    public Guid? UnitTypeId { get; set; }
}