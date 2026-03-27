using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Units;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using System.Text.Json;
using YemenBooking.Core.Enums;
using YemenBooking.Core.Helpers;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.DynamicFields.DTOs;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features.Units.DTOs;
using YemenBooking.Application.Features;
using YemenBooking.Application.Features.Scheduling.DTOs;

namespace YemenBooking.Application.Features.Units.Queries.GetUnitDetails;

/// <summary>
/// يعالج جلب الوحدة التفاصيل ويعيد النتيجة المطلوبة.
/// Processes the Get Unit Details request and returns the requested result.
/// </summary>
public class GetUnitDetailsQueryHandler : IRequestHandler<GetUnitDetailsQuery, ResultDto<UnitDetailsDto>>
{
    private readonly IUnitRepository _unitRepository;
    private readonly IPropertyRepository _propertyRepository;
    private readonly IUnitTypeRepository _unitTypeRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IPropertyImageRepository _propertyImageRepository;
    private readonly IUnitFieldValueRepository _unitFieldValueRepository;
    private readonly IDailyUnitScheduleRepository _scheduleRepository;
    private readonly ILogger<GetUnitDetailsQueryHandler> _logger;
    private readonly ICurrentUserService _currentUserService;

    /// <summary>
    /// ينشئ مثيلاً جديداً من GetUnitDetailsQueryHandler.
    /// Initializes a new instance of GetUnitDetailsQueryHandler.
    /// </summary>
    public GetUnitDetailsQueryHandler(
        IUnitRepository unitRepository,
        IPropertyRepository propertyRepository,
        IUnitTypeRepository unitTypeRepository,
        IBookingRepository bookingRepository,
        IPropertyImageRepository propertyImageRepository,
        IUnitFieldValueRepository unitFieldValueRepository,
        IDailyUnitScheduleRepository scheduleRepository,
        ILogger<GetUnitDetailsQueryHandler> logger,
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
    public async Task<ResultDto<UnitDetailsDto>> Handle(GetUnitDetailsQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء استعلام تفاصيل الوحدة. معرف الوحدة: {UnitId}, تاريخ الوصول: {CheckIn}, تاريخ المغادرة: {CheckOut}", 
                request.UnitId, request.CheckIn, request.CheckOut);

            // Validate the input data.
            // التحقق من صحة البيانات المدخلة.
            var validationResult = ValidateRequest(request);
            if (!validationResult.IsSuccess)
            {
                return validationResult;
            }

            // Load the unit.
            // جلب الوحدة.
            var unit = await _unitRepository.GetByIdAsync(request.UnitId, cancellationToken);
            if (unit == null)
            {
                _logger.LogWarning("لم يتم العثور على الوحدة: {UnitId}", request.UnitId);
                return ResultDto<UnitDetailsDto>.Failed("الوحدة غير موجودة", "UNIT_NOT_FOUND");
            }

            // Ensure the unit is active.
            // التأكد من أن الوحدة نشطة.
            if (!unit.IsActive)
            {
                _logger.LogWarning("الوحدة غير نشطة: {UnitId}", request.UnitId);
                return ResultDto<UnitDetailsDto>.Failed("الوحدة غير متاحة حالياً", "UNIT_INACTIVE");
            }

            // Load the property details.
            // جلب تفاصيل العقار.
            var property = await _propertyRepository.GetByIdAsync(unit.PropertyId, cancellationToken);
            if (property == null)
            {
                _logger.LogWarning("لم يتم العثور على العقار للوحدة: {UnitId}", request.UnitId);
                return ResultDto<UnitDetailsDto>.Failed("بيانات العقار غير متاحة", "PROPERTY_NOT_FOUND");
            }

            // Load the unit type.
            // جلب نوع الوحدة.
            var unitType = await _unitTypeRepository.GetByIdAsync(unit.UnitTypeId, cancellationToken);
            var unitTypeDto = unitType != null ? new UnitTypeDto
            {
                Id = unitType.Id,
                Name = unitType.Name ?? string.Empty,
                Description = unitType.Description ?? string.Empty
            } : new UnitTypeDto();

            // Load unit images.
            // جلب صور الوحدة.
            var allImages = await _propertyImageRepository.GetAllAsync(cancellationToken);
            var unitImages = allImages?.Where(img => img.PropertyId == unit.PropertyId);
            var imageDtos = unitImages?.Select(img => new UnitImageDto
            {
                Id = img.Id,
                Url = img.Url ?? string.Empty,
                Caption = img.Caption ?? string.Empty,
                IsMain = img.IsMain,
                Is360 = img.Is360
            }).OrderByDescending(img => img.IsMain).ThenBy(img => img.Caption).ToList() ?? new List<UnitImageDto>();

            // Load dynamic field values.
            // جلب قيم الحقول الديناميكية.
            var fieldValues = await _unitFieldValueRepository.GetByUnitIdAsync(unit.Id, cancellationToken);
            var fieldValueDtos = fieldValues?.Select(fv => new UnitFieldValueDto
            {
                FieldName = fv.UnitTypeField?.FieldName ?? string.Empty,
                DisplayName = fv.UnitTypeField?.DisplayName ?? string.Empty,
                Value = fv.FieldValue ?? string.Empty,
                FieldType = fv.UnitTypeField?.FieldTypeId ?? string.Empty
            }).ToList() ?? new List<UnitFieldValueDto>();

            // Load daily pricing schedules.
            // جلب الجداول اليومية للتسعير.
            var dailySchedules = new List<DailyScheduleDto>();
            if (request.CheckIn.HasValue && request.CheckOut.HasValue)
            {
                var dailyScheduleEndDate = request.CheckOut.Value.Date > request.CheckIn.Value.Date
                    ? request.CheckOut.Value.Date.AddDays(-1)
                    : request.CheckIn.Value.Date;
                var schedules = await _scheduleRepository.GetByUnitAndDateRangeAsync(
                    unit.Id, request.CheckIn.Value.Date, dailyScheduleEndDate);
                
                dailySchedules = schedules?.Select(s => new DailyScheduleDto
                {
                    Date = s.Date,
                    PriceAmount = s.PriceAmount ?? 0,
                    PriceType = s.PriceType ?? "Base",
                    Status = s.Status,
                    Reason = s.Reason
                }).ToList() ?? new List<DailyScheduleDto>();
            }

            // Check availability.
            // التحقق من التوفر.
            bool isAvailable = true;
            if (request.CheckIn.HasValue && request.CheckOut.HasValue)
            {
                isAvailable = await IsUnitAvailable(unit.Id, request.CheckIn.Value, request.CheckOut.Value, cancellationToken);
            }

            // Calculate the price when dates are provided.
            // حساب السعر عند توفير التواريخ.
            CalculatedPriceDto? calculatedPrice = null;
            if (request.CheckIn.HasValue && request.CheckOut.HasValue && isAvailable)
            {
                calculatedPrice = await CalculatePrice(unit, request.CheckIn.Value, request.CheckOut.Value, cancellationToken);
            }

            // Convert DailySchedules dates to the user's local time.
            // تحويل تواريخ DailySchedules إلى التوقيت المحلي للمستخدم.
            for (int i = 0; i < dailySchedules.Count; i++)
            {
                dailySchedules[i].Date = await _currentUserService.ConvertFromUtcToUserLocalAsync(dailySchedules[i].Date);
            }

            // Convert CalculatedPrice breakdown dates to the user's local time.
            // تحويل تواريخ breakdown في CalculatedPrice إلى التوقيت المحلي للمستخدم.
            if (calculatedPrice?.Breakdown != null)
            {
                for (int i = 0; i < calculatedPrice.Breakdown.Count; i++)
                {
                    calculatedPrice.Breakdown[i].Date = await _currentUserService.ConvertFromUtcToUserLocalAsync(calculatedPrice.Breakdown[i].Date);
                }
            }

            // Build the response DTO.
            // إنشاء DTO للاستجابة.
            var unitDetailsDto = new UnitDetailsDto
            {
                Id = unit.Id,
                PropertyId = unit.PropertyId,
                PropertyName = property.Name ?? string.Empty,
                Name = unit.Name ?? string.Empty,
                UnitType = unitTypeDto,
                MaxCapacity = unit.MaxCapacity,
                PricingMethod = unit.PricingMethod.ToString(),
                Images = imageDtos,
                CustomFeatures = unit.CustomFeatures ?? string.Empty,
                FieldValues = fieldValueDtos,
                DailySchedules = dailySchedules,
                CalculatedPrice = calculatedPrice
            };

            _logger.LogInformation("تم الحصول على تفاصيل الوحدة بنجاح. معرف الوحدة: {UnitId}, متاحة: {IsAvailable}", 
                request.UnitId, isAvailable);

            return ResultDto<UnitDetailsDto>.Ok(
                unitDetailsDto, 
                "تم الحصول على تفاصيل الوحدة بنجاح"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء الحصول على تفاصيل الوحدة. معرف الوحدة: {UnitId}", request.UnitId);
            return ResultDto<UnitDetailsDto>.Failed(
                $"حدث خطأ أثناء الحصول على تفاصيل الوحدة: {ex.Message}", 
                "GET_UNIT_DETAILS_ERROR"
            );
        }
    }

    private ResultDto<UnitDetailsDto> ValidateRequest(GetUnitDetailsQuery request)
    {
        if (request.UnitId == Guid.Empty)
        {
            _logger.LogWarning("معرف الوحدة مطلوب");
            return ResultDto<UnitDetailsDto>.Failed("معرف الوحدة مطلوب", "UNIT_ID_REQUIRED");
        }

            // Validate dates when both boundaries are provided.
            // التحقق من التواريخ عند توفير الحدين.
        if (request.CheckIn.HasValue && request.CheckOut.HasValue)
        {
            if (request.CheckIn >= request.CheckOut)
            {
                _logger.LogWarning("تاريخ الوصول يجب أن يكون قبل تاريخ المغادرة");
                return ResultDto<UnitDetailsDto>.Failed("تاريخ الوصول يجب أن يكون قبل تاريخ المغادرة", "INVALID_DATE_RANGE");
            }

            if (request.CheckIn.Value.Date < DateTime.Today)
            {
                _logger.LogWarning("تاريخ الوصول لا يمكن أن يكون في الماضي");
                return ResultDto<UnitDetailsDto>.Failed("تاريخ الوصول لا يمكن أن يكون في الماضي", "INVALID_CHECKIN_DATE");
            }
        }

        return ResultDto<UnitDetailsDto>.Ok(null, "البيانات صحيحة");
    }

    private async Task<bool> IsUnitAvailable(Guid unitId, DateTime checkIn, DateTime checkOut, CancellationToken cancellationToken)
    {
        var conflictingBookings = await _bookingRepository.GetConflictingBookingsAsync(
            unitId, checkIn, checkOut, cancellationToken);

        return conflictingBookings == null || !conflictingBookings.Any();
    }

    private async Task<CalculatedPriceDto> CalculatePrice(
        Core.Entities.Unit unit, 
        DateTime checkIn, 
        DateTime checkOut, 
        CancellationToken cancellationToken)
    {
        var nights = (checkOut - checkIn).Days;
        var breakdown = new List<PriceBreakdownDto>();
        decimal baseAmount = 0;

        // Load daily schedules for the selected period.
        // جلب الجداول اليومية للفترة المحددة.
        var pricingEndDate = checkOut.Date > checkIn.Date
            ? checkOut.Date.AddDays(-1)
            : checkIn.Date;
        var schedules = await _scheduleRepository.GetByUnitAndDateRangeAsync(
            unit.Id, checkIn.Date, pricingEndDate);

        // Calculate the price for each day.
        // حساب السعر لكل يوم.
        for (var date = checkIn.Date; date < checkOut.Date; date = date.AddDays(1))
        {
            var dailyPrice = GetDailyPrice(unit, schedules, date);
            baseAmount += dailyPrice;

            breakdown.Add(new PriceBreakdownDto
            {
                Date = date,
                Amount = dailyPrice,
                Reason = GetPriceReason(date, schedules)
            });
        }

        // Calculate discounts.
        // حساب الخصومات.
        var discounts = CalculateDiscounts(baseAmount, nights);

        // Calculate additional fees.
        // حساب الرسوم الإضافية.
        var fees = CalculateFees(unit, baseAmount);

        // Calculate taxes.
        // حساب الضرائب.
        var taxes = CalculateTaxes(unit, baseAmount + fees - discounts);

        var totalAmount = baseAmount + fees + taxes - discounts;

        return new CalculatedPriceDto
        {
            BaseAmount = baseAmount,
            Discounts = discounts,
            Fees = fees,
            Taxes = taxes,
            TotalAmount = totalAmount,
            NumberOfNights = nights,
            Breakdown = breakdown
        };
    }

    private decimal GetDailyPrice(Core.Entities.Unit unit, IEnumerable<Core.Entities.DailyUnitSchedule>? schedules, DateTime date)
    {
        // Look up the daily schedule for this date.
        // البحث عن الجدول اليومي لهذا التاريخ.
        var schedule = schedules?
            .Where(s => s.Date.Date == date.Date && s.PriceAmount.HasValue)
            .FirstOrDefault();

        return schedule?.PriceAmount ?? 0m;
    }

    private string GetPriceReason(DateTime date, IEnumerable<Core.Entities.DailyUnitSchedule>? schedules)
    {
        var schedule = schedules?
            .Where(s => s.Date.Date == date.Date)
            .FirstOrDefault();

        if (schedule != null && !string.IsNullOrWhiteSpace(schedule.PriceType))
        {
            return schedule.Reason ?? schedule.PriceType ?? "سعر خاص";
        }

        // Determine the day type.
        // تحديد نوع اليوم.
        return date.DayOfWeek switch
        {
            DayOfWeek.Friday or DayOfWeek.Saturday => "نهاية أسبوع",
            _ => "سعر عادي"
        };
    }

    private decimal CalculateDiscounts(decimal baseAmount, int nights)
    {
        decimal discount = 0;

        // Long-stay discount.
        // خصم الإقامة الطويلة.
        if (nights >= 7)
        {
            discount += baseAmount * 0.1m; // خصم 10% للإقامة أسبوع أو أكثر
        }
        else if (nights >= 3)
        {
            discount += baseAmount * 0.05m; // خصم 5% للإقامة 3 أيام أو أكثر
        }

        return discount;
    }

    private decimal CalculateFees(Core.Entities.Unit unit, decimal baseAmount)
    {
        decimal fees = 0;

        // Service fee (2% of the base amount).
        // رسوم الخدمة (2% من المبلغ الأساسي).
        fees += baseAmount * 0.02m;

        // Cleaning fee when present in custom JSON features.
        // رسوم التنظيف عند وجودها في ميزات الوحدة المخصصة بصيغة JSON.
        if (!string.IsNullOrWhiteSpace(unit.CustomFeatures))
        {
            var features = JsonHelper.SafeDeserializeDictionary(unit.CustomFeatures);
            if (features.TryGetValue("cleaning_fee", out var feeObj))
            {
                if (decimal.TryParse(feeObj?.ToString(), out var cleaningFee))
                {
                    fees += cleaningFee;
                }
            }
        }

        return fees;
    }

    private decimal CalculateTaxes(Core.Entities.Unit unit, decimal taxableAmount)
    {
        // VAT (5% in Yemen).
        // الضريبة المضافة (5% في اليمن).
        return taxableAmount * 0.05m;
    }
}
