using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Notifications.Services;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Notifications.Channels.Queries.GetChannelHistory;

/// <summary>
/// يعالج الاستعلام ويعيد النتائج المطلوبة.
/// Processes the query and returns the requested data.
/// </summary>
public class GetChannelHistoryQueryHandler : IRequestHandler<GetChannelHistoryQuery, IEnumerable<NotificationChannelHistory>>
{
    private readonly INotificationChannelService _channelService;
    private readonly ILogger<GetChannelHistoryQueryHandler> _logger;

    /// <summary>
    /// يهيئ مثيلاً جديدًا من المعالج.
    /// Initializes a new handler instance.
    /// </summary>
    public GetChannelHistoryQueryHandler(INotificationChannelService channelService, ILogger<GetChannelHistoryQueryHandler> logger)
    {
        _channelService = channelService;
        _logger = logger;
    }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
    public async Task<IEnumerable<NotificationChannelHistory>> Handle(GetChannelHistoryQuery request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("GetChannelHistoryQuery: {ChannelId} page={Page}", request.ChannelId, request.Page);
        return await _channelService.GetChannelHistoryAsync(request.ChannelId, request.Page, request.PageSize, cancellationToken);
    }
}
