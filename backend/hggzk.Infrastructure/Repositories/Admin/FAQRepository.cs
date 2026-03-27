using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Admin
{
/// <summary>
/// يمثل مستودعًا للوصول إلى الأسئلة الشائعة.
/// Represents a repository for accessing FAQ entries.
/// </summary>
    public class FAQRepository : BaseRepository<FAQ>, IFAQRepository
    {
/// <summary>
/// ينشئ المستودع مع سياق قاعدة البيانات المشترك.
/// Creates the repository with the shared database context.
/// </summary>
        public FAQRepository(YemenBookingDbContext context) : base(context) { }

/// <summary>
/// يسترجع العناصر النشطة.
/// Retrieves the active items.
/// </summary>
        public async Task<IEnumerable<FAQ>> GetActiveFAQsAsync(
            string language = "ar",
            string? category = null,
            CancellationToken cancellationToken = default)
        {
            var normalizedLanguage = string.IsNullOrWhiteSpace(language)
                ? "ar"
                : language.Trim().ToLowerInvariant();

            var query = _dbSet
                .AsNoTracking()
                .Where(faq => faq.IsActive && faq.Language == normalizedLanguage);

            if (!string.IsNullOrWhiteSpace(category))
            {
                var normalizedCategory = category.Trim();
                query = query.Where(faq => faq.Category == normalizedCategory);
            }

            return await query
                .OrderBy(faq => faq.DisplayOrder)
                .ThenBy(faq => faq.Question)
                .ToListAsync(cancellationToken);
        }
    }
}
