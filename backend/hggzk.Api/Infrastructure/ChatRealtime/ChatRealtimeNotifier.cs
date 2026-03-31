using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Settings;

namespace YemenBooking.Api.Infrastructure.ChatRealtime;

/// <summary>
/// Resolves chat participants and broadcasts normalized realtime events.
/// يستخرج المشاركين في الدردشة ويبث أحداثًا لحظية موحدة.
/// </summary>
public class ChatRealtimeNotifier : IChatRealtimeNotifier
{
    private readonly IChatConversationRepository _conversationRepository;
    private readonly IChatRealtimeConnectionManager _connectionManager;
    private readonly ChatMessagingSettings _chatMessagingSettings;

    public ChatRealtimeNotifier(
        IChatConversationRepository conversationRepository,
        IChatRealtimeConnectionManager connectionManager,
        IOptions<ChatMessagingSettings> chatMessagingSettings)
    {
        _conversationRepository = conversationRepository;
        _connectionManager = connectionManager;
        _chatMessagingSettings = chatMessagingSettings.Value;
    }

    public async Task NotifyConversationUpdatedAsync(Guid conversationId, string reason, Guid? triggeredByUserId = null, CancellationToken cancellationToken = default)
    {
        if (!_chatMessagingSettings.IsWebSocketEnabled)
        {
            return;
        }

        await PublishToConversationAsync(
            conversationId,
            new
            {
                type = "conversation.updated",
                payload = new
                {
                    conversationId,
                    reason
                }
            },
            triggeredByUserId,
            cancellationToken);
    }

    public async Task NotifyMessageCreatedAsync(Guid conversationId, YemenBooking.Application.Features.Chat.DTOs.ChatMessageDto message, Guid? triggeredByUserId = null, CancellationToken cancellationToken = default)
    {
        if (!_chatMessagingSettings.IsWebSocketEnabled)
        {
            return;
        }

        await PublishToConversationAsync(
            conversationId,
            new
            {
                type = "message.new",
                payload = new
                {
                    conversationId,
                    message
                }
            },
            triggeredByUserId,
            cancellationToken);
    }

    public async Task NotifyMessageUpdatedAsync(Guid conversationId, YemenBooking.Application.Features.Chat.DTOs.ChatMessageDto message, Guid? triggeredByUserId = null, CancellationToken cancellationToken = default)
    {
        if (!_chatMessagingSettings.IsWebSocketEnabled)
        {
            return;
        }

        await PublishToConversationAsync(
            conversationId,
            new
            {
                type = "message.updated",
                payload = new
                {
                    conversationId,
                    message
                }
            },
            triggeredByUserId,
            cancellationToken);
    }

    public async Task NotifyMessageDeletedAsync(Guid conversationId, Guid messageId, Guid? triggeredByUserId = null, CancellationToken cancellationToken = default)
    {
        if (!_chatMessagingSettings.IsWebSocketEnabled)
        {
            return;
        }

        await PublishToConversationAsync(
            conversationId,
            new
            {
                type = "message.deleted",
                payload = new
                {
                    conversationId,
                    messageId
                }
            },
            triggeredByUserId,
            cancellationToken);
    }

    public async Task NotifyMessageStatusAsync(Guid conversationId, Guid messageId, string status, DateTime? deliveredAt, DateTime? readAt, Guid? triggeredByUserId = null, CancellationToken cancellationToken = default)
    {
        if (!_chatMessagingSettings.IsWebSocketEnabled)
        {
            return;
        }

        await PublishToConversationAsync(
            conversationId,
            new
            {
                type = "message.status",
                payload = new
                {
                    conversationId,
                    messageId,
                    status,
                    deliveredAt,
                    readAt
                }
            },
            triggeredByUserId,
            cancellationToken);
    }

    public async Task NotifyReactionAddedAsync(Guid conversationId, Guid messageId, object reaction, Guid? triggeredByUserId = null, CancellationToken cancellationToken = default)
    {
        if (!_chatMessagingSettings.IsWebSocketEnabled)
        {
            return;
        }

        await PublishToConversationAsync(
            conversationId,
            new
            {
                type = "message.reaction_added",
                payload = new
                {
                    conversationId,
                    messageId,
                    reaction
                }
            },
            triggeredByUserId,
            cancellationToken);
    }

    public async Task NotifyReactionRemovedAsync(Guid conversationId, Guid messageId, Guid userId, string reactionType, Guid? triggeredByUserId = null, CancellationToken cancellationToken = default)
    {
        if (!_chatMessagingSettings.IsWebSocketEnabled)
        {
            return;
        }

        await PublishToConversationAsync(
            conversationId,
            new
            {
                type = "message.reaction_removed",
                payload = new
                {
                    conversationId,
                    messageId,
                    reaction = new
                    {
                        id = Guid.Empty,
                        messageId,
                        userId,
                        reactionType
                    }
                }
            },
            triggeredByUserId,
            cancellationToken);
    }

    public async Task NotifyTypingAsync(Guid conversationId, CancellationToken cancellationToken = default)
    {
        if (!_chatMessagingSettings.IsWebSocketEnabled)
        {
            return;
        }

        var typingUsers = _connectionManager.GetTypingUsers(conversationId).Select(x => x.ToString()).ToArray();
        await PublishToConversationAsync(
            conversationId,
            new
            {
                type = "typing.updated",
                payload = new
                {
                    conversationId,
                    typingUserIds = typingUsers
                }
            },
            null,
            cancellationToken);
    }

    public async Task NotifyPresenceAsync(Guid userId, string status, DateTime? lastSeen, CancellationToken cancellationToken = default)
    {
        if (!_chatMessagingSettings.IsWebSocketEnabled)
        {
            return;
        }

        var targetUserIds = await _conversationRepository
            .GetQueryable()
            .AsNoTracking()
            .Where(c => c.Participants.Any(p => p.Id == userId))
            .SelectMany(c => c.Participants.Select(p => p.Id))
            .Distinct()
            .ToListAsync(cancellationToken);

        if (!targetUserIds.Contains(userId))
        {
            targetUserIds.Add(userId);
        }

        await _connectionManager.SendToUsersAsync(
            targetUserIds,
            new
            {
                type = "presence.updated",
                payload = new
                {
                    userId,
                    status,
                    lastSeen
                }
            },
            null,
            cancellationToken);
    }

    private async Task PublishToConversationAsync(Guid conversationId, object payload, Guid? triggeredByUserId, CancellationToken cancellationToken)
    {
        var participantIds = await _conversationRepository
            .GetQueryable()
            .AsNoTracking()
            .Where(c => c.Id == conversationId)
            .SelectMany(c => c.Participants.Select(p => p.Id))
            .Distinct()
            .ToListAsync(cancellationToken);

        if (participantIds.Count == 0)
        {
            return;
        }

        await _connectionManager.SendToUsersAsync(
            participantIds,
            payload,
            triggeredByUserId,
            cancellationToken);
    }
}
