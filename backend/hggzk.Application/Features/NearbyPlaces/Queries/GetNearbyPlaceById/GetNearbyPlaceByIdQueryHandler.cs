using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.NearbyPlaces.DTOs;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.NearbyPlaces.Queries.GetNearbyPlaceById;

/// <summary>
/// Retrieves a single property nearby place.
/// يجلب مكانًا قريبًا واحدًا للعقار.
/// </summary>
public class GetNearbyPlaceByIdQueryHandler : IRequestHandler<GetNearbyPlaceByIdQuery, ResultDto<PropertyNearbyPlaceDto>>
{
    private readonly IPropertyNearbyPlaceRepository _nearbyPlaceRepository;

    public GetNearbyPlaceByIdQueryHandler(IPropertyNearbyPlaceRepository nearbyPlaceRepository)
    {
        _nearbyPlaceRepository = nearbyPlaceRepository;
    }

    public async Task<ResultDto<PropertyNearbyPlaceDto>> Handle(GetNearbyPlaceByIdQuery request, CancellationToken cancellationToken)
    {
        var entity = await _nearbyPlaceRepository.GetByIdAsync(request.NearbyPlaceId, cancellationToken);
        if (entity == null)
        {
            return ResultDto<PropertyNearbyPlaceDto>.Failed("المكان القريب غير موجود");
        }

        var dto = new PropertyNearbyPlaceDto
        {
            Id = entity.Id,
            PropertyId = entity.PropertyId,
            PropertyName = entity.Property?.Name ?? string.Empty,
            PropertyNameEn = entity.Property?.NameEn,
            Name = entity.Name,
            NameEn = entity.NameEn,
            Description = entity.Description,
            DescriptionEn = entity.DescriptionEn,
            Category = entity.Category,
            Icon = entity.Icon,
            Latitude = entity.Latitude,
            Longitude = entity.Longitude,
            DistanceInMeters = entity.DistanceInMeters,
            WalkingMinutes = entity.WalkingMinutes,
            DrivingMinutes = entity.DrivingMinutes,
            DisplayOrder = entity.DisplayOrder,
            IsActive = entity.IsActive,
            CreatedAt = entity.CreatedAt,
            UpdatedAt = entity.UpdatedAt
        };

        return ResultDto<PropertyNearbyPlaceDto>.Succeeded(dto, "تم جلب المكان القريب بنجاح");
    }
}
