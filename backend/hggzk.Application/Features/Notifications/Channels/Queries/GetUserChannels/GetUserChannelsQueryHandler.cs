using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Notifications.Services;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Notifications.Channels.Queries.GetUserChannels;

/// <summary>
/// يعالج الاستعلام ويعيد النتائج المطلوبة.
/// Processes the query and returns the requested data.
/// </summary>
public class GetUserChannelsQueryHandler : IRequestHandler<GetUserChannelsQuery, IEnumerable<NotificationChannel>>
{
    private readonly INotificationChannelService _channelService;
    private readonly ILogger<GetUserChannelsQueryHandler> _logger;

    /// <summary>
    /// يهيئ مثيلاً جديدًا من المعالج.
    /// Initializes a new handler instance.
    /// </summary>
    public GetUserChannelsQueryHandler(INotificationChannelService channelService, ILogger<GetUserChannelsQueryHandler> logger)
    {
        _channelService = channelService;
        _logger = logger;
    }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
    public async Task<IEnumerable<NotificationChannel>> Handle(GetUserChannelsQuery request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("GetUserChannelsQuery: User {UserId} activeOnly={ActiveOnly}", request.UserId, request.ActiveOnly);
        return await _channelService.GetUserChannelsAsync(request.UserId, request.ActiveOnly, cancellationToken);
    }
}
