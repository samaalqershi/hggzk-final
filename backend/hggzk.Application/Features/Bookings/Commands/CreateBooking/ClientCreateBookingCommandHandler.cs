using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Bookings;
using YemenBooking.Core.Interfaces;
using YemenBooking.Core.Enums;
using YemenBooking.Core.ValueObjects;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.SearchAndFilters.Services;
using YemenBooking.Application.Features.Bookings.Commands.CreateBooking;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Bookings.Commands.CreateBooking;

    /// <summary>
    /// يعالج مكوّن الحجوزات ويعيد النتيجة المطلوبة.
    /// Handles a booking-related component and returns the requested result.
    /// </summary>
public class ClientCreateBookingCommandHandler : IRequestHandler<CreateBookingCommand, ResultDto<CreateBookingResponse>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<ClientCreateBookingCommandHandler> _logger;
    private readonly IUserRepository _userRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IUnitRepository _unitRepository;
    private readonly IPropertyRepository _propertyRepository;
    private readonly IDailyUnitScheduleRepository _scheduleRepository;
    private readonly IPropertyServiceRepository _propertyServiceRepository;
    private readonly IBookingServiceRepository _bookingServiceRepository;
    private readonly IDailyUnitScheduleService _scheduleService;
    private readonly IUnitIndexingService _indexingService;
    private readonly ICurrentUserService _currentUserService;

/// <summary>
/// ينشئ مثيلًا جديدًا مع الاعتمادات المطلوبة.
/// Creates a new instance with its required dependencies.
/// </summary>
    public ClientCreateBookingCommandHandler(
        IUnitOfWork unitOfWork,
        ILogger<ClientCreateBookingCommandHandler> logger,
        IUserRepository userRepository,
        IBookingRepository bookingRepository,
        IUnitRepository unitRepository,
        IPropertyRepository propertyRepository,
        IDailyUnitScheduleRepository scheduleRepository,
        IPropertyServiceRepository propertyServiceRepository,
        IBookingServiceRepository bookingServiceRepository,
        IDailyUnitScheduleService scheduleService,
        IUnitIndexingService indexingService,
        ICurrentUserService currentUserService)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
        _userRepository = userRepository;
        _bookingRepository = bookingRepository;
        _unitRepository = unitRepository;
        _propertyRepository = propertyRepository;
        _scheduleRepository = scheduleRepository;
        _propertyServiceRepository = propertyServiceRepository;
        _bookingServiceRepository = bookingServiceRepository;
        _scheduleService = scheduleService;
        _indexingService = indexingService;
        _currentUserService = currentUserService;
    }

/// <summary>
/// يعالج هذا المكوّن المرتبط بـ الحجوزات ويعيد النتيجة المطلوبة.
/// Handles the corresponding booking-related command or query and returns the requested result.
/// </summary>
    public async Task<ResultDto<CreateBookingResponse>> Handle(CreateBookingCommand request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء إنشاء حجز جديد للمستخدم {UserId} في الوحدة {UnitId}", request.UserId, request.UnitId);

            // Normalize incoming dates from user-local to UTC
            request.CheckIn = await _currentUserService.ConvertFromUserLocalToUtcAsync(request.CheckIn);
            request.CheckOut = await _currentUserService.ConvertFromUserLocalToUtcAsync(request.CheckOut);

            // التحقق من صحة البيانات الأساسية
            var validationError = await ValidateRequestAsync(request);
            if (validationError != null)
            {
                return ResultDto<CreateBookingResponse>.Failure(validationError.Message);
            }

            // التحقق من وجود المستخدم
            var user = await _userRepository.GetUserByIdAsync(request.UserId, cancellationToken);
            if (user == null)
            {
                _logger.LogWarning("المستخدم غير موجود {UserId}", request.UserId);
                return new ResultDto<CreateBookingResponse>
                {
                    Success = false,
                    Message = "المستخدم غير موجود"
                };
            }

            // التحقق من وجود الوحدة
            var unit = await _unitRepository.GetUnitByIdAsync(request.UnitId, cancellationToken);
            if (unit == null)
            {
                _logger.LogWarning("الوحدة غير موجودة {UnitId}", request.UnitId);
                    return new ResultDto<CreateBookingResponse>
                    {
                        Success = false,
                        Message = "الوحدة غير موجودة"
                    };
            }

            // التحقق من توفر الوحدة في التواريخ المطلوبة
            var availabilityError = await CheckAvailability(request.UnitId, request.CheckIn, request.CheckOut, cancellationToken);
            if (availabilityError != null)
            {
                return new ResultDto<CreateBookingResponse>
                {
                    Success = false,
                    Message = availabilityError.Message
                };
            }

            // حساب السعر الإجمالي
            var totalPrice = await CalculateTotalPrice(unit, request, cancellationToken);

            // إنشاء الحجز
            var booking = new Core.Entities.Booking
            {
                Id = Guid.NewGuid(),
                UserId = request.UserId,
                UnitId = request.UnitId,
                CheckIn = request.CheckIn,
                CheckOut = request.CheckOut,
                GuestsCount = request.GuestsCount,
                Status = BookingStatus.Pending,
                BookingSource = request.BookingSource,
                TotalPrice = totalPrice,
                BookedAt = DateTime.UtcNow,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            await _unitOfWork.ExecuteInTransactionAsync(async () =>
            {
                // إضافة الحجز إلى قاعدة البيانات
                await _bookingRepository.AddAsync(booking, cancellationToken);

                // حفظ الخدمات الإضافية المطلوبة (إن وجدت)
                if (request.Services != null && request.Services.Any())
                {
                    var allPropertyServices = await _propertyServiceRepository.GetAllAsync(cancellationToken);

                    foreach (var serviceRequest in request.Services)
                    {
                        var propertyService = allPropertyServices.FirstOrDefault(ps => ps.Id == serviceRequest.ServiceId);
                        if (propertyService != null)
                        {
                            var bookingService = new Core.Entities.BookingService
                            {
                                Id = Guid.NewGuid(),
                                BookingId = booking.Id,
                                ServiceId = propertyService.Id,
                                Quantity = serviceRequest.Quantity,
                                TotalPrice = new Money(propertyService.Price.Amount * serviceRequest.Quantity, propertyService.Price.Currency ?? "YER"),
                                CreatedAt = DateTime.UtcNow,
                                UpdatedAt = DateTime.UtcNow,
                                IsActive = true
                            };

                            await _bookingServiceRepository.AddAsync(bookingService, cancellationToken);
                        }
                    }
                }

                // تحديث جدول الإتاحة اليومي
                var lastOccupiedDate = booking.CheckOut.Date > booking.CheckIn.Date
                    ? booking.CheckOut.Date.AddDays(-1)
                    : booking.CheckIn.Date;
                await _scheduleService.SetAvailabilityForPeriodAsync(
                    booking.UnitId,
                    booking.CheckIn,
                    lastOccupiedDate,
                    "Booked",
                    "Customer Booking",
                    $"Block for booking {booking.Id}",
                    booking.Id,
                    overwriteExisting: true,
                    createdBy: _currentUserService.Username
                );

                await _bookingRepository.SaveChangesAsync(cancellationToken);
            }, cancellationToken);

            // إنشاء رقم الحجز
            var bookingNumber = GenerateBookingNumber(booking.Id);


            var response = new CreateBookingResponse
            {
                BookingId = booking.Id,
                BookingNumber = bookingNumber,
                TotalPrice = booking.TotalPrice,
                Status = booking.Status,
                Message = "تم إنشاء الحجز بنجاح"
            };

            // تحديث مباشر لفهرس الإتاحة
            try
            {
                if (booking != null)
                {
                    var from = DateTime.UtcNow.Date;
                    var to = from.AddMonths(6);
                    var periods = await _scheduleRepository.GetAvailableDaysAsync(booking.UnitId, from, to);
                    var availableRanges = periods
                        .Select(p => (p.Date, p.Date.AddDays(1)))
                        .ToList();

                    await _indexingService.OnAvailabilityChangedAsync(booking.UnitId, cancellationToken);
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "تعذرت الفهرسة المباشرة للإتاحة بعد إنشاء الحجز {BookingId}", booking.Id);
            }

            _logger.LogInformation("تم إنشاء الحجز بنجاح {BookingId} للمستخدم {UserId}", booking.Id, request.UserId);

            return new ResultDto<CreateBookingResponse>
            {
                Success = true,
                Data = response
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء إنشاء الحجز للمستخدم {UserId}", request.UserId);
            return new ResultDto<CreateBookingResponse>
            {
                Success = false,
                Message = $"حدث خطأ أثناء إنشاء الحجز: {ex.Message}"
            };
        }
    }

    private async Task<CreateBookingResponse?> ValidateRequestAsync(CreateBookingCommand request)
    {
        if (request.UserId == Guid.Empty)
        {
            return new CreateBookingResponse
            {
                BookingId = Guid.Empty,
                Message = "معرف المستخدم مطلوب"
            };
        }

        if (request.UnitId == Guid.Empty)
        {
            return new CreateBookingResponse
            {
                BookingId = Guid.Empty,
                Message = "معرف الوحدة مطلوب"
            };
        }

        if (request.CheckIn >= request.CheckOut)
        {
            return new CreateBookingResponse
            {
                BookingId = Guid.Empty,
                Message = "تاريخ الوصول يجب أن يكون قبل تاريخ المغادرة"
            };
        }

        var userToday = (await _currentUserService.ConvertFromUtcToUserLocalAsync(DateTime.UtcNow)).Date;
        var checkInLocal = (await _currentUserService.ConvertFromUtcToUserLocalAsync(request.CheckIn)).Date;
        if (checkInLocal < userToday)
        {
            return new CreateBookingResponse
            {
                BookingId = Guid.Empty,
                Message = "تاريخ الوصول لا يمكن أن يكون في الماضي"
            };
        }

        if (request.GuestsCount <= 0)
        {
            return new CreateBookingResponse
            {
                BookingId = Guid.Empty,
                Message = "عدد الضيوف يجب أن يكون أكبر من صفر"
            };
        }

        return null;
    }

    private async Task<CreateBookingResponse?> CheckAvailability(
        Guid unitId,
        DateTime checkIn,
        DateTime checkOut,
        CancellationToken cancellationToken)
    {
        var existingBookings = await _bookingRepository.GetAllAsync(cancellationToken);

        var conflictingBookings = existingBookings.Where(b =>
            b.UnitId == unitId &&
            b.Status != BookingStatus.Cancelled &&
            !(checkOut <= b.CheckIn || checkIn >= b.CheckOut)
        ).ToList();

        if (conflictingBookings.Any())
        {
            return new CreateBookingResponse
            {
                BookingId = Guid.Empty,
                Message = "الوحدة غير متاحة في التواريخ المطلوبة"
            };
        }

        return null;
    }

    private async Task<Money> CalculateTotalPrice(
        Core.Entities.Unit unit,
        CreateBookingCommand request,
        CancellationToken cancellationToken)
    {
        // حساب السعر الإجمالي من جداول الأيام (DailyUnitSchedule)
        var pricingEndDate = request.CheckOut.Date > request.CheckIn.Date
            ? request.CheckOut.Date.AddDays(-1)
            : request.CheckIn.Date;
        var schedules = await _scheduleRepository.GetByUnitAndDateRangeAsync(
            request.UnitId,
            request.CheckIn.Date,
            pricingEndDate);

        var pricingValidation = ValidateDailyPricingSchedules(
            request.CheckIn.Date,
            pricingEndDate,
            schedules);
        if (!pricingValidation.IsValid)
        {
            _logger.LogWarning(
                "تعذر حساب سعر الحجز بسبب تسعير يومي غير صالح. UnitId={UnitId}, CheckIn={CheckIn}, LastNight={LastNight}, Issues={Issues}",
                unit.Id,
                request.CheckIn.Date,
                pricingEndDate,
                string.Join(", ", pricingValidation.Issues));

            throw new InvalidOperationException(
                "تعذر إنشاء الحجز لأن جدول الإتاحة والتسعير غير مكتمل أو يحتوي أسعار غير صالحة. يرجى تحديث التسعير ثم إعادة المحاولة.");
        }

        // إضافة تكلفة الخدمات الإضافية (إذا وجدت)
        decimal servicesTotal = 0m;
        if (request.Services != null && request.Services.Any())
        {
            var allPropertyServices = await _propertyServiceRepository.GetAllAsync(cancellationToken);

            foreach (var serviceRequest in request.Services)
            {
                var propertyService = allPropertyServices.FirstOrDefault(ps => ps.Id == serviceRequest.ServiceId);
                if (propertyService != null)
                {
                    var serviceTotalAmount = propertyService.Price.Amount * serviceRequest.Quantity;
                    servicesTotal += serviceTotalAmount;
                }
            }
        }

        var finalTotalAmount = pricingValidation.TotalAccommodationAmount + servicesTotal;

        // الحصول على العملة من العقار
        var property = await _propertyRepository.GetPropertyByIdAsync(unit.PropertyId, cancellationToken);
        var currency = property?.Currency ?? "YER";

        _logger.LogInformation("تم حساب السعر الإجمالي للحجز: {TotalAmount} {Currency} (إقامة: {BaseAmount}, خدمات: {ServicesTotal})",
            finalTotalAmount, currency, pricingValidation.TotalAccommodationAmount, servicesTotal);

        return new Money(finalTotalAmount, currency);
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

    private string GenerateBookingNumber(Guid bookingId)
    {
        // إنشاء رقم حجز فريد باستخدام التاريخ وجزء من معرف الحجز
        var datePrefix = DateTime.UtcNow.ToString("yyyyMMdd");
        var idSuffix = bookingId.ToString("N")[..8].ToUpper();
        return $"BK{datePrefix}{idSuffix}";
    }
}
