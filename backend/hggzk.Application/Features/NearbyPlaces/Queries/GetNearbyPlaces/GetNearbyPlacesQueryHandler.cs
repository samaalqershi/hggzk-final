using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.NearbyPlaces.DTOs;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.NearbyPlaces.Queries.GetNearbyPlaces;

/// <summary>
/// Retrieves nearby places for admin or property detail views.
/// يجلب الأماكن القريبة لواجهات الإدارة أو تفاصيل العقار.
/// </summary>
public class GetNearbyPlacesQueryHandler : IRequestHandler<GetNearbyPlacesQuery, ResultDto<List<PropertyNearbyPlaceDto>>>
{
    private readonly IPropertyNearbyPlaceRepository _nearbyPlaceRepository;
    private readonly ILogger<GetNearbyPlacesQueryHandler> _logger;

    public GetNearbyPlacesQueryHandler(
        IPropertyNearbyPlaceRepository nearbyPlaceRepository,
        ILogger<GetNearbyPlacesQueryHandler> logger)
    {
        _nearbyPlaceRepository = nearbyPlaceRepository;
        _logger = logger;
    }

    public async Task<ResultDto<List<PropertyNearbyPlaceDto>>> Handle(GetNearbyPlacesQuery request, CancellationToken cancellationToken)
    {
        var entities = await _nearbyPlaceRepository.SearchAsync(
            request.PropertyId,
            request.SearchTerm,
            request.IsActive,
            cancellationToken);

        var dtos = entities.Select(place => new PropertyNearbyPlaceDto
        {
            Id = place.Id,
            PropertyId = place.PropertyId,
            PropertyName = place.Property?.Name ?? string.Empty,
            PropertyNameEn = place.Property?.NameEn,
            Name = place.Name,
            NameEn = place.NameEn,
            Description = place.Description,
            DescriptionEn = place.DescriptionEn,
            Category = place.Category,
            Icon = place.Icon,
            Latitude = place.Latitude,
            Longitude = place.Longitude,
            DistanceInMeters = place.DistanceInMeters,
            WalkingMinutes = place.WalkingMinutes,
            DrivingMinutes = place.DrivingMinutes,
            DisplayOrder = place.DisplayOrder,
            IsActive = place.IsActive,
            CreatedAt = place.CreatedAt,
            UpdatedAt = place.UpdatedAt
        }).ToList();

        _logger.LogInformation("Loaded {Count} nearby places", dtos.Count);
        return ResultDto<List<PropertyNearbyPlaceDto>>.Succeeded(dtos, "تم جلب الأماكن القريبة بنجاح");
    }
}
