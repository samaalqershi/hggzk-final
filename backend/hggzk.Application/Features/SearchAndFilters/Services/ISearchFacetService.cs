using YemenBooking.Application.Features.SearchAndFilters.DTOs;
using YemenBooking.Core.Indexing.Models;

namespace YemenBooking.Application.Features.SearchAndFilters.Services;

/// <summary>
/// Builds live search facets for the current search criteria.
/// ينشئ الفلاتر والعدادات الحية وفق معايير البحث الحالية.
/// </summary>
public interface ISearchFacetService
{
    /// <summary>
    /// Returns live facets for the supplied request.
    /// يعيد الفلاتر الحية للطلب المرسل.
    /// </summary>
    Task<SearchFiltersDto> BuildFacetsAsync(
        PropertyWithUnitsSearchRequest request,
        CancellationToken cancellationToken = default);
}
