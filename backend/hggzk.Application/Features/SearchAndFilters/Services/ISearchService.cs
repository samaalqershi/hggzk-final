using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.SearchAndFilters.Services;

/// <summary>
/// عقد بحث مبسط مخصص للبحث في العقارات داخل الطبقة الحالية.
/// A slim search contract focused on property search within the current layer.
/// </summary>
public interface ISearchService
{
    /// <summary>
    /// يبحث عن العقارات باستخدام نص ومعايير اختيارية مثل التوفر والموقع.
    /// Searches properties using a text term and optional availability or location filters.
    /// </summary>
    Task<IEnumerable<Property>> SearchPropertiesAsync(
        string searchTerm,
        DateTime? checkIn = null,
        DateTime? checkOut = null,
        int? guestCount = null,
        Guid? propertyTypeId = null,
        decimal? minPrice = null,
        decimal? maxPrice = null,
        string? city = null,
        double? latitude = null,
        double? longitude = null,
        double? radiusKm = null,
        CancellationToken cancellationToken = default);
}
