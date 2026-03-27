using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Search
{
    /// <summary>
    /// Provides persistence operations for search logs.
    /// يوفّر عمليات الحفظ الخاصة بسجلات البحث.
    /// </summary>
    public class SearchLogRepository : ISearchLogRepository
    {
        private readonly YemenBookingDbContext _context;

        /// <summary>
        /// يهيئ مثيلاً جديدًا من SearchLogRepository باستخدام سياق قاعدة البيانات المشترك.
        /// Initializes a new instance of SearchLogRepository with the shared database context.
        /// </summary>
        public SearchLogRepository(YemenBookingDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Returns a queryable set for search logs.
        /// يعيد مجموعة قابلة للاستعلام لسجلات البحث.
        /// </summary>
        public IQueryable<SearchLog> GetQueryable()
        {
            return _context.SearchLogs.AsNoTracking();
        }

        /// <summary>
        /// Adds a new search log and stages it for persistence.
        /// يضيف سجل بحث جديدًا ويجهزه للحفظ.
        /// </summary>
        public async Task AddAsync(SearchLog log, CancellationToken cancellationToken = default)
        {
            await _context.SearchLogs.AddAsync(log, cancellationToken);
        }

        /// <summary>
        /// Persists the pending changes to the database.
        /// يحفظ التغييرات المعلّقة في قاعدة البيانات.
        /// </summary>
        public async Task SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            await _context.SaveChangesAsync(cancellationToken);
        }
    }
} 
