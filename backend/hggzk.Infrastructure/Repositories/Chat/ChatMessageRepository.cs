using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Chat
{
/// <summary>
/// يمثل مستودعًا للوصول إلى رسائل الدردشة.
/// Represents a repository for accessing chat messages.
/// </summary>
    public class ChatMessageRepository : BaseRepository<ChatMessage>, IChatMessageRepository
    {
/// <summary>
/// ينشئ المستودع مع سياق قاعدة البيانات المشترك.
/// Creates the repository with the shared database context.
/// </summary>
        public ChatMessageRepository(YemenBookingDbContext context) : base(context) { }

/// <summary>
/// يحدّث السجل المطلوب في المستودع.
/// Updates the requested record in the repository.
/// </summary>
        public Task<ChatMessage> UpdateMessageAsync(ChatMessage message, CancellationToken cancellationToken = default)
        {
            return Task.FromResult(TrackForUpdate(_dbSet, message));
        }

/// <summary>
/// يحذف السجل المطلوب من المستودع.
/// Deletes the requested record from the repository.
/// </summary>
        public Task DeleteMessageAsync(ChatMessage message, CancellationToken cancellationToken = default)
        {
            _dbSet.Remove(message);
            return Task.CompletedTask;
        }

        /// <summary>
        /// يسترجع رسائل المحادثة المطلوبة مع الترقيم ودعم التصفية السابقة.
        /// Retrieves messages for the requested conversation with paging and backward filtering support.
        /// </summary>
        public async Task<(IEnumerable<ChatMessage> Items, int TotalCount)> GetMessagesByConversationAsync(Guid conversationId, int page, int pageSize, string? beforeMessageId = null, CancellationToken cancellationToken = default)
        {
            var query = _context.Set<ChatMessage>()
                .Include(m => m.Reactions)
                .Include(m => m.Attachments)
                .Where(m => m.ConversationId == conversationId);

            if (!string.IsNullOrEmpty(beforeMessageId) && Guid.TryParse(beforeMessageId, out var beforeId))
            {
                var beforeMsg = await GetByIdAsync(beforeId, cancellationToken);
                if (beforeMsg != null)
                {
                    query = query.Where(m => m.CreatedAt < beforeMsg.CreatedAt);
                }
            }

            var total = await query.CountAsync(cancellationToken);
            var items = await query
                .OrderByDescending(m => m.CreatedAt)
                .ThenByDescending(m => m.Id)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync(cancellationToken);

            return (items, total);
        }
    }
} 
