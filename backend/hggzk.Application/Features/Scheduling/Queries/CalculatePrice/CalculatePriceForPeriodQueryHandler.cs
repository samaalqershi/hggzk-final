using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Scheduling.Queries.CalculatePrice;

/// <summary>
/// يعالج حساب السعر for period ويعيد النتيجة المطلوبة.
/// Processes the Calculate Price For Period request and returns the requested result.
/// </summary>
public class CalculatePriceForPeriodQueryHandler : IRequestHandler<CalculatePriceForPeriodQuery, ResultDto<PricingCalculationResultDto>>
{
    private readonly IDailyUnitScheduleService _scheduleService;
    private readonly ICurrentUserService _currentUserService;
    private readonly IUnitRepository _unitRepository;
    private readonly ILogger<CalculatePriceForPeriodQueryHandler> _logger;

    /// <summary>
    /// ينشئ مثيلاً جديداً من CalculatePriceForPeriodQueryHandler.
    /// Initializes a new instance of CalculatePriceForPeriodQueryHandler.
    /// </summary>
    /// <param name="scheduleService">خدمة الجدول / schedule service.</param>
    /// <param name="currentUserService">خدمة المستخدم الحالي / Current user service.</param>
    /// <param name="unitRepository">مستودع الوحدة / unit repository.</param>
    /// <param name="logger">مسجل الأحداث / Logger.</param>
    public CalculatePriceForPeriodQueryHandler(
        IDailyUnitScheduleService scheduleService,
        ICurrentUserService currentUserService,
        IUnitRepository unitRepository,
        ILogger<CalculatePriceForPeriodQueryHandler> logger)
    {
        _scheduleService = scheduleService;
        _currentUserService = currentUserService;
        _unitRepository = unitRepository;
        _logger = logger;
    }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
    public async Task<ResultDto<PricingCalculationResultDto>> Handle(CalculatePriceForPeriodQuery request, CancellationToken cancellationToken)
    {
        try
        {
            var localStart = request.StartDate.Date;
            var localEnd = request.EndDate.Date;

            Core.Entities.Unit? unit = null;
            if (await _currentUserService.IsInRoleAsync("Owner"))
            {
                unit = await _unitRepository.GetByIdAsync(request.UnitId, cancellationToken);
                if (unit == null)
                {
                    return ResultDto<PricingCalculationResultDto>.Failure("الوحدة غير موجودة");
                }

                var enforcedPropertyId = _currentUserService.PropertyId;
                if (enforcedPropertyId.HasValue && enforcedPropertyId.Value != Guid.Empty)
                {
                    if (unit.PropertyId != enforcedPropertyId.Value)
                        return ResultDto<PricingCalculationResultDto>.Failure("غير مصرح لك بالوصول إلى هذه الوحدة");
                }
                else
                {
                    var property = await _unitRepository.GetPropertyByIdAsync(unit.PropertyId, cancellationToken);
                    if (property == null || property.OwnerId != _currentUserService.UserId)
                        return ResultDto<PricingCalculationResultDto>.Failure("غير مصرح لك بالوصول إلى هذه الوحدة");
                }
            }
            else
            {
                unit = await _unitRepository.GetByIdAsync(request.UnitId, cancellationToken);
            }

            var propertyCurrency = unit == null
                ? request.BaseCurrency
                : (await _unitRepository.GetPropertyByIdAsync(unit.PropertyId, cancellationToken))?.Currency
                    ?? request.BaseCurrency;

            var result = await _scheduleService.CalculatePriceForPeriodAsync(
                request.UnitId,
                localStart,
                localEnd,
                request.BasePriceAmount,
                propertyCurrency);

            var dto = new PricingCalculationResultDto
            {
                TotalPrice = result.TotalPrice,
                Currency = result.Currency,
                TotalDays = result.TotalDays,
                DaysWithCustomPricing = result.DaysWithCustomPricing,
                DaysWithBasePrice = result.DaysWithBasePrice,
                AveragePerDay = result.AveragePerDay,
                DailyPrices = result.DailyPrices.Select(dp => new DailyPriceInfoDto
                {
                    Date = dp.Date,
                    Price = dp.Price,
                    PriceType = dp.PriceType,
                    IsCustomPrice = dp.IsCustomPrice
                }).ToList()
            };

            return ResultDto<PricingCalculationResultDto>.Ok(dto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "حدث خطأ أثناء حساب السعر للوحدة {UnitId}", request.UnitId);
            return ResultDto<PricingCalculationResultDto>.Failure($"حدث خطأ: {ex.Message}");
        }
    }
}
