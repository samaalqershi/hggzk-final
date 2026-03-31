using System;
using System.Collections.Generic;
using System.Net.WebSockets;
using System.Threading;
using System.Threading.Tasks;

namespace YemenBooking.Api.Infrastructure.ChatRealtime;

/// <summary>
/// Tracks live chat WebSocket connections and delivers payloads to users.
/// يتتبع اتصالات WebSocket الحية للدردشة ويرسل الحمولة للمستخدمين.
/// </summary>
public interface IChatRealtimeConnectionManager
{
    Task RegisterAsync(Guid userId, WebSocket socket, CancellationToken cancellationToken = default);
    Task UnregisterAsync(Guid userId, WebSocket socket, CancellationToken cancellationToken = default);
    bool IsUserOnline(Guid userId);
    IReadOnlyCollection<Guid> GetTypingUsers(Guid conversationId);
    Task UpdateTypingAsync(Guid conversationId, Guid userId, bool isTyping, CancellationToken cancellationToken = default);
    Task SendToUserAsync(Guid userId, object payload, CancellationToken cancellationToken = default);
    Task SendToUsersAsync(IEnumerable<Guid> userIds, object payload, Guid? excludeUserId = null, CancellationToken cancellationToken = default);
}
