using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.NearbyPlaces.Commands.DeleteProperty;

/// <summary>
/// Deletes a nearby place from a property.
/// يحذف مكانًا قريبًا من عقار.
/// </summary>
public class DeletePropertyNearbyPlaceCommand : IRequest<ResultDto<bool>>
{
    public Guid NearbyPlaceId { get; set; }
}
