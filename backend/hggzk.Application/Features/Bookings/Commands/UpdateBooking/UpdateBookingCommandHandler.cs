using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Bookings;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;
using YemenBooking.Core.Interfaces;
using YemenBooking.Core.Interfaces.Events;
using YemenBooking.Core.ValueObjects;
using YemenBooking.Application.Features.AuditLog.Services;
using System.Linq;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Core.Notifications;
using YemenBooking.Application.Features.Notifications.Services;
using YemenBooking.Application.Contracts.Services.Scheduling;
using YemenBooking.Core.Interfaces.Repositories;
using System.Collections.Generic;

namespace YemenBooking.Application.Features.Bookings.Commands.UpdateBooking;

    /// <summary>
    /// يعالج مكوّن الحجوزات ويعيد النتيجة المطلوبة.
    /// Handles a booking-related component and returns the requested result.
    /// </summary>
public class UpdateBookingCommandHandler : IRequestHandler<UpdateBookingCommand, ResultDto<bool>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ICurrentUserService _currentUserService;
    private readonly IAvailabilityService _availabilityService;
    private readonly IDailyUnitScheduleRepository _scheduleRepository;
    private readonly IValidationService _validationService;
    private readonly IAuditService _auditService;
    private readonly IEventPublisher _eventPublisher;
    private readonly ILogger<UpdateBookingCommandHandler> _logger;
    private readonly INotificationService _notificationService;
    private readonly IPropertyServiceRepository _propertyServiceRepository;
    private readonly IBookingServiceRepository _bookingServiceRepository;
    private readonly IUnitRepository _unitRepository;
    private readonly IPropertyRepository _propertyRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IPolicyRepository _policyRepository;
    private readonly ICurrencySettingsService _currencySettingsService;

/// <summary>
/// ينشئ مثيلًا جديدًا مع الاعتمادات المطلوبة.
/// Creates a new instance with its required dependencies.
/// </summary>
    public UpdateBookingCommandHandler(
        IUnitOfWork unitOfWork,
        ICurrentUserService currentUserService,
        IAvailabilityService availabilityService,
        IDailyUnitScheduleRepository scheduleRepository,
        IValidationService validationService,
        IAuditService auditService,
        IEventPublisher eventPublisher,
        ILogger<UpdateBookingCommandHandler> logger,
        INotificationService notificationService,
        IPropertyServiceRepository propertyServiceRepository,
        IBookingServiceRepository bookingServiceRepository,
        IUnitRepository unitRepository,
        IPropertyRepository propertyRepository,
        IBookingRepository bookingRepository,
        IPolicyRepository policyRepository,
        ICurrencySettingsService currencySettingsService)
    {
        _unitOfWork = unitOfWork;
        _currentUserService = currentUserService;
        _availabilityService = availabilityService;
        _scheduleRepository = scheduleRepository;
        _validationService = validationService;
        _auditService = auditService;
        _eventPublisher = eventPublisher;
        _logger = logger;
        _notificationService = notificationService;
        _propertyServiceRepository = propertyServiceRepository;
        _bookingServiceRepository = bookingServiceRepository;
        _unitRepository = unitRepository;
        _propertyRepository = propertyRepository;
        _bookingRepository = bookingRepository;
        _policyRepository = policyRepository;
        _currencySettingsService = currencySettingsService;
    }

/// <summary>
/// يعالج هذا المكوّن المرتبط بـ الحجوزات ويعيد النتيجة المطلوبة.
/// Handles the corresponding booking-related command or query and returns the requested result.
/// </summary>
    public async Task<ResultDto<bool>> Handle(UpdateBookingCommand request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء معالجة أمر تحديث الحجز {BookingId}", request.BookingId);

            // Normalize any provided user-local dates to UTC.
            // تحويل أي تواريخ محلية واردة من المستخدم إلى UTC.
            if (request.CheckIn.HasValue)
            {
                request.CheckIn = await _currentUserService.ConvertFromUserLocalToUtcAsync(request.CheckIn.Value);
            }
            if (request.CheckOut.HasValue)
            {
                request.CheckOut = await _currentUserService.ConvertFromUserLocalToUtcAsync(request.CheckOut.Value);
            }

            // Validate booking existence.
            var booking = await _bookingRepository.GetBookingByIdAsync(request.BookingId, cancellationToken);
            if (booking == null)
            {
                _logger.LogWarning("الحجز غير موجود: {BookingId}", request.BookingId);
                return ResultDto<bool>.Failure("الحجز غير موجود.");
            }

            var authorizationValidation = await ValidateAuthorizationAsync(booking, cancellationToken);
            if (!authorizationValidation.IsSuccess)
            {
                return authorizationValidation;
            }

            // Validate booking state.
            var stateValidation = ValidateBookingState(booking);
            if (!stateValidation.IsSuccess)
            {
                return stateValidation;
            }

            // Validate input.
            var validationResult = await ValidateInputAsync(request, booking, cancellationToken);
            if (!validationResult.IsSuccess)
            {
                return validationResult;
            }

            // Validate business rules.
            var businessRulesValidation = await ValidateBusinessRulesAsync(request, booking, cancellationToken);
            if (!businessRulesValidation.IsSuccess)
            {
                return businessRulesValidation;
            }

            // Check unit availability for the new period.
            if (request.CheckIn.HasValue || request.CheckOut.HasValue)
            {
                var newCheckIn = request.CheckIn ?? booking.CheckIn;
                var newCheckOut = request.CheckOut ?? booking.CheckOut;
                var (newLocalCheckInDate, newLocalCheckOutDate) = await GetLocalDateRangeAsync(newCheckIn, newCheckOut);
                // Exclude the current booking from the availability check.
                var isAvailable = await _availabilityService.CheckAvailabilityAsync(
                    booking.UnitId,
                    newLocalCheckInDate,
                    newLocalCheckOutDate,
                    booking.Id);
                if (!isAvailable)
                {
                    return ResultDto<bool>.Failed("لا يمكن تحديث الحجز؛ الوحدة غير متاحة للفترة الجديدة");
                }
            }

            // Preserve the original values for change tracking.
            var originalCheckIn = booking.CheckIn;
            var originalCheckOut = booking.CheckOut;
            var originalGuestsCount = booking.GuestsCount;
            var originalTotalPrice = booking.TotalPrice;

            // Apply requested changes.
            if (request.CheckIn.HasValue)
                booking.CheckIn = request.CheckIn.Value;

            if (request.CheckOut.HasValue)
                booking.CheckOut = request.CheckOut.Value;

            if (request.GuestsCount.HasValue)
                booking.GuestsCount = request.GuestsCount.Value;

            // Synchronize services (add, update, delete) if included in the request.
            decimal servicesTotalAmount = 0m;
            string currency = booking.TotalPrice?.Currency ?? "YER";
            if (request.Services != null)
            {
                // Load the unit, currency, and property services.
                var unit = await _unitRepository.GetByIdAsync(booking.UnitId, cancellationToken);
                var bookingProperty = await _propertyRepository.GetByIdAsync(unit.PropertyId, cancellationToken);
                currency = bookingProperty?.Currency ?? currency;

                var currencies = await _currencySettingsService.GetCurrenciesAsync(cancellationToken);
                var isSupported = currencies.Any(c => string.Equals(c.Code, currency, StringComparison.OrdinalIgnoreCase));
                if (!isSupported)
                {
                    return ResultDto<bool>.Failed($"العملة المحددة للحجز غير مدعومة: {currency} / The selected booking currency is not supported: {currency}");
                }

                var propertyServices = await _propertyServiceRepository.GetPropertyServicesAsync(bookingProperty.Id, cancellationToken);
                var propertyServicesDict = propertyServices.ToDictionary(ps => ps.Id, ps => ps);

                // Read the current booking services.
                var currentServices = (await _bookingServiceRepository.GetBookingServicesAsync(booking.Id, cancellationToken)).ToList();
                var currentByServiceId = currentServices.ToDictionary(cs => cs.ServiceId, cs => cs);

                // Build the desired state while validating quantities and eligibility.
                var desired = new Dictionary<Guid, int>();
                foreach (var item in request.Services)
                {
                    if (item.Quantity <= 0) continue; // Treat non-positive quantities as deletion.
                    if (!propertyServicesDict.TryGetValue(item.ServiceId, out var svc))
                    {
                        return ResultDto<bool>.Failed("الخدمة غير موجودة ضمن خدمات هذا العقار");
                    }
                    // Verify currency compatibility.
                    if (!string.Equals(svc.Price.Currency, currency, StringComparison.OrdinalIgnoreCase))
                    {
                        return ResultDto<bool>.Failed($"عملة الخدمة ({svc.Price.Currency}) لا تطابق عملة الحجز ({currency})");
                    }
                    desired[item.ServiceId] = item.Quantity;
                }

                // Remove missing services.
                foreach (var cs in currentServices)
                {
                    if (!desired.ContainsKey(cs.ServiceId))
                    {
                        await _bookingServiceRepository.RemoveServiceFromBookingAsync(booking.Id, cs.ServiceId, cancellationToken);
                    }
                }

                // Add or update remaining services.
                foreach (var kv in desired)
                {
                    var serviceId = kv.Key;
                    var quantity = kv.Value;
                    var svc = propertyServicesDict[serviceId];
                    var totalServiceAmount = svc.Price.Amount * quantity;

                    if (currentByServiceId.TryGetValue(serviceId, out var existing))
                    {
                        if (existing.Quantity != quantity || existing.TotalPrice.Amount != totalServiceAmount)
                        {
                            existing.Quantity = quantity;
                            existing.TotalPrice = new Money(totalServiceAmount, currency);
                            existing.UpdatedAt = DateTime.UtcNow;
                            await _bookingServiceRepository.UpdateBookingServiceAsync(existing, cancellationToken);
                        }
                    }
                    else
                    {
                        var bs = new BookingService
                        {
                            Id = Guid.NewGuid(),
                            BookingId = booking.Id,
                            ServiceId = serviceId,
                            Quantity = quantity,
                            TotalPrice = new Money(totalServiceAmount, currency),
                            CreatedAt = DateTime.UtcNow,
                            UpdatedAt = DateTime.UtcNow,
                            IsActive = true,
                        };
                        await _bookingServiceRepository.AddServiceToBookingAsync(bs, cancellationToken);
                    }

                    servicesTotalAmount += totalServiceAmount;
                }
            }

            // Recalculate nightly price plus service cost when dates, guest count, or services change.
            if (request.CheckIn.HasValue || request.CheckOut.HasValue || request.GuestsCount.HasValue || request.Services != null)
            {
                var checkIn = request.CheckIn ?? booking.CheckIn;
                var checkOut = request.CheckOut ?? booking.CheckOut;
                var (localCheckInDate, localCheckOutDate) = await GetLocalDateRangeAsync(checkIn, checkOut);
                var pricingEndDate = localCheckOutDate > localCheckInDate
                    ? localCheckOutDate.AddDays(-1)
                    : localCheckInDate;

                // Load daily schedules and calculate price from PriceAmount values.
                var schedules = await _scheduleRepository.GetByUnitAndDateRangeAsync(
                    booking.UnitId,
                    localCheckInDate,
                    pricingEndDate);

                var nightsAmount = schedules.Sum(s => s.PriceAmount ?? 0);

                // If services were not sent, use the current service total.
                if (request.Services == null)
                {
                    var currentServices = await _bookingServiceRepository.GetBookingServicesAsync(booking.Id, cancellationToken);
                    servicesTotalAmount = currentServices.Sum(cs => cs.TotalPrice.Amount);
                }

                var finalTotal = nightsAmount + servicesTotalAmount;
                // Use the current booking currency if available, otherwise the property currency or YER.
                var finalCurrency = booking.TotalPrice?.Currency ?? currency ?? "YER";
                booking.TotalPrice = new Money(decimal.Round(finalTotal, 2), finalCurrency);
            }

            booking.UpdatedAt = DateTime.UtcNow;

            await _unitOfWork.ExecuteInTransactionAsync(async () =>
            {
                // Persist the changes.
                await _bookingRepository.UpdateAsync(booking, cancellationToken);

                // Refresh booking daily schedules when dates change.
                if (request.CheckIn.HasValue || request.CheckOut.HasValue)
                {
                    var (updatedLocalCheckInDate, updatedLocalCheckOutDate) =
                        await GetLocalDateRangeAsync(booking.CheckIn, booking.CheckOut);

                    // Unlink all days attached to the current booking first, including stale records.
                    var schedulesToRelease = (await _scheduleRepository.GetByBookingIdAsync(booking.Id)).ToList();
                    foreach (var schedule in schedulesToRelease)
                    {
                        schedule.Status = "Available";
                        schedule.BookingId = null;
                        schedule.ModifiedBy = _currentUserService.Username;
                        schedule.UpdatedAt = DateTime.UtcNow;
                    }
                    
                    if (schedulesToRelease.Any())
                    {
                        await _scheduleRepository.BulkUpdateAsync(schedulesToRelease);
                    }
                    
                    // Update the daily schedules for the new period.
                    var newScheduleEndDate = updatedLocalCheckOutDate > updatedLocalCheckInDate
                        ? updatedLocalCheckOutDate.AddDays(-1)
                        : updatedLocalCheckInDate;
                    var newSchedules = await _scheduleRepository.GetByUnitAndDateRangeAsync(
                        booking.UnitId,
                        updatedLocalCheckInDate,
                        newScheduleEndDate);
                    
                    foreach (var schedule in newSchedules)
                    {
                        schedule.Status = "Booked";
                        schedule.BookingId = booking.Id;
                        schedule.ModifiedBy = _currentUserService.Username;
                        schedule.UpdatedAt = DateTime.UtcNow;
                    }
                    
                    await _scheduleRepository.BulkUpdateAsync(newSchedules);
                }

                await _bookingRepository.SaveChangesAsync(cancellationToken);
            }, cancellationToken);

            // Record the schedule refresh in audit logs.
            await _auditService.LogAuditAsync(
                entityType: nameof(DailyUnitSchedule),
                entityId: booking.Id,
                action: AuditAction.UPDATE,
                oldValues: null,
                newValues: System.Text.Json.JsonSerializer.Serialize(new { booking.CheckIn, booking.CheckOut }),
                performedBy: _currentUserService.UserId,
                notes: $"تم تحديث الجداول اليومية للحجز {booking.Id} إلى {booking.CheckIn:yyyy-MM-dd} - {booking.CheckOut:yyyy-MM-dd} بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})",
                cancellationToken: cancellationToken);

            // Record the booking update in audit logs.
            var changes = BuildChangesList(originalCheckIn, originalCheckOut, originalGuestsCount, originalTotalPrice, booking);
            await _auditService.LogAuditAsync(
                entityType: nameof(Booking),
                entityId: booking.Id,
                action: AuditAction.UPDATE,
                oldValues: null,
                newValues: System.Text.Json.JsonSerializer.Serialize(new { Changes = changes }),
                performedBy: _currentUserService.UserId,
                notes: $"تم تحديث الحجز: {string.Join(", ", changes)} بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})",
                cancellationToken: cancellationToken);

            // Publish the booking updated event.
            await _eventPublisher.PublishAsync(new BookingUpdatedEvent
            {
                BookingId = booking.Id,
                UserId = booking.UserId,
                UnitId = booking.UnitId,
                UpdatedAt = booking.UpdatedAt,
                UpdatedBy = _currentUserService.UserId,
                UpdatedFields = changes.ToArray(),
                OccurredAt = DateTime.UtcNow,
                EventId = Guid.NewGuid(),
                OccurredOn = DateTime.UtcNow,
                EventType = nameof(BookingUpdatedEvent),
                Version = 1,
                CorrelationId = null,
                NewCheckIn = request.CheckIn,
                NewCheckOut = request.CheckOut,
                NewGuestsCount = request.GuestsCount,
                NewTotalPrice = booking.TotalPrice,
                NewStatus = booking.Status.ToString()
            }, cancellationToken);

            // Send a notification to the guest about the booking update.
            var bookingNumber = $"BK-{booking.Id.ToString("N")[..8].ToUpperInvariant()}";
            await _notificationService.SendAsync(new NotificationRequest
            {
                UserId = booking.UserId,
                Type = NotificationType.BookingUpdated,
                Title = "تم تحديث حجزك / Your booking has been updated",
                Message = $"تم تحديث تفاصيل حجزك رقم {bookingNumber} / Your booking {bookingNumber} details have been updated",
                Data = new { BookingId = booking.Id, BookingNumber = bookingNumber }
            }, cancellationToken);

            // Send a notification to the property owner about the booking update.
            var property = await GetPropertyFromBookingAsync(booking, cancellationToken);
            await _notificationService.SendAsync(new NotificationRequest
            {
                UserId = property.OwnerId,
                Type = NotificationType.BookingUpdated,
                Title = "تم تعديل حجز في عقارك / A booking in your property has been updated",
                Message = $"تم تعديل حجز رقم {bookingNumber} في عقارك {property.Name} للفترة من {booking.CheckIn:yyyy-MM-dd} إلى {booking.CheckOut:yyyy-MM-dd} بعدد ضيوف {booking.GuestsCount} وبسعر إجمالي {booking.TotalPrice}.",
                Data = new
                {
                    BookingId = booking.Id,
                    PropertyId = property.Id,
                    UnitId = booking.UnitId,
                    CheckIn = booking.CheckIn,
                    CheckOut = booking.CheckOut,
                    GuestsCount = booking.GuestsCount,
                    TotalPrice = booking.TotalPrice,
                    BookingNumber = bookingNumber
                }
            }, cancellationToken);

            _logger.LogInformation("تم تحديث الحجز {BookingId} بنجاح", booking.Id);

            return ResultDto<bool>.Succeeded(true, "تم تحديث الحجز بنجاح");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في تحديث الحجز {BookingId}", request.BookingId);
            return ResultDto<bool>.Failed("حدث خطأ أثناء تحديث الحجز");
        }
    }

    private async Task<ResultDto<bool>> ValidateAuthorizationAsync(Booking booking, CancellationToken cancellationToken)
    {
        var currentUserId = _currentUserService.UserId;
        var roles = _currentUserService.UserRoles;
        var isAdmin = roles.Any(r => string.Equals(r, "Admin", StringComparison.OrdinalIgnoreCase));

        if (isAdmin)
        {
            return ResultDto<bool>.Succeeded(true);
        }

        if (currentUserId == booking.UserId)
        {
            return ResultDto<bool>.Succeeded(true);
        }

        var unit = await _unitRepository.GetByIdAsync(booking.UnitId, cancellationToken);
        if (unit == null)
        {
            return ResultDto<bool>.Failed("الوحدة غير موجودة");
        }

        var property = await _propertyRepository.GetByIdAsync(unit.PropertyId, cancellationToken);
        if (property == null)
        {
            return ResultDto<bool>.Failed("العقار غير موجود");
        }
        
        if (property.OwnerId == currentUserId)
        {
            return ResultDto<bool>.Succeeded(true);
        }

        return ResultDto<bool>.Failed("ليس لديك صلاحية لتحديث هذا الحجز");
    }

    private ResultDto<bool> ValidateBookingState(Booking booking)
    {
        // Validate the booking state.
        if (booking.Status != BookingStatus.Pending && booking.Status != BookingStatus.Confirmed)
        {
            return ResultDto<bool>.Failed("لا يمكن تحديث حجز ليس في حالة انتظار أو تأكيد");
        }

        return ResultDto<bool>.Succeeded(true);
    }

    private async Task<ResultDto<bool>> ValidateInputAsync(UpdateBookingCommand request, Booking booking, CancellationToken cancellationToken)
    {
        var errors = new List<string>();

        // Determine the effective dates.
        var checkIn = request.CheckIn ?? booking.CheckIn;
        var checkOut = request.CheckOut ?? booking.CheckOut;
        var guestsCount = request.GuestsCount ?? booking.GuestsCount;

        // Validate dates.
        if (checkIn >= checkOut)
            errors.Add("تاريخ المغادرة يجب أن يكون بعد تاريخ الوصول");

        var userToday = (await _currentUserService.ConvertFromUtcToUserLocalAsync(DateTime.UtcNow)).Date;
        var checkInLocal = (await _currentUserService.ConvertFromUtcToUserLocalAsync(checkIn)).Date;
        if (checkInLocal < userToday && request.CheckIn.HasValue)
            errors.Add("تاريخ الوصول يجب أن يكون في المستقبل");

        // Validate guest count.
        if (guestsCount <= 0)
            errors.Add("عدد الضيوف يجب أن يكون أكبر من صفر");

        // Authorization is validated centrally in ValidateAuthorizationAsync, so it is not repeated here.
        // تم التحقق من الصلاحيات بشكل مركزي في ValidateAuthorizationAsync، لذلك لا نكرر التحقق هنا.

        var validationResult = await _validationService.ValidateAsync(request, cancellationToken);
        if (!validationResult.IsValid)
        {
            errors.AddRange(validationResult.Errors.Select(e => e.Message));
        }

        if (errors.Any())
        {
            return ResultDto<bool>.Failed(errors, "بيانات غير صحيحة");
        }

        return ResultDto<bool>.Succeeded(true);
    }

    private async Task<ResultDto<bool>> ValidateBusinessRulesAsync(UpdateBookingCommand request, Booking booking, CancellationToken cancellationToken)
    {
        // Validate unit availability if the dates changed.
        if (request.CheckIn.HasValue || request.CheckOut.HasValue)
        {
            var checkIn = request.CheckIn ?? booking.CheckIn;
            var checkOut = request.CheckOut ?? booking.CheckOut;
            var (localCheckInDate, localCheckOutDate) = await GetLocalDateRangeAsync(checkIn, checkOut);

            // Validate availability for the new period and exclude the current booking.
            var isAvailable = await _availabilityService.CheckAvailabilityAsync(
                booking.UnitId,
                localCheckInDate,
                localCheckOutDate,
                booking.Id);

            // Exclude the current booking from overlap checks.
            var overlappingBookings = await _bookingRepository.FindAsync(
                b => b.Id != booking.Id && b.UnitId == booking.UnitId && b.CheckIn < checkOut && b.CheckOut > checkIn,
                cancellationToken);

            if (!isAvailable || overlappingBookings.Any())
            {
                return ResultDto<bool>.Failed("الوحدة غير متوفرة في الفترة الجديدة");
            }
        }

        // Validate unit capacity.
        if (request.GuestsCount.HasValue)
        {
            var unit = await _unitRepository.GetByIdAsync(booking.UnitId, cancellationToken);
            if (request.GuestsCount.Value > unit.MaxCapacity)
            {
                return ResultDto<bool>.Failed($"عدد الضيوف يتجاوز السعة القصوى للوحدة ({unit.MaxCapacity})");
            }
        }

        // Validate the property's modification policy.
        var property = await GetPropertyFromBookingAsync(booking, cancellationToken);
        var modificationPolicy = await GetPropertyModificationPolicyAsync(property.Id, cancellationToken);
        
        if (modificationPolicy != null)
        {
            var timeToCheckIn = booking.CheckIn - DateTime.UtcNow;
            if (timeToCheckIn.TotalHours < modificationPolicy.MinHoursBeforeCheckIn)
            {
                return ResultDto<bool>.Failed($"لا يمكن تعديل الحجز قبل {modificationPolicy.MinHoursBeforeCheckIn} ساعة من الوصول");
            }
        }

        return ResultDto<bool>.Succeeded(true);
    }

    private async Task<(DateTime LocalCheckInDate, DateTime LocalCheckOutDate)> GetLocalDateRangeAsync(
        DateTime checkInUtc,
        DateTime checkOutUtc)
    {
        var localCheckInDate = (await _currentUserService.ConvertFromUtcToUserLocalAsync(checkInUtc)).Date;
        var localCheckOutDate = (await _currentUserService.ConvertFromUtcToUserLocalAsync(checkOutUtc)).Date;
        return (localCheckInDate, localCheckOutDate);
    }

    private List<string> BuildChangesList(DateTime originalCheckIn, DateTime originalCheckOut, 
        int originalGuestsCount, Core.ValueObjects.Money originalTotalPrice, Core.Entities.Booking booking)
    {
        var changes = new List<string>();

        if (originalCheckIn != booking.CheckIn)
            changes.Add($"تاريخ الوصول من {originalCheckIn:yyyy-MM-dd} إلى {booking.CheckIn:yyyy-MM-dd}");

        if (originalCheckOut != booking.CheckOut)
            changes.Add($"تاريخ المغادرة من {originalCheckOut:yyyy-MM-dd} إلى {booking.CheckOut:yyyy-MM-dd}");

        if (originalGuestsCount != booking.GuestsCount)
            changes.Add($"عدد الضيوف من {originalGuestsCount} إلى {booking.GuestsCount}");

        if (originalTotalPrice.Amount != booking.TotalPrice.Amount)
            changes.Add($"السعر الإجمالي من {originalTotalPrice} إلى {booking.TotalPrice}");

        return changes;
    }

    private async Task<Property> GetPropertyFromBookingAsync(Booking booking, CancellationToken cancellationToken)
    {
        var unit = await _unitRepository.GetByIdAsync(booking.UnitId, cancellationToken);
        return await _propertyRepository.GetByIdAsync(unit.PropertyId, cancellationToken);
    }

    private async Task<PropertyPolicy> GetPropertyModificationPolicyAsync(Guid propertyId, CancellationToken cancellationToken)
    {
        return await _policyRepository
            .FirstOrDefaultAsync(p => p.PropertyId == propertyId && p.Type == PolicyType.Modification, cancellationToken);
    }
}

/// <summary>
/// يمثل عنصرًا ضمن نطاق الحجوزات.
/// Represents an item in the booking-related feature area.
/// </summary>
public class BookingUpdatedEvent : IBookingUpdatedEvent
{
    /// <summary>
    /// معرّف الحجز
    /// Booking identifier.
    /// </summary>
    public Guid BookingId { get; set; }
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
    /// يمثل تاريخ التحديث.
    /// Represents updated at.
    /// </summary>
    public DateTime UpdatedAt { get; set; }
    /// <summary>
    /// معرّف التحديث بحسب
    /// Updated By identifier.
    /// </summary>
    public Guid UpdatedBy { get; set; }
    /// <summary>
    /// يمثل التحديث Fields.
    /// Represents updated fields.
    /// </summary>
    public string[] UpdatedFields { get; set; }
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
    public string EventType { get; set; } = nameof(BookingUpdatedEvent);
    /// <summary>
    /// يمثل الإصدار.
    /// Represents version.
    /// </summary>
    public int Version { get; set; } = 1;
    /// <summary>
    /// يمثل معرّف الارتباط.
    /// Represents correlation id.
    /// </summary>
    public string CorrelationId { get; set; }
    /// <summary>
    /// يمثل الجديد تسجيل الوصول.
    /// Represents new check in.
    /// </summary>
    public DateTime? NewCheckIn { get; set; }
    /// <summary>
    /// يمثل الجديد تسجيل المغادرة.
    /// Represents new check out.
    /// </summary>
    public DateTime? NewCheckOut { get; set; }
    /// <summary>
    /// يمثل عدد الضيوف الجديد.
    /// Represents new guests count.
    /// </summary>
    public int? NewGuestsCount { get; set; }
    /// <summary>
    /// يمثل السعر الإجمالي الجديد.
    /// Represents new total price.
    /// </summary>
    public Money? NewTotalPrice { get; set; }
    /// <summary>
    /// يمثل الحالة الجديدة.
    /// Represents new status.
    /// </summary>
    public string NewStatus { get; set; }

}
