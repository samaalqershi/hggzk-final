using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Notifications.Services;

namespace YemenBooking.Application.Features.Notifications.Channels.Queries.GetChannelsStatistics;

/// <summary>
/// يعالج الاستعلام ويعيد النتائج المطلوبة.
/// Processes the query and returns the requested data.
/// </summary>
public class GetChannelsStatisticsQueryHandler : IRequestHandler<GetChannelsStatisticsQuery, Dictionary<string, object>>
{
    private readonly INotificationChannelService _channelService;
    private readonly ILogger<GetChannelsStatisticsQueryHandler> _logger;

    /// <summary>
    /// يهيئ مثيلاً جديدًا من المعالج.
    /// Initializes a new handler instance.
    /// </summary>
    public GetChannelsStatisticsQueryHandler(INotificationChannelService channelService, ILogger<GetChannelsStatisticsQueryHandler> logger)
    {
        _channelService = channelService;
        _logger = logger;
    }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
    public async Task<Dictionary<string, object>> Handle(GetChannelsStatisticsQuery request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("GetChannelsStatisticsQuery");
        return await _channelService.GetChannelsStatisticsAsync(cancellationToken);
    }
}
