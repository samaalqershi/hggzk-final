using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Bookings;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Infrastructure.Services;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;
using YemenBooking.Core.Interfaces;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.AuditLog.Services;

namespace YemenBooking.Application.Features.Bookings.Commands.CheckInOut;

/// <summary>
/// معالج أمر تسجيل الوصول
/// Check-in booking command handler
/// </summary>
public class CheckInBookingCommandHandler : IRequestHandler<CheckInBookingCommand, ResultDto<bool>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ICurrentUserService _currentUserService;
    private readonly IValidationService _validationService;
    private readonly IAuditService _auditService;
    private readonly ILogger<CheckInBookingCommandHandler> _logger;

    public CheckInBookingCommandHandler(
        IUnitOfWork unitOfWork,
        ICurrentUserService currentUserService,
        IValidationService validationService,
        IAuditService auditService,
        ILogger<CheckInBookingCommandHandler> logger)
    {
        _unitOfWork = unitOfWork;
        _currentUserService = currentUserService;
        _validationService = validationService;
        _auditService = auditService;
        _logger = logger;
    }

    public async Task<ResultDto<bool>> Handle(CheckInBookingCommand request, CancellationToken cancellationToken)
    {
        try
        {
            // Validate command
            var validation = await _validationService.ValidateAsync(request, cancellationToken);
            if (!validation.IsValid)
            {
                return ResultDto<bool>.Failed(validation.Errors.Select(e => e.Message).ToArray());
            }

            var booking = await _unitOfWork.Repository<Booking>().GetByIdAsync(request.BookingId, cancellationToken);
            if (booking == null)
            {
                return ResultDto<bool>.Failed("الحجز غير موجود");
            }

            // التحقق من الصلاحيات - Admin/Owner/Staff
            var authResult = await ValidateAuthorizationAsync(booking, cancellationToken);
            if (!authResult.IsSuccess)
            {
                return authResult;
            }

            if (booking.Status != BookingStatus.Confirmed)
            {
                return ResultDto<bool>.Failed("لا يمكن تسجيل الوصول إلا للحجز المؤكد");
            }

            // التحقق من تاريخ تنفيذ العملية باستخدام توقيت المستخدم
            var userToday = (await _currentUserService.ConvertFromUtcToUserLocalAsync(DateTime.UtcNow)).Date;
            var checkInLocal = (await _currentUserService.ConvertFromUtcToUserLocalAsync(booking.CheckIn)).Date;
            var checkOutLocal = (await _currentUserService.ConvertFromUtcToUserLocalAsync(booking.CheckOut)).Date;
            if (userToday < checkInLocal)
            {
                return ResultDto<bool>.Failed("لا يمكن تسجيل الوصول قبل تاريخ الوصول المحدد");
            }
            if (userToday > checkOutLocal)
            {
                return ResultDto<bool>.Failed("لا يمكن تسجيل الوصول لحجز منتهي");
            }

            booking.Status = BookingStatus.CheckedIn;
            booking.ActualCheckInDate = await _currentUserService.ConvertFromUserLocalToUtcAsync(DateTime.UtcNow);
            booking.UpdatedAt = DateTime.UtcNow;

            await _unitOfWork.Repository<Booking>().UpdateAsync(booking, cancellationToken);
            await _unitOfWork.SaveChangesAsync(cancellationToken);

            await _auditService.LogAuditAsync(
                entityType: nameof(Booking),
                entityId: booking.Id,
                action: AuditAction.UPDATE,
                oldValues: null,
                newValues: System.Text.Json.JsonSerializer.Serialize(new { Status = booking.Status.ToString(), ActualCheckInDate = booking.ActualCheckInDate }),
                performedBy: _currentUserService.UserId,
                notes: $"تم تسجيل الوصول بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})",
                cancellationToken: cancellationToken);

            return ResultDto<bool>.Succeeded(true, "تم تسجيل الوصول بنجاح");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء تسجيل الوصول للحجز {BookingId}", request.BookingId);
            return ResultDto<bool>.Failed("حدث خطأ أثناء تسجيل الوصول");
        }
    }

    /// <summary>
    /// التحقق من صلاحيات المستخدم للقيام بتسجيل الوصول
    /// Authorization validation for check-in operation
    /// </summary>
    private async Task<ResultDto<bool>> ValidateAuthorizationAsync(Booking booking, CancellationToken cancellationToken)
    {
        var unit = await _unitOfWork.Repository<YemenBooking.Core.Entities.Unit>()
            .GetByIdAsync(booking.UnitId, cancellationToken);
        if (unit == null)
        {
            return ResultDto<bool>.Failed("الوحدة المرتبطة بالحجز غير موجودة");
        }

        var property = await _unitOfWork.Repository<Property>()
            .GetByIdAsync(unit.PropertyId, cancellationToken);
        if (property == null)
        {
            return ResultDto<bool>.Failed("العقار المرتبط بالحجز غير موجود");
        }

        var scopedPropertyId = _currentUserService.PropertyId;
        var hasPropertyScope = scopedPropertyId.HasValue &&
                               scopedPropertyId.Value != Guid.Empty &&
                               scopedPropertyId.Value == property.Id;

        // Admin: صلاحية كاملة
        if (HasRole("Admin"))
        {
            return ResultDto<bool>.Succeeded(true);
        }

        // Owner: يجب أن يكون مالك العقار المرتبط بالحجز
        if (HasRole("Owner"))
        {
            if (property.OwnerId != _currentUserService.UserId && !hasPropertyScope)
            {
                return ResultDto<bool>.Failed("ليس لديك الصلاحية لتسجيل الوصول لهذا الحجز - أنت لست مالك هذا العقار");
            }
            return ResultDto<bool>.Succeeded(true);
        }

        // Staff: يجب أن يكون موظفًا في نفس العقار
        if (HasRole("Staff"))
        {
            if (!_currentUserService.IsStaffInProperty(unit.PropertyId))
            {
                return ResultDto<bool>.Failed("لست موظفًا في هذا العقار");
            }
            return ResultDto<bool>.Succeeded(true);
        }

        return ResultDto<bool>.Failed("ليس لديك الصلاحية لتسجيل الوصول لهذا الحجز");
    }

    private bool HasRole(string roleName)
    {
        if (string.IsNullOrWhiteSpace(roleName))
        {
            return false;
        }

        if (string.Equals(_currentUserService.Role, roleName, StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        if (string.Equals(_currentUserService.AccountRole, roleName, StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        return _currentUserService.UserRoles.Any(r =>
            string.Equals(r, roleName, StringComparison.OrdinalIgnoreCase));
    }
}
