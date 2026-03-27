namespace YemenBooking.Core.Interfaces.Repositories
{
    using YemenBooking.Core.Entities;
    using System;
    using System.Threading;
    using System.Threading.Tasks;
    using System.Collections.Generic;

    /// <summary>
    /// واجهة مستودع رسالة الدردشة repository.
    /// Chat message repository repository interface.
    /// </summary>
    public interface IChatMessageRepository : IRepository<ChatMessage>
    {
    /// <summary>
    /// يحدّث الرسالة.
    /// Updates message.
    /// </summary>
    Task<ChatMessage> UpdateMessageAsync(ChatMessage message, CancellationToken cancellationToken = default);

        /// <summary>
        /// يحذف الرسالة.
        /// Deletes message.
        /// </summary>
        Task DeleteMessageAsync(ChatMessage message, CancellationToken cancellationToken = default);

        /// <summary>
        /// الحصول على الرسائل في محادثة معينة
        /// Get messages by conversation
        /// </summary>
        Task<(IEnumerable<ChatMessage> Items, int TotalCount)> GetMessagesByConversationAsync(Guid conversationId, int page, int pageSize, string? beforeMessageId = null, CancellationToken cancellationToken = default);
    }
} 
