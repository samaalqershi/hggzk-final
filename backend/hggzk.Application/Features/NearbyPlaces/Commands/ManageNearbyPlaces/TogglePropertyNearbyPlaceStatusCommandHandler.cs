using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.NearbyPlaces.Commands.ManageNearbyPlaces;

/// <summary>
/// Handles status toggling for property nearby places.
/// يعالج تبديل حالة الأماكن القريبة للعقار.
/// </summary>
public class TogglePropertyNearbyPlaceStatusCommandHandler : IRequestHandler<TogglePropertyNearbyPlaceStatusCommand, ResultDto<bool>>
{
    private readonly IPropertyNearbyPlaceRepository _nearbyPlaceRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<TogglePropertyNearbyPlaceStatusCommandHandler> _logger;

    public TogglePropertyNearbyPlaceStatusCommandHandler(
        IPropertyNearbyPlaceRepository nearbyPlaceRepository,
        ICurrentUserService currentUserService,
        ILogger<TogglePropertyNearbyPlaceStatusCommandHandler> logger)
    {
        _nearbyPlaceRepository = nearbyPlaceRepository;
        _currentUserService = currentUserService;
        _logger = logger;
    }

    public async Task<ResultDto<bool>> Handle(TogglePropertyNearbyPlaceStatusCommand request, CancellationToken cancellationToken)
    {
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
            return ResultDto<bool>.Failed("غير مصرح لك بإدارة هذا المكان القريب");
        }

        entity.IsActive = !entity.IsActive;
        entity.UpdatedAt = DateTime.UtcNow;
        entity.UpdatedBy = _currentUserService.UserId;

        await _nearbyPlaceRepository.UpdateAsync(entity, cancellationToken);
        await _nearbyPlaceRepository.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Toggled nearby place {NearbyPlaceId} status to {IsActive}", entity.Id, entity.IsActive);
        return ResultDto<bool>.Succeeded(true, entity.IsActive ? "تم تفعيل المكان القريب" : "تم تعطيل المكان القريب");
    }
}
