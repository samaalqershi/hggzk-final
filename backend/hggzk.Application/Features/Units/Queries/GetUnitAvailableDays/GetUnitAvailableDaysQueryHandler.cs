using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Units.Queries.GetUnitAvailableDays;

/// <summary>
/// يعالج جلب الوحدة المتاح days ويعيد النتيجة المطلوبة.
/// Processes the Get Unit Available Days request and returns the requested result.
/// </summary>
public class GetUnitAvailableDaysQueryHandler : IRequestHandler<GetUnitAvailableDaysQuery, ResultDto<UnitAvailableDaysResponseDto>>
{
    private readonly IDailyUnitScheduleRepository _scheduleRepository;
    private readonly IUnitRepository _unitRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<GetUnitAvailableDaysQueryHandler> _logger;

    /// <summary>
    /// ينشئ مثيلاً جديداً من GetUnitAvailableDaysQueryHandler.
    /// Initializes a new instance of GetUnitAvailableDaysQueryHandler.
    /// </summary>
    /// <param name="scheduleRepository">مستودع الجدول / schedule repository.</param>
    /// <param name="unitRepository">مستودع الوحدة / unit repository.</param>
    /// <param name="currentUserService">خدمة المستخدم الحالي / Current user service.</param>
    /// <param name="logger">مسجل الأحداث / Logger.</param>
    public GetUnitAvailableDaysQueryHandler(
        IDailyUnitScheduleRepository scheduleRepository,
        IUnitRepository unitRepository,
        ICurrentUserService currentUserService,
        ILogger<GetUnitAvailableDaysQueryHandler> logger)
    {
        _scheduleRepository = scheduleRepository;
        _unitRepository = unitRepository;
        _currentUserService = currentUserService;
        _logger = logger;
    }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
    public async Task<ResultDto<UnitAvailableDaysResponseDto>> Handle(GetUnitAvailableDaysQuery request, CancellationToken cancellationToken)
    {
        try
        {
            if (request.UnitId == Guid.Empty)
                return ResultDto<UnitAvailableDaysResponseDto>.Failed("معرف الوحدة مطلوب", "UNIT_ID_REQUIRED");

            var unit = await _unitRepository.GetUnitByIdAsync(request.UnitId, cancellationToken);
            if (unit == null || unit.IsDeleted || !unit.IsActive)
                return ResultDto<UnitAvailableDaysResponseDto>.Failed("الوحدة غير موجودة", "UNIT_NOT_FOUND");

            var months = request.Months;
            if (months <= 0) months = 3;
            if (months > 3) months = 3;

            var localToday = (await _currentUserService.ConvertFromUtcToUserLocalAsync(DateTime.UtcNow)).Date;
            var localEndDate = localToday.AddMonths(months).AddDays(-1);

            // DailyUnitSchedule يُخزن على أساس التاريخ المحلي فقط، لذلك أي تحويل إلى UTC هنا
            // قد يزحزح اليوم ويجعل يوماً محجوباً/صيانة يظهر كأنه متاح في التقويم.
            var schedules = await _scheduleRepository.GetByUnitAndDateRangeAsync(
                request.UnitId,
                localToday,
                localEndDate);
            var scheduleMap = schedules
                .GroupBy(s => s.Date.Date)
                .ToDictionary(g => g.Key, g => g.OrderByDescending(x => x.UpdatedAt).First());

            var available = new List<DateTime>();
            var unpriced = new List<DateTime>();

            for (var localDate = localToday; localDate <= localEndDate; localDate = localDate.AddDays(1))
            {
                if (scheduleMap.TryGetValue(localDate, out var schedule))
                {
                    var isAvailable = IsBookableStatus(schedule.Status) ||
                                      IsExcludedBookingDay(schedule, request.ExcludeBookingId);

                    if (isAvailable && HasValidPricing(schedule))
                        available.Add(localDate);
                    else if (isAvailable)
                        unpriced.Add(localDate);
                }
                else
                {
                    // Missing schedule means pricing is not configured for this day yet.
                    unpriced.Add(localDate);
                }
            }

            var dto = new UnitAvailableDaysResponseDto
            {
                StartDate = localToday,
                EndDate = localEndDate,
                AvailableDates = available,
                UnpricedDates = unpriced
            };

            return ResultDto<UnitAvailableDaysResponseDto>.Ok(dto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting available days for unit {UnitId}", request.UnitId);
            return ResultDto<UnitAvailableDaysResponseDto>.Failed("حدث خطأ أثناء جلب الأيام المتاحة", "GET_AVAILABLE_DAYS_ERROR");
        }
    }

    private static bool IsBookableStatus(string? status)
    {
        return string.Equals(status, AvailabilityStatus.Available, StringComparison.OrdinalIgnoreCase) ||
               string.Equals(status, "Free", StringComparison.OrdinalIgnoreCase);
    }

    private static bool IsExcludedBookingDay(DailyUnitSchedule schedule, Guid? excludeBookingId)
    {
        return excludeBookingId.HasValue &&
               string.Equals(schedule.Status, AvailabilityStatus.Booked, StringComparison.OrdinalIgnoreCase) &&
               schedule.BookingId == excludeBookingId.Value;
    }

    private static bool HasValidPricing(DailyUnitSchedule schedule)
    {
        return schedule.PriceAmount.HasValue && schedule.PriceAmount.Value > 0;
    }
}
