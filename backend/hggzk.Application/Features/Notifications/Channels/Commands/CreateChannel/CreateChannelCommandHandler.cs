using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Notifications.Services;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Notifications.Channels.Commands.CreateChannel;

/// <summary>
/// يعالج الطلب ويطبق منطق التنفيذ.
/// Processes the request and applies the execution logic.
/// </summary>
public class CreateChannelCommandHandler : IRequestHandler<CreateChannelCommand, NotificationChannel>
{
    private readonly INotificationChannelService _channelService;
    private readonly ILogger<CreateChannelCommandHandler> _logger;

    /// <summary>
    /// يهيئ مثيلاً جديدًا من المعالج.
    /// Initializes a new handler instance.
    /// </summary>
    public CreateChannelCommandHandler(INotificationChannelService channelService, ILogger<CreateChannelCommandHandler> logger)
    {
        _channelService = channelService;
        _logger = logger;
    }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
    public async Task<NotificationChannel> Handle(CreateChannelCommand request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("CreateChannelCommand: {Name} ({Identifier})", request.Name, request.Identifier);
        var channel = await _channelService.CreateChannelAsync(
            request.Name,
            request.Identifier,
            request.Description,
            request.Type ?? "CUSTOM",
            request.CreatedBy,
            request.Icon,
            request.Color,
            cancellationToken);
        return channel;
    }
}
