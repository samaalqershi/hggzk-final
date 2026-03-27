using AutoMapper;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Scheduling.DTOs;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Scheduling.Queries.GetSchedule;

/// <summary>
/// يعالج جلب الجدول for period ويعيد النتيجة المطلوبة.
/// Processes the Get Schedule For Period request and returns the requested result.
/// </summary>
public class GetScheduleForPeriodQueryHandler : IRequestHandler<GetScheduleForPeriodQuery, ResultDto<List<DailyScheduleDto>>>
{
    private readonly IDailyUnitScheduleService _scheduleService;
    private readonly ICurrentUserService _currentUserService;
    private readonly IUnitRepository _unitRepository;
    private readonly IMapper _mapper;
    private readonly ILogger<GetScheduleForPeriodQueryHandler> _logger;

    /// <summary>
    /// ينشئ مثيلاً جديداً من GetScheduleForPeriodQueryHandler.
    /// Initializes a new instance of GetScheduleForPeriodQueryHandler.
    /// </summary>
    /// <param name="scheduleService">خدمة الجدول / schedule service.</param>
    /// <param name="currentUserService">خدمة المستخدم الحالي / Current user service.</param>
    /// <param name="unitRepository">مستودع الوحدة / unit repository.</param>
    /// <param name="mapper">أداة التحويل / Mapper.</param>
    /// <param name="logger">مسجل الأحداث / Logger.</param>
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

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
    public async Task<ResultDto<List<DailyScheduleDto>>> Handle(GetScheduleForPeriodQuery request, CancellationToken cancellationToken)
    {
        try
        {
            // DailyUnitSchedule يعتمد على تاريخ محلي بدون وقت، لذلك لا نحول إلى UTC
            // حتى لا يتحرك أول يوم في النطاق إلى اليوم السابق.
            var localStart = request.StartDate.Date;
            var localEnd = request.EndDate.Date;

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
                localStart,
                localEnd,
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
