using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Scheduling.Queries.CheckAvailability;

/// <summary>
/// يعالج التحقق من الوحدة التوفر ويعيد النتيجة المطلوبة.
/// Processes the Check Unit Availability request and returns the requested result.
/// </summary>
public class CheckUnitAvailabilityQueryHandler : IRequestHandler<CheckUnitAvailabilityQuery, ResultDto<AvailabilityCheckResultDto>>
{
    private readonly IDailyUnitScheduleService _scheduleService;
    private readonly IUnitRepository _unitRepository;
    private readonly ILogger<CheckUnitAvailabilityQueryHandler> _logger;

    /// <summary>
    /// ينشئ مثيلاً جديداً من CheckUnitAvailabilityQueryHandler.
    /// Initializes a new instance of CheckUnitAvailabilityQueryHandler.
    /// </summary>
    /// <param name="scheduleService">خدمة الجدول / schedule service.</param>
    /// <param name="unitRepository">مستودع الوحدة / unit repository.</param>
    /// <param name="logger">مسجل الأحداث / Logger.</param>
    public CheckUnitAvailabilityQueryHandler(
        IDailyUnitScheduleService scheduleService,
        IUnitRepository unitRepository,
        ILogger<CheckUnitAvailabilityQueryHandler> logger)
    {
        _scheduleService = scheduleService;
        _unitRepository = unitRepository;
        _logger = logger;
    }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
    public async Task<ResultDto<AvailabilityCheckResultDto>> Handle(CheckUnitAvailabilityQuery request, CancellationToken cancellationToken)
    {
        try
        {
            // DailyUnitSchedule يعتمد على التاريخ المحلي مباشرة، لا على UTC.
            var localStart = request.StartDate.Date;
            var localEnd = request.EndDate.Date.AddDays(-1);

            var unit = await _unitRepository.GetByIdWithIncludesAsync(
                request.UnitId,
                u => u.Property);

            if (unit == null)
            {
                return ResultDto<AvailabilityCheckResultDto>.Failure("الوحدة غير موجودة");
            }

            // فحص التوفر بناءً على الجداول اليومية
            var availabilityResult = await _scheduleService.CheckAvailabilityAsync(
                request.UnitId,
                localStart,
                localEnd,
                request.ExcludeBookingId);

            // حساب السعر للفترة نفسها باستخدام خدمة الجدول اليومي
            PricingCalculationResult? pricingResult = null;
            try
            {
                pricingResult = await _scheduleService.CalculatePriceForPeriodAsync(
                    request.UnitId,
                    localStart,
                    localEnd,
                    0m,
                    unit.Property?.Currency ?? "YER");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "حدث خطأ أثناء حساب السعر للوحدة {UnitId} في استعلام التوفر", request.UnitId);
            }

            decimal? totalPrice = null;
            decimal? pricePerNight = null;
            string? currency = null;

            if (pricingResult != null && pricingResult.TotalDays > 0 && pricingResult.TotalPrice > 0)
            {
                totalPrice = pricingResult.TotalPrice;
                currency = pricingResult.Currency;
                pricePerNight = pricingResult.TotalPrice / pricingResult.TotalDays;
            }

            var dto = new AvailabilityCheckResultDto
            {
                IsAvailable = availabilityResult.IsAvailable,
                TotalDays = availabilityResult.TotalDays,
                AvailableDays = availabilityResult.AvailableDays,
                UnavailableDays = availabilityResult.UnavailableDays,
                UnavailableDates = availabilityResult.UnavailableDates,
                Message = availabilityResult.Message,
                TotalPrice = totalPrice,
                PricePerNight = pricePerNight,
                Currency = currency
            };

            return ResultDto<AvailabilityCheckResultDto>.Ok(dto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "حدث خطأ أثناء فحص توفر الوحدة {UnitId}", request.UnitId);
            return ResultDto<AvailabilityCheckResultDto>.Failure($"حدث خطأ: {ex.Message}");
        }
    }
}
