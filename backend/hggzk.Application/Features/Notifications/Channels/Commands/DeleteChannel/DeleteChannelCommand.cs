using MediatR;

namespace YemenBooking.Application.Features.Notifications.Channels.Commands.DeleteChannel;

    /// <summary>
    /// يمثل أمرًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area command.
    /// </summary>
public class DeleteChannelCommand : IRequest<bool>
{
    /// <summary>
    /// معرّف القناة.
    /// Channel identifier.
    /// </summary>
    public Guid ChannelId { get; set; }
}
