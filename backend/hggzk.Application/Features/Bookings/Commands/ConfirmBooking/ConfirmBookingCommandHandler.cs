
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Bookings.DTOs;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;
using YemenBooking.Core.Interfaces;
using YemenBooking.Core.Interfaces.Events;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features.AuditLog.Services;
using System.Linq;
using YemenBooking.Core.Notifications;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Accounting.Services;
using YemenBooking.Application.Features.Notifications.Services;
using YemenBooking.Application.Features.SearchAndFilters.Services;
using YemenBooking.Application.Contracts.Services.Scheduling;
using PaymentStatus = YemenBooking.Core.Enums.PaymentStatus;

namespace YemenBooking.Application.Features.Bookings.Commands.ConfirmBooking;

    /// <summary>
    /// يعالج مكوّن الحجوزات ويعيد النتيجة المطلوبة.
    /// Handles a booking-related component and returns the requested result.
    /// </summary>
public class ConfirmBookingCommandHandler : IRequestHandler<ConfirmBookingCommand, ResultDto<bool>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IBookingRepository _bookingRepository;
    private readonly IUnitRepository _unitRepository;
    private readonly IPropertyRepository _propertyRepository;
    private readonly IPaymentRepository _paymentRepository;
    private readonly IPolicyRepository _policyRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly IValidationService _validationService;
    private readonly IAuditService _auditService;
    private readonly IEventPublisher _eventPublisher;
    private readonly INotificationService _notificationService;
    private readonly ILogger<ConfirmBookingCommandHandler> _logger;
    private readonly IAvailabilityService _availabilityService;
    private readonly IDailyUnitScheduleRepository _scheduleRepository;
    private readonly IUnitIndexingService _indexingService;
    private readonly IFinancialAccountingService _financialAccountingService;

/// <summary>
/// ينشئ مثيلًا جديدًا مع الاعتمادات المطلوبة.
/// Creates a new instance with its required dependencies.
/// </summary>
    public ConfirmBookingCommandHandler(
        IUnitOfWork unitOfWork,
        IBookingRepository bookingRepository,
        IUnitRepository unitRepository,
        IPropertyRepository propertyRepository,
        IPaymentRepository paymentRepository,
        IPolicyRepository policyRepository,
        ICurrentUserService currentUserService,
        IValidationService validationService,
        IAuditService auditService,
        IEventPublisher eventPublisher,
        INotificationService notificationService,
        ILogger<ConfirmBookingCommandHandler> logger,
        IAvailabilityService availabilityService,
        IDailyUnitScheduleRepository scheduleRepository,
        IUnitIndexingService indexingService,
        IFinancialAccountingService financialAccountingService)
    {
        _unitOfWork = unitOfWork;
        _bookingRepository = bookingRepository;
        _unitRepository = unitRepository;
        _propertyRepository = propertyRepository;
        _paymentRepository = paymentRepository;
        _policyRepository = policyRepository;
        _currentUserService = currentUserService;
        _validationService = validationService;
        _auditService = auditService;
        _eventPublisher = eventPublisher;
        _notificationService = notificationService;
        _logger = logger;
        _availabilityService = availabilityService;
        _scheduleRepository = scheduleRepository;
        _indexingService = indexingService;
        _financialAccountingService = financialAccountingService;
    }

/// <summary>
/// يعالج هذا المكوّن المرتبط بـ الحجوزات ويعيد النتيجة المطلوبة.
/// Handles the corresponding booking-related command or query and returns the requested result.
/// </summary>
    public async Task<ResultDto<bool>> Handle(ConfirmBookingCommand request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء معالجة أمر تأكيد الحجز {BookingId}", request.BookingId);

            // التحقق من وجود الحجز
            var booking = await _bookingRepository.GetBookingByIdAsync(request.BookingId, cancellationToken);
            if (booking == null)
            {
                return ResultDto<bool>.Failed("الحجز غير موجود");
            }

            var unitEntity = await _unitRepository.GetUnitByIdAsync(booking.UnitId, cancellationToken);
            if (unitEntity == null)
            {
                return ResultDto<bool>.Failed("الوحدة المرتبطة بالحجز غير موجودة");
            }

            var propertyEntity = await _propertyRepository.GetPropertyByIdAsync(unitEntity.PropertyId, cancellationToken);
            if (propertyEntity == null)
            {
                return ResultDto<bool>.Failed("العقار المرتبط بالحجز غير موجود");
            }

            // التحقق من الصلاحيات
            var authorizationValidation = await ValidateAuthorizationAsync(
                request,
                unitEntity,
                propertyEntity,
                cancellationToken);
            if (!authorizationValidation.IsSuccess)
            {
                return authorizationValidation;
            }

            // التحقق من حالة الكيان
            var stateValidation = ValidateBookingState(booking);
            if (!stateValidation.IsSuccess)
            {
                return stateValidation;
            }

            // التحقق من قواعد العمل
            var businessRulesValidation = await ValidateBusinessRulesAsync(booking, cancellationToken);
            if (!businessRulesValidation.IsSuccess)
            {
                return businessRulesValidation;
            }

            // التحقق من توفر الوحدة (تواريخ مخزنة UTC)
            // استثناء الحجز الحالي من الفحص لأنه بالفعل يحجز هذه الفترة
            _logger.LogInformation("التحقق من توفر الوحدة {UnitId} للحجز {BookingId} من {CheckIn} إلى {CheckOut}",
                booking.UnitId, booking.Id, booking.CheckIn, booking.CheckOut);

            var bookingLocalCheckInDate = (await _currentUserService.ConvertFromUtcToUserLocalAsync(booking.CheckIn)).Date;
            var bookingLocalCheckOutDate = (await _currentUserService.ConvertFromUtcToUserLocalAsync(booking.CheckOut)).Date;
            var isAvailable = await _availabilityService.CheckAvailabilityAsync(
                booking.UnitId,
                bookingLocalCheckInDate,
                bookingLocalCheckOutDate,
                booking.Id);

            if (!isAvailable)
            {
                _logger.LogWarning("الوحدة {UnitId} غير متاحة للحجز {BookingId} في التواريخ من {CheckIn} إلى {CheckOut}. قد يكون هناك تعارض مع حجز آخر.",
                    booking.UnitId, request.BookingId, booking.CheckIn, booking.CheckOut);
                return ResultDto<bool>.Failure("الوحدة غير متاحة في التواريخ المحددة");
            }

            _logger.LogInformation("الوحدة {UnitId} متاحة للتأكيد", booking.UnitId);

            // تأكيد الحجز + قيد العمولة في ترانزاكشن واحدة
            await _unitOfWork.ExecuteInTransactionAsync(async () =>
            {
                booking.Status = BookingStatus.Confirmed;
                booking.UpdatedAt = DateTime.UtcNow;

                await _bookingRepository.UpdateAsync(booking, cancellationToken);
                await _bookingRepository.SaveChangesAsync(cancellationToken);

                var tx = await _financialAccountingService.RecordBookingConfirmationTransactionAsync(
                    booking.Id,
                    _currentUserService.UserId);
                if (tx == null)
                    throw new InvalidOperationException("FAILED_TO_RECORD_BOOKING_CONFIRMATION_TX");
            }, cancellationToken);

            // تسجيل العملية في سجل التدقيق
            await _auditService.LogAuditAsync(
                entityType: nameof(Booking),
                entityId: booking.Id,
                action: AuditAction.APPROVE,
                oldValues: null,
                newValues: System.Text.Json.JsonSerializer.Serialize(new { Status = booking.Status.ToString() }),
                performedBy: _currentUserService.UserId,
                notes: $"تم تأكيد الحجز بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})",
                cancellationToken: cancellationToken);

            // إرسال حدث تأكيد الحجز
            await _eventPublisher.PublishAsync(new BookingConfirmedEvent
            {
                BookingId = booking.Id,
                ConfirmedBookingId = booking.Id,
                UserId = booking.UserId,
                UnitId = booking.UnitId,
                PropertyId = propertyEntity.Id,
                ConfirmedAt = DateTime.UtcNow,
                ConfirmedBy = _currentUserService.UserId,
                ConfirmedAmount = booking.TotalPrice.Amount,
                CheckInDate = booking.CheckIn,
                CheckOutDate = booking.CheckOut,
                ConfirmationNotes = "",
                OccurredAt = DateTime.UtcNow,
                EventId = Guid.NewGuid(),
                OccurredOn = DateTime.UtcNow,
                EventType = nameof(BookingConfirmedEvent),
                Version = 1,
                CorrelationId = booking.Id.ToString()
            }, cancellationToken);

            // تحديث فهرس الإتاحة بعد تأكيد الحجز مع retry mechanism
            var indexingSuccess = false;
            var indexingAttempts = 0;
            const int maxIndexingAttempts = 3;

            while (!indexingSuccess && indexingAttempts < maxIndexingAttempts)
            {
                try
                {
                    indexingAttempts++;
                    var from = DateTime.UtcNow.Date;
                    var to = from.AddMonths(6);
                    var schedules = await _scheduleRepository.GetByUnitAndDateRangeAsync(booking.UnitId, from, to);
                    var availableRanges = schedules
                        .Where(s => s.Status == "Available")
                        .Select(s => (s.Date, s.Date.AddDays(1)))
                        .ToList();

                    await _indexingService.OnAvailabilityChangedAsync(booking.UnitId, cancellationToken);
                    indexingSuccess = true;
                    _logger.LogInformation("✅ تم تحديث فهرس الإتاحة بنجاح بعد تأكيد الحجز {BookingId} (محاولة {Attempt}/{Max})",
                        booking.Id, indexingAttempts, maxIndexingAttempts);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "⚠️ فشلت محاولة {Attempt}/{Max} لتحديث فهرس الإتاحة بعد تأكيد الحجز {BookingId}",
                        indexingAttempts, maxIndexingAttempts, booking.Id);

                    if (indexingAttempts < maxIndexingAttempts)
                    {
                        await Task.Delay(TimeSpan.FromSeconds(Math.Pow(2, indexingAttempts - 1)), cancellationToken);
                    }
                    else
                    {
                        _logger.LogCritical("❌ CRITICAL: فشل تحديث فهرس الإتاحة بعد {Attempts} محاولات للحجز {BookingId}. " +
                            "الفهرس غير متطابق! يجب تشغيل re-index يدوي.",
                            maxIndexingAttempts, booking.Id);
                    }
                }
            }

            // إرسال إشعار للضيف (عربي فقط)
            var bookingNumber = $"BK-{booking.Id.ToString("N")[..8].ToUpperInvariant()}";
            await _notificationService.SendAsync(new NotificationRequest
            {
                UserId = booking.UserId,
                Type = NotificationType.BookingConfirmed,
                Title = "تم تأكيد الحجز / Booking confirmed",
                Message = $"تم تأكيد حجزك بنجاح. رقم الحجز: {bookingNumber}. / Your booking has been confirmed successfully. Booking number: {bookingNumber}.",
                Data = new { BookingId = booking.Id, BookingNumber = bookingNumber }
            }, cancellationToken);

            // إرسال إشعار لمالك الكيان
            if (propertyEntity.OwnerId != Guid.Empty)
            {
                await _notificationService.SendAsync(new NotificationRequest
                {
                    UserId = propertyEntity.OwnerId,
                    Type = NotificationType.BookingConfirmed,
                    Title = "تم تأكيد حجز / A booking has been confirmed",
                    Message = $"تم تأكيد حجز في وحدتك. رقم الحجز: {bookingNumber}. / A booking in your unit has been confirmed. Booking number: {bookingNumber}.",
                    Data = new { BookingId = booking.Id, UnitId = unitEntity.Id, BookingNumber = bookingNumber }
                }, cancellationToken);
            }

            _logger.LogInformation("تم تأكيد الحجز {BookingId} بنجاح", booking.Id);

            return ResultDto<bool>.Succeeded(true, "تم تأكيد الحجز بنجاح");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في تأكيد الحجز {BookingId}", request.BookingId);
            return ResultDto<bool>.Failed("حدث خطأ أثناء تأكيد الحجز");
        }
    }

    private async Task<ResultDto<bool>> ValidateAuthorizationAsync(
        ConfirmBookingCommand request,
        YemenBooking.Core.Entities.Unit unit,
        Property property,
        CancellationToken cancellationToken)
    {
        var currentUserId = _currentUserService.UserId;
        var errors = new List<string>();

        // التحقق من صحة الطلب
        var validationResult = await _validationService.ValidateAsync(request, cancellationToken);
        if (!validationResult.IsValid)
        {
            errors.AddRange(validationResult.Errors.Select(e => e.Message));
        }

        var isAdmin = HasRole("Admin");
        var isOwner = HasRole("Owner");
        var isStaff = HasRole("Staff");
        var scopedPropertyId = _currentUserService.PropertyId;
        var hasPropertyScope = scopedPropertyId.HasValue &&
                               scopedPropertyId.Value != Guid.Empty &&
                               scopedPropertyId.Value == property.Id;

        // Admin: صلاحية كاملة
        if (isAdmin)
        {
            return ResultDto<bool>.Succeeded(true);
        }

        // Owner: يجب أن يكون مالك العقار المرتبط بالحجز
        if (isOwner)
        {
            if (property.OwnerId != _currentUserService.UserId && !hasPropertyScope)
            {
                errors.Add("ليس لديك الصلاحية لتأكيد هذا الحجز / You do not own this property's booking");
            }
        }
        // Staff: يجب أن يكون موظفًا في نفس الكيان
        else if (isStaff)
        {
            if (!_currentUserService.IsStaffInProperty(unit.PropertyId))
            {
                errors.Add("لست موظفًا في هذا الكيان / You are not a staff member of this property");
            }
        }
        else
        {
            errors.Add("ليس لديك الصلاحية لتأكيد هذا الحجز / You do not have permission to confirm this booking");
        }

        if (errors.Any())
        {
            return ResultDto<bool>.Failed(string.Join("\n", errors));
        }

        return ResultDto<bool>.Succeeded(true);
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

    private ResultDto<bool> ValidateBookingState(Booking booking)
    {
        // يمكن تأكيد الحجوزات المعلقة فقط
        if (booking.Status != BookingStatus.Pending)
        {
            return ResultDto<bool>.Failed($"لا يمكن تأكيد الحجز في الحالة الحالية: {booking.Status}");
        }

        return ResultDto<bool>.Succeeded(true);
    }

    private async Task<ResultDto<bool>> ValidateBusinessRulesAsync(Booking booking, CancellationToken cancellationToken)
    {
        // التحقق من اكتمال الدفع إذا كان مطلوباً
        var payments = await _paymentRepository.GetPaymentsByBookingAsync(booking.Id, cancellationToken);

        var totalPaid = payments
            .Where(p => p.Status == PaymentStatus.Successful)
            .Sum(p => p.Amount.Amount);
        var requiredAmount = booking.TotalPrice.Amount;

        // التحقق من سياسة الدفع للكيان
        var unit = await _unitRepository.GetUnitByIdAsync(booking.UnitId, cancellationToken);
        var property = unit == null
            ? null
            : await _propertyRepository.GetPropertyByIdAsync(unit.PropertyId, cancellationToken);
        if (unit == null || property == null)
        {
            return ResultDto<bool>.Failed("تعذر تحميل بيانات الوحدة أو العقار المرتبط بالحجز");
        }
        var paymentPolicy = await GetPropertyPaymentPolicyAsync(property.Id, cancellationToken);

        if (paymentPolicy != null && paymentPolicy.RequireFullPaymentBeforeConfirmation)
        {
            if (totalPaid < requiredAmount)
            {
                return ResultDto<bool>.Failed($"يجب دفع المبلغ كاملاً ({requiredAmount} {booking.TotalPrice.Currency}) قبل التأكيد");
            }
        }
        else if (paymentPolicy != null && paymentPolicy.MinimumDepositPercentage > 0)
        {
            var minimumRequired = requiredAmount * (paymentPolicy.MinimumDepositPercentage / 100);
            if (totalPaid < minimumRequired)
            {
                return ResultDto<bool>.Failed($"يجب دفع مبلغ لا يقل عن {minimumRequired} {booking.TotalPrice.Currency} قبل التأكيد");
            }
        }

        // التحقق من أن تاريخ الوصول لم يمضي
        {
            var userToday = (await _currentUserService.ConvertFromUtcToUserLocalAsync(DateTime.UtcNow)).Date;
            var checkInLocal = (await _currentUserService.ConvertFromUtcToUserLocalAsync(booking.CheckIn)).Date;
            if (checkInLocal < userToday)
            {
                return ResultDto<bool>.Failed("لا يمكن تأكيد حجز انتهت فترة الوصول المحددة له");
            }
        }

        return ResultDto<bool>.Succeeded(true);
    }

    private async Task<PropertyPolicy> GetPropertyPaymentPolicyAsync(Guid propertyId, CancellationToken cancellationToken)
    {
        return await _policyRepository.FirstOrDefaultAsync(
            p => p.PropertyId == propertyId && p.Type == PolicyType.Payment,
            cancellationToken);
    }
}

/// <summary>
/// يمثل عنصرًا ضمن نطاق الحجوزات.
/// Represents an item in the booking-related feature area.
/// </summary>
public class BookingConfirmedEvent : IBookingConfirmedEvent
{
    /// <summary>
    /// معرّف الحجز
    /// Booking identifier.
    /// </summary>
    public Guid BookingId { get; set; }
    /// <summary>
    /// معرّف مؤكد الحجز
    /// Confirmed Booking identifier.
    /// </summary>
    public Guid ConfirmedBookingId { get; set; }
    /// <summary>
    /// معرّف المستخدم
    /// User identifier.
    /// </summary>
    public Guid? UserId { get; set; }
    /// <summary>
    /// معرّف الوحدة
    /// Unit identifier.
    /// </summary>
    public Guid UnitId { get; set; }
    /// <summary>
    /// معرّف العقار
    /// Property identifier.
    /// </summary>
    public Guid PropertyId { get; set; }
    /// <summary>
    /// يمثل مؤكد At.
    /// Represents confirmed at.
    /// </summary>
    public DateTime ConfirmedAt { get; set; }
    /// <summary>
    /// معرّف مؤكد بحسب
    /// Confirmed by identifier.
    /// </summary>
    public Guid? ConfirmedBy { get; set; }
    /// <summary>
    /// يمثل مؤكد المبلغ.
    /// Represents confirmed amount.
    /// </summary>
    public decimal ConfirmedAmount { get; set; }
    /// <summary>
    /// يمثل تسجيل الوصول التاريخ.
    /// Represents check in date.
    /// </summary>
    public DateTime CheckInDate { get; set; }
    /// <summary>
    /// يمثل تسجيل المغادرة التاريخ.
    /// Represents check out date.
    /// </summary>
    public DateTime CheckOutDate { get; set; }
    /// <summary>
    /// يمثل Confirmation الملاحظات.
    /// Represents confirmation notes.
    /// </summary>
    public string ConfirmationNotes { get; set; } = string.Empty;
    /// <summary>
    /// يمثل وقت الحدوث.
    /// Represents occurred at.
    /// </summary>
    public DateTime OccurredAt { get; set; } = DateTime.UtcNow;
    /// <summary>
    /// معرّف الحدث
    /// Event identifier.
    /// </summary>
    public Guid EventId { get; set; } = Guid.NewGuid();
    /// <summary>
    /// يمثل تاريخ الحدوث.
    /// Represents occurred on.
    /// </summary>
    public DateTime OccurredOn { get; set; } = DateTime.UtcNow;
    /// <summary>
    /// يمثل نوع الحدث.
    /// Represents event type.
    /// </summary>
    public string EventType { get; set; } = nameof(BookingConfirmedEvent);
    /// <summary>
    /// يمثل الإصدار.
    /// Represents version.
    /// </summary>
    public int Version { get; set; } = 1;
    /// <summary>
    /// يمثل معرّف الارتباط.
    /// Represents correlation id.
    /// </summary>
    public string CorrelationId { get; set; } = string.Empty;
}
