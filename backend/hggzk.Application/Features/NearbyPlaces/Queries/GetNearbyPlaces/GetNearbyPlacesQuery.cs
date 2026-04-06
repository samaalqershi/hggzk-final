using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.NearbyPlaces.DTOs;

namespace YemenBooking.Application.Features.NearbyPlaces.Queries.GetNearbyPlaces;

/// <summary>
/// Retrieves nearby places with optional property and search filtering.
/// يجلب الأماكن القريبة مع دعم فلترة العقار والبحث.
/// </summary>
public class GetNearbyPlacesQuery : IRequest<ResultDto<List<PropertyNearbyPlaceDto>>>
{
    public Guid? PropertyId { get; set; }
    public string? SearchTerm { get; set; }
    public bool? IsActive { get; set; }
}
