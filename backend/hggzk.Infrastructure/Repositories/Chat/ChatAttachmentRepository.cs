using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Chat
{
/// <summary>
/// يمثل مستودعًا للوصول إلى مرفقات الدردشة.
/// Represents a repository for accessing chat attachments.
/// </summary>
    public class ChatAttachmentRepository : BaseRepository<ChatAttachment>, IChatAttachmentRepository
    {
/// <summary>
/// ينشئ المستودع مع سياق قاعدة البيانات المشترك.
/// Creates the repository with the shared database context.
/// </summary>
        public ChatAttachmentRepository(YemenBookingDbContext context) : base(context) { }

/// <summary>
/// ينشئ سجلًا جديدًا في المستودع.
/// Creates a new record in the repository.
/// </summary>
        public async Task<ChatAttachment> CreateAttachmentAsync(ChatAttachment attachment, CancellationToken cancellationToken = default)
        {
            await _dbSet.AddAsync(attachment, cancellationToken);
            return attachment;
        }
    }
} 
