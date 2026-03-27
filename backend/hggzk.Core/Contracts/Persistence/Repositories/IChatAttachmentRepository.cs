namespace YemenBooking.Core.Interfaces.Repositories
{
    using YemenBooking.Core.Entities;
    using System;
    using System.Threading;
    using System.Threading.Tasks;

    /// <summary>
    /// واجهة مستودع الدردشة المرفق repository.
    /// Chat attachment repository repository interface.
    /// </summary>
    public interface IChatAttachmentRepository : IRepository<ChatAttachment>
    {
        /// <summary>
        /// ينشئ المرفق.
        /// Creates attachment.
        /// </summary>
        Task<ChatAttachment> CreateAttachmentAsync(ChatAttachment attachment, CancellationToken cancellationToken = default);
    }
} 
