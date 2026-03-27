using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Bookings.DTOs;
using YemenBooking.Application.Features.Payments;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;
using YemenBooking.Core.Interfaces.Events;
using YemenBooking.Core.Interfaces;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Notifications;
using YemenBooking.Core.ValueObjects;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Accounting.Services;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Application.Features.Notifications.Services;
using YemenBooking.Application.Features.Payments.Services;
using YemenBooking.Application.Features.Payments.Commands.PaymentEvents;
using AutoMapper;


namespace YemenBooking.Application.Features.Payments.Commands.VoidPayment;

    /// <summary>
    /// يعالج مكوّن المدفوعات ويعيد النتيجة المطلوبة.
    /// Handles a payment-related component and returns the requested result.
    /// </summary>
public class VoidPaymentCommandHandler : IRequestHandler<VoidPaymentCommand, ResultDto<bool>>
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IUnitRepository _unitRepository;
    private readonly IPropertyRepository _propertyRepository;
    private readonly YemenBooking.Application.Features.Payments.Services.IPaymentGatewayService _paymentGatewayService;
    private readonly IValidationService _validationService;
    private readonly IAuditService _auditService;
    private readonly INotificationService _notificationService;
    private readonly IEventPublisher _eventPublisher;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<VoidPaymentCommandHandler> _logger;
    private readonly IFinancialAccountingService _financialAccountingService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

/// <summary>
/// ينشئ مثيلًا جديدًا مع الاعتمادات المطلوبة.
/// Creates a new instance with its required dependencies.
/// </summary>
    public VoidPaymentCommandHandler(
        IPaymentRepository paymentRepository,
        IBookingRepository bookingRepository,
        IUnitRepository unitRepository,
        IPropertyRepository propertyRepository,
        YemenBooking.Application.Features.Payments.Services.IPaymentGatewayService paymentGatewayService,
        IValidationService validationService,
        IAuditService auditService,
        INotificationService notificationService,
        IEventPublisher eventPublisher,
        ICurrentUserService currentUserService,
        ILogger<VoidPaymentCommandHandler> logger,
        IFinancialAccountingService financialAccountingService,
        IUnitOfWork unitOfWork,
        IMapper mapper)
    {
        _paymentRepository = paymentRepository;
        _bookingRepository = bookingRepository;
        _unitRepository = unitRepository;
        _propertyRepository = propertyRepository;
        _paymentGatewayService = paymentGatewayService;
        _validationService = validationService;
        _auditService = auditService;
        _notificationService = notificationService;
        _eventPublisher = eventPublisher;
        _currentUserService = currentUserService;
        _logger = logger;
        _financialAccountingService = financialAccountingService;
        _unitOfWork = unitOfWork;
        _mapper = mapper;
    }

/// <summary>
/// يعالج هذا المكوّن المرتبط بـ المدفوعات ويعيد النتيجة المطلوبة.
/// Handles the corresponding payment-related command or query and returns the requested result.
/// </summary>
    public async Task<ResultDto<bool>> Handle(VoidPaymentCommand request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء معالجة أمر إبطال الدفع / Starting void payment processing for payment: {PaymentId}", request.PaymentId);

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

            var bookingEntity = await _bookingRepository.GetByIdAsync(payment.BookingId, cancellationToken);
            if (bookingEntity == null)
            {
                _logger.LogWarning("الحجز غير موجود / BookingDto not found: {BookingId}", payment.BookingId);
                return ResultDto<bool>.Failed("الحجز غير موجود / BookingDto not found");
            }

            // Map the booking entity to BookingDto.
            var booking = _mapper.Map<BookingDto>(bookingEntity);

            // Verify currency consistency between payment and booking.
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
            var businessRulesResult = await ValidateBusinessRulesAsync(payment, cancellationToken);
            if (!businessRulesResult.Success)
            {
                _logger.LogWarning("فشل التحقق من قواعد الأعمال / Business rules validation failed: {Errors}", string.Join(", ", businessRulesResult.Errors));
                return ResultDto<bool>.Failed(businessRulesResult.Errors);
            }

            // Step 5: Validate payment state.
            // الخطوة 5: التحقق من حالة الدفعة.
            var stateValidationResult = await ValidatePaymentStateAsync(payment, cancellationToken);
            if (!stateValidationResult.Success)
            {
                _logger.LogWarning("فشل التحقق من حالة الدفعة / Payment state validation failed: {Errors}", string.Join(", ", stateValidationResult.Errors));
                return ResultDto<bool>.Failed(stateValidationResult.Errors);
            }

            // Step 6: Process the void operation.
            // الخطوة 6: معالجة الإبطال.
            var voidResult = await ProcessVoidAsync(payment, cancellationToken);
            if (!voidResult.Success)
            {
                _logger.LogError("فشل في معالجة إبطال الدفعة / Void processing failed: {Errors}", string.Join(", ", voidResult.Errors));
                return ResultDto<bool>.Failed(voidResult.Errors);
            }

            // Step 7: Update booking status if needed.
            // الخطوة 7: تحديث حالة الحجز إذا لزم الأمر.
            await UpdateBookingStatusIfNeededAsync(payment, cancellationToken);

            // Step 8: Write audit logs and publish events.
            // الخطوة 8: تسجيل العملية ونشر الأحداث.
            await LogAuditAndPublishEventsAsync(payment, booking, cancellationToken);

            _logger.LogInformation("تم إبطال الدفعة بنجاح / Payment voided successfully: {PaymentId}", payment.Id);
            return ResultDto<bool>.Succeeded(true, "تم إبطال الدفعة بنجاح / Payment voided successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في معالجة أمر إبطال الدفع / Error processing void payment command: {PaymentId}", request.PaymentId);
            return ResultDto<bool>.Failed("حدث خطأ أثناء إبطال الدفعة / An error occurred while voiding payment");
        }
    }

    private async Task<ResultDto<bool>> ValidateInputAsync(VoidPaymentCommand request, CancellationToken cancellationToken)
    {
        var errors = new List<string>();

        // Validate payment ID.
        // التحقق من معرف الدفعة.
        if (request.PaymentId == Guid.Empty)
        {
            errors.Add("معرف الدفعة مطلوب / Payment ID is required");
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

    private async Task<ResultDto<bool>> ValidateAuthorizationAsync(Payment payment, BookingDto booking, CancellationToken cancellationToken)
    {
        var userRoles = _currentUserService.UserRoles;
        // Only Admin can void payments. Owners are not permitted to perform void operations.
        if (userRoles.Contains("Admin"))
        {
            return ResultDto<bool>.Succeeded(true);
        }

        return ResultDto<bool>.Failed("غير مسموح لغير المدير بإبطال الدفعات / Only Admin can void payments");
    }

    private async Task<ResultDto<bool>> ValidateBusinessRulesAsync(Payment payment, CancellationToken cancellationToken)
    {
        var errors = new List<string>();

        // Ensure there is no prior void for the same payment.
        // التأكد من عدم وجود إبطال سابق لنفس الدفعة.
        if (payment.Status == Core.Enums.PaymentStatus.Voided)
        {
            errors.Add("الدفعة تم إبطالها مسبقًا / Payment has already been voided");
        }

        // Ensure the payment has not been refunded.
        // التأكد من أن الدفعة لم يتم استردادها.
        if (payment.Status == Core.Enums.PaymentStatus.Refunded || payment.Status == Core.Enums.PaymentStatus.PartiallyRefunded)
        {
            errors.Add("لا يمكن إبطال دفعة تم استردادها / Cannot void a refunded payment");
        }

        return errors.Any() ? ResultDto<bool>.Failed(errors) : ResultDto<bool>.Succeeded(true);
    }

    private async Task<ResultDto<bool>> ValidatePaymentStateAsync(Payment payment, CancellationToken cancellationToken)
    {
        var errors = new List<string>();

        // Ensure the payment is in a state that allows voiding.
        // التأكد من أن الدفعة في حالة تسمح بالإبطال.
        if (payment.Status != Core.Enums.PaymentStatus.Pending && payment.Status != Core.Enums.PaymentStatus.Successful)
        {
            errors.Add($"لا يمكن إبطال الدفعة في الحالة الحالية: {payment.Status} / Cannot void payment in current status: {payment.Status}");
        }

        return errors.Any() ? ResultDto<bool>.Failed(errors) : ResultDto<bool>.Succeeded(true);
    }

    private async Task<ResultDto<bool>> ProcessVoidAsync(Payment payment, CancellationToken cancellationToken)
    {
        try
        {
            var isWalletPayment = payment.PaymentMethod == PaymentMethodEnum.JwaliWallet
                                  || payment.PaymentMethod == PaymentMethodEnum.SabaCashWallet
                                  || payment.PaymentMethod == PaymentMethodEnum.FloskWallet;

            if (isWalletPayment)
            {
                return ResultDto<bool>.Failed("إبطال (Void) غير مدعوم لهذه الطريقة. استخدم الاسترداد (Refund) بدلاً من ذلك / Void is not supported for this method; use Refund instead");
            }

            // محاولة إبطال الدفعة عبر بوابة الدفع إذا كانت ناجحة
            // Attempt to void payment through gateway if it was successful
            if (payment.Status == YemenBooking.Core.Enums.PaymentStatus.Successful)
            {
                var gatewayResult = await _paymentGatewayService.CancelTransactionAsync(payment.TransactionId, cancellationToken);
                if (!gatewayResult)
                {
                    return ResultDto<bool>.Failed("فشل في إبطال الدفعة / Void payment failed");
                }
            }

            // تنفيذ تحديث حالة الدفعة والقيد المحاسبي ضمن ترانزاكشن واحدة
            await _unitOfWork.ExecuteInTransactionAsync(async () =>
            {
                // Update the payment status to voided.
                // تحديث حالة الدفعة إلى مبطلة.
                payment.Status = YemenBooking.Core.Enums.PaymentStatus.Voided;
                payment.UpdatedAt = DateTime.UtcNow;

                await _paymentRepository.UpdateAsync(payment, cancellationToken);

                // Record the reversing accounting entry for the original payment.
                // تسجيل القيد المحاسبي العكسي لقيد الدفعة الأصلي.
                var booking = await _bookingRepository.GetByIdAsync(payment.BookingId, cancellationToken);
                if (booking != null)
                {
                    var tx = await _financialAccountingService.RecordRefundTransactionAsync(
                        payment.BookingId,
                        payment.Amount.Amount,
                        "إلغاء دفعة",
                        _currentUserService.UserId);
                    if (tx == null)
                        throw new InvalidOperationException("FAILED_TO_RECORD_VOID_PAYMENT_TX");
                }
            }, cancellationToken);

            return ResultDto<bool>.Succeeded(true);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في معالجة إبطال الدفعة / Error processing void for payment: {PaymentId}", payment.Id);
            return ResultDto<bool>.Failed("حدث خطأ أثناء إبطال الدفعة / An error occurred while voiding payment");
        }
    }

    private async Task UpdateBookingStatusIfNeededAsync(Payment payment, CancellationToken cancellationToken)
    {
        // Update the booking status based on the payment status.
        // تحديث حالة الحجز بناءً على حالة الدفع.
        var booking = await _bookingRepository.GetByIdAsync(payment.BookingId, cancellationToken);
        if (booking == null) return;

        var totalPaid = await _paymentRepository.GetTotalPaidAmountAsync(booking.Id, cancellationToken);

        if (totalPaid < booking.TotalPrice.Amount)
        {
            booking.Status = BookingStatus.Pending;
            booking.UpdatedAt = DateTime.UtcNow;
            await _bookingRepository.UpdateAsync(booking, cancellationToken);
        }
    }

    private async Task LogAuditAndPublishEventsAsync(Payment payment, BookingDto booking, CancellationToken cancellationToken)
    {
        // Audit logging.
        // تسجيل العملية.
        var notes = $"Payment voided for booking {booking.Id} by {_currentUserService.Username} (ID={_currentUserService.UserId})";
        await _auditService.LogAuditAsync(
            entityType: "Payment",
            entityId: payment.Id,
            action: AuditAction.UPDATE,
            oldValues: null,
            newValues: System.Text.Json.JsonSerializer.Serialize(new { Voided = true, BookingId = booking.Id }),
            performedBy: _currentUserService.UserId,
            notes: notes,
            cancellationToken: cancellationToken);

        // Publish the payment voided event.
        // نشر حدث إبطال الدفع.
        await _eventPublisher.PublishAsync(new YemenBooking.Application.Features.Payments.Commands.PaymentEvents.PaymentVoidedEvent
        {
            PaymentId = payment.Id,
            BookingId = booking.Id,
            AttemptedAt = DateTime.UtcNow,
            AttemptedAmount = payment.Amount,
            Method = payment.PaymentMethod.ToString(),
            FailureReason = string.Empty,
            ErrorCode = null,
            UserId = _currentUserService.UserId
        }, cancellationToken);

        // Send a notification to the guest.
        // إرسال إشعار للضيف.
        var bookingNumber = $"BK-{booking.Id.ToString("N")[..8].ToUpperInvariant()}";
        await _notificationService.SendAsync(new NotificationRequest
        {
            UserId = booking.UserId,
            Type = NotificationType.PaymentVoided,
            Title = "تم إبطال الدفع / Payment Voided",
            Message = $"تم إبطال دفعتك بمبلغ {payment.Amount.Amount} {payment.Amount.Currency} لحجزك رقم {bookingNumber} / Your payment of {payment.Amount.Amount} {payment.Amount.Currency} has been voided for your booking {bookingNumber}",
            Data = new { PaymentId = payment.Id, BookingId = booking.Id, BookingNumber = bookingNumber }
        }, cancellationToken);
    }
}
