using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Net.WebSockets;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace YemenBooking.Api.Infrastructure.ChatRealtime;

/// <summary>
/// In-memory live connection registry for chat websocket sessions.
/// سجل حي داخل الذاكرة لجلسات websocket الخاصة بالدردشة.
/// </summary>
public class ChatRealtimeConnectionManager : IChatRealtimeConnectionManager
{
    private sealed class SocketSession
    {
        public SocketSession(WebSocket socket)
        {
            Socket = socket;
        }

        public WebSocket Socket { get; }
        public SemaphoreSlim SendLock { get; } = new(1, 1);
    }

    private readonly ConcurrentDictionary<Guid, ConcurrentDictionary<string, SocketSession>> _userSockets = new();
    private readonly ConcurrentDictionary<Guid, ConcurrentDictionary<Guid, byte>> _typingByConversation = new();
    private readonly JsonSerializerOptions _serializerOptions = new(JsonSerializerDefaults.Web);
    private readonly ILogger<ChatRealtimeConnectionManager> _logger;

    public ChatRealtimeConnectionManager(ILogger<ChatRealtimeConnectionManager> logger)
    {
        _logger = logger;
    }

    public Task RegisterAsync(Guid userId, WebSocket socket, CancellationToken cancellationToken = default)
    {
        var sessions = _userSockets.GetOrAdd(userId, _ => new ConcurrentDictionary<string, SocketSession>());
        sessions.TryAdd(Guid.NewGuid().ToString("N"), new SocketSession(socket));
        _logger.LogInformation("Registered chat realtime socket for user {UserId}. Active sockets: {Count}", userId, sessions.Count);
        return Task.CompletedTask;
    }

    public Task UnregisterAsync(Guid userId, WebSocket socket, CancellationToken cancellationToken = default)
    {
        if (_userSockets.TryGetValue(userId, out var sessions))
        {
            foreach (var entry in sessions.ToArray())
            {
                if (ReferenceEquals(entry.Value.Socket, socket))
                {
                    sessions.TryRemove(entry.Key, out _);
                }
            }

            if (sessions.IsEmpty)
            {
                _userSockets.TryRemove(userId, out _);
            }
        }

        foreach (var typingEntry in _typingByConversation.ToArray())
        {
            if (typingEntry.Value.TryRemove(userId, out _) && typingEntry.Value.IsEmpty)
            {
                _typingByConversation.TryRemove(typingEntry.Key, out _);
            }
        }

        return Task.CompletedTask;
    }

    public bool IsUserOnline(Guid userId)
        => _userSockets.TryGetValue(userId, out var sessions) && sessions.Any(x => x.Value.Socket.State == WebSocketState.Open);

    public IReadOnlyCollection<Guid> GetTypingUsers(Guid conversationId)
    {
        if (!_typingByConversation.TryGetValue(conversationId, out var users))
        {
            return Array.Empty<Guid>();
        }

        return users.Keys.ToArray();
    }

    public Task UpdateTypingAsync(Guid conversationId, Guid userId, bool isTyping, CancellationToken cancellationToken = default)
    {
        var bucket = _typingByConversation.GetOrAdd(conversationId, _ => new ConcurrentDictionary<Guid, byte>());
        if (isTyping)
        {
            bucket[userId] = 0;
        }
        else
        {
            bucket.TryRemove(userId, out _);
            if (bucket.IsEmpty)
            {
                _typingByConversation.TryRemove(conversationId, out _);
            }
        }

        return Task.CompletedTask;
    }

    public Task SendToUserAsync(Guid userId, object payload, CancellationToken cancellationToken = default)
        => SendToUsersAsync(new[] { userId }, payload, null, cancellationToken);

    public async Task SendToUsersAsync(IEnumerable<Guid> userIds, object payload, Guid? excludeUserId = null, CancellationToken cancellationToken = default)
    {
        var serialized = JsonSerializer.Serialize(payload, _serializerOptions);
        var bytes = Encoding.UTF8.GetBytes(serialized);
        var segment = new ArraySegment<byte>(bytes);

        foreach (var userId in userIds.Distinct())
        {
            if (excludeUserId.HasValue && userId == excludeUserId.Value)
            {
                continue;
            }

            if (!_userSockets.TryGetValue(userId, out var sessions))
            {
                continue;
            }

            foreach (var entry in sessions.ToArray())
            {
                var session = entry.Value;
                if (session.Socket.State != WebSocketState.Open)
                {
                    sessions.TryRemove(entry.Key, out _);
                    continue;
                }

                await session.SendLock.WaitAsync(cancellationToken);
                try
                {
                    if (session.Socket.State == WebSocketState.Open)
                    {
                        await session.Socket.SendAsync(segment, WebSocketMessageType.Text, endOfMessage: true, cancellationToken);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Failed sending realtime chat payload to user {UserId}", userId);
                    sessions.TryRemove(entry.Key, out _);
                }
                finally
                {
                    session.SendLock.Release();
                }
            }

            if (sessions.IsEmpty)
            {
                _userSockets.TryRemove(userId, out _);
            }
        }
    }
}
