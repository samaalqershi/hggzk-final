using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Notifications.Services;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Notifications.Channels.Commands.SendChannelNotification;

/// <summary>
/// يعالج الطلب ويطبق منطق التنفيذ.
/// Processes the request and applies the execution logic.
/// </summary>
public class SendChannelNotificationCommandHandler : IRequestHandler<SendChannelNotificationCommand, NotificationChannelHistory>
{
    private readonly INotificationChannelService _channelService;
    private readonly ILogger<SendChannelNotificationCommandHandler> _logger;

    /// <summary>
    /// يهيئ مثيلاً جديدًا من المعالج.
    /// Initializes a new handler instance.
    /// </summary>
    public SendChannelNotificationCommandHandler(INotificationChannelService channelService, ILogger<SendChannelNotificationCommandHandler> logger)
    {
        _channelService = channelService;
        _logger = logger;
    }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
    public async Task<NotificationChannelHistory> Handle(SendChannelNotificationCommand request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("SendChannelNotificationCommand: {ChannelId} {Title}", request.ChannelId, request.Title);
        return await _channelService.SendChannelNotificationAsync(
            request.ChannelId,
            request.Title,
            request.Content,
            request.Type ?? "INFO",
            request.SenderId,
            request.Data,
            cancellationToken);
    }
}
