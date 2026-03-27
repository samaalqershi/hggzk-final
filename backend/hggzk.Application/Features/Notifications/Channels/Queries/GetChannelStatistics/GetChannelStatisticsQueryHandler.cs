using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Notifications.Services;

namespace YemenBooking.Application.Features.Notifications.Channels.Queries.GetChannelStatistics;

/// <summary>
/// يعالج الاستعلام ويعيد النتائج المطلوبة.
/// Processes the query and returns the requested data.
/// </summary>
public class GetChannelStatisticsQueryHandler : IRequestHandler<GetChannelStatisticsQuery, Dictionary<string, object>>
{
    private readonly INotificationChannelService _channelService;
    private readonly ILogger<GetChannelStatisticsQueryHandler> _logger;

    /// <summary>
    /// يهيئ مثيلاً جديدًا من المعالج.
    /// Initializes a new handler instance.
    /// </summary>
    public GetChannelStatisticsQueryHandler(INotificationChannelService channelService, ILogger<GetChannelStatisticsQueryHandler> logger)
    {
        _channelService = channelService;
        _logger = logger;
    }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
    public async Task<Dictionary<string, object>> Handle(GetChannelStatisticsQuery request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("GetChannelStatisticsQuery: {ChannelId}", request.ChannelId);
        return await _channelService.GetChannelStatisticsAsync(request.ChannelId, cancellationToken);
    }
}
