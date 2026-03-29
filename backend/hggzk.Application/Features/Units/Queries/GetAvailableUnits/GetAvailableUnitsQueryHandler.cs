using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Units;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using System.Text.Json;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features.Units.DTOs;
using YemenBooking.Application.Features;
using YemenBooking.Core.Enums;

namespace YemenBooking.Application.Features.Units.Queries.GetAvailableUnits;

/// <summary>
/// يعالج جلب المتاح الوحدات ويعيد النتيجة المطلوبة.
/// Processes the Get Available Units request and returns the requested result.
/// </summary>
public class GetAvailableUnitsQueryHandler : IRequestHandler<GetAvailableUnitsQuery, ResultDto<AvailableUnitsResponse>>
{
    private readonly IUnitRepository _unitRepository;
    private readonly IPropertyRepository _propertyRepository;
    private readonly IUnitTypeRepository _unitTypeRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IPropertyImageRepository _propertyImageRepository;
    private readonly IUnitFieldValueRepository _unitFieldValueRepository;
    private readonly IDailyUnitScheduleRepository _scheduleRepository;
    private readonly ILogger<GetAvailableUnitsQueryHandler> _logger;
    private readonly ICurrentUserService _currentUserService;

    /// <summary>
    /// ينشئ مثيلاً جديداً من GetAvailableUnitsQueryHandler.
    /// Initializes a new instance of GetAvailableUnitsQueryHandler.
    /// </summary>
    public GetAvailableUnitsQueryHandler(
        IUnitRepository unitRepository,
        IPropertyRepository propertyRepository,
        IUnitTypeRepository unitTypeRepository,
        IBookingRepository bookingRepository,
        IPropertyImageRepository propertyImageRepository,
        IUnitFieldValueRepository unitFieldValueRepository,
        IDailyUnitScheduleRepository scheduleRepository,
        ILogger<GetAvailableUnitsQueryHandler> logger,
        ICurrentUserService currentUserService)
    {
        _unitRepository = unitRepository;
        _propertyRepository = propertyRepository;
        _unitTypeRepository = unitTypeRepository;
        _bookingRepository = bookingRepository;
        _propertyImageRepository = propertyImageRepository;
        _unitFieldValueRepository = unitFieldValueRepository;
        _scheduleRepository = scheduleRepository;
        _logger = logger;
        _currentUserService = currentUserService;
    }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
    public async Task<ResultDto<AvailableUnitsResponse>> Handle(GetAvailableUnitsQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء استعلام الوحدات المتاحة. معرف العقار: {PropertyId}, تاريخ الوصول: {CheckIn}, تاريخ المغادرة: {CheckOut}, عدد الضيوف: {GuestsCount}", 
                request.PropertyId, request.CheckIn.GetValueOrDefault(), request.CheckOut.GetValueOrDefault(), request.GuestsCount);

            // Validate the input data.
            var validationResult = ValidateRequest(request);
            if (!validationResult.IsSuccess)
            {
                return validationResult;
            }

            // Ensure the property exists.
            var property = await _propertyRepository.GetByIdAsync(request.PropertyId, cancellationToken);
            if (property == null)
            {
                _logger.LogWarning("لم يتم العثور على العقار: {PropertyId}", request.PropertyId);
                return ResultDto<AvailableUnitsResponse>.Failed("العقار غير موجود", "PROPERTY_NOT_FOUND");
            }

            // Ensure the property is active.
            if (!property.IsActive)
            {
                _logger.LogWarning("العقار غير نشط: {PropertyId}", request.PropertyId);
                return ResultDto<AvailableUnitsResponse>.Failed("العقار غير متاح حالياً", "PROPERTY_INACTIVE");
            }

            // Load all units for the property.
            var allUnits = await _unitRepository.GetByPropertyIdAsync(request.PropertyId, cancellationToken);
            if (allUnits == null || !allUnits.Any())
            {
                _logger.LogInformation("لا توجد وحدات في العقار: {PropertyId}", request.PropertyId);
                
                return ResultDto<AvailableUnitsResponse>.Ok(
                    new AvailableUnitsResponse
                    {
                        Units = new List<AvailableUnitDto>(),
                        TotalAvailable = 0
                    }, 
                    "لا توجد وحدات متاحة في هذا العقار"
                );
            }

            // Filter active units that can host the requested guest count.
            var eligibleUnitsQuery = allUnits
                .Where(u => u.IsActive && u.MaxCapacity >= request.GuestsCount);

            // فلترة إضافية حسب نوع الوحدة إذا تم تمرير UnitTypeId
            if (request.UnitTypeId.HasValue && request.UnitTypeId.Value != Guid.Empty)
            {
                eligibleUnitsQuery = eligibleUnitsQuery
                    .Where(u => u.UnitTypeId == request.UnitTypeId.Value);
            }

            var eligibleUnits = eligibleUnitsQuery.ToList();

            if (!eligibleUnits.Any())
            {
                _logger.LogInformation("لا توجد وحدات تتسع لـ {GuestsCount} ضيف في العقار: {PropertyId}", 
                    request.GuestsCount, request.PropertyId);
                
                return ResultDto<AvailableUnitsResponse>.Ok(
                    new AvailableUnitsResponse
                    {
                        Units = new List<AvailableUnitDto>(),
                        TotalAvailable = 0
                    }, 
                    $"لا توجد وحدات تتسع لـ {request.GuestsCount} ضيف"
                );
            }

            // Use the local date directly for DailyUnitSchedule because it is based on the local calendar.
            DateTime? checkInLocal = request.CheckIn?.Date;
            DateTime? checkOutLocal = request.CheckOut?.Date;

            // Keep UTC conversion only for conflict checks.
            DateTime? checkInUtc = null;
            DateTime? checkOutUtc = null;
            if (request.CheckIn.HasValue)
                checkInUtc = await _currentUserService.ConvertFromUserLocalToUtcAsync(request.CheckIn.Value);
            if (request.CheckOut.HasValue)
                checkOutUtc = await _currentUserService.ConvertFromUserLocalToUtcAsync(request.CheckOut.Value);

            // Check unit availability for the requested period.
            var availableUnits = new List<AvailableUnitDto>();
            var propertyCurrency = property.Currency ?? "YER";


                foreach (var unit in eligibleUnits)
                {
                    // Ensure there are no conflicting bookings.
                    var isAvailable = !checkInUtc.HasValue || !checkOutUtc.HasValue ? true : await IsUnitAvailable(unit.Id, checkInUtc.Value, checkOutUtc.Value, cancellationToken);

                    if (!isAvailable)
                    {
                        continue;
                    }

                    // Load unit type details.
                    var unitType = await _unitTypeRepository.GetByIdAsync(unit.UnitTypeId, cancellationToken);
                    var unitTypeDto = unitType != null ? new UnitTypeDto
                    {
                        Id = unitType.Id,
                        Name = unitType.Name ?? string.Empty,
                        NameEn = unitType.NameEn,
                        Description = unitType.Description ?? string.Empty,
                        DescriptionEn = unitType.DescriptionEn
                    } : new UnitTypeDto();

                    // Load unit images.
                    var allImages = await _propertyImageRepository.GetAllAsync(cancellationToken);
                    var unitImages = allImages?.Where(img => img.PropertyId == unit.PropertyId);
                    var imageDtos = unitImages?.Select(img => new UnitImageDto
                    {
                        Id = img.Id,
                        Url = img.Url ?? string.Empty,
                        Caption = img.Caption ?? string.Empty,
                        IsMain = img.IsMain
                    }).OrderByDescending(img => img.IsMain).ThenBy(img => img.Caption).ToList() ?? new List<UnitImageDto>();

                    // Load dynamic field values.
                    var fieldValues = await _unitFieldValueRepository.GetByUnitIdAsync(unit.Id, cancellationToken);
                    var fieldValueDtos = fieldValues?.Select(fv => new UnitFieldSimpleDto
                    {
                        FieldName = fv.UnitTypeField?.FieldName ?? string.Empty,
                        DisplayName = fv.UnitTypeField?.DisplayName ?? string.Empty,
                        DisplayNameEn = fv.UnitTypeField?.DisplayNameEn,
                        Value = fv.FieldValue ?? string.Empty,
                        FieldType = fv.UnitTypeField?.FieldTypeId ?? string.Empty,
                        IsPrimaryFilter = fv.UnitTypeField?.IsPrimaryFilter ?? false,
                        ShowInCards = fv.UnitTypeField?.ShowInCards ?? false
                    }).ToList() ?? new List<UnitFieldSimpleDto>();

                    // Calculate the price for the selected period.
                    var (totalPrice, pricePerNight, currency) =
                        !checkInLocal.HasValue || !checkOutLocal.HasValue
                            ? (0m, 0m, propertyCurrency)
                            : await CalculateUnitPrice(unit, propertyCurrency, checkInLocal.Value, checkOutLocal.Value, cancellationToken);

                    if (checkInLocal.HasValue && checkOutLocal.HasValue && totalPrice <= 0)
                    {
                        _logger.LogDebug(
                            "تم استبعاد الوحدة {UnitId} من النتائج بسبب عدم اكتمال/صحة التسعير للفترة {CheckIn} -> {CheckOut}",
                            unit.Id,
                            checkInLocal.Value.ToString("yyyy-MM-dd"),
                            checkOutLocal.Value.ToString("yyyy-MM-dd"));
                        continue;
                    }

                    var availableUnitDto = new AvailableUnitDto
                    {
                        Id = unit.Id,
                        Name = unit.Name ?? string.Empty,
                        NameEn = unit.NameEn,
                        UnitType = unitTypeDto,
                        MaxCapacity = unit.MaxCapacity,
                        TotalPrice = totalPrice,
                        PricePerNight = pricePerNight,
                        Currency = currency,
                        PricingMethod = unit.PricingMethod.ToString(),
                        Images = imageDtos,
                        CustomFeatures = ParseCustomFeatures(unit.CustomFeatures),
                        CustomFeaturesEn = ParseCustomFeatures(unit.CustomFeaturesEn),
                        FieldValues = fieldValueDtos
                    };

                    availableUnits.Add(availableUnitDto);
                }

            // Sort units by price, lowest first.
            availableUnits = availableUnits.OrderBy(u => u.TotalPrice).ToList();

            var response = new AvailableUnitsResponse
            {
                Units = availableUnits,
                TotalAvailable = availableUnits.Count
            };

            _logger.LogInformation("تم العثور على {Count} وحدة متاحة في العقار {PropertyId}", 
                availableUnits.Count, request.PropertyId);

            return ResultDto<AvailableUnitsResponse>.Ok(
                response, 
                $"تم العثور على {availableUnits.Count} وحدة متاحة"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء البحث عن الوحدات المتاحة. معرف العقار: {PropertyId}", request.PropertyId);
            return ResultDto<AvailableUnitsResponse>.Failed(
                $"حدث خطأ أثناء البحث عن الوحدات المتاحة: {ex.Message}", 
                "GET_AVAILABLE_UNITS_ERROR"
            );
        }
    }

    private ResultDto<AvailableUnitsResponse> ValidateRequest(GetAvailableUnitsQuery request)
    {
        if (request.PropertyId == Guid.Empty)
        {
            _logger.LogWarning("معرف العقار مطلوب");
            return ResultDto<AvailableUnitsResponse>.Failed("معرف العقار مطلوب", "PROPERTY_ID_REQUIRED");
        }

        if (request.CheckIn >= request.CheckOut)
        {
            _logger.LogWarning("تاريخ الوصول يجب أن يكون قبل تاريخ المغادرة");
            return ResultDto<AvailableUnitsResponse>.Failed("تاريخ الوصول يجب أن يكون قبل تاريخ المغادرة", "INVALID_DATE_RANGE");
        }

        // Use the user's local today value for validation.
        if (request.CheckIn.HasValue)
        {
            var userTodayLocal = _currentUserService.ConvertFromUtcToUserLocalAsync(DateTime.UtcNow).GetAwaiter().GetResult().Date;
            if (request.CheckIn.Value.Date < userTodayLocal)
            {
                _logger.LogWarning("تاريخ الوصول لا يمكن أن يكون في الماضي");
                return ResultDto<AvailableUnitsResponse>.Failed("تاريخ الوصول لا يمكن أن يكون في الماضي", "INVALID_CHECKIN_DATE");
            }
        }

        if (request.GuestsCount < 1 || request.GuestsCount > 50)
        {
            _logger.LogWarning("عدد الضيوف يجب أن يكون بين 1 و 50");
            return ResultDto<AvailableUnitsResponse>.Failed("عدد الضيوف يجب أن يكون بين 1 و 50", "INVALID_GUESTS_COUNT");
        }
        if (request.CheckIn.HasValue && request.CheckOut.HasValue)
        {
            // Ensure the stay does not exceed one year.
            var daysDifference = (request.CheckOut.Value - request.CheckIn.Value).Days;
            if (daysDifference > 365)
            {
                _logger.LogWarning("فترة الإقامة لا يمكن أن تتجاوز سنة واحدة");
                return ResultDto<AvailableUnitsResponse>.Failed("فترة الإقامة لا يمكن أن تتجاوز سنة واحدة", "INVALID_STAY_DURATION");
            }

        }

        return ResultDto<AvailableUnitsResponse>.Ok(null, "البيانات صحيحة");
    }

    private async Task<bool> IsUnitAvailable(Guid unitId, DateTime checkIn, DateTime checkOut, CancellationToken cancellationToken)
    {
        // Look up conflicting bookings.
        var conflictingBookings = await _bookingRepository.GetConflictingBookingsAsync(
            unitId, checkIn, checkOut, cancellationToken);

        return conflictingBookings == null || !conflictingBookings.Any();
    }

    private async Task<(decimal totalPrice, decimal pricePerNight, string currency)> CalculateUnitPrice(
        Core.Entities.Unit unit,
        string defaultCurrency,
        DateTime checkIn,
        DateTime checkOut,
        CancellationToken cancellationToken)
    {
        var nights = (checkOut - checkIn).Days;
        if (nights <= 0)
        {
            return (0m, 0m, defaultCurrency);
        }

        var pricingEndDate = checkOut.Date > checkIn.Date
            ? checkOut.Date.AddDays(-1)
            : checkIn.Date;

        var schedules = await _scheduleRepository.GetByUnitAndDateRangeAsync(
            unit.Id,
            checkIn.Date,
            pricingEndDate);

        var schedulesByDate = schedules
            .GroupBy(s => s.Date.Date)
            .ToDictionary(g => g.Key, g => g.OrderByDescending(x => x.UpdatedAt).First());

        decimal totalPrice = 0m;
        for (var date = checkIn.Date; date < checkOut.Date; date = date.AddDays(1))
        {
            if (!schedulesByDate.TryGetValue(date, out var schedule))
            {
                return (0m, 0m, defaultCurrency);
            }

            if (!IsBookableStatus(schedule.Status))
            {
                return (0m, 0m, defaultCurrency);
            }

            if (!schedule.PriceAmount.HasValue || schedule.PriceAmount.Value <= 0)
            {
                return (0m, 0m, defaultCurrency);
            }

            totalPrice += schedule.PriceAmount.Value;
        }

        totalPrice = decimal.Round(totalPrice, 2);
        var averagePricePerNight = nights > 0
            ? decimal.Round(totalPrice / nights, 2)
            : 0m;

        return (totalPrice, averagePricePerNight, defaultCurrency);
    }

    private static bool IsBookableStatus(string? status)
    {
        return string.Equals(status, AvailabilityStatus.Available, StringComparison.OrdinalIgnoreCase) ||
               string.Equals(status, "Free", StringComparison.OrdinalIgnoreCase);
    }

    // Safely parse invalid, empty, or non-object JSON in CustomFeatures.
    private static Dictionary<string, object> ParseCustomFeatures(string? json)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(json))
            {
                return new Dictionary<string, object>();
            }

            json = json.Trim();
            if (string.Equals(json, "null", StringComparison.OrdinalIgnoreCase))
            {
                return new Dictionary<string, object>();
            }

            // Use JsonHelper to parse JSON correctly, including nested lists.
            return YemenBooking.Core.Helpers.JsonHelper.SafeDeserializeDictionary(json);
        }
        catch
        {
            // Return an empty dictionary on parse errors to avoid crashing.
            return new Dictionary<string, object>();
        }
    }
}
