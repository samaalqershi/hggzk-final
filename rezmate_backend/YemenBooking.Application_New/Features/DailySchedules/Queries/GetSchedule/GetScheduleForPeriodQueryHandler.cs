using AutoMapper;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.DailySchedules.DTOs;
using YemenBooking.Application.Infrastructure.Services;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.DailySchedules.Queries.GetSchedule;

public class GetScheduleForPeriodQueryHandler : IRequestHandler<GetScheduleForPeriodQuery, ResultDto<List<DailyScheduleDto>>>
{
    private readonly IDailyUnitScheduleService _scheduleService;
    private readonly ICurrentUserService _currentUserService;
    private readonly IUnitRepository _unitRepository;
    private readonly IMapper _mapper;
    private readonly ILogger<GetScheduleForPeriodQueryHandler> _logger;

    public GetScheduleForPeriodQueryHandler(
        IDailyUnitScheduleService scheduleService,
        ICurrentUserService currentUserService,
        IUnitRepository unitRepository,
        IMapper mapper,
        ILogger<GetScheduleForPeriodQueryHandler> logger)
    {
        _scheduleService = scheduleService;
        _currentUserService = currentUserService;
        _unitRepository = unitRepository;
        _mapper = mapper;
        _logger = logger;
    }

    public async Task<ResultDto<List<DailyScheduleDto>>> Handle(GetScheduleForPeriodQuery request, CancellationToken cancellationToken)
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
                    return ResultDto<List<DailyScheduleDto>>.Failure("الوحدة غير موجودة");
                }

                var enforcedPropertyId = _currentUserService.PropertyId;
                if (enforcedPropertyId.HasValue && enforcedPropertyId.Value != Guid.Empty)
                {
                    if (unit.PropertyId != enforcedPropertyId.Value)
                        return ResultDto<List<DailyScheduleDto>>.Failure("غير مصرح لك بالوصول إلى هذه الوحدة");
                }
                else
                {
                    var property = await _unitRepository.GetPropertyByIdAsync(unit.PropertyId, cancellationToken);
                    if (property == null || property.OwnerId != _currentUserService.UserId)
                        return ResultDto<List<DailyScheduleDto>>.Failure("غير مصرح لك بالوصول إلى هذه الوحدة");
                }
            }

            var schedules = await _scheduleService.GetScheduleForPeriodAsync(
                request.UnitId,
                startUtc,
                endUtc,
                request.IncludeUnit,
                request.IncludeBooking);

            var scheduleDtos = _mapper.Map<List<DailyScheduleDto>>(schedules);

            return ResultDto<List<DailyScheduleDto>>.Ok(scheduleDtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "حدث خطأ أثناء الحصول على الجدول اليومي للوحدة {UnitId}", request.UnitId);
            return ResultDto<List<DailyScheduleDto>>.Failure($"حدث خطأ: {ex.Message}");
        }
    }
}
