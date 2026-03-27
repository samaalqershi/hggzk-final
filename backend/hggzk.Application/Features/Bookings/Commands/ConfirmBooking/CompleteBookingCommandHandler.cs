using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Bookings;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;
using YemenBooking.Core.Interfaces;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Application.Features.Accounting.Services;
using System.Linq;

namespace YemenBooking.Application.Features.Bookings.Commands.ConfirmBooking;

    /// <summary>
    /// يعالج مكوّن الحجوزات ويعيد النتيجة المطلوبة.
    /// Handles a booking-related component and returns the requested result.
    /// </summary>
public class CompleteBookingCommandHandler : IRequestHandler<CompleteBookingCommand, ResultDto<bool>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IBookingRepository _bookingRepository;
    private readonly IUnitRepository _unitRepository;
    private readonly IPropertyRepository _propertyRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly IValidationService _validationService;
    private readonly IAuditService _auditService;
    private readonly ILogger<CompleteBookingCommandHandler> _logger;
    private readonly IFinancialAccountingService _financialAccountingService;
    private readonly IPaymentRepository _paymentRepository;

/// <summary>
/// ينشئ مثيلًا جديدًا مع الاعتمادات المطلوبة.
/// Creates a new instance with its required dependencies.
/// </summary>
    public CompleteBookingCommandHandler(
        IUnitOfWork unitOfWork,
        IBookingRepository bookingRepository,
        IUnitRepository unitRepository,
        IPropertyRepository propertyRepository,
        ICurrentUserService currentUserService,
        IValidationService validationService,
        IAuditService auditService,
        ILogger<CompleteBookingCommandHandler> logger,
        IFinancialAccountingService financialAccountingService,
        IPaymentRepository paymentRepository)
    {
        _unitOfWork = unitOfWork;
        _bookingRepository = bookingRepository;
        _unitRepository = unitRepository;
        _propertyRepository = propertyRepository;
        _currentUserService = currentUserService;
        _validationService = validationService;
        _auditService = auditService;
        _logger = logger;
        _financialAccountingService = financialAccountingService;
        _paymentRepository = paymentRepository;
    }

/// <summary>
/// يعالج هذا المكوّن المرتبط بـ الحجوزات ويعيد النتيجة المطلوبة.
/// Handles the corresponding booking-related command or query and returns the requested result.
/// </summary>
    public async Task<ResultDto<bool>> Handle(CompleteBookingCommand request, CancellationToken cancellationToken)
    {
        try
        {
            var validation = await _validationService.ValidateAsync(request, cancellationToken);
            if (!validation.IsValid)
            {
                return ResultDto<bool>.Failed(validation.Errors.Select(e => e.Message).ToArray());
            }

            var booking = await _bookingRepository.GetBookingByIdAsync(request.BookingId, cancellationToken);
            if (booking == null)
            {
                return ResultDto<bool>.Failed("الحجز غير موجود");
            }

            var authResult = await ValidateAuthorizationAsync(booking, cancellationToken);
            if (!authResult.IsSuccess)
            {
                return authResult;
            }

            var finalAmountToPay = booking.FinalAmount > 0 ? booking.FinalAmount : booking.TotalPrice.Amount;
            var totalPaid = await _paymentRepository.GetTotalPaidAmountAsync(booking.Id, cancellationToken);
            var remainingAmount = finalAmountToPay - totalPaid;
            if (remainingAmount > 0)
            {
                return ResultDto<bool>.Failed($"لا يمكن إكمال الحجز قبل سداد كامل المبلغ. المبلغ المتبقي: {remainingAmount}");
            }

            // تنفيذ تحديث حالة الإكمال وتسجيل القيد المحاسبي ضمن ترانزاكشن واحدة
            await _unitOfWork.ExecuteInTransactionAsync(async () =>
            {
                // يمكن الإكمال بعد تسجيل المغادرة أو في حالات خاصة
                if (booking.Status != BookingStatus.Completed)
                {
                    booking.Status = BookingStatus.Completed;
                }

                booking.UpdatedAt = DateTime.UtcNow;

                await _bookingRepository.UpdateAsync(booking, cancellationToken);
                await _bookingRepository.SaveChangesAsync(cancellationToken);

                // حساب المبلغ النهائي (يمكن أن يكون من حقل FinalAmount أو TotalPrice)
                var finalAmount = booking.FinalAmount > 0 ? booking.FinalAmount : booking.TotalPrice.Amount;

                var tx = await _financialAccountingService.RecordBookingCompletionAsync(
                    booking.Id,
                    finalAmount,
                    _currentUserService.UserId);
                if (tx == null)
                    throw new InvalidOperationException("FAILED_TO_RECORD_BOOKING_COMPLETION_TX");
            }, cancellationToken);

            await _auditService.LogAuditAsync(
                entityType: nameof(Booking),
                entityId: booking.Id,
                action: AuditAction.UPDATE,
                oldValues: null,
                newValues: System.Text.Json.JsonSerializer.Serialize(new { Status = booking.Status.ToString() }),
                performedBy: _currentUserService.UserId,
                notes: $"تم إكمال الحجز بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})",
                cancellationToken: cancellationToken);

            return ResultDto<bool>.Succeeded(true, "تم إكمال الحجز بنجاح");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء إكمال الحجز {BookingId}", request.BookingId);
            return ResultDto<bool>.Failed("حدث خطأ أثناء إكمال الحجز");
        }
    }

    private async Task<ResultDto<bool>> ValidateAuthorizationAsync(Booking booking, CancellationToken cancellationToken)
    {
        var unit = await _unitRepository.GetUnitByIdAsync(booking.UnitId, cancellationToken);
        if (unit == null)
        {
            return ResultDto<bool>.Failed("الوحدة المرتبطة بالحجز غير موجودة");
        }

        var property = await _propertyRepository.GetPropertyByIdAsync(unit.PropertyId, cancellationToken);
        if (property == null)
        {
            return ResultDto<bool>.Failed("العقار المرتبط بالحجز غير موجود");
        }

        if (HasRole("Admin"))
        {
            return ResultDto<bool>.Succeeded(true);
        }

        var scopedPropertyId = _currentUserService.PropertyId;
        var hasPropertyScope = scopedPropertyId.HasValue &&
                               scopedPropertyId.Value != Guid.Empty &&
                               scopedPropertyId.Value == property.Id;

        if (HasRole("Owner"))
        {
            if (property.OwnerId == _currentUserService.UserId || hasPropertyScope)
            {
                return ResultDto<bool>.Succeeded(true);
            }

            return ResultDto<bool>.Failed("ليس لديك الصلاحية لإكمال هذا الحجز");
        }

        if (HasRole("Staff"))
        {
            if (_currentUserService.IsStaffInProperty(unit.PropertyId))
            {
                return ResultDto<bool>.Succeeded(true);
            }

            return ResultDto<bool>.Failed("لست موظفًا في هذا العقار");
        }

        return ResultDto<bool>.Failed("ليس لديك الصلاحية لإكمال هذا الحجز");
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
