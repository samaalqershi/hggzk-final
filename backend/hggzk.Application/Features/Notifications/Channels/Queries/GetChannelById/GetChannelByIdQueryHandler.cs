using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Notifications.Services;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Notifications.Channels.Queries.GetChannelById;

/// <summary>
/// يعالج الاستعلام ويعيد النتائج المطلوبة.
/// Processes the query and returns the requested data.
/// </summary>
public class GetChannelByIdQueryHandler : IRequestHandler<GetChannelByIdQuery, NotificationChannel?>
{
    private readonly INotificationChannelService _channelService;
    private readonly ILogger<GetChannelByIdQueryHandler> _logger;

    /// <summary>
    /// يهيئ مثيلاً جديدًا من المعالج.
    /// Initializes a new handler instance.
    /// </summary>
    public GetChannelByIdQueryHandler(INotificationChannelService channelService, ILogger<GetChannelByIdQueryHandler> logger)
    {
        _channelService = channelService;
        _logger = logger;
    }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
    public async Task<NotificationChannel?> Handle(GetChannelByIdQuery request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("GetChannelByIdQuery: {ChannelId}", request.ChannelId);
        return await _channelService.GetChannelAsync(request.ChannelId, cancellationToken);
    }
}
