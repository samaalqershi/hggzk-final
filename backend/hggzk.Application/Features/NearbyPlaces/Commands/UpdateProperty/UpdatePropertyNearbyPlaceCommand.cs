using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.NearbyPlaces.Commands.UpdateProperty;

/// <summary>
/// Updates a nearby place for a property.
/// يحدّث مكانًا قريبًا لعقار.
/// </summary>
public class UpdatePropertyNearbyPlaceCommand : IRequest<ResultDto<bool>>
{
    public Guid NearbyPlaceId { get; set; }
    public string? Name { get; set; }
    public string? NameEn { get; set; }
    public string? Description { get; set; }
    public string? DescriptionEn { get; set; }
    public string? Category { get; set; }
    public string? Icon { get; set; }
    public decimal? Latitude { get; set; }
    public decimal? Longitude { get; set; }
    public int? DistanceInMeters { get; set; }
    public int? WalkingMinutes { get; set; }
    public int? DrivingMinutes { get; set; }
    public int? DisplayOrder { get; set; }
    public bool? IsActive { get; set; }
}
