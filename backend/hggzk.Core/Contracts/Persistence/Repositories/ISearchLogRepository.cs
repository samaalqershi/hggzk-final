using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories
{
    /// <summary>
    /// واجهة مستودع سجل البحث repository.
    /// Search log repository repository interface.
    /// </summary>
    public interface ISearchLogRepository
    {
        /// <summary>
        /// يعيد مصدر استعلام قابلًا للتجميع.
        /// Returns a queryable source.
        /// </summary>
        IQueryable<SearchLog> GetQueryable();
        /// <summary>
        /// يضيف .
        /// Adds .
        /// </summary>
        Task AddAsync(SearchLog log, CancellationToken cancellationToken = default);

        /// <summary>
        /// يحفظ التغييرات المعلقة.
        /// Saves pending changes.
        /// </summary>
        Task SaveChangesAsync(CancellationToken cancellationToken = default);
    }
} 
