using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Notifications.Services;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Notifications.Channels.Commands.UpdateChannel;

/// <summary>
/// يعالج الطلب ويطبق منطق التنفيذ.
/// Processes the request and applies the execution logic.
/// </summary>
public class UpdateChannelCommandHandler : IRequestHandler<UpdateChannelCommand, NotificationChannel>
{
    private readonly INotificationChannelService _channelService;
    private readonly ILogger<UpdateChannelCommandHandler> _logger;

    /// <summary>
    /// يهيئ مثيلاً جديدًا من المعالج.
    /// Initializes a new handler instance.
    /// </summary>
    public UpdateChannelCommandHandler(INotificationChannelService channelService, ILogger<UpdateChannelCommandHandler> logger)
    {
        _channelService = channelService;
        _logger = logger;
    }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
    public async Task<NotificationChannel> Handle(UpdateChannelCommand request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("UpdateChannelCommand: {ChannelId}", request.ChannelId);
        var channel = await _channelService.UpdateChannelAsync(
            request.ChannelId,
            request.Name,
            request.Description,
            request.IsActive,
            request.Icon,
            request.Color,
            cancellationToken);
        return channel;
    }
}
