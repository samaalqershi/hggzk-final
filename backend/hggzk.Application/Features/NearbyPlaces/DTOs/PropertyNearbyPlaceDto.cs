namespace YemenBooking.Application.Features.NearbyPlaces.DTOs;

/// <summary>
/// Represents a nearby place associated with a property.
/// يمثل مكانًا قريبًا مرتبطًا بعقار.
/// </summary>
public class PropertyNearbyPlaceDto
{
    public Guid Id { get; set; }
    public Guid PropertyId { get; set; }
    public string PropertyName { get; set; } = string.Empty;
    public string? PropertyNameEn { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? NameEn { get; set; }
    public string? Description { get; set; }
    public string? DescriptionEn { get; set; }
    public string Category { get; set; } = string.Empty;
    public string Icon { get; set; } = string.Empty;
    public decimal? Latitude { get; set; }
    public decimal? Longitude { get; set; }
    public int DistanceInMeters { get; set; }
    public int? WalkingMinutes { get; set; }
    public int? DrivingMinutes { get; set; }
    public int DisplayOrder { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
