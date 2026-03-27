using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features.Properties.Queries.SearchAdvancedProperty;

namespace YemenBooking.Application.Contracts.Persistence.Repositories.Search;

/// <summary>
/// واجهة مستودع البحث المتقدم عن العقارات.
/// Defines the contract for advanced property search queries.
/// </summary>
public interface IAdvancedPropertySearchRepository
{
    /// <summary>
    /// ينفذ بحثا متقدما عن العقارات اعتمادا على معايير الاستعلام المحددة.
    /// Executes an advanced property search using the supplied query criteria.
    /// </summary>
    Task<IEnumerable<AdvancedPropertyDto>> SearchAsync(
        AdvancedPropertySearchQuery query,
        CancellationToken cancellationToken = default);
}
