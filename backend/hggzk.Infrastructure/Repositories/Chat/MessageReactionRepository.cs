using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Chat
{
/// <summary>
/// يمثل مستودعًا للوصول إلى تفاعلات الرسائل.
/// Represents a repository for accessing message reactions.
/// </summary>
    public class MessageReactionRepository : BaseRepository<MessageReaction>, IMessageReactionRepository
    {
/// <summary>
/// ينشئ المستودع مع سياق قاعدة البيانات المشترك.
/// Creates the repository with the shared database context.
/// </summary>
        public MessageReactionRepository(YemenBookingDbContext context) : base(context) { }

/// <summary>
/// يضيف السجل المطلوب إلى المستودع.
/// Adds the requested record to the repository.
/// </summary>
        public async Task<MessageReaction> AddReactionAsync(MessageReaction reaction, CancellationToken cancellationToken = default)
        {
            await _dbSet.AddAsync(reaction, cancellationToken);
            return reaction;
        }

/// <summary>
/// يحدّث السجل المطلوب في المستودع.
/// Updates the requested record in the repository.
/// </summary>
        public Task<MessageReaction> UpdateReactionAsync(MessageReaction reaction, CancellationToken cancellationToken = default)
        {
            return Task.FromResult(TrackForUpdate(_dbSet, reaction));
        }

/// <summary>
/// يحذف السجل المطلوب من المستودع.
/// Deletes the requested record from the repository.
/// </summary>
        public Task DeleteReactionAsync(MessageReaction reaction, CancellationToken cancellationToken = default)
        {
            _dbSet.Remove(reaction);
            return Task.CompletedTask;
        }
    }
} 
