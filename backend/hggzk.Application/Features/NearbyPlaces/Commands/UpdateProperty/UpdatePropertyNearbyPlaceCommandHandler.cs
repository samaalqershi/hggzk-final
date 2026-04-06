using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Contracts.Services.Location;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.NearbyPlaces.Commands.UpdateProperty;

/// <summary>
/// Handles updates for nearby places linked to properties.
/// يعالج تحديثات الأماكن القريبة المرتبطة بالعقارات.
/// </summary>
public class UpdatePropertyNearbyPlaceCommandHandler : IRequestHandler<UpdatePropertyNearbyPlaceCommand, ResultDto<bool>>
{
    private readonly IPropertyNearbyPlaceRepository _nearbyPlaceRepository;
    private readonly IPropertyRepository _propertyRepository;
    private readonly IPropertyTravelMetricsService _propertyTravelMetricsService;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<UpdatePropertyNearbyPlaceCommandHandler> _logger;

    public UpdatePropertyNearbyPlaceCommandHandler(
        IPropertyNearbyPlaceRepository nearbyPlaceRepository,
        IPropertyRepository propertyRepository,
        IPropertyTravelMetricsService propertyTravelMetricsService,
        ICurrentUserService currentUserService,
        ILogger<UpdatePropertyNearbyPlaceCommandHandler> logger)
    {
        _nearbyPlaceRepository = nearbyPlaceRepository;
        _propertyRepository = propertyRepository;
        _propertyTravelMetricsService = propertyTravelMetricsService;
        _currentUserService = currentUserService;
        _logger = logger;
    }

    public async Task<ResultDto<bool>> Handle(UpdatePropertyNearbyPlaceCommand request, CancellationToken cancellationToken)
    {
        if (request.NearbyPlaceId == Guid.Empty)
        {
            return ResultDto<bool>.Failed("معرف المكان القريب مطلوب");
        }

        var entity = await _nearbyPlaceRepository.GetByIdAsync(request.NearbyPlaceId, cancellationToken);
        if (entity == null)
        {
            return ResultDto<bool>.Failed("المكان القريب غير موجود");
        }

        var isAdmin = string.Equals(_currentUserService.Role, "Admin", StringComparison.OrdinalIgnoreCase)
            || string.Equals(_currentUserService.AccountRole, "Admin", StringComparison.OrdinalIgnoreCase)
            || (_currentUserService.UserRoles?.Any(role => string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase)) ?? false);

        if (!isAdmin && entity.Property.OwnerId != _currentUserService.UserId)
        {
            return ResultDto<bool>.Failed("غير مصرح لك بتحديث هذا المكان القريب");
        }

        if (request.Name != null)
        {
            entity.Name = request.Name.Trim();
        }

        if (request.NameEn != null)
        {
            entity.NameEn = string.IsNullOrWhiteSpace(request.NameEn) ? null : request.NameEn.Trim();
        }

        if (request.Description != null)
        {
            entity.Description = string.IsNullOrWhiteSpace(request.Description) ? null : request.Description.Trim();
        }

        if (request.DescriptionEn != null)
        {
            entity.DescriptionEn = string.IsNullOrWhiteSpace(request.DescriptionEn) ? null : request.DescriptionEn.Trim();
        }

        if (request.Category != null)
        {
            entity.Category = request.Category.Trim();
        }

        if (request.Icon != null)
        {
            entity.Icon = string.IsNullOrWhiteSpace(request.Icon) ? entity.Icon : request.Icon.Trim();
        }

        var targetLatitude = request.Latitude ?? entity.Latitude;
        var targetLongitude = request.Longitude ?? entity.Longitude;
        var shouldRecalculateMetrics =
            request.Latitude.HasValue ||
            request.Longitude.HasValue ||
            request.DistanceInMeters.HasValue ||
            request.WalkingMinutes.HasValue ||
            request.DrivingMinutes.HasValue;

        if (request.Latitude.HasValue)
        {
            entity.Latitude = request.Latitude.Value;
        }

        if (request.Longitude.HasValue)
        {
            entity.Longitude = request.Longitude.Value;
        }

        if (shouldRecalculateMetrics)
        {
            if (!targetLatitude.HasValue || !targetLongitude.HasValue)
            {
                return ResultDto<bool>.Failed("يجب توفر إحداثيات المكان القريب ليتم إعادة احتساب المسافة والمدة");
            }

            var property = await _propertyRepository.GetPropertyByIdAsync(entity.PropertyId, cancellationToken);
            if (property == null)
            {
                return ResultDto<bool>.Failed("العقار المرتبط بالمكان القريب غير موجود");
            }

            var metricsResult = await _propertyTravelMetricsService.CalculateAsync(
                property.Latitude,
                property.Longitude,
                targetLatitude.Value,
                targetLongitude.Value,
                cancellationToken);

            if (!metricsResult.Success || metricsResult.Data == null)
            {
                return ResultDto<bool>.Failed(
                    metricsResult.Message ?? "تعذر احتساب المسافة والمدة من Google");
            }

            entity.DistanceInMeters = metricsResult.Data.DistanceInMeters;
            entity.WalkingMinutes = metricsResult.Data.WalkingMinutes;
            entity.DrivingMinutes = metricsResult.Data.DrivingMinutes;
        }

        if (request.DisplayOrder.HasValue)
        {
            entity.DisplayOrder = request.DisplayOrder.Value;
        }

        if (request.IsActive.HasValue)
        {
            entity.IsActive = request.IsActive.Value;
        }

        entity.UpdatedAt = DateTime.UtcNow;
        entity.UpdatedBy = _currentUserService.UserId;

        await _nearbyPlaceRepository.UpdateAsync(entity, cancellationToken);
        await _nearbyPlaceRepository.SaveChangesAsync(cancellationToken);

        _logger.LogInformation(
            "Updated nearby place {NearbyPlaceId} with Google-calculated distance {DistanceInMeters}m",
            entity.Id,
            entity.DistanceInMeters);
        return ResultDto<bool>.Succeeded(true, "تم تحديث المكان القريب واحتساب المسافة والمدة تلقائيًا");
    }
}
