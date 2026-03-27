namespace YemenBooking.Core.Interfaces.Repositories
{
    using YemenBooking.Core.Entities;
    using System.Threading;
    using System.Threading.Tasks;

    /// <summary>
    /// واجهة مستودع الرسالة التفاعل repository.
    /// Message reaction repository repository interface.
    /// </summary>
    public interface IMessageReactionRepository : IRepository<MessageReaction>
    {
        /// <summary>
        /// يضيف التفاعل.
        /// Adds reaction.
        /// </summary>
        Task<MessageReaction> AddReactionAsync(MessageReaction reaction, CancellationToken cancellationToken = default);

        /// <summary>
        /// يحدّث التفاعل.
        /// Updates reaction.
        /// </summary>
        Task<MessageReaction> UpdateReactionAsync(MessageReaction reaction, CancellationToken cancellationToken = default);

        /// <summary>
        /// يحذف التفاعل.
        /// Deletes reaction.
        /// </summary>
        Task DeleteReactionAsync(MessageReaction reaction, CancellationToken cancellationToken = default);
    }
}
