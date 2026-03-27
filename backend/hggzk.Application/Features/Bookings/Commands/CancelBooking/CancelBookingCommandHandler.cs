
using MediatR;
using Microsoft.Extensions.Logging;
using System.Globalization;
using System.Linq;
using YemenBooking.Application.Features.Bookings;
using YemenBooking.Core.Interfaces;
using YemenBooking.Application.Features.Notifications.Services;
using System.Text.Json;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.SearchAndFilters.Services;
using YemenBooking.Core.Entities;
using YemenBooking.Application.Features.Payments.Commands.RefundPayment;
using YemenBooking.Core.Notifications;

namespace YemenBooking.Application.Features.Bookings.Commands.CancelBooking;

/// <summary>
/// يعالج طلب إلغاء الحجز ويطبق سياسات الإلغاء والاسترداد المرتبطة به.
/// Handles booking cancellation requests and applies the related cancellation and refund policies.
/// </summary>
public class CancelBookingCommandHandler : IRequestHandler<CancelBookingCommand, ResultDto<bool>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IAuditService _auditService;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<CancelBookingCommandHandler> _logger;
    private readonly IBookingRepository _bookingRepository;
    private readonly IUnitRepository _unitRepository;
    private readonly IDailyUnitScheduleRepository _scheduleRepository;
    private readonly IDailyUnitScheduleService _scheduleService;
    private readonly IMediator _mediator;
    private readonly IUnitIndexingService _indexingService;
    private readonly IPropertyRepository _propertyRepository;
    private readonly IPaymentRepository _paymentRepository;
    private readonly INotificationService _notificationService;


/// <summary>
/// ينشئ مثيلًا جديدًا مع الاعتمادات المطلوبة.
/// Creates a new instance with its required dependencies.
/// </summary>
    public CancelBookingCommandHandler(
        IUnitOfWork unitOfWork,
        IAuditService auditService,
        ICurrentUserService currentUserService,
        ILogger<CancelBookingCommandHandler> logger,
        IBookingRepository bookingRepository,
        IUnitRepository unitRepository,
        IDailyUnitScheduleRepository scheduleRepository,
        IDailyUnitScheduleService scheduleService,
        IMediator mediator,
        IUnitIndexingService indexingService,
        IPropertyRepository propertyRepository,
        IPaymentRepository paymentRepository,
        INotificationService notificationService)
    {
        _unitOfWork = unitOfWork;
        _auditService = auditService;
        _currentUserService = currentUserService;
        _logger = logger;
        _bookingRepository = bookingRepository;
        _unitRepository = unitRepository;
        _scheduleRepository = scheduleRepository;
        _scheduleService = scheduleService;
        _mediator = mediator;
        _indexingService = indexingService;
        _propertyRepository = propertyRepository;
        _paymentRepository = paymentRepository;
        _notificationService = notificationService;
    }

/// <summary>
/// يعالج هذا المكوّن المرتبط بـ الحجوزات ويعيد النتيجة المطلوبة.
/// Handles the corresponding booking-related command or query and returns the requested result.
/// </summary>
    public async Task<ResultDto<bool>> Handle(CancelBookingCommand request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("بدء إلغاء الحجز {BookingId} من قبل المستخدم {UserId}", request.BookingId, request.UserId);

        var booking = await _bookingRepository.GetBookingByIdAsync(request.BookingId, cancellationToken);
        if (booking == null)
        {
            return ResultDto<bool>.Failure("الحجز غير موجود");
        }

        var previousStatus = booking.Status;

        if (booking.Status == BookingStatus.Cancelled ||
            booking.Status == BookingStatus.Completed ||
            booking.Status == BookingStatus.CheckedIn)
        {
            return ResultDto<bool>.Failure("لا يمكن إلغاء هذا الحجز في حالته الحالية");
        }
        var roles = _currentUserService.UserRoles;
        var isAdmin = roles.Any(r => string.Equals(r, "Admin", StringComparison.OrdinalIgnoreCase));
        var currentUserId = _currentUserService.UserId;

        if (!isAdmin && request.UserId != Guid.Empty && request.UserId != currentUserId)
        {
            return ResultDto<bool>.Failure("بيانات المستخدم غير صحيحة");
        }

        if (booking.UserId != currentUserId && !isAdmin)
        {
            var unitForAuth = await _unitRepository.GetByIdAsync(booking.UnitId, cancellationToken);
            if (unitForAuth == null)
            {
                return ResultDto<bool>.Failure("الوحدة غير موجودة");
            }
            var propertyForAuth = await _propertyRepository.GetByIdAsync(unitForAuth.PropertyId, cancellationToken);
            if (propertyForAuth == null || propertyForAuth.OwnerId != currentUserId)
            {
                return ResultDto<bool>.Failure("ليس لديك صلاحية لإلغاء هذا الحجز");
            }
        }
        // سياسة الإلغاء: للحجوزات المؤكدة فقط
        var unit = await _unitRepository.GetByIdAsync(booking.UnitId, cancellationToken);
        if (unit == null)
        {
            return ResultDto<bool>.Failure("الوحدة غير موجودة");
        }

        var hasPolicySnapshot = !string.IsNullOrWhiteSpace(booking.PolicySnapshot);
        var snapshotInfo = GetCancellationSnapshotInfo(booking.PolicySnapshot);

        if (booking.Status == BookingStatus.Confirmed && !isAdmin)
        {
            var allowsCancellation = hasPolicySnapshot
                ? (snapshotInfo.AllowsCancellation ?? true)
                : (snapshotInfo.AllowsCancellation ?? unit.AllowsCancellation);
            if (!allowsCancellation)
            {
                return ResultDto<bool>.Failure(
                    "سياسة الإلغاء الخاصة بهذا الحجز لا تسمح بإلغاء الحجز بعد التأكيد",
                    errorCode: "CANCELLATION_NOT_ALLOWED",
                    showAsDialog: true
                );
            }

            int? windowDays = hasPolicySnapshot
                ? snapshotInfo.CancellationWindowDays
                : (snapshotInfo.CancellationWindowDays ?? unit.CancellationWindowDays);

            if (!hasPolicySnapshot && !windowDays.HasValue)
            {
                var propertyPolicy = await _propertyRepository.GetCancellationPolicyAsync(unit.PropertyId, cancellationToken);
                windowDays = propertyPolicy?.CancellationWindowDays;
            }

            if (snapshotInfo.CancellationDaysBeforeCheckIn.HasValue)
            {
                windowDays = windowDays.HasValue
                    ? Math.Max(windowDays.Value, snapshotInfo.CancellationDaysBeforeCheckIn.Value)
                    : snapshotInfo.CancellationDaysBeforeCheckIn.Value;
            }

            if (windowDays.HasValue || snapshotInfo.CancellationHoursBeforeCheckIn.HasValue)
            {
                var userNow = await _currentUserService.ConvertFromUtcToUserLocalAsync(DateTime.UtcNow);
                var checkInLocal = await _currentUserService.ConvertFromUtcToUserLocalAsync(booking.CheckIn);
                var userToday = userNow.Date;
                var checkInLocalDate = checkInLocal.Date;
                var daysBeforeCheckIn = (checkInLocalDate - userToday).TotalDays;

                if (daysBeforeCheckIn < 0)
                {
                    return ResultDto<bool>.Failure(
                        "لا يمكن إلغاء الحجز بعد وقت تسجيل الوصول حسب سياسة الإلغاء",
                        errorCode: "CANCELLATION_AFTER_CHECKIN",
                        showAsDialog: true
                    );
                }

                if (snapshotInfo.CancellationHoursBeforeCheckIn.HasValue)
                {
                    var hoursBeforeCheckIn = (checkInLocal - userNow).TotalHours;
                    if (hoursBeforeCheckIn < snapshotInfo.CancellationHoursBeforeCheckIn.Value)
                    {
                        return ResultDto<bool>.Failure(
                            "لا يمكن إلغاء الحجز خلال نافذة الإلغاء المحددة حسب سياسة الإلغاء",
                            errorCode: "CANCELLATION_WINDOW_EXCEEDED",
                            showAsDialog: true
                        );
                    }
                }

                if (daysBeforeCheckIn < windowDays.Value)
                {
                    return ResultDto<bool>.Failure(
                        $"لا يمكن إلغاء الحجز خلال {windowDays.Value} يوم/أيام قبل تاريخ الوصول حسب سياسة الإلغاء",
                        errorCode: "CANCELLATION_WINDOW_EXCEEDED",
                        showAsDialog: true
                    );
                }
            }
        }

        // التحقق من وجود مدفوعات ناجحة للحجز
        var payments = await _paymentRepository.GetPaymentsByBookingAsync(booking.Id, cancellationToken);
        var hasSuccessfulPayments = payments.Any(p => p.Status == PaymentStatus.Successful || p.Status == PaymentStatus.PartiallyRefunded);

        var allowedRefundPercentage = isAdmin ? 100 : GetAllowedRefundPercentage(snapshotInfo);

        if (hasSuccessfulPayments && !request.RefundPayments)
        {
            var canCancelWithoutRefund = isAdmin || allowedRefundPercentage <= 0;
            if (!canCancelWithoutRefund)
            {
                return ResultDto<bool>.Failure(
                    "لا يمكن إلغاء حجز يحتوي على مدفوعات. هل تريد استرداد المدفوعات ثم إلغاء الحجز؟",
                    errorCode: "PAYMENTS_EXIST",
                    showAsDialog: true
                );
            }
        }

        if (hasSuccessfulPayments && request.RefundPayments)
        {
            var successfulPays = payments
                .Where(p => p.Status == PaymentStatus.Successful)
                .OrderBy(p => p.PaymentDate)
                .ToList();

            var totalPaid = payments
                .Where(p => p.Status == PaymentStatus.Successful || p.Status == PaymentStatus.PartiallyRefunded)
                .Sum(p => p.Amount.Amount);

            var allowedRefundTotal = isAdmin
                ? totalPaid
                : decimal.Round(totalPaid * (allowedRefundPercentage / 100m), 2);

            var remaining = allowedRefundTotal;

            foreach (var pay in successfulPays)
            {
                if (remaining <= 0m)
                {
                    break;
                }

                var amountToRefund = Math.Min(pay.Amount.Amount, remaining);
                if (amountToRefund <= 0m)
                {
                    continue;
                }

                var refundCmd = new RefundPaymentCommand
                {
                    PaymentId = pay.Id,
                    RefundAmount = new MoneyDto { Amount = amountToRefund, Currency = pay.Amount.Currency, ExchangeRate = 1 },
                    RefundReason = request.CancellationReason ?? "Cancellation"
                };
                var refundRes = await _mediator.Send(refundCmd, cancellationToken);
                if (!refundRes.Success)
                {
                    return ResultDto<bool>.Failure(
                        refundRes.Message ?? "فشل استرداد المبالغ قبل الإلغاء",
                        errorCode: refundRes.ErrorCode ?? "REFUND_FAILED_BEFORE_CANCELLATION",
                        showAsDialog: refundRes.ShowAsDialog);
                }

                remaining = decimal.Round(remaining - amountToRefund, 2);
            }
        }

        await _unitOfWork.ExecuteInTransactionAsync(async () =>
        {
            // Passed policy checks and handled payments: proceed to cancel
            booking.Status = BookingStatus.Cancelled;
            booking.CancellationReason = request.CancellationReason;
            booking.UpdatedAt = DateTime.UtcNow;
            await _bookingRepository.UpdateAsync(booking, cancellationToken);

            // تحرير فترة الحجز في الجداول اليومية وإعادتها إلى متاحة
            var bookingSchedules = await _scheduleRepository.GetByBookingIdAsync(booking.Id);
            var schedulesToUpdate = bookingSchedules.ToList();

            foreach (var schedule in schedulesToUpdate)
            {
                schedule.Status = AvailabilityStatus.Available;
                schedule.Reason = null;
                schedule.Notes = null;
                schedule.BookingId = null;
                schedule.UpdatedAt = DateTime.UtcNow;
            }

            if (schedulesToUpdate.Any())
            {
                await _scheduleRepository.BulkUpdateAsync(schedulesToUpdate);
            }

            await _bookingRepository.SaveChangesAsync(cancellationToken);
        }, cancellationToken);

        // ✅ تحديث مباشر لفهرس الإتاحة - Critical للبحث
        // إذا فشل، نحتاج إعادة المحاولة لأن الفهرس سيصبح غير متطابق
        var indexingSuccess = false;
        var indexingAttempts = 0;
        const int maxIndexingAttempts = 3;

        while (!indexingSuccess && indexingAttempts < maxIndexingAttempts)
        {
            try
            {
                indexingAttempts++;
                var bookingToUpdate = await _bookingRepository.GetByIdAsync(request.BookingId, cancellationToken);
                if (bookingToUpdate != null)
                {
                    var from = DateTime.UtcNow.Date;
                    var to = from.AddMonths(6);
                    var periods = await _scheduleRepository.GetAvailableDaysAsync(bookingToUpdate.UnitId, from, to);
                    var availableRanges = periods
                        .Select(p => (p.Date, p.Date.AddDays(1)))
                        .ToList();

                    await _indexingService.OnAvailabilityChangedAsync(bookingToUpdate.UnitId, cancellationToken);
                    indexingSuccess = true;
                    _logger.LogInformation("✅ تم تحديث فهرس الإتاحة بنجاح بعد إلغاء الحجز {BookingId} (محاولة {Attempt}/{Max})",
                        request.BookingId, indexingAttempts, maxIndexingAttempts);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "⚠️ فشلت محاولة {Attempt}/{Max} لتحديث فهرس الإتاحة بعد إلغاء الحجز {BookingId}",
                    indexingAttempts, maxIndexingAttempts, request.BookingId);

                if (indexingAttempts < maxIndexingAttempts)
                {
                    await Task.Delay(TimeSpan.FromSeconds(1 * indexingAttempts), cancellationToken); // Exponential backoff
                }
                else
                {
                    // ❌ Critical failure: الفهرس لن يتطابق مع الواقع
                    _logger.LogCritical("❌ CRITICAL: فشل تحديث فهرس الإتاحة بعد {Attempts} محاولات للحجز {BookingId}. " +
                        "الفهرس غير متطابق! يجب تشغيل re-index يدوي.",
                        maxIndexingAttempts, request.BookingId);

                    // TODO: إضافة إلى background job queue للمحاولة لاحقاً
                }
            }
        }

        var performerName = _currentUserService.Username;
        var performerId = _currentUserService.UserId;
        var notes = $"تم إلغاء الحجز {booking.Id} بواسطة {performerName} (ID={performerId})";
        await _auditService.LogAuditAsync(
            entityType: "BookingDto",
            entityId: booking.Id,
            action: AuditAction.DELETE,
            oldValues: JsonSerializer.Serialize(new { booking.Id, PreviousStatus = previousStatus.ToString() }),
            newValues: null,
            performedBy: performerId,
            notes: notes,
            cancellationToken: cancellationToken);

        // إرسال إشعار للضيف يتضمن سبب الإلغاء (عربي فقط)
        try
        {
            var reason = string.IsNullOrWhiteSpace(booking.CancellationReason)
                ? (string.IsNullOrWhiteSpace(request.CancellationReason) ? "غير محدد" : request.CancellationReason!)
                : booking.CancellationReason!;

            var bookingNumber = $"BK-{booking.Id.ToString("N")[..8].ToUpperInvariant()}";

            await _notificationService.SendAsync(new NotificationRequest
            {
                UserId = booking.UserId,
                Type = NotificationType.BookingCancelled,
                Title = "تم إلغاء الحجز",
                Message = $"تم إلغاء حجزك. رقم الحجز: {bookingNumber}. السبب: {reason}.",
                Data = new { BookingId = booking.Id, BookingNumber = bookingNumber, Reason = reason }
            }, cancellationToken);

            // إشعار مالك العقار
            var unitEntity = await _unitRepository.GetByIdAsync(booking.UnitId, cancellationToken);
            if (unitEntity != null)
            {
                var propertyEntity = await _propertyRepository.GetByIdAsync(unitEntity.PropertyId, cancellationToken);
                if (propertyEntity != null && propertyEntity.OwnerId != Guid.Empty)
                {
                    await _notificationService.SendAsync(new NotificationRequest
                    {
                        UserId = propertyEntity.OwnerId,
                        Type = NotificationType.BookingCancelled,
                        Title = "تم إلغاء حجز",
                        Message = $"تم إلغاء حجز في وحدتك. رقم الحجز: {bookingNumber}. السبب: {reason}.",
                        Data = new { BookingId = booking.Id, UnitId = unitEntity.Id, BookingNumber = bookingNumber, Reason = reason }
                    }, cancellationToken);
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "فشل إرسال إشعار إلغاء الحجز للمستخدم {UserId} للحجز {BookingId}", booking.UserId, booking.Id);
            // لا نُفشل العملية الأساسية بسبب فشل الإشعار
        }

        return ResultDto<bool>.Succeeded(true, "تم إلغاء الحجز بنجاح");
    }

    private sealed class CancellationSnapshotInfo
    {
        /// <summary>
        /// يحدد ما إذا كان الإلغاء مسموحًا.
        /// Indicates whether cancellation is allowed.
        /// </summary>
        public bool? AllowsCancellation { get; set; }
        /// <summary>
        /// عدد الأيام المسموح خلالها بالإلغاء قبل الوصول.
        /// Number of days before arrival during which cancellation remains allowed.
        /// </summary>
        public int? CancellationWindowDays { get; set; }
        /// <summary>
        /// عدد الأيام قبل تسجيل الوصول التي يبقى فيها الإلغاء متاحًا.
        /// Number of days before check-in during which cancellation remains available.
        /// </summary>
        public int? CancellationDaysBeforeCheckIn { get; set; }
        /// <summary>
        /// عدد الساعات قبل تسجيل الوصول التي يبقى فيها الإلغاء متاحًا.
        /// Number of hours before check-in during which cancellation remains available.
        /// </summary>
        public int? CancellationHoursBeforeCheckIn { get; set; }
        /// <summary>
        /// يحدد ما إذا كان الإلغاء مجانيًا بالكامل.
        /// Indicates whether cancellation is fully free.
        /// </summary>
        public bool? CancellationFreeCancel { get; set; }
        /// <summary>
        /// يحدد ما إذا كان الإلغاء يمنح استردادًا كاملًا.
        /// Indicates whether cancellation results in a full refund.
        /// </summary>
        public bool? CancellationFullRefund { get; set; }
        /// <summary>
        /// نسبة الاسترداد المسموح بها عند الإلغاء.
        /// Refund percentage allowed on cancellation.
        /// </summary>
        public int? CancellationRefundPercentage { get; set; }
        /// <summary>
        /// يحدد ما إذا كان الإلغاء غير قابل للاسترداد.
        /// Indicates whether cancellation is non-refundable.
        /// </summary>
        public bool? CancellationNonRefundable { get; set; }
        /// <summary>
        /// نسبة الجزاء المطبقة بعد انتهاء مهلة الإلغاء.
        /// Penalty percentage applied after the cancellation deadline.
        /// </summary>
        public decimal? CancellationPenaltyAfterDeadlinePercentage { get; set; }
    }

    private static CancellationSnapshotInfo GetCancellationSnapshotInfo(string? policySnapshot)
    {
        var info = new CancellationSnapshotInfo();
        if (string.IsNullOrWhiteSpace(policySnapshot))
        {
            return info;
        }

        try
        {
            using var doc = JsonDocument.Parse(policySnapshot);
            var root = doc.RootElement;

            if (root.TryGetProperty("UnitOverrides", out var overridesEl) && overridesEl.ValueKind == JsonValueKind.Object)
            {
                if (overridesEl.TryGetProperty("AllowsCancellation", out var allowsEl) &&
                    (allowsEl.ValueKind == JsonValueKind.True || allowsEl.ValueKind == JsonValueKind.False))
                {
                    info.AllowsCancellation = allowsEl.GetBoolean();
                }

                if (overridesEl.TryGetProperty("CancellationWindowDays", out var wndEl) && wndEl.ValueKind == JsonValueKind.Number)
                {
                    info.CancellationWindowDays = wndEl.GetInt32();
                }
            }

            if (root.TryGetProperty("Policies", out var policiesEl) && policiesEl.ValueKind == JsonValueKind.Array)
            {
                foreach (var p in policiesEl.EnumerateArray())
                {
                    var typeStr = p.TryGetProperty("Type", out var tEl) ? tEl.GetString() : null;
                    if (string.IsNullOrWhiteSpace(typeStr) ||
                        !typeStr.Equals("Cancellation", StringComparison.OrdinalIgnoreCase))
                    {
                        continue;
                    }

                    if (p.TryGetProperty("CancellationWindowDays", out var policyWndEl) && policyWndEl.ValueKind == JsonValueKind.Number)
                    {
                        info.CancellationWindowDays ??= policyWndEl.GetInt32();
                    }

                    if (p.TryGetProperty("Rules", out var rulesEl) && rulesEl.ValueKind == JsonValueKind.String)
                    {
                        var rulesJson = rulesEl.GetString();
                        PopulateCancellationInfoFromRulesJson(info, rulesJson);
                    }

                    break;
                }
            }
        }
        catch
        {
            return info;
        }

        return info;
    }

    private static void PopulateCancellationInfoFromRulesJson(CancellationSnapshotInfo info, string? rulesJson)
    {
        if (info == null || string.IsNullOrWhiteSpace(rulesJson))
        {
            return;
        }

        try
        {
            using var rulesDoc = JsonDocument.Parse(rulesJson);
            var rules = rulesDoc.RootElement;
            if (rules.ValueKind != JsonValueKind.Object)
            {
                return;
            }

            if (rules.TryGetProperty("freeCancel", out var freeCancelEl) &&
                (freeCancelEl.ValueKind == JsonValueKind.True || freeCancelEl.ValueKind == JsonValueKind.False))
            {
                info.CancellationFreeCancel = freeCancelEl.GetBoolean();
            }

            if (rules.TryGetProperty("fullRefund", out var fullRefundEl) &&
                (fullRefundEl.ValueKind == JsonValueKind.True || fullRefundEl.ValueKind == JsonValueKind.False))
            {
                info.CancellationFullRefund = fullRefundEl.GetBoolean();
            }

            if (rules.TryGetProperty("refundPercentage", out var refundPctEl) && refundPctEl.ValueKind == JsonValueKind.Number)
            {
                info.CancellationRefundPercentage = refundPctEl.GetInt32();
            }

            if (rules.TryGetProperty("daysBeforeCheckIn", out var daysEl) && daysEl.ValueKind == JsonValueKind.Number)
            {
                info.CancellationDaysBeforeCheckIn = daysEl.GetInt32();
            }

            if (rules.TryGetProperty("hoursBeforeCheckIn", out var hoursEl) && hoursEl.ValueKind == JsonValueKind.Number)
            {
                info.CancellationHoursBeforeCheckIn = hoursEl.GetInt32();
            }

            if (rules.TryGetProperty("nonRefundable", out var nonRefundableEl) &&
                (nonRefundableEl.ValueKind == JsonValueKind.True || nonRefundableEl.ValueKind == JsonValueKind.False))
            {
                info.CancellationNonRefundable = nonRefundableEl.GetBoolean();
            }

            string? penaltyStr = null;
            if (rules.TryGetProperty("penaltyAfterDeadline", out var penaltyEl) && penaltyEl.ValueKind == JsonValueKind.String)
            {
                penaltyStr = penaltyEl.GetString();
            }
            else if (rules.TryGetProperty("penaltyAfter", out var penaltyAfterEl) && penaltyAfterEl.ValueKind == JsonValueKind.String)
            {
                penaltyStr = penaltyAfterEl.GetString();
            }

            info.CancellationPenaltyAfterDeadlinePercentage = TryExtractPercentage(penaltyStr);
        }
        catch
        {
            return;
        }
    }

    private static int GetAllowedRefundPercentage(CancellationSnapshotInfo info)
    {
        if (info.CancellationNonRefundable == true)
        {
            return 0;
        }

        if (info.CancellationFullRefund == true)
        {
            return 100;
        }

        if (info.CancellationRefundPercentage.HasValue)
        {
            return Math.Clamp(info.CancellationRefundPercentage.Value, 0, 100);
        }

        if (info.CancellationFreeCancel == true)
        {
            return 100;
        }

        if (info.CancellationPenaltyAfterDeadlinePercentage.HasValue)
        {
            var pct = 100m - info.CancellationPenaltyAfterDeadlinePercentage.Value;
            return (int)Math.Clamp(decimal.Round(pct, 0), 0, 100);
        }

        return 100;
    }

    private static decimal? TryExtractPercentage(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return null;
        }

        var trimmed = value.Trim();
        var numeric = new string(trimmed.Where(c => char.IsDigit(c) || c == '.' || c == ',').ToArray());
        if (string.IsNullOrWhiteSpace(numeric))
        {
            return null;
        }

        numeric = numeric.Replace(',', '.');
        if (decimal.TryParse(numeric, NumberStyles.Any, CultureInfo.InvariantCulture, out var parsed))
        {
            return parsed;
        }

        return null;
    }
}
