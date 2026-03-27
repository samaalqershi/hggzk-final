using MediatR;

namespace YemenBooking.Application.Features.Notifications.Channels.Queries.GetChannelsStatistics;

    /// <summary>
    /// يمثل استعلامًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area query.
    /// </summary>
public class GetChannelsStatisticsQuery : IRequest<Dictionary<string, object>>
{
}
