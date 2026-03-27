using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Notifications.Services;

namespace YemenBooking.Application.Features.Notifications.Channels.Commands.AddSubscribers;

/// <summary>
/// يعالج الطلب ويطبق منطق التنفيذ.
/// Processes the request and applies the execution logic.
/// </summary>
public class AddSubscribersCommandHandler : IRequestHandler<AddSubscribersCommand, int>
{
    private readonly INotificationChannelService _channelService;
    private readonly ILogger<AddSubscribersCommandHandler> _logger;

    /// <summary>
    /// يهيئ مثيلاً جديدًا من المعالج.
    /// Initializes a new handler instance.
    /// </summary>
    public AddSubscribersCommandHandler(INotificationChannelService channelService, ILogger<AddSubscribersCommandHandler> logger)
    {
        _channelService = channelService;
        _logger = logger;
    }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
    public async Task<int> Handle(AddSubscribersCommand request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("AddSubscribersCommand: Channel {ChannelId} - Count {Count}", request.ChannelId, request.UserIds?.Count ?? 0);
        return await _channelService.BulkSubscribeUsersAsync(request.ChannelId, request.UserIds ?? Enumerable.Empty<Guid>(), cancellationToken);
    }
}
