using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Admin
{
/// <summary>
/// يمثل مستودعًا للوصول إلى إصدارات التطبيق.
/// Represents a repository for accessing application versions.
/// </summary>
    public class AppVersionRepository : BaseRepository<AppVersion>, IAppVersionRepository
    {
/// <summary>
/// ينشئ المستودع مع سياق قاعدة البيانات المشترك.
/// Creates the repository with the shared database context.
/// </summary>
        public AppVersionRepository(YemenBookingDbContext context) : base(context) { }

/// <summary>
/// يسترجع أحدث قيمة متاحة.
/// Retrieves the latest available value.
/// </summary>
        public async Task<AppVersion?> GetLatestVersionAsync(string platform)
            => await _dbSet
                .AsNoTracking()
                .Where(version => version.Platform == platform && version.IsActive)
                .OrderByDescending(version => version.ReleaseDate)
                .FirstOrDefaultAsync();
    }
}
