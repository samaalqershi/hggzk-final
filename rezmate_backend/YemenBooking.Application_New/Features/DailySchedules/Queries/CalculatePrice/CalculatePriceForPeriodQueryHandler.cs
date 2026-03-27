using MediatR;
using Microsoft.Extensions.Logging;
using System.Linq;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Infrastructure.Services;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.DailySchedules.Queries.CalculatePrice;

public class CalculatePriceForPeriodQueryHandler : IRequestHandler<CalculatePriceForPeriodQuery, ResultDto<PricingCalculationResultDto>>
{
    private readonly IDailyUnitScheduleService _scheduleService;
    private readonly ICurrentUserService _currentUserService;
    private readonly IUnitRepository _unitRepository;
    private readonly ILogger<CalculatePriceForPeriodQueryHandler> _logger;

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

    public async Task<ResultDto<PricingCalculationResultDto>> Handle(CalculatePriceForPeriodQuery request, CancellationToken cancellationToken)
    {
        try
        {
            var localStart = new DateTime(request.StartDate.Year, request.StartDate.Month, request.StartDate.Day, 0, 0, 0);
            var localEnd = new DateTime(request.EndDate.Year, request.EndDate.Month, request.EndDate.Day, 23, 59, 59, 999);
            var startUtc = await _currentUserService.ConvertFromUserLocalToUtcAsync(localStart);
            var endUtc = await _currentUserService.ConvertFromUserLocalToUtcAsync(localEnd);

            if (await _currentUserService.IsInRoleAsync("Owner"))
            {
                var unit = await _unitRepository.GetByIdAsync(request.UnitId, cancellationToken);
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

            var result = await _scheduleService.CalculatePriceForPeriodAsync(
                request.UnitId,
                startUtc,
                endUtc,
                request.BasePriceAmount,
                request.BaseCurrency);

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
