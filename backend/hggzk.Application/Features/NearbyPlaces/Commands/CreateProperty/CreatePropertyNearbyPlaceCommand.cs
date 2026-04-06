using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.NearbyPlaces.Commands.CreateProperty;

/// <summary>
/// Creates a nearby place for a property.
/// ينشئ مكانًا قريبًا لعقار.
/// </summary>
public class CreatePropertyNearbyPlaceCommand : IRequest<ResultDto<Guid>>
{
    public Guid PropertyId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? NameEn { get; set; }
    public string? Description { get; set; }
    public string? DescriptionEn { get; set; }
    public string Category { get; set; } = string.Empty;
    public string Icon { get; set; } = string.Empty;
    public decimal? Latitude { get; set; }
    public decimal? Longitude { get; set; }
    public int? DistanceInMeters { get; set; }
    public int? WalkingMinutes { get; set; }
    public int? DrivingMinutes { get; set; }
    public int DisplayOrder { get; set; }
    public bool IsActive { get; set; } = true;
}
