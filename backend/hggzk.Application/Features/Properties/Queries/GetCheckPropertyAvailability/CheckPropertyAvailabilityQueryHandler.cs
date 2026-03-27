using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Properties;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Properties.Queries.GetCheckPropertyAvailability;

/// <summary>
/// يعالج التحقق من توفر العقار للفترة المطلوبة.
/// Handles checking property availability for the requested stay.
/// </summary>
public class CheckPropertyAvailabilityQueryHandler : IRequestHandler<CheckPropertyAvailabilityQuery, ResultDto<PropertyAvailabilityResponse>>
{
    private readonly IPropertyRepository _propertyRepository;
    private readonly IUnitRepository _unitRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IUnitTypeRepository _unitTypeRepository;
    private readonly IDailyUnitScheduleService _scheduleService;
    private readonly ILogger<CheckPropertyAvailabilityQueryHandler> _logger;

    /// <summary>
    /// يهيّئ مثيلاً جديداً من [CheckPropertyAvailabilityQueryHandler].
    /// Initializes a new instance of [CheckPropertyAvailabilityQueryHandler].
    /// </summary>
    public CheckPropertyAvailabilityQueryHandler(
        IPropertyRepository propertyRepository,
        IUnitRepository unitRepository,
        IBookingRepository bookingRepository,
        IUnitTypeRepository unitTypeRepository,
        IDailyUnitScheduleService scheduleService,
        ILogger<CheckPropertyAvailabilityQueryHandler> logger)
    {
        _propertyRepository = propertyRepository;
        _unitRepository = unitRepository;
        _bookingRepository = bookingRepository;
        _unitTypeRepository = unitTypeRepository;
        _scheduleService = scheduleService;
        _logger = logger;
    }
    /// <summary>
    /// يعالج التحقق من توفر العقار للفترة وعدد الضيوف المحددين.
    /// Handles checking property availability for the requested dates and guest count.
    /// </summary>
    public async Task<ResultDto<PropertyAvailabilityResponse>> Handle(CheckPropertyAvailabilityQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء التحقق من توفر العقار. معرف العقار: {PropertyId}, تاريخ الوصول: {CheckIn}, تاريخ المغادرة: {CheckOut}, عدد الضيوف: {GuestsCount}", 
                request.PropertyId, request.CheckInDate, request.CheckOutDate, request.GuestsCount);

            // Validate the input data.
            // التحقق من صحة البيانات المدخلة / Validate the input data.
            var validationResult = ValidateRequest(request);
            if (!validationResult.IsSuccess)
            {
                return validationResult;
            }

            // Ensure the property exists.
            // التحقق من وجود العقار / Ensure the property exists.
            var property = await _propertyRepository.GetByIdAsync(request.PropertyId, cancellationToken);
            if (property == null)
            {
                _logger.LogWarning("لم يتم العثور على العقار: {PropertyId}", request.PropertyId);
                return ResultDto<PropertyAvailabilityResponse>.Failed("العقار غير موجود", "PROPERTY_NOT_FOUND");
            }

            // Ensure the property is active.
            // التحقق من أن العقار نشط / Ensure the property is active.
            if (!property.IsActive)
            {
                _logger.LogWarning("العقار غير نشط: {PropertyId}", request.PropertyId);
                
                var inactiveResponse = new PropertyAvailabilityResponse
                {
                    HasAvailableUnits = false,
                    AvailableUnitsCount = 0,
                    MinAvailablePrice = null,
                    Currency = property.Currency ?? "YER",
                    Message = "العقار غير متاح حالياً",
                    AvailableUnitTypes = new List<string>()
                };

                return ResultDto<PropertyAvailabilityResponse>.Ok(inactiveResponse, "العقار غير متاح حالياً");
            }

            // Load all units in the property.
            // الحصول على جميع الوحدات في العقار / Load all units in the property.
            var allUnits = await _unitRepository.GetByPropertyIdAsync(request.PropertyId, cancellationToken);
            if (allUnits == null || !allUnits.Any())
            {
                _logger.LogInformation("لا توجد وحدات في العقار: {PropertyId}", request.PropertyId);
                
                var noUnitsResponse = new PropertyAvailabilityResponse
                {
                    HasAvailableUnits = false,
                    AvailableUnitsCount = 0,
                    MinAvailablePrice = null,
                    Currency = property.Currency ?? "YER",
                    Message = "لا توجد وحدات في هذا العقار",
                    AvailableUnitTypes = new List<string>()
                };

                return ResultDto<PropertyAvailabilityResponse>.Ok(noUnitsResponse, "لا توجد وحدات في هذا العقار");
            }

            // Filter active units that can accommodate the requested guests.
            // فلترة الوحدات النشطة التي تتسع للعدد المطلوب من الضيوف / Filter active units that can accommodate the requested guests.
            var eligibleUnits = allUnits
                .Where(u => u.IsActive && u.MaxCapacity >= request.GuestsCount)
                .ToList();

            if (!eligibleUnits.Any())
            {
                _logger.LogInformation("لا توجد وحدات تتسع لـ {GuestsCount} ضيف في العقار: {PropertyId}", 
                    request.GuestsCount, request.PropertyId);
                
                var noCapacityResponse = new PropertyAvailabilityResponse
                {
                    HasAvailableUnits = false,
                    AvailableUnitsCount = 0,
                    MinAvailablePrice = null,
                    Currency = property.Currency ?? "YER",
                    Message = $"لا توجد وحدات تتسع لـ {request.GuestsCount} ضيف",
                    AvailableUnitTypes = new List<string>()
                };

                return ResultDto<PropertyAvailabilityResponse>.Ok(noCapacityResponse, $"لا توجد وحدات تتسع لـ {request.GuestsCount} ضيف");
            }

            // Filter available units and calculate prices sequentially to avoid sharing DbContext across tasks.
            // فلترة الوحدات المتاحة وحساب الأسعار بشكل تسلسلي لتجنب مشاركة DbContext بين المهام / Filter available units and calculate prices sequentially to avoid sharing DbContext across tasks.
            var filteredResults = new List<AvailabilityResult>();
            foreach (var unit in eligibleUnits)
            {
                var isAvailable = await IsUnitAvailable(unit.Id, request.CheckInDate, request.CheckOutDate, cancellationToken);
                if (!isAvailable) continue;
                var unitType = await _unitTypeRepository.GetByIdAsync(unit.UnitTypeId, cancellationToken);
                var unitPrice = await CalculateUnitPrice(unit, property.Currency ?? "YER", request.CheckInDate, request.CheckOutDate, cancellationToken);
                filteredResults.Add(new AvailabilityResult { Unit = unit, UnitTypeName = unitType?.Name, Price = unitPrice });
            }
            var availableUnits = filteredResults.Select(r => r.Unit).ToList();
            var availableUnitTypes = filteredResults
                .Select(r => r.UnitTypeName)
                .Where(name => !string.IsNullOrEmpty(name))
                .Select(name => name!)
                .ToList();
            var prices = filteredResults.Select(r => r.Price).Where(price => price > 0).ToList();
            // Build the response.
            // إنشاء الاستجابة / Build the response.
            var response = new PropertyAvailabilityResponse
            {
                HasAvailableUnits = availableUnits.Any(),
                AvailableUnitsCount = availableUnits.Count,
                MinAvailablePrice = prices.Any() ? prices.Min() : null,
                Currency = property.Currency ?? "YER",
                Message = availableUnits.Any() 
                    ? $"يوجد {availableUnits.Count} وحدة متاحة"
                    : "لا توجد وحدات متاحة في الفترة المحددة",
                AvailableUnitTypes = availableUnitTypes.ToList()
            };

            _logger.LogInformation("تم التحقق من توفر العقار {PropertyId}. الوحدات المتاحة: {AvailableCount}, أقل سعر: {MinPrice}", 
                request.PropertyId, response.AvailableUnitsCount, response.MinAvailablePrice);

            return ResultDto<PropertyAvailabilityResponse>.Ok(response, response.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء التحقق من توفر العقار. معرف العقار: {PropertyId}", request.PropertyId);
            return ResultDto<PropertyAvailabilityResponse>.Failed(
                $"حدث خطأ أثناء التحقق من توفر العقار: {ex.Message}", 
                "CHECK_AVAILABILITY_ERROR"
            );
        }
    }

    private sealed class AvailabilityResult
    {
        /// <summary>
        /// الوحدة المطابقة التي أمكن تخصيصها في نتيجة الفحص.
        /// Matching unit selected as part of the availability evaluation result.
        /// </summary>
        public Core.Entities.Unit Unit { get; set; } = default!;

        /// <summary>
        /// اسم نوع الوحدة المرتبط بالوحدة المطابقة.
        /// Unit type name associated with the matching unit.
        /// </summary>
        public string? UnitTypeName { get; set; }

        /// <summary>
        /// السعر المحسوب للوحدة ضمن نتيجة التحقق.
        /// Calculated price for the unit within the availability result.
        /// </summary>
        public decimal Price { get; set; }
    }

    private ResultDto<PropertyAvailabilityResponse> ValidateRequest(CheckPropertyAvailabilityQuery request)
    {
        if (request.PropertyId == Guid.Empty)
        {
            _logger.LogWarning("معرف العقار مطلوب");
            return ResultDto<PropertyAvailabilityResponse>.Failed("معرف العقار مطلوب", "PROPERTY_ID_REQUIRED");
        }

        if (request.CheckInDate >= request.CheckOutDate)
        {
            _logger.LogWarning("تاريخ الوصول يجب أن يكون قبل تاريخ المغادرة");
            return ResultDto<PropertyAvailabilityResponse>.Failed("تاريخ الوصول يجب أن يكون قبل تاريخ المغادرة", "INVALID_DATE_RANGE");
        }

        if (request.CheckInDate.Date < DateTime.Today)
        {
            _logger.LogWarning("تاريخ الوصول لا يمكن أن يكون في الماضي");
            return ResultDto<PropertyAvailabilityResponse>.Failed("تاريخ الوصول لا يمكن أن يكون في الماضي", "INVALID_CHECKIN_DATE");
        }

        if (request.GuestsCount < 1 || request.GuestsCount > 50)
        {
            _logger.LogWarning("عدد الضيوف يجب أن يكون بين 1 و 50");
            return ResultDto<PropertyAvailabilityResponse>.Failed("عدد الضيوف يجب أن يكون بين 1 و 50", "INVALID_GUESTS_COUNT");
        }

        // Ensure the stay does not exceed one year.
        // التحقق من أن الفترة لا تتجاوز سنة واحدة / Ensure the stay does not exceed one year.
        var daysDifference = (request.CheckOutDate - request.CheckInDate).Days;
        if (daysDifference > 365)
        {
            _logger.LogWarning("فترة الإقامة لا يمكن أن تتجاوز سنة واحدة");
            return ResultDto<PropertyAvailabilityResponse>.Failed("فترة الإقامة لا يمكن أن تتجاوز سنة واحدة", "INVALID_STAY_DURATION");
        }

        if (daysDifference < 1)
        {
            _logger.LogWarning("فترة الإقامة يجب أن تكون ليلة واحدة على الأقل");
            return ResultDto<PropertyAvailabilityResponse>.Failed("فترة الإقامة يجب أن تكون ليلة واحدة على الأقل", "INVALID_STAY_DURATION");
        }

        return ResultDto<PropertyAvailabilityResponse>.Ok(null, "البيانات صحيحة");
    }

    private async Task<bool> IsUnitAvailable(Guid unitId, DateTime checkIn, DateTime checkOut, CancellationToken cancellationToken)
    {
        try
        {
            // Search for conflicting bookings.
            // البحث عن حجوزات متضاربة.
            var conflictingBookings = await _bookingRepository.GetConflictingBookingsAsync(
                unitId, checkIn, checkOut, cancellationToken);

            return conflictingBookings == null || !conflictingBookings.Any();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء التحقق من توفر الوحدة: {UnitId}", unitId);
            // In case of errors, treat the unit as unavailable for safety.
            // في حالة الخطأ نعتبر الوحدة غير متاحة للسلامة.
            return false;
        }
    }

    private async Task<decimal> CalculateUnitPrice(Core.Entities.Unit unit, string propertyCurrency, DateTime checkIn, DateTime checkOut, CancellationToken cancellationToken)
    {
        try
        {
            if (checkOut <= checkIn)
            {
                return 0m;
            }

            var localStart = new DateTime(checkIn.Year, checkIn.Month, checkIn.Day, 0, 0, 0);
            var lastNight = checkOut.AddDays(-1);
            var localEnd = new DateTime(lastNight.Year, lastNight.Month, lastNight.Day, 23, 59, 59, 999);

            var pricingResult = await _scheduleService.CalculatePriceForPeriodAsync(
                unit.Id,
                localStart.Date,
                localEnd.Date,
                0m,
                propertyCurrency);

            if (pricingResult.TotalDays <= 0 || pricingResult.TotalPrice <= 0)
            {
                return 0m;
            }

            var pricePerNight = pricingResult.TotalPrice / pricingResult.TotalDays;
            // The daily schedule price returned by the pricing service is final.
            // سعر الجدول اليومي الناتج من خدمة التسعير هو سعر نهائي.

            if (pricePerNight < 0)
            {
                pricePerNight = 0m;
            }

            return pricePerNight;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء حساب سعر الوحدة: {UnitId}", unit.Id);
            return 0m; // Return zero on failure / إرجاع صفر في حالة الخطأ.
        }
    }
}
