using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Favorites.Commands;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Core.Entities;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Favorites.Commands.ToFavorites;

/// <summary>
/// يعالج الطلب ويطبق منطق التنفيذ.
/// Processes the request and applies the execution logic.
/// </summary>
public class AddToFavoritesCommandHandler : IRequestHandler<AddToFavoritesCommand, ResultDto<AddToFavoritesResponse>>
{
    private readonly IUserRepository _userRepository;
    private readonly IPropertyRepository _propertyRepository;
    private readonly IFavoriteRepository _favoriteRepository;
    private readonly IAuditService _auditService;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<AddToFavoritesCommandHandler> _logger;

    /// <summary>
    /// يهيئ مثيلاً جديدًا من المعالج.
    /// Initializes a new handler instance.
    /// </summary>
    public AddToFavoritesCommandHandler(
        IUserRepository userRepository,
        IPropertyRepository propertyRepository,
        IFavoriteRepository favoriteRepository,
        IAuditService auditService,
        ICurrentUserService currentUserService,
        ILogger<AddToFavoritesCommandHandler> logger)
    {
        _userRepository = userRepository;
        _propertyRepository = propertyRepository;
        _favoriteRepository = favoriteRepository;
        _auditService = auditService;
        _currentUserService = currentUserService;
        _logger = logger;
    }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
    public async Task<ResultDto<AddToFavoritesResponse>> Handle(AddToFavoritesCommand request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("إضافة العقار {PropertyId} إلى مفضلة المستخدم {UserId}", request.PropertyId, request.UserId);

        // Validate user
        var user = await _userRepository.GetUserByIdAsync(request.UserId, cancellationToken);
        if (user == null)
            return ResultDto<AddToFavoritesResponse>.Failed("المستخدم غير موجود", "USER_NOT_FOUND");

        // Validate property
        var property = await _propertyRepository.GetByIdAsync(request.PropertyId, cancellationToken);
        if (property == null)
            return ResultDto<AddToFavoritesResponse>.Failed("العقار غير موجود", "PROPERTY_NOT_FOUND");

        // Check if exists (idempotent)
        var exists = await _favoriteRepository.ExistsAsync(request.UserId, request.PropertyId, cancellationToken);
        if (exists)
        {
            return ResultDto<AddToFavoritesResponse>.Ok(new AddToFavoritesResponse
            {
                Success = true,
                Message = "تمت الإضافة بنجاح"
            }, "تمت الإضافة بنجاح");
        }

        // Create favorite
        var favorite = new Favorite
        {
            Id = Guid.NewGuid(),
            UserId = request.UserId,
            PropertyId = request.PropertyId,
            DateAdded = DateTime.UtcNow,
            IsActive = true,
            IsDeleted = false,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        await _favoriteRepository.CreateFavoriteAsync(favorite, cancellationToken);
        await _favoriteRepository.SaveChangesAsync(cancellationToken);

        // Audit
        var performerName = _currentUserService.Username;
        var performerId = _currentUserService.UserId;
        var notes = $"تمت إضافة العقار {request.PropertyId} إلى المفضلة بواسطة {performerName} (ID={performerId})";
        await _auditService.LogAuditAsync(
            entityType: "Favorite",
            entityId: favorite.Id,
            action: AuditAction.CREATE,
            oldValues: null,
            newValues: System.Text.Json.JsonSerializer.Serialize(new { FavoriteAdded = request.PropertyId, UserId = user.Id }),
            performedBy: performerId,
            notes: notes,
            cancellationToken: cancellationToken);

        return ResultDto<AddToFavoritesResponse>.Ok(new AddToFavoritesResponse
        {
            Success = true,
            Message = "تمت الإضافة بنجاح"
        }, "تمت الإضافة بنجاح");
    }
}
