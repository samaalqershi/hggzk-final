using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.NearbyPlaces.Commands.DeleteProperty;

/// <summary>
/// Handles deletion of property nearby places.
/// يعالج حذف الأماكن القريبة للعقار.
/// </summary>
public class DeletePropertyNearbyPlaceCommandHandler : IRequestHandler<DeletePropertyNearbyPlaceCommand, ResultDto<bool>>
{
    private readonly IPropertyNearbyPlaceRepository _nearbyPlaceRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<DeletePropertyNearbyPlaceCommandHandler> _logger;

    public DeletePropertyNearbyPlaceCommandHandler(
        IPropertyNearbyPlaceRepository nearbyPlaceRepository,
        ICurrentUserService currentUserService,
        ILogger<DeletePropertyNearbyPlaceCommandHandler> logger)
    {
        _nearbyPlaceRepository = nearbyPlaceRepository;
        _currentUserService = currentUserService;
        _logger = logger;
    }

    public async Task<ResultDto<bool>> Handle(DeletePropertyNearbyPlaceCommand request, CancellationToken cancellationToken)
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
            return ResultDto<bool>.Failed("غير مصرح لك بحذف هذا المكان القريب");
        }

        await _nearbyPlaceRepository.DeleteAsync(request.NearbyPlaceId, cancellationToken);
        await _nearbyPlaceRepository.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Deleted nearby place {NearbyPlaceId}", request.NearbyPlaceId);
        return ResultDto<bool>.Succeeded(true, "تم حذف المكان القريب بنجاح");
    }
}
