using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Admin
{
/// <summary>
/// يمثل مستودعًا للوصول إلى المستندات القانونية.
/// Represents a repository for accessing legal documents.
/// </summary>
    public class LegalDocumentRepository : BaseRepository<LegalDocument>, ILegalDocumentRepository
    {
/// <summary>
/// ينشئ المستودع مع سياق قاعدة البيانات المشترك.
/// Creates the repository with the shared database context.
/// </summary>
        public LegalDocumentRepository(YemenBookingDbContext context) : base(context) { }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<LegalDocument?> GetByTypeAndLanguageAsync(
            LegalDocumentType type,
            string language,
            CancellationToken cancellationToken = default)
            => await _dbSet
                .AsNoTracking()
                .Where(document => document.Type == type
                    && document.Language == language
                    && document.IsActive)
                .OrderByDescending(document => document.EffectiveDate)
                .ThenByDescending(document => document.UpdatedAt ?? document.CreatedAt)
                .FirstOrDefaultAsync(cancellationToken);
    }
}
