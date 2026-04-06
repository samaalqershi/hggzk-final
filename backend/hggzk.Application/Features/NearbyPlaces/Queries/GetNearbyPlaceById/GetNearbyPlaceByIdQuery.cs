using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.NearbyPlaces.DTOs;

namespace YemenBooking.Application.Features.NearbyPlaces.Queries.GetNearbyPlaceById;

/// <summary>
/// Retrieves a single nearby place by identifier.
/// يجلب مكانًا قريبًا واحدًا حسب المعرّف.
/// </summary>
public class GetNearbyPlaceByIdQuery : IRequest<ResultDto<PropertyNearbyPlaceDto>>
{
    public Guid NearbyPlaceId { get; set; }
}
