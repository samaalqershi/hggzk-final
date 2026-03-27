using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Search;

/// <summary>
/// Provides persistence operations for search filters.
/// يوفّر عمليات الحفظ الخاصة بفلاتر البحث.
/// </summary>
public class SearchFilterRepository : BaseRepository<YemenBooking.Core.Entities.SearchFilter>, ISearchFilterRepository
{
    /// <summary>
    /// يهيئ مثيلاً جديدًا من SearchFilterRepository باستخدام سياق قاعدة البيانات المشترك.
    /// Initializes a new instance of SearchFilterRepository with the shared database context.
    /// </summary>
    public SearchFilterRepository(YemenBookingDbContext context) : base(context)
    {
    }
}
