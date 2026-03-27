using MediatR;

namespace YemenBooking.Application.Features.Notifications.Channels.Queries.GetChannelStatistics;

    /// <summary>
    /// يمثل استعلامًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area query.
    /// </summary>
public class GetChannelStatisticsQuery : IRequest<Dictionary<string, object>>
{
    /// <summary>
    /// معرّف القناة.
    /// Channel identifier.
    /// </summary>
    public Guid ChannelId { get; set; }
}
