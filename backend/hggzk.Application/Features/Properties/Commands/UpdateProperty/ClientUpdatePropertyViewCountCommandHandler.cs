using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using System.Text.Json;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.AuditLog.Services;

namespace YemenBooking.Application.Features.Properties.Commands.UpdateProperty;

/// <summary>
/// يعالج زيادة عدد مشاهدات العقار من جهة العميل.
/// Handles incrementing a property's view count from the client side.
/// </summary>
public class ClientUpdatePropertyViewCountCommandHandler : IRequestHandler<ClientUpdatePropertyViewCountCommand, ResultDto<bool>>
{
    private readonly IPropertyRepository _propertyRepository;
    private readonly IAuditService _auditService;
    private readonly ICurrentUserService _currentUserService;

    /// <summary>
    /// يهيّئ مثيلاً جديداً من [ClientUpdatePropertyViewCountCommandHandler].
    /// Initializes a new instance of [ClientUpdatePropertyViewCountCommandHandler].
    /// </summary>
    public ClientUpdatePropertyViewCountCommandHandler(
        IPropertyRepository propertyRepository,
        IAuditService auditService,
        ICurrentUserService currentUserService)
    {
        _propertyRepository = propertyRepository;
        _auditService = auditService;
        _currentUserService = currentUserService;
    }
    /// <summary>
    /// يعالج زيادة عدد مشاهدات العقار ويسجل الزيادة.
    /// Handles incrementing the property view count and records the increment.
    /// </summary>
    public async Task<ResultDto<bool>> Handle(ClientUpdatePropertyViewCountCommand request, CancellationToken cancellationToken)
    {
        try
        {
            // التحقق من وجود العقار
            // Check if property exists
            var property = await _propertyRepository.GetPropertyByIdAsync(request.PropertyId, cancellationToken);

            if (property == null)
            {
                return ResultDto<bool>.Failed("العقار غير موجود", "PROPERTY_NOT_FOUND");
            }

            // زيادة عدد المشاهدات
            // Increment view count
            property.ViewCount++;
            property.UpdatedAt = DateTime.UtcNow;

            // تحديث العقار
            // Update property
            await _propertyRepository.UpdatePropertyAsync(property, cancellationToken);
            await _propertyRepository.SaveChangesAsync(cancellationToken);

            // تدقيق يدوي: زيادة عدد المشاهدات
            var performerName = _currentUserService.Username;
            var performerId = _currentUserService.UserId;
            var notes = $"تم تحديث عدد المشاهدات للعقار {request.PropertyId} بواسطة {performerName} (ID={performerId})";
            await _auditService.LogAuditAsync(
                entityType: "Property",
                entityId: request.PropertyId,
                action: AuditAction.UPDATE,
                oldValues: null,
                newValues: JsonSerializer.Serialize(new { ViewCount = property.ViewCount }),
                performedBy: performerId,
                notes: notes,
                cancellationToken: cancellationToken);

            return ResultDto<bool>.Ok(true, "تم تحديث عدد المشاهدات بنجاح");
        }
        catch (Exception ex)
        {
            return ResultDto<bool>.Failed($"حدث خطأ أثناء تحديث عدد المشاهدات: {ex.Message}", "UPDATE_VIEW_COUNT_ERROR");
        }
    }
}
