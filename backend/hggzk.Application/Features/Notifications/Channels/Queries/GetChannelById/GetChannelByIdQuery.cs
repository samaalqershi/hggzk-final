using MediatR;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Notifications.Channels.Queries.GetChannelById;

    /// <summary>
    /// يمثل استعلامًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area query.
    /// </summary>
public class GetChannelByIdQuery : IRequest<NotificationChannel?>
{
    /// <summary>
    /// معرّف القناة.
    /// Channel identifier.
    /// </summary>
    public Guid ChannelId { get; set; }
}
