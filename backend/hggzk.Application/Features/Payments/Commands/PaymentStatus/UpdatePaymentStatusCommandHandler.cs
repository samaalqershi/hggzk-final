using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Payments;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;
using YemenBooking.Core.Interfaces.Events;
using YemenBooking.Core.Interfaces;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Notifications;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Accounting.Services;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Application.Features.Notifications.Services;
using YemenBooking.Application.Features.Payments.Commands.PaymentEvents;

namespace YemenBooking.Application.Features.Payments.Commands.PaymentStatus;

    /// <summary>
    /// يعالج مكوّن المدفوعات ويعيد النتيجة المطلوبة.
    /// Handles a payment-related component and returns the requested result.
    /// </summary>
public class UpdatePaymentStatusCommandHandler : IRequestHandler<UpdatePaymentStatusCommand, ResultDto<bool>>
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IUnitRepository _unitRepository;
    private readonly IPropertyRepository _propertyRepository;
    private readonly IValidationService _validationService;
    private readonly IAuditService _auditService;
    private readonly INotificationService _notificationService;
    private readonly IEventPublisher _eventPublisher;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<UpdatePaymentStatusCommandHandler> _logger;
    private readonly IFinancialAccountingService _financialAccountingService;
    private readonly IUnitOfWork _unitOfWork;

/// <summary>
/// ينشئ مثيلًا جديدًا مع الاعتمادات المطلوبة.
/// Creates a new instance with its required dependencies.
/// </summary>
    public UpdatePaymentStatusCommandHandler(
        IPaymentRepository paymentRepository,
        IBookingRepository bookingRepository,
        IUnitRepository unitRepository,
        IPropertyRepository propertyRepository,
        IValidationService validationService,
        IAuditService auditService,
        INotificationService notificationService,
        IEventPublisher eventPublisher,
        ICurrentUserService currentUserService,
        ILogger<UpdatePaymentStatusCommandHandler> logger,
        IFinancialAccountingService financialAccountingService,
        IUnitOfWork unitOfWork)
    {
        _paymentRepository = paymentRepository;
        _bookingRepository = bookingRepository;
        _unitRepository = unitRepository;
        _propertyRepository = propertyRepository;
        _validationService = validationService;
        _auditService = auditService;
        _notificationService = notificationService;
        _eventPublisher = eventPublisher;
        _currentUserService = currentUserService;
        _logger = logger;
        _financialAccountingService = financialAccountingService;
        _unitOfWork = unitOfWork;
    }

/// <summary>
/// يعالج هذا المكوّن المرتبط بـ المدفوعات ويعيد النتيجة المطلوبة.
/// Handles the corresponding payment-related command or query and returns the requested result.
/// </summary>
    public async Task<ResultDto<bool>> Handle(UpdatePaymentStatusCommand request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء معالجة أمر تحديث حالة الدفع / Starting update payment status for payment: {PaymentId}", request.PaymentId);

            // Step 1: Validate input data.
            // الخطوة 1: التحقق من صحة البيانات المدخلة.
            var inputValidationResult = await ValidateInputAsync(request, cancellationToken);
            if (!inputValidationResult.Success)
            {
                _logger.LogWarning("فشل التحقق من صحة البيانات المدخلة / Input validation failed: {Errors}", string.Join(", ", inputValidationResult.Errors));
                return ResultDto<bool>.Failed(inputValidationResult.Errors);
            }

            // Step 2: Validate payment and booking existence.
            // الخطوة 2: التحقق من وجود الدفعة والحجز.
            var payment = await _paymentRepository.GetByIdAsync(request.PaymentId, cancellationToken);
            if (payment == null)
            {
                _logger.LogWarning("الدفعة غير موجودة / Payment not found: {PaymentId}", request.PaymentId);
                return ResultDto<bool>.Failed("الدفعة غير موجودة / Payment not found");
            }

            var booking = await _bookingRepository.GetByIdAsync(payment.BookingId, cancellationToken);
            if (booking == null)
            {
                _logger.LogWarning("الحجز غير موجود / Booking not found: {BookingId}", payment.BookingId);
                return ResultDto<bool>.Failed("الحجز غير موجود / Booking not found");
            }

            // Validate currency consistency between payment and booking.
            if (!string.Equals(payment.Amount.Currency, booking.TotalPrice.Currency, StringComparison.OrdinalIgnoreCase))
            {
                _logger.LogWarning("عدم تطابق عملة الدفعة ({PaymentCurrency}) مع عملة الحجز ({BookingCurrency})", payment.Amount.Currency, booking.TotalPrice.Currency);
                return ResultDto<bool>.Failed($"عملة الدفعة ({payment.Amount.Currency}) لا تطابق عملة الحجز ({booking.TotalPrice.Currency})");
            }

            // Step 3: Validate user authorization.
            // الخطوة 3: التحقق من صلاحيات المستخدم.
            var authorizationResult = await ValidateAuthorizationAsync(payment, booking, cancellationToken);
            if (!authorizationResult.Success)
            {
                _logger.LogWarning("فشل التحقق من الصلاحيات للمستخدم / Authorization failed for user: {UserId}", _currentUserService.UserId);
                return ResultDto<bool>.Failed(authorizationResult.Errors);
            }

            // Step 4: Validate business rules.
            // الخطوة 4: التحقق من قواعد الأعمال.
            var businessRulesResult = await ValidateBusinessRulesAsync(payment, request, cancellationToken);
            if (!businessRulesResult.Success)
            {
                _logger.LogWarning("فشل التحقق من قواعد الأعمال / Business rules validation failed: {Errors}", string.Join(", ", businessRulesResult.Errors));
                return ResultDto<bool>.Failed(businessRulesResult.Errors);
            }

            // Step 5: Validate state transition.
            // الخطوة 5: التحقق من انتقال الحالة.
            var stateTransitionResult = await ValidateStateTransitionAsync(payment, request.NewStatus, cancellationToken);
            if (!stateTransitionResult.Success)
            {
                _logger.LogWarning("فشل التحقق من انتقال الحالة / State transition validation failed: {Errors}", string.Join(", ", stateTransitionResult.Errors));
                return ResultDto<bool>.Failed(stateTransitionResult.Errors);
            }

            // Steps 6-7: Special handling for rejected status inside a transaction with a compensating entry when needed.
            // الخطوتان 6-7: منطق خاص لحالة مرفوض داخل ترانزاكشن مع قيد عكسي عند الحاجة.
            if (request.NewStatus == YemenBooking.Core.Enums.PaymentStatus.Rejected)
            {
                await _unitOfWork.ExecuteInTransactionAsync(async () =>
                {
                    var previousStatus = payment.Status;
                    var updateResult = await UpdatePaymentStatusAsync(payment, request.NewStatus, cancellationToken);
                    if (!updateResult.Success)
                    {
                        _logger.LogError("فشل في تحديث حالة الدفعة / Update payment status failed: {Errors}", string.Join(", ", updateResult.Errors));
                        throw new InvalidOperationException("FAILED_TO_UPDATE_PAYMENT_STATUS");
                    }

                    await _paymentRepository.SaveChangesAsync(cancellationToken);

                    if (previousStatus == YemenBooking.Core.Enums.PaymentStatus.Successful)
                    {
                        var tx = await _financialAccountingService.RecordRefundTransactionAsync(
                            payment.BookingId,
                            payment.Amount.Amount,
                            "رفض دفعة",
                            _currentUserService.UserId);
                        if (tx == null)
                            throw new InvalidOperationException("FAILED_TO_RECORD_REJECTED_PAYMENT_TX");
                    }

                    await UpdateBookingStatusIfNeededAsync(payment, cancellationToken);
                }, cancellationToken);
            }
            else
            {
                var updateResult = await UpdatePaymentStatusAsync(payment, request.NewStatus, cancellationToken);
                if (!updateResult.Success)
                {
                    _logger.LogError("فشل في تحديث حالة الدفعة / Update payment status failed: {Errors}", string.Join(", ", updateResult.Errors));
                    return ResultDto<bool>.Failed(updateResult.Errors);
                }

                await UpdateBookingStatusIfNeededAsync(payment, cancellationToken);
            }

            // Step 8: Write audit logs and publish events.
            // الخطوة 8: تسجيل العملية ونشر الأحداث.
            await LogAuditAndPublishEventsAsync(payment, booking, request.NewStatus, cancellationToken);

            _logger.LogInformation("تم تحديث حالة الدفعة بنجاح / Payment status updated successfully: {PaymentId}", payment.Id);
            return ResultDto<bool>.Succeeded(true, "تم تحديث حالة الدفعة بنجاح / Payment status updated successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في معالجة أمر تحديث حالة الدفع / Error processing update payment status command: {PaymentId}", request.PaymentId);
            return ResultDto<bool>.Failed("حدث خطأ أثناء تحديث حالة الدفعة / An error occurred while updating payment status");
        }
    }

    private async Task<ResultDto<bool>> ValidateInputAsync(UpdatePaymentStatusCommand request, CancellationToken cancellationToken)
    {
        var errors = new List<string>();

        // Validate payment ID.
        // التحقق من معرف الدفعة.
        if (request.PaymentId == Guid.Empty)
        {
            errors.Add("معرف الدفعة مطلوب / Payment ID is required");
        }

        // Validate the new status.
        // التحقق من الحالة الجديدة.
        if (!Enum.IsDefined(typeof(YemenBooking.Core.Enums.PaymentStatus), request.NewStatus))
        {
            errors.Add("الحالة الجديدة غير صحيحة / Invalid new status");
        }

        // Validate the request through the validation service.
        // التحقق من صحة البيانات باستخدام خدمة التحقق.
        var validationResult = await _validationService.ValidateAsync(request, cancellationToken);
        if (!validationResult.IsValid)
        {
            errors.AddRange(validationResult.Errors.Select(e => e.Message));
        }

        return errors.Any() ? ResultDto<bool>.Failed(errors) : ResultDto<bool>.Succeeded(true);
    }

    private async Task<ResultDto<bool>> ValidateAuthorizationAsync(Payment payment, YemenBooking.Core.Entities.Booking booking, CancellationToken cancellationToken)
    {
        var errors = new List<string>();
        var currentUserId = _currentUserService.UserId;
        var userRoles = _currentUserService.UserRoles;

        // Admin has full access.
        // المدير لديه صلاحية كاملة.
        if (userRoles.Contains("Admin"))
        {
            return ResultDto<bool>.Succeeded(true);
        }

        // Property owner.
        // مالك الكيان.
        var unit = await _unitRepository.GetByIdAsync(booking.UnitId, cancellationToken);
        if (unit != null)
        {
            var property = await _propertyRepository.GetByIdAsync(unit.PropertyId, cancellationToken);
            if (property != null && property.OwnerId == currentUserId)
                return ResultDto<bool>.Succeeded(true);
        }

        // Authorized staff member.
        // الموظف المخول.
        if (_currentUserService.Role != "Admin" && _currentUserService.Role != "Staff")
        {
            errors.Add("ليس لديك الصلاحية لتحديث حالة هذه الدفعة / You do not have permission to update this payment status");
        }

        if (_currentUserService.Role != "Admin" && !_currentUserService.IsStaffInProperty(unit?.PropertyId ?? Guid.Empty))
        {
            errors.Add("لست موظفًا في هذا الكيان / You are not a staff member of this property");
        }

        return errors.Any()
            ? ResultDto<bool>.Failed(errors)
            : ResultDto<bool>.Succeeded(true);
    }

    private async Task<ResultDto<bool>> ValidateBusinessRulesAsync(Payment payment, UpdatePaymentStatusCommand request, CancellationToken cancellationToken)
    {
        var errors = new List<string>();

        // Ensure the new status differs from the current status.
        // التأكد من أن الحالة الجديدة تختلف عن الحالية.
        // Check that new status is different from current status
        if (payment.Status == request.NewStatus)
        {
            errors.Add("الحالة الجديدة يجب أن تكون مختلفة عن الحالة الحالية / New status must be different from current status");
        }

        // Additional validation rules.
        // قواعد تحقق إضافية.
        // Additional business rules validation
        if (request.NewStatus == YemenBooking.Core.Enums.PaymentStatus.Refunded && request.RefundRecord == null)
        {
            errors.Add("لا يمكن تعيين الحالة إلى مستردة بدون سجل استرداد / Cannot set status to refunded without refund record");
        }

        return errors.Any() ? ResultDto<bool>.Failed(errors) : ResultDto<bool>.Succeeded(true);
    }

    private async Task<ResultDto<bool>> ValidateStateTransitionAsync(Payment payment, YemenBooking.Core.Enums.PaymentStatus newStatus, CancellationToken cancellationToken)
    {
        var errors = new List<string>();

        // Validate transitions allowed for the current state.
        // التحقق من الانتقالات المسموح بها بناءً على الحالة الحالية.
        // Check allowed transitions based on current status
        switch (payment.Status)
        {
            case YemenBooking.Core.Enums.PaymentStatus.Pending:
                if (newStatus != YemenBooking.Core.Enums.PaymentStatus.Successful && newStatus != YemenBooking.Core.Enums.PaymentStatus.Failed && newStatus != YemenBooking.Core.Enums.PaymentStatus.Voided && newStatus != YemenBooking.Core.Enums.PaymentStatus.Rejected)
                {
                    errors.Add($"لا يمكن الانتقال من الحالة {payment.Status} إلى {newStatus} / Cannot transition from {payment.Status} to {newStatus}");
                }
                break;

            case YemenBooking.Core.Enums.PaymentStatus.Successful:
                if (newStatus != YemenBooking.Core.Enums.PaymentStatus.Refunded && newStatus != YemenBooking.Core.Enums.PaymentStatus.PartiallyRefunded)
                {
                    errors.Add($"لا يمكن الانتقال من الحالة {payment.Status} إلى {newStatus} / Cannot transition from {payment.Status} to {newStatus}");
                }
                break;

            case YemenBooking.Core.Enums.PaymentStatus.Failed:
            case YemenBooking.Core.Enums.PaymentStatus.Voided:
            case YemenBooking.Core.Enums.PaymentStatus.Rejected:
            case YemenBooking.Core.Enums.PaymentStatus.PartiallyRefunded:
                errors.Add($"لا يمكن تغيير الحالة بعد الوصول إلى {payment.Status} / Cannot change status after reaching {payment.Status}");
                break;

            default:
                break;
        }

        return errors.Any() ? ResultDto<bool>.Failed(errors) : ResultDto<bool>.Succeeded(true);
    }

    private async Task<ResultDto<bool>> UpdatePaymentStatusAsync(Payment payment, YemenBooking.Core.Enums.PaymentStatus newStatus, CancellationToken cancellationToken)
    {
        try
        {
            // Update the status.
            // تحديث الحالة.
            // Update status
            payment.Status = newStatus;
            payment.UpdatedAt = DateTime.UtcNow;

            // Set the processed date when the status becomes successful.
            // تحديث تاريخ المعالجة إذا أصبحت الحالة ناجحة.
            // Update processed date if status is set to successful
            if (newStatus == YemenBooking.Core.Enums.PaymentStatus.Successful && payment.PaymentDate == default)
            {
                payment.PaymentDate = DateTime.UtcNow;
            }

            // Persist the changes.
            // حفظ التغييرات في قاعدة البيانات.
            // Save changes to database
            await _paymentRepository.UpdateAsync(payment, cancellationToken);

            return ResultDto<bool>.Succeeded(true);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في تحديث حالة الدفعة / Error updating payment status: {PaymentId}", payment.Id);
            return ResultDto<bool>.Failed("حدث خطأ أثناء تحديث حالة الدفعة / An error occurred while updating payment status");
        }
    }

    private async Task UpdateBookingStatusIfNeededAsync(Payment payment, CancellationToken cancellationToken)
    {
        // Update the booking status based on the payment status.
        // تحديث حالة الحجز بناءً على حالة الدفع.
        var booking = await _bookingRepository.GetByIdAsync(payment.BookingId, cancellationToken);
        if (booking == null) return;

        var totalPaid = await _paymentRepository.GetTotalPaidAmountAsync(booking.Id, cancellationToken);

        if (payment.Status == YemenBooking.Core.Enums.PaymentStatus.Successful)
        {
        }
        else if (payment.Status == YemenBooking.Core.Enums.PaymentStatus.Refunded || payment.Status == YemenBooking.Core.Enums.PaymentStatus.PartiallyRefunded)
        {
            if (totalPaid < booking.TotalPrice.Amount)
            {
                booking.Status = BookingStatus.Pending;
            }
        }
        else if (payment.Status == YemenBooking.Core.Enums.PaymentStatus.Failed || payment.Status == YemenBooking.Core.Enums.PaymentStatus.Voided || payment.Status == YemenBooking.Core.Enums.PaymentStatus.Rejected)
        {
            booking.Status = BookingStatus.Pending;
        }

        booking.UpdatedAt = DateTime.UtcNow;
        await _bookingRepository.UpdateAsync(booking, cancellationToken);
    }

    private async Task LogAuditAndPublishEventsAsync(Payment payment, YemenBooking.Core.Entities.Booking booking, YemenBooking.Core.Enums.PaymentStatus newStatus, CancellationToken cancellationToken)
    {
        // Audit logging.
        // تسجيل العملية.
        var notes = $"Payment status updated to {newStatus} for booking {booking.Id} by {_currentUserService.Username} (ID={_currentUserService.UserId})";
        await _auditService.LogAuditAsync(
            entityType: "Payment",
            entityId: payment.Id,
            action: YemenBooking.Core.Entities.AuditAction.UPDATE,
            oldValues: null,
            newValues: System.Text.Json.JsonSerializer.Serialize(new { NewStatus = newStatus, BookingId = booking.Id }),
            performedBy: _currentUserService.UserId,
            notes: notes,
            cancellationToken: cancellationToken);

        // Publish the payment status updated event.
        // نشر حدث تحديث حالة الدفع.
        await _eventPublisher.PublishAsync(new PaymentStatusUpdatedEvent
        {
            PaymentId = payment.Id,
            BookingId = booking.Id,
            PreviousStatus = payment.Status,
            NewStatus = newStatus,
            UpdatedAt = DateTime.UtcNow,
            UpdatedByUserId = _currentUserService.UserId,
            UpdateReason = null,
            Amount = payment.Amount.Amount,
            TransactionId = payment.TransactionId,
            Notes = null,
            EventId = Guid.NewGuid(),
            OccurredOn = DateTime.UtcNow,
            EventType = nameof(PaymentStatusUpdatedEvent),
            Version = 1,
            UserId = null,
            CorrelationId = booking.Id.ToString()
        }, cancellationToken);

        // Send a guest notification when needed.
        // إرسال إشعار للضيف عند الحاجة.
        if (newStatus == YemenBooking.Core.Enums.PaymentStatus.Successful || newStatus == YemenBooking.Core.Enums.PaymentStatus.Failed || newStatus == YemenBooking.Core.Enums.PaymentStatus.Refunded)
        {
            var bookingNumber = $"BK-{booking.Id.ToString("N")[..8].ToUpperInvariant()}";
            var notificationType = newStatus == YemenBooking.Core.Enums.PaymentStatus.Successful ? NotificationType.PaymentProcessed :
                                   newStatus == YemenBooking.Core.Enums.PaymentStatus.Failed ? NotificationType.PaymentFailed :
                                   NotificationType.RefundProcessed;

            var title = newStatus == YemenBooking.Core.Enums.PaymentStatus.Successful ? "تم معالجة الدفع / Payment Processed" :
                        newStatus == YemenBooking.Core.Enums.PaymentStatus.Failed ? "فشل الدفع / Payment Failed" :
                        "تم معالجة الاسترداد / Refund Processed";

            var message = newStatus == YemenBooking.Core.Enums.PaymentStatus.Successful ? $"تم معالجة دفعتك بمبلغ {payment.Amount.Amount} {payment.Amount.Currency} بنجاح لحجزك رقم {bookingNumber} / Your payment of {payment.Amount.Amount} {payment.Amount.Currency} has been processed successfully for your booking {bookingNumber}" :
                          newStatus == YemenBooking.Core.Enums.PaymentStatus.Failed ? $"فشلت عملية الدفع بمبلغ {payment.Amount.Amount} {payment.Amount.Currency} لحجزك رقم {bookingNumber} / Your payment of {payment.Amount.Amount} {payment.Amount.Currency} has failed for your booking {bookingNumber}" :
                          $"تم معالجة استرداد بمبلغ {payment.Amount.Amount} {payment.Amount.Currency} بنجاح لحجزك رقم {bookingNumber} / Your refund of {payment.Amount.Amount} {payment.Amount.Currency} has been processed successfully for your booking {bookingNumber}";

            await _notificationService.SendAsync(new NotificationRequest
            {
                UserId = booking.UserId,
                Type = notificationType,
                Title = title,
                Message = message,
                Data = new { PaymentId = payment.Id, BookingId = booking.Id, BookingNumber = bookingNumber }
            }, cancellationToken);
        }
    }
}
