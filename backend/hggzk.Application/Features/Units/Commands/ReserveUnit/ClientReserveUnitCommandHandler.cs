using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Units;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces;
using System.Text.Json;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Units.Commands.ReserveUnit;

/// <summary>
/// يعالج client حجز الوحدة ويعيد النتيجة المطلوبة.
/// Processes the Client Reserve Unit request and returns the requested result.
/// </summary>
public class ClientReserveUnitCommandHandler : IRequestHandler<ClientReserveUnitCommand, ResultDto<ClientUnitReservationResponse>>
{
    private readonly IUnitRepository _unitRepository;
    private readonly ILogger<ClientReserveUnitCommandHandler> _logger;
    private readonly IAuditService _auditService;
    private readonly ICurrentUserService _currentUserService;

    /// <summary>
    /// ينشئ مثيلاً جديداً من ClientReserveUnitCommandHandler.
    /// Initializes a new instance of ClientReserveUnitCommandHandler.
    /// </summary>
    /// <param name="unitRepository">مستودع الوحدة / unit repository.</param>
    /// <param name="logger">مسجل الأحداث / Logger.</param>
    /// <param name="auditService">خدمة التدقيق / Audit service.</param>
    /// <param name="currentUserService">خدمة المستخدم الحالي / Current user service.</param>
    public ClientReserveUnitCommandHandler(
        IUnitRepository unitRepository,
        ILogger<ClientReserveUnitCommandHandler> logger,
        IAuditService auditService,
        ICurrentUserService currentUserService)
    {
        _unitRepository = unitRepository;
        _logger = logger;
        _auditService = auditService;
        _currentUserService = currentUserService;
    }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
    public async Task<ResultDto<ClientUnitReservationResponse>> Handle(ClientReserveUnitCommand request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("حجز مؤقت للوحدة {UnitId} من قبل المستخدم {UserId}", request.UnitId, request.UserId);

        // Basic validation & availability checks يمكن توسعتها لاحقاً
        var unit = await _unitRepository.GetByIdAsync(request.UnitId, cancellationToken);
        if (unit == null)
            return ResultDto<ClientUnitReservationResponse>.Failed("الوحدة غير موجودة");

        // TODO: Check overlaps with existing bookings

        // إنشاء الحجز المؤقت (سيتم حفظه في جدول خاص أو في الذاكرة حسب التصميم)
        var reservation = new ClientUnitReservationResponse
        {
            ReservationId = Guid.NewGuid(),
            UnitId = unit.Id,
            UnitName = unit.Name,
            ExpiresAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(DateTime.UtcNow.AddMinutes(request.ReservationDurationMinutes)),
            TotalPrice = 0, // TODO: حساب السعر الفعلي
            Currency = "YER",
            ReservationToken = Guid.NewGuid().ToString("N"),
            CreatedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(DateTime.UtcNow)
        };

        // سجل تدقيق: حجز مؤقت
        var performerName = _currentUserService.Username;
        var performerId = _currentUserService.UserId;
        var notes = $"تم إنشاء حجز مؤقت للوحدة {unit.Id} بواسطة {performerName} (ID={performerId})";
        await _auditService.LogAuditAsync(
            entityType: "Reservation",
            entityId: reservation.ReservationId,
            action: AuditAction.CREATE,
            oldValues: null,
            newValues: JsonSerializer.Serialize(new { reservation.ReservationId, unit.Id, request.UserId, reservation.ExpiresAt }),
            performedBy: performerId,
            notes: notes,
            cancellationToken: cancellationToken);

        return ResultDto<ClientUnitReservationResponse>.Ok(reservation, "تم إنشاء الحجز المؤقت");
    }
}
