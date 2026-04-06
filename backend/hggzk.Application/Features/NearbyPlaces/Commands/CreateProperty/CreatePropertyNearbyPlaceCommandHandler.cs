using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Contracts.Services.Location;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.NearbyPlaces.Commands.CreateProperty;

/// <summary>
/// Handles creation of nearby places for properties.
/// يعالج إنشاء الأماكن القريبة للعقارات.
/// </summary>
public class CreatePropertyNearbyPlaceCommandHandler : IRequestHandler<CreatePropertyNearbyPlaceCommand, ResultDto<Guid>>
{
    private readonly IPropertyNearbyPlaceRepository _nearbyPlaceRepository;
    private readonly IPropertyRepository _propertyRepository;
    private readonly IPropertyTravelMetricsService _propertyTravelMetricsService;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<CreatePropertyNearbyPlaceCommandHandler> _logger;

    public CreatePropertyNearbyPlaceCommandHandler(
        IPropertyNearbyPlaceRepository nearbyPlaceRepository,
        IPropertyRepository propertyRepository,
        IPropertyTravelMetricsService propertyTravelMetricsService,
        ICurrentUserService currentUserService,
        ILogger<CreatePropertyNearbyPlaceCommandHandler> logger)
    {
        _nearbyPlaceRepository = nearbyPlaceRepository;
        _propertyRepository = propertyRepository;
        _propertyTravelMetricsService = propertyTravelMetricsService;
        _currentUserService = currentUserService;
        _logger = logger;
    }

    public async Task<ResultDto<Guid>> Handle(CreatePropertyNearbyPlaceCommand request, CancellationToken cancellationToken)
    {
        if (request.PropertyId == Guid.Empty)
        {
            return ResultDto<Guid>.Failed("معرف العقار مطلوب");
        }

        if (string.IsNullOrWhiteSpace(request.Name))
        {
            return ResultDto<Guid>.Failed("اسم المكان القريب مطلوب");
        }

        if (string.IsNullOrWhiteSpace(request.Category))
        {
            return ResultDto<Guid>.Failed("تصنيف المكان القريب مطلوب");
        }

        if (!request.Latitude.HasValue || !request.Longitude.HasValue)
        {
            return ResultDto<Guid>.Failed("يجب تحديد إحداثيات المكان القريب ليتم احتساب المسافة والمدة تلقائيًا");
        }

        var property = await _propertyRepository.GetPropertyByIdAsync(request.PropertyId, cancellationToken);
        if (property == null)
        {
            return ResultDto<Guid>.Failed("العقار غير موجود");
        }

        var isAdmin = string.Equals(_currentUserService.Role, "Admin", StringComparison.OrdinalIgnoreCase)
            || string.Equals(_currentUserService.AccountRole, "Admin", StringComparison.OrdinalIgnoreCase)
            || (_currentUserService.UserRoles?.Any(role => string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase)) ?? false);

        if (!isAdmin && property.OwnerId != _currentUserService.UserId)
        {
            return ResultDto<Guid>.Failed("غير مصرح لك بإدارة الأماكن القريبة لهذا العقار");
        }

        var exists = await _nearbyPlaceRepository.ExistsAsync(
            place => place.PropertyId == request.PropertyId && place.Name == request.Name.Trim(),
            cancellationToken);

        if (exists)
        {
            return ResultDto<Guid>.Failed("يوجد مكان قريب بنفس الاسم لهذا العقار");
        }

        var metricsResult = await _propertyTravelMetricsService.CalculateAsync(
            property.Latitude,
            property.Longitude,
            request.Latitude.Value,
            request.Longitude.Value,
            cancellationToken);

        if (!metricsResult.Success || metricsResult.Data == null)
        {
            return ResultDto<Guid>.Failed(
                metricsResult.Message ?? "تعذر احتساب المسافة والمدة من Google");
        }

        var entity = new PropertyNearbyPlace
        {
            PropertyId = request.PropertyId,
            Name = request.Name.Trim(),
            NameEn = string.IsNullOrWhiteSpace(request.NameEn) ? null : request.NameEn.Trim(),
            Description = string.IsNullOrWhiteSpace(request.Description) ? null : request.Description.Trim(),
            DescriptionEn = string.IsNullOrWhiteSpace(request.DescriptionEn) ? null : request.DescriptionEn.Trim(),
            Category = request.Category.Trim(),
            Icon = string.IsNullOrWhiteSpace(request.Icon) ? request.Category.Trim() : request.Icon.Trim(),
            Latitude = request.Latitude,
            Longitude = request.Longitude,
            DistanceInMeters = metricsResult.Data.DistanceInMeters,
            WalkingMinutes = metricsResult.Data.WalkingMinutes,
            DrivingMinutes = metricsResult.Data.DrivingMinutes,
            DisplayOrder = request.DisplayOrder,
            IsActive = request.IsActive,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
            CreatedBy = _currentUserService.UserId,
            UpdatedBy = _currentUserService.UserId,
        };

        await _nearbyPlaceRepository.CreateAsync(entity, cancellationToken);
        await _nearbyPlaceRepository.SaveChangesAsync(cancellationToken);

        _logger.LogInformation(
            "Created nearby place {NearbyPlaceId} for property {PropertyId} with Google-calculated distance {DistanceInMeters}m",
            entity.Id,
            entity.PropertyId,
            entity.DistanceInMeters);
        return ResultDto<Guid>.Succeeded(entity.Id, "تم إنشاء المكان القريب واحتساب المسافة والمدة تلقائيًا");
    }
}
