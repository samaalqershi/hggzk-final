using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Notifications.Services;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Notifications.Channels.Queries.GetChannelSubscribers;

/// <summary>
/// يعالج الاستعلام ويعيد النتائج المطلوبة.
/// Processes the query and returns the requested data.
/// </summary>
public class GetChannelSubscribersQueryHandler : IRequestHandler<GetChannelSubscribersQuery, IEnumerable<UserChannel>>
{
    private readonly INotificationChannelService _channelService;
    private readonly ILogger<GetChannelSubscribersQueryHandler> _logger;

    /// <summary>
    /// يهيئ مثيلاً جديدًا من المعالج.
    /// Initializes a new handler instance.
    /// </summary>
    public GetChannelSubscribersQueryHandler(INotificationChannelService channelService, ILogger<GetChannelSubscribersQueryHandler> logger)
    {
        _channelService = channelService;
        _logger = logger;
    }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
    public async Task<IEnumerable<UserChannel>> Handle(GetChannelSubscribersQuery request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("GetChannelSubscribersQuery: {ChannelId}, activeOnly={ActiveOnly}", request.ChannelId, request.ActiveOnly);
        return await _channelService.GetChannelSubscribersAsync(request.ChannelId, request.ActiveOnly, cancellationToken);
    }
}
