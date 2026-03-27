
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Units.Queries.GetUnitAvailableDays;

public class GetUnitAvailableDaysQueryHandler : IRequestHandler<GetUnitAvailableDaysQuery, ResultDto<UnitAvailableDaysResponseDto>>
{
    private readonly IDailyUnitScheduleRepository _scheduleRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<GetUnitAvailableDaysQueryHandler> _logger;

    public GetUnitAvailableDaysQueryHandler(
        IDailyUnitScheduleRepository scheduleRepository,
        ICurrentUserService currentUserService,
        ILogger<GetUnitAvailableDaysQueryHandler> logger)
    {
        _scheduleRepository = scheduleRepository;
        _currentUserService = currentUserService;
        _logger = logger;
    }

    public async Task<ResultDto<UnitAvailableDaysResponseDto>> Handle(GetUnitAvailableDaysQuery request, CancellationToken cancellationToken)
    {
        try
        {
            if (request.UnitId == Guid.Empty)
                return ResultDto<UnitAvailableDaysResponseDto>.Failed("معرف الوحدة مطلوب", "UNIT_ID_REQUIRED");

            var months = request.Months;
            if (months <= 0) months = 3;
            if (months > 12) months = 12;

            var localToday = (await _currentUserService.ConvertFromUtcToUserLocalAsync(DateTime.UtcNow)).Date;
            var localEndDate = localToday.AddMonths(months).AddDays(-1);

            // Build mapping localDate -> scheduleKeyDate (UTC date after converting user's local midnight to UTC)
            var localDates = new List<DateTime>();
            var scheduleKeyDates = new List<DateTime>();

            for (var d = localToday; d <= localEndDate; d = d.AddDays(1))
            {
                localDates.Add(d);
                var utc = await _currentUserService.ConvertFromUserLocalToUtcAsync(new DateTime(d.Year, d.Month, d.Day, 0, 0, 0));
                scheduleKeyDates.Add(utc.Date);
            }

            var scheduleStart = scheduleKeyDates.Min();
            var scheduleEnd = scheduleKeyDates.Max();

            var schedules = await _scheduleRepository.GetByUnitAndDateRangeAsync(request.UnitId, scheduleStart, scheduleEnd);
            var scheduleMap = schedules
                .GroupBy(s => s.Date.Date)
                .ToDictionary(g => g.Key, g => g.OrderByDescending(x => x.UpdatedAt).First());

            var available = new List<DateTime>(capacity: localDates.Count);
            var unpriced = new List<DateTime>();

            for (var i = 0; i < localDates.Count; i++)
            {
                var localDate = localDates[i];
                var keyDate = scheduleKeyDates[i];

                if (scheduleMap.TryGetValue(keyDate, out var schedule))
                {
                    var isAvailable = schedule.Status == "Available" ||
                                      (request.ExcludeBookingId.HasValue &&
                                       schedule.Status == "Booked" &&
                                       schedule.BookingId == request.ExcludeBookingId);

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

    private static bool HasValidPricing(YemenBooking.Core.Entities.DailyUnitSchedule schedule)
    {
        return schedule.PriceAmount.HasValue && schedule.PriceAmount.Value > 0;
    }
}
