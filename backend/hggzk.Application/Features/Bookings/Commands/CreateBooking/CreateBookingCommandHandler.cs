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
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features.Accounting.Services;
using YemenBooking.Application.Features.Notifications.Services;
using YemenBooking.Application.Features.SearchAndFilters.Services;
using YemenBooking.Application.Contracts.Services.Scheduling;
using YemenBooking.Application.Features.Bookings.Commands.CreateBooking;
using YemenBooking.Application.Features.Policies;
using System.Text.Json;

namespace YemenBooking.Application.Features.Bookings.Commands.CreateBooking;

    /// <summary>
    /// يعالج مكوّن الحجوزات ويعيد النتيجة المطلوبة.
    /// Handles a booking-related component and returns the requested result.
    /// </summary>
public class CreateBookingCommandHandler : IRequestHandler<CreateBookingCommand, ResultDto<CreateBookingResponse>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ICurrentUserService _currentUserService;
    private readonly IAvailabilityService _availabilityService;
    private readonly IDailyUnitScheduleRepository _scheduleRepository;
    private readonly IValidationService _validationService;
    private readonly IAuditService _auditService;
    private readonly IEventPublisher _eventPublisher;
    private readonly ILogger<CreateBookingCommandHandler> _logger;
    private readonly INotificationService _notificationService;
    private readonly IBookingRepository _bookingRepository;
    private readonly IUserRepository _userRepository;
    private readonly IUnitRepository _unitRepository;
    private readonly IPropertyRepository _propertyRepository;
    private readonly IPropertyServiceRepository _propertyServiceRepository;
    private readonly IBookingServiceRepository _bookingServiceRepository;
    private readonly IPolicyRepository _policyRepository;
    private readonly IUnitIndexingService _indexingService;
    private readonly IFinancialAccountingService _financialAccountingService;
    private readonly ICurrencySettingsService _currencySettingsService;

/// <summary>
/// ينشئ مثيلًا جديدًا مع الاعتمادات المطلوبة.
/// Creates a new instance with its required dependencies.
/// </summary>
    public CreateBookingCommandHandler(
        IBookingRepository bookingRepository,
        IUserRepository userRepository,
        IUnitRepository unitRepository,
        IPropertyRepository propertyRepository,
        IPropertyServiceRepository propertyServiceRepository,
        IBookingServiceRepository bookingServiceRepository,
        IPolicyRepository policyRepository,
        IUnitOfWork unitOfWork,
        ICurrentUserService currentUserService,
        IAvailabilityService availabilityService,
        IDailyUnitScheduleRepository scheduleRepository,
        IValidationService validationService,
        IAuditService auditService,
        IEventPublisher eventPublisher,
        ILogger<CreateBookingCommandHandler> logger,
        INotificationService notificationService,
        IUnitIndexingService indexingService,
        IFinancialAccountingService financialAccountingService,
        ICurrencySettingsService currencySettingsService)
    {
        _bookingRepository = bookingRepository;
        _userRepository = userRepository;
        _unitRepository = unitRepository;
        _propertyRepository = propertyRepository;
        _propertyServiceRepository = propertyServiceRepository;
        _bookingServiceRepository = bookingServiceRepository;
        _policyRepository = policyRepository;
        _unitOfWork = unitOfWork;
        _currentUserService = currentUserService;
        _availabilityService = availabilityService;
        _scheduleRepository = scheduleRepository;
        _validationService = validationService;
        _auditService = auditService;
        _eventPublisher = eventPublisher;
        _logger = logger;
        _notificationService = notificationService;
        _indexingService = indexingService;
        _financialAccountingService = financialAccountingService;
        _currencySettingsService = currencySettingsService;
    }

/// <summary>
/// يعالج هذا المكوّن المرتبط بـ الحجوزات ويعيد النتيجة المطلوبة.
/// Handles the corresponding booking-related command or query and returns the requested result.
/// </summary>
    public async Task<ResultDto<CreateBookingResponse>> Handle(CreateBookingCommand request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء معالجة أمر إنشاء حجز جديد للمستخدم {UserId} والوحدة {UnitId}", 
                request.UserId, request.UnitId);

            // Normalize incoming dates from user-local time to UTC.
            // تحويل التواريخ القادمة من توقيت المستخدم إلى UTC.
            request.CheckIn = await _currentUserService.ConvertFromUserLocalToUtcAsync(request.CheckIn);
            request.CheckOut = await _currentUserService.ConvertFromUserLocalToUtcAsync(request.CheckOut);

            // Daily schedules are managed by local calendar dates, so derive a local-date
            // range from the normalized UTC timestamps before querying prices.
            // تتم إدارة الجداول اليومية بحسب التاريخ المحلي، لذلك نشتق نطاقًا محليًا قبل الاستعلام عن الأسعار.
            var localCheckInDate = (await _currentUserService.ConvertFromUtcToUserLocalAsync(request.CheckIn)).Date;
            var localCheckOutDate = (await _currentUserService.ConvertFromUtcToUserLocalAsync(request.CheckOut)).Date;

            // Validate the input.
            var validationResult = await ValidateInputAsync(request, cancellationToken);
            if (!validationResult.IsSuccess)
            {
                return validationResult;
            }

            // Validate user and unit existence.
            var existenceValidation = await ValidateExistenceAsync(request, cancellationToken);
            if (!existenceValidation.IsSuccess)
            {
                return existenceValidation;
            }

            // Validate authorization.
            var authorizationValidation = await ValidateAuthorizationAsync(request, cancellationToken);
            if (!authorizationValidation.IsSuccess)
            {
                return authorizationValidation;
            }

            // Validate business rules.
            var businessRulesValidation = await ValidateBusinessRulesAsync(request, cancellationToken);
            if (!businessRulesValidation.IsSuccess)
            {
                return businessRulesValidation;
            }

            // Check unit availability for the requested period.
            var isAvailable = await _availabilityService.CheckAvailabilityAsync(
                request.UnitId,
                localCheckInDate,
                localCheckOutDate);
            if (!isAvailable)
            {
                return ResultDto<CreateBookingResponse>.Failed("لا يمكن إنشاء الحجز؛ الوحدة غير متاحة للفترة المحددة / The booking cannot be created because the unit is unavailable for the selected period");
            }

            var lastOccupiedDate = localCheckOutDate > localCheckInDate
                ? localCheckOutDate.AddDays(-1)
                : localCheckInDate;

            // Calculate the total price from daily schedules.
            var schedules = await _scheduleRepository.GetByUnitAndDateRangeAsync(
                request.UnitId,
                localCheckInDate,
                lastOccupiedDate);

            var pricingValidation = ValidateDailyPricingSchedules(
                localCheckInDate,
                lastOccupiedDate,
                schedules);
            if (!pricingValidation.IsValid)
            {
                _logger.LogWarning(
                    "تعذر إنشاء الحجز بسبب تسعير يومي غير صالح. UnitId={UnitId}, CheckIn={CheckIn}, LastNight={LastNight}, Issues={Issues}",
                    request.UnitId,
                    localCheckInDate,
                    lastOccupiedDate,
                    string.Join(", ", pricingValidation.Issues));

                return ResultDto<CreateBookingResponse>.Failed(
                    "تعذر إنشاء الحجز لأن جدول الإتاحة والتسعير غير مكتمل أو يحتوي أسعار غير صالحة. يرجى تحديث التسعير ثم إعادة المحاولة.");
            }

            var priceAmount = pricingValidation.TotalAccommodationAmount;
            
            var unit = await _unitRepository.GetUnitByIdAsync(request.UnitId, cancellationToken);
            var property = await _propertyRepository.GetPropertyByIdAsync(unit.PropertyId, cancellationToken);
            
            var currency = property?.Currency ?? "YER";

            // Verify that the currency is supported by system settings.
            var currencies = await _currencySettingsService.GetCurrenciesAsync(cancellationToken);
            var isSupported = currencies.Any(c => string.Equals(c.Code, currency, StringComparison.OrdinalIgnoreCase));
            if (!isSupported)
            {
                return ResultDto<CreateBookingResponse>.Failed($"العملة المحددة للحجز غير مدعومة: {currency}");
            }

            // Limit the price to two decimal places.
            var roundedPrice = decimal.Round(priceAmount, 2);

            // Calculate additional service costs, if any, using property service prices.
            decimal servicesTotalAmount = 0m;
            var bookingServicesToPersist = new List<BookingService>();

            if (request.Services != null && request.Services.Any())
            {
                var propertyServices = await _propertyServiceRepository.GetPropertyServicesAsync(property.Id, cancellationToken);
                var propertyServicesDict = propertyServices.ToDictionary(ps => ps.Id, ps => ps);

                foreach (var serviceRequest in request.Services)
                {
                    if (!propertyServicesDict.TryGetValue(serviceRequest.ServiceId, out var propertyService))
                    {
                        _logger.LogWarning("A missing service was requested while creating the booking. ServiceId={ServiceId} / تم طلب خدمة غير موجودة أثناء إنشاء الحجز.", serviceRequest.ServiceId);
                        continue;
                    }

                    var unitPriceAmount = propertyService.Price.Amount;
                    var serviceCurrency = propertyService.Price.Currency ?? currency;
                    var totalServiceAmount = unitPriceAmount * serviceRequest.Quantity;
                    servicesTotalAmount += totalServiceAmount;

                    var bookingService = new BookingService
                    {
                        Id = Guid.NewGuid(),
                        ServiceId = propertyService.Id,
                        Quantity = serviceRequest.Quantity,
                        TotalPrice = new Money(totalServiceAmount, serviceCurrency),
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow,
                        IsActive = true
                    };

                    bookingServicesToPersist.Add(bookingService);
                }
            }

            // Booking total = nightly price + service cost.
            var finalTotalAmount = roundedPrice + servicesTotalAmount;
            var totalPrice = new Money(finalTotalAmount, currency);

            // Create the booking entity.
            var booking = new Booking
            {
                Id = Guid.NewGuid(),
                UserId = request.UserId,
                UnitId = request.UnitId,
                CheckIn = request.CheckIn,
                CheckOut = request.CheckOut,
                GuestsCount = request.GuestsCount,
                TotalPrice = totalPrice,
                Status = BookingStatus.Pending,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                IsActive = true
            };

            try
            {
                var currentPolicies = await _policyRepository.GetPropertyPoliciesAsync(property.Id, cancellationToken);
                var policySnapshotObj = new
                {
                    PropertyId = property.Id,
                    UnitId = unit.Id,
                    CapturedAt = DateTime.UtcNow,
                    UnitOverrides = new
                    {
                        AllowsCancellation = unit.AllowsCancellation,
                        CancellationWindowDays = unit.CancellationWindowDays
                    },
                    Policies = currentPolicies.Select(p => new
                    {
                        p.Id,
                        Type = p.Type.ToString(),
                        p.Description,
                        Rules = PolicyRulesMapper.BuildRulesJson(p),
                        p.CancellationWindowDays,
                        p.RequireFullPaymentBeforeConfirmation,
                        p.MinimumDepositPercentage,
                        p.MinHoursBeforeCheckIn
                    }).ToList()
                };
                booking.PolicySnapshot = JsonSerializer.Serialize(policySnapshotObj);
                booking.PolicySnapshotAt = DateTime.UtcNow;
            }
            catch
            {
                booking.PolicySnapshot = null;
                booking.PolicySnapshotAt = null;
            }

            List<DailyUnitSchedule> updatedSchedules = new();

            // Execute booking creation, availability locking, and financial posting in one transaction.
            // تنفيذ إنشاء الحجز وقفل الإتاحة وتسجيل القيد المالي ضمن ترانزاكشن واحدة.
            await _unitOfWork.ExecuteInTransactionAsync(async () =>
            {
                // Persist the booking.
                await _bookingRepository.AddAsync(booking, cancellationToken);

                var bookingLastOccupiedDate = localCheckOutDate > localCheckInDate
                    ? localCheckOutDate.AddDays(-1)
                    : localCheckInDate;

                // Mark daily schedules as booked.
                var schedulesToUpdate = await _scheduleRepository.GetByUnitAndDateRangeAsync(
                    booking.UnitId,
                    localCheckInDate,
                    bookingLastOccupiedDate);
                
                foreach (var schedule in schedulesToUpdate)
                {
                    schedule.Status = "Booked";
                    schedule.BookingId = booking.Id;
                    schedule.Reason = "Customer Booking";
                    schedule.Notes = $"Block for booking {booking.Id}";
                    schedule.UpdatedAt = DateTime.UtcNow;
                    updatedSchedules.Add(schedule);
                }

                if (updatedSchedules.Any())
                {
                    await _scheduleRepository.BulkUpdateAsync(updatedSchedules);
                }

                // Attach booking services, if any.
                if (bookingServicesToPersist.Any())
                {
                    foreach (var bs in bookingServicesToPersist)
                    {
                        bs.BookingId = booking.Id;
                        await _bookingServiceRepository.AddServiceToBookingAsync(bs, cancellationToken);
                    }
                }

                // Persist all changes before financial entries.
                await _bookingRepository.SaveChangesAsync(cancellationToken);

                // Record the accounting entry for the new booking (95% / 5% split).
                var tx = await _financialAccountingService.RecordBookingTransactionAsync(booking.Id, _currentUserService.UserId);
                if (tx == null)
                    throw new InvalidOperationException("FAILED_TO_RECORD_BOOKING_TRANSACTION");
            }, cancellationToken);

            // Record the availability block in audit logs.
            await _auditService.LogAuditAsync(
                entityType: nameof(DailyUnitSchedule),
                entityId: booking.Id,
                action: AuditAction.UPDATE,
                oldValues: null,
                newValues: System.Text.Json.JsonSerializer.Serialize(new { booking.UnitId, booking.Id, booking.CheckIn, booking.CheckOut }),
                performedBy: _currentUserService.UserId,
                notes: $"تم حجز الوحدة {booking.UnitId} للحجز {booking.Id} بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})",
                cancellationToken: cancellationToken);

            // Update the availability index immediately; this is critical for search.
            // If it fails, retry because the index would become inconsistent.
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
                    var periods = await _scheduleRepository.GetAvailableDaysAsync(booking.UnitId, from, to);
                    var availableRanges = periods
                        .Select(p => (p.Date, p.Date.AddDays(1)))
                        .ToList();

                    await _indexingService.OnAvailabilityChangedAsync(booking.UnitId, cancellationToken);
                    indexingSuccess = true;
                    _logger.LogInformation("✅ تم تحديث فهرس الإتاحة بنجاح بعد إنشاء الحجز {BookingId} (محاولة {Attempt}/{Max})", 
                        booking.Id, indexingAttempts, maxIndexingAttempts);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "⚠️ فشلت محاولة {Attempt}/{Max} لتحديث فهرس الإتاحة بعد إنشاء الحجز {BookingId}", 
                        indexingAttempts, maxIndexingAttempts, booking.Id);
                    
                    if (indexingAttempts < maxIndexingAttempts)
                    {
                        await Task.Delay(TimeSpan.FromSeconds(1 * indexingAttempts), cancellationToken); // Exponential backoff.
                    }
                    else
                    {
                        // Critical failure: the index no longer matches reality.
                        // Critical failure: the index no longer matches reality.
                        // فشل حرج: الفهرس لم يعد متطابقًا مع الواقع.
                        _logger.LogCritical("❌ CRITICAL: فشل تحديث فهرس الإتاحة بعد {Attempts} محاولات للحجز {BookingId}. " +
                            "الفهرس غير متطابق! يجب تشغيل re-index يدوي.", 
                            maxIndexingAttempts, booking.Id);
                        
                        // TODO: enqueue a background retry for later processing.
                    }
                }
            }

            // Record the operation in audit logs.
            await _auditService.LogAuditAsync(
                entityType: nameof(Booking),
                entityId: booking.Id,
                action: AuditAction.CREATE,
                oldValues: null,
                newValues: System.Text.Json.JsonSerializer.Serialize(new { booking.UserId, booking.UnitId, booking.CheckIn, booking.CheckOut, booking.GuestsCount, booking.TotalPrice }),
                performedBy: _currentUserService.UserId,
                notes: $"تم إنشاء حجز جديد للمستخدم {request.UserId} بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})",
                cancellationToken: cancellationToken);

            // Publish the booking created event.
            await _eventPublisher.PublishAsync(new BookingCreatedEvent
            {
                BookingId = booking.Id,
                UserId = request.UserId,
                UnitId = request.UnitId,
                CheckIn = request.CheckIn,
                CheckOut = request.CheckOut,
                TotalPrice = totalPrice,
                GuestsCount = request.GuestsCount,
                Status = booking.Status.ToString(),
                BookedAt = booking.CreatedAt
            }, cancellationToken);

            // Send a notification to the guest confirming the initial booking.
            var bookingNumber = $"BK-{booking.Id.ToString("N")[..8].ToUpperInvariant()}";
            await _notificationService.SendAsync(new NotificationRequest
            {
                UserId = request.UserId,
                Type = NotificationType.BookingCreated,
                Title = "تم إنشاء حجزك / Your booking has been created",
                Message = $"تم إنشاء حجزك رقم {bookingNumber} بنجاح / Your booking {bookingNumber} has been created successfully",
                Data = new { BookingId = booking.Id, BookingNumber = bookingNumber }
            }, cancellationToken);

            _logger.LogInformation("Booking created successfully with ID {BookingId} / تم إنشاء الحجز بنجاح بالمعرف المحدد", booking.Id);

            var response = new CreateBookingResponse
            {
                BookingId = booking.Id,
                BookingNumber = bookingNumber,
                TotalPrice = booking.TotalPrice,
                Status = booking.Status,
                Message = "تم إنشاء الحجز بنجاح"
            };
            return ResultDto<CreateBookingResponse>.Succeeded(response, "تم إنشاء الحجز بنجاح");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في إنشاء الحجز للمستخدم {UserId}", request.UserId);
            return ResultDto<CreateBookingResponse>.Failed("حدث خطأ أثناء إنشاء الحجز");
        }
    }

    private (bool IsValid, decimal TotalAccommodationAmount, List<string> Issues) ValidateDailyPricingSchedules(
        DateTime checkInDate,
        DateTime lastOccupiedDate,
        IEnumerable<DailyUnitSchedule> schedules)
    {
        var issues = new List<string>();
        var total = 0m;

        var schedulesByDate = schedules
            .GroupBy(s => s.Date.Date)
            .ToDictionary(
                g => g.Key,
                g => g
                    .OrderByDescending(x => x.UpdatedAt)
                    .ThenByDescending(x => x.CreatedAt)
                    .First());

        for (var day = checkInDate.Date; day <= lastOccupiedDate.Date; day = day.AddDays(1))
        {
            if (!schedulesByDate.TryGetValue(day, out var schedule))
            {
                issues.Add($"{day:yyyy-MM-dd}:MISSING");
                continue;
            }

            if (!string.Equals(schedule.Status, "Available", StringComparison.OrdinalIgnoreCase))
            {
                issues.Add($"{day:yyyy-MM-dd}:STATUS_{schedule.Status}");
                continue;
            }

            if (!schedule.PriceAmount.HasValue || schedule.PriceAmount.Value <= 0)
            {
                issues.Add($"{day:yyyy-MM-dd}:INVALID_PRICE");
                continue;
            }

            total += schedule.PriceAmount.Value;
        }

        if (issues.Count > 0)
        {
            return (false, 0m, issues);
        }

        return (true, decimal.Round(total, 2), issues);
    }

    private async Task<ResultDto<CreateBookingResponse>> ValidateInputAsync(CreateBookingCommand request, CancellationToken cancellationToken)
    {
        var errors = new List<string>();

        // Validate identifiers.
        if (request.UserId == Guid.Empty)
            errors.Add("معرف المستخدم مطلوب");

        if (request.UnitId == Guid.Empty)
            errors.Add("معرف الوحدة مطلوب");

        // Validate dates.
        if (request.CheckIn >= request.CheckOut)
            errors.Add("تاريخ المغادرة يجب أن يكون بعد تاريخ الوصول");

        var userToday = (await _currentUserService.ConvertFromUtcToUserLocalAsync(DateTime.UtcNow)).Date;
        var checkInLocal = (await _currentUserService.ConvertFromUtcToUserLocalAsync(request.CheckIn)).Date;
        if (checkInLocal < userToday)
            errors.Add("تاريخ الوصول يجب أن يكون في المستقبل");

        // Validate guest count.
        if (request.GuestsCount <= 0)
            errors.Add("عدد الضيوف يجب أن يكون أكبر من صفر");

        // Validate the request.
        var validationResult = await _validationService.ValidateAsync(request, cancellationToken);
        if (!validationResult.IsValid)
        {
            errors.AddRange(validationResult.Errors.Select(e => e.Message));
        }

        if (errors.Any())
        {
            return ResultDto<CreateBookingResponse>.Failed(errors, "بيانات غير صحيحة");
        }

        return ResultDto<CreateBookingResponse>.Succeeded(new CreateBookingResponse { BookingId = Guid.Empty });
    }

    private async Task<ResultDto<CreateBookingResponse>> ValidateExistenceAsync(CreateBookingCommand request, CancellationToken cancellationToken)
    {
        // Validate user existence.
        var user = await _userRepository.GetUserByIdAsync(request.UserId, cancellationToken);
        if (user == null || !user.IsActive)
        {
            return ResultDto<CreateBookingResponse>.Failed("المستخدم غير موجود أو غير نشط");
        }

        // Validate unit existence.
        var unit = await _unitRepository.GetUnitByIdAsync(request.UnitId, cancellationToken);
        if (unit == null || !unit.IsActive)
        {
            return ResultDto<CreateBookingResponse>.Failed("الوحدة غير موجودة أو غير نشطة");
        }

        return ResultDto<CreateBookingResponse>.Succeeded(new CreateBookingResponse { BookingId = Guid.Empty });
    }

    private async Task<ResultDto<CreateBookingResponse>> ValidateAuthorizationAsync(CreateBookingCommand request, CancellationToken cancellationToken)
    {
        var currentUserId = _currentUserService.UserId;
        // Load the unit to validate authorization.
        var unit = await _unitRepository.GetUnitByIdAsync(request.UnitId, cancellationToken);

        // Allow self-booking, admin, or staff.
            if (currentUserId != request.UserId)
            {
                if (_currentUserService.Role != "Admin" && _currentUserService.Role != "Staff" && _currentUserService.UserId != request.UserId)
                {
                    return ResultDto<CreateBookingResponse>.Failed("ليس لديك الصلاحية لإنشاء حجز لمستخدم آخر");
                }
            }

        // Ensure the user is staff in the property when not admin or owner.
        if (_currentUserService.Role != "Admin" && _currentUserService.Role != "Staff" && unit != null && !_currentUserService.IsStaffInProperty(unit.PropertyId))
        {
            return ResultDto<CreateBookingResponse>.Failed("لست موظفًا في هذا الكيان");
        }

        return ResultDto<CreateBookingResponse>.Succeeded(new CreateBookingResponse { BookingId = Guid.Empty });
    }

    private async Task<ResultDto<CreateBookingResponse>> ValidateBusinessRulesAsync(CreateBookingCommand request, CancellationToken cancellationToken)
    {
        // Validate unit capacity.
        var unit = await _unitRepository.GetUnitByIdAsync(request.UnitId, cancellationToken);
        if (request.GuestsCount > unit.MaxCapacity)
        {
            return ResultDto<CreateBookingResponse>.Failed($"عدد الضيوف يتجاوز السعة القصوى للوحدة ({unit.MaxCapacity})");
        }

        // Validate that the user has no overlapping booking.
        var overlappingBookings = await _bookingRepository.FindAsync(
            b => b.UserId == request.UserId && b.CheckIn < request.CheckOut && b.CheckOut > request.CheckIn,
            cancellationToken);
        if (overlappingBookings.Any())
        {
            return ResultDto<CreateBookingResponse>.Failed("لديك حجز آخر في نفس الفترة الزمنية");
        }

        if (request.Services != null && request.Services.Any())
        {
            var unitEntity = await _unitRepository.GetUnitByIdAsync(request.UnitId, cancellationToken);
            if (unitEntity != null)
            {
                var propertyServices = await _propertyServiceRepository.GetPropertyServicesAsync(unitEntity.PropertyId, cancellationToken);
                var availableServiceIds = propertyServices.Select(ps => ps.Id);
                var requestedServiceIds = request.Services.Select(s => s.ServiceId);
                var invalidServiceIds = requestedServiceIds.Except(availableServiceIds).ToList();
                if (invalidServiceIds.Any())
                {
                    _logger.LogWarning("Invalid services requested: {InvalidServiceIds}", invalidServiceIds);
                    return ResultDto<CreateBookingResponse>.Failure($"Invalid services requested: {string.Join(", ", invalidServiceIds)}");
                }
            }
        }

        return ResultDto<CreateBookingResponse>.Succeeded(new CreateBookingResponse { BookingId = Guid.Empty });
    }
}

/// <summary>
/// يمثل عنصرًا ضمن نطاق الحجوزات.
/// Represents an item in the booking-related feature area.
/// </summary>
public class BookingCreatedEvent : IBookingCreatedEvent
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
    /// يمثل تاريخ تسجيل الوصول.
    /// Represents check in.
    /// </summary>
    public DateTime CheckIn { get; set; }
    /// <summary>
    /// يمثل تاريخ تسجيل المغادرة.
    /// Represents check out.
    /// </summary>
    public DateTime CheckOut { get; set; }
    /// <summary>
    /// يمثل السعر الإجمالي.
    /// Represents total price.
    /// </summary>
    public Money TotalPrice { get; set; }
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
    public string EventType { get; set; } = nameof(BookingCreatedEvent);
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
    /// يمثل عدد الضيوف.
    /// Represents guests count.
    /// </summary>
    public int GuestsCount { get; set; }
    /// <summary>
    /// يمثل الحالة.
    /// Represents status.
    /// </summary>
    public string Status { get; set; }
    /// <summary>
    /// يمثل Booked At.
    /// Represents booked at.
    /// </summary>
    public DateTime BookedAt { get; set; }
}
