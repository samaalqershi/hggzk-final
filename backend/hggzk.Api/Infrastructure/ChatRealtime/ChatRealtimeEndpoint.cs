using System;
using System.Linq;
using System.Net.WebSockets;
using System.Security.Claims;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Api.Infrastructure.ChatRealtime;

/// <summary>
/// Minimal authenticated WebSocket endpoint for chat realtime events.
/// نقطة WebSocket مصادقة ومبسطة لأحداث الدردشة اللحظية.
/// </summary>
public static class ChatRealtimeEndpoint
{
    private sealed class ClientCommand
    {
        public string? Type { get; set; }
        public string? ConversationId { get; set; }
        public string? Status { get; set; }
    }

    public static async Task HandleAsync(HttpContext context)
    {
        if (!context.WebSockets.IsWebSocketRequest)
        {
            if (!context.Response.HasStarted)
            {
                context.Response.StatusCode = StatusCodes.Status400BadRequest;
            }
            return;
        }

        if (context.User.Identity?.IsAuthenticated != true)
        {
            if (!context.Response.HasStarted)
            {
                context.Response.StatusCode = StatusCodes.Status401Unauthorized;
            }
            return;
        }

        var userIdClaim = context.User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdClaim, out var userId) || userId == Guid.Empty)
        {
            if (!context.Response.HasStarted)
            {
                context.Response.StatusCode = StatusCodes.Status401Unauthorized;
            }
            return;
        }

        var services = context.RequestServices;
        var logger = services.GetRequiredService<ILoggerFactory>().CreateLogger("ChatRealtimeEndpoint");
        var connectionManager = services.GetRequiredService<IChatRealtimeConnectionManager>();
        var notifier = services.GetRequiredService<IChatRealtimeNotifier>();
        var conversationRepository = services.GetRequiredService<IChatConversationRepository>();

        using var socket = await context.WebSockets.AcceptWebSocketAsync();
        await connectionManager.RegisterAsync(userId, socket, context.RequestAborted);
        await notifier.NotifyPresenceAsync(userId, "online", null, context.RequestAborted);
        await connectionManager.SendToUserAsync(
            userId,
            new
            {
                type = "connection.ready",
                payload = new
                {
                    userId,
                    serverTime = DateTime.UtcNow
                }
            },
            context.RequestAborted);

        var buffer = new byte[16 * 1024];

        try
        {
            while (socket.State == WebSocketState.Open && !context.RequestAborted.IsCancellationRequested)
            {
                var result = await socket.ReceiveAsync(new ArraySegment<byte>(buffer), context.RequestAborted);
                if (result.MessageType == WebSocketMessageType.Close)
                {
                    break;
                }

                if (result.MessageType != WebSocketMessageType.Text)
                {
                    continue;
                }

                var message = await ReadMessageAsync(socket, buffer, result, context.RequestAborted);
                if (string.IsNullOrWhiteSpace(message))
                {
                    continue;
                }

                await HandleClientCommandAsync(
                    userId,
                    message,
                    connectionManager,
                    notifier,
                    conversationRepository,
                    logger,
                    context.RequestAborted);
            }
        }
        catch (OperationCanceledException)
        {
        }
        catch (WebSocketException ex)
        {
            logger.LogDebug(ex, "Chat websocket closed for user {UserId}", userId);
        }
        finally
        {
            await connectionManager.UnregisterAsync(userId, socket, CancellationToken.None);
            await notifier.NotifyPresenceAsync(userId, connectionManager.IsUserOnline(userId) ? "online" : "offline", connectionManager.IsUserOnline(userId) ? null : DateTime.UtcNow, CancellationToken.None);
            if (socket.State == WebSocketState.Open || socket.State == WebSocketState.CloseReceived)
            {
                try
                {
                    await socket.CloseAsync(WebSocketCloseStatus.NormalClosure, "closed", CancellationToken.None);
                }
                catch
                {
                }
            }
        }
    }

    private static async Task<string> ReadMessageAsync(WebSocket socket, byte[] buffer, WebSocketReceiveResult initial, CancellationToken cancellationToken)
    {
        var count = initial.Count;
        while (!initial.EndOfMessage)
        {
            if (count >= buffer.Length)
            {
                break;
            }

            initial = await socket.ReceiveAsync(new ArraySegment<byte>(buffer, count, buffer.Length - count), cancellationToken);
            count += initial.Count;
        }

        return Encoding.UTF8.GetString(buffer, 0, count);
    }

    private static async Task HandleClientCommandAsync(
        Guid userId,
        string rawMessage,
        IChatRealtimeConnectionManager connectionManager,
        IChatRealtimeNotifier notifier,
        IChatConversationRepository conversationRepository,
        ILogger logger,
        CancellationToken cancellationToken)
    {
        ClientCommand? command;
        try
        {
            command = JsonSerializer.Deserialize<ClientCommand>(rawMessage, new JsonSerializerOptions(JsonSerializerDefaults.Web));
        }
        catch (JsonException ex)
        {
            logger.LogDebug(ex, "Ignoring invalid chat realtime command from user {UserId}", userId);
            return;
        }

        if (command?.Type == null)
        {
            return;
        }

        switch (command.Type)
        {
            case "ping":
                await notifier.NotifyPresenceAsync(userId, "online", null, cancellationToken);
                break;

            case "presence.update":
                await notifier.NotifyPresenceAsync(userId, string.IsNullOrWhiteSpace(command.Status) ? "online" : command.Status!, null, cancellationToken);
                break;

            case "typing.start":
            case "typing.stop":
                if (!Guid.TryParse(command.ConversationId, out var conversationId))
                {
                    return;
                }

                var hasAccess = await conversationRepository
                    .GetQueryable()
                    .AnyAsync(c => c.Id == conversationId && c.Participants.Any(p => p.Id == userId), cancellationToken);

                if (!hasAccess)
                {
                    return;
                }

                await connectionManager.UpdateTypingAsync(conversationId, userId, command.Type == "typing.start", cancellationToken);
                await notifier.NotifyTypingAsync(conversationId, cancellationToken);
                break;
        }
    }
}
