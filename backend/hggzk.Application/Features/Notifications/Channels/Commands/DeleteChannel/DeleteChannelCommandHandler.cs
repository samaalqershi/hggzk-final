using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Notifications.Services;

namespace YemenBooking.Application.Features.Notifications.Channels.Commands.DeleteChannel;

/// <summary>
/// يعالج الطلب ويطبق منطق التنفيذ.
/// Processes the request and applies the execution logic.
/// </summary>
public class DeleteChannelCommandHandler : IRequestHandler<DeleteChannelCommand, bool>
{
    private readonly INotificationChannelService _channelService;
    private readonly ILogger<DeleteChannelCommandHandler> _logger;

    /// <summary>
    /// يهيئ مثيلاً جديدًا من المعالج.
    /// Initializes a new handler instance.
    /// </summary>
    public DeleteChannelCommandHandler(INotificationChannelService channelService, ILogger<DeleteChannelCommandHandler> logger)
    {
        _channelService = channelService;
        _logger = logger;
    }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
    public async Task<bool> Handle(DeleteChannelCommand request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("DeleteChannelCommand: {ChannelId}", request.ChannelId);
        return await _channelService.DeleteChannelAsync(request.ChannelId, cancellationToken);
    }
}
