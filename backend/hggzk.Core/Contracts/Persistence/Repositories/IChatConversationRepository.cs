namespace YemenBooking.Core.Interfaces.Repositories
{
    using YemenBooking.Core.Entities;
    using System;
    using System.Threading;
    using System.Threading.Tasks;
    using System.Collections.Generic;

    /// <summary>
    /// واجهة مستودع محادثة الدردشة repository.
    /// Chat conversation repository repository interface.
    /// </summary>
    public interface IChatConversationRepository : IRepository<ChatConversation>
    {
        /// <summary>
        /// الحصول على المحادثات المرتبطة بمشارك محدد
        /// Get conversations by participant
        /// </summary>
        Task<(IEnumerable<ChatConversation> Items, int TotalCount)> GetConversationsByParticipantAsync(Guid userId, int page, int pageSize, CancellationToken cancellationToken = default);

        /// <summary>
        /// ينشئ المحادثة.
        /// Creates conversation.
        /// </summary>
        Task<ChatConversation> CreateConversationAsync(ChatConversation conversation, CancellationToken cancellationToken = default);

        /// <summary>
        /// يجلب المباشر المحادثة.
        /// Gets direct conversation.
        /// </summary>
        Task<ChatConversation?> GetDirectConversationAsync(Guid userId1, Guid userId2, CancellationToken cancellationToken = default);

        /// <summary>
        /// يجلب العنصر حسب المعرّف مع details.
        /// Gets the item by id with details.
        /// </summary>
        Task<ChatConversation?> GetByIdWithDetailsAsync(Guid id, CancellationToken cancellationToken = default);

        /// <summary>
        /// يجلب العنصر حسب المعرّف مع المشاركون.
        /// Gets the item by id with participants.
        /// </summary>
        Task<ChatConversation?> GetByIdWithParticipantsAsync(Guid id, CancellationToken cancellationToken = default);

        /// <summary>
        /// يحدّث المحادثة.
        /// Updates conversation.
        /// </summary>
        Task<ChatConversation> UpdateConversationAsync(ChatConversation conversation, CancellationToken cancellationToken = default);

        /// <summary>
        /// يحذف المحادثة.
        /// Deletes conversation.
        /// </summary>
        Task DeleteConversationAsync(ChatConversation conversation, CancellationToken cancellationToken = default);

        /// <summary>
        /// الحصول على المحادثات المرتبطة بعقار محدد (حساب المراسلة الخاص بالعقار)
        /// Get conversations associated with a specific property (property-level messaging account)
        /// </summary>
        Task<(IEnumerable<ChatConversation> Items, int TotalCount)> GetConversationsByPropertyAsync(Guid propertyId, int page, int pageSize, CancellationToken cancellationToken = default);

        /// <summary>
        /// يتحقق مما إذا كان المحادثة between client and العقار موجودًا.
        /// Checks whether conversation between client and property exists.
        /// </summary>
        Task<bool> ExistsConversationBetweenClientAndPropertyAsync(Guid clientUserId, Guid propertyId, CancellationToken cancellationToken = default);
    }
} 
