
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Units.Queries.GetUnitAvailableDays;

public class GetUnitAvailableDaysQuery : IRequest<ResultDto<UnitAvailableDaysResponseDto>>
{
    public Guid UnitId { get; set; }

    public int Months { get; set; } = 3;

    public Guid? ExcludeBookingId { get; set; }
}

public class UnitAvailableDaysResponseDto
{
    public DateTime StartDate { get; set; }

    public DateTime EndDate { get; set; }

    public List<DateTime> AvailableDates { get; set; } = new();

    public List<DateTime> UnpricedDates { get; set; } = new();
}
