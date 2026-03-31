using System;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Application.Features.Chat.DTOs;

namespace YemenBooking.Application.Common.Interfaces;

/// <summary>
/// Publishes realtime chat events to connected participants.
/// ينشر أحداث الدردشة اللحظية للمشاركين المتصلين.
/// </summary>
public interface IChatRealtimeNotifier
{
    Task NotifyConversationUpdatedAsync(Guid conversationId, string reason, Guid? triggeredByUserId = null, CancellationToken cancellationToken = default);
    Task NotifyMessageCreatedAsync(Guid conversationId, ChatMessageDto message, Guid? triggeredByUserId = null, CancellationToken cancellationToken = default);
    Task NotifyMessageUpdatedAsync(Guid conversationId, ChatMessageDto message, Guid? triggeredByUserId = null, CancellationToken cancellationToken = default);
    Task NotifyMessageDeletedAsync(Guid conversationId, Guid messageId, Guid? triggeredByUserId = null, CancellationToken cancellationToken = default);
    Task NotifyMessageStatusAsync(Guid conversationId, Guid messageId, string status, DateTime? deliveredAt, DateTime? readAt, Guid? triggeredByUserId = null, CancellationToken cancellationToken = default);
    Task NotifyReactionAddedAsync(Guid conversationId, Guid messageId, object reaction, Guid? triggeredByUserId = null, CancellationToken cancellationToken = default);
    Task NotifyReactionRemovedAsync(Guid conversationId, Guid messageId, Guid userId, string reactionType, Guid? triggeredByUserId = null, CancellationToken cancellationToken = default);
    Task NotifyTypingAsync(Guid conversationId, CancellationToken cancellationToken = default);
    Task NotifyPresenceAsync(Guid userId, string status, DateTime? lastSeen, CancellationToken cancellationToken = default);
}
