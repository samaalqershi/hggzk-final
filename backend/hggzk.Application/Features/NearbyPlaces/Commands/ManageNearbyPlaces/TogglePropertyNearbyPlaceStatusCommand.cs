using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.NearbyPlaces.Commands.ManageNearbyPlaces;

/// <summary>
/// Toggles the active state of a property nearby place.
/// يبدّل حالة التفعيل لمكان قريب تابع للعقار.
/// </summary>
public class TogglePropertyNearbyPlaceStatusCommand : IRequest<ResultDto<bool>>
{
    public Guid NearbyPlaceId { get; set; }
}
