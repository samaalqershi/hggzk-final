using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// Repository contract for property nearby places.
/// عقد مستودع الأماكن القريبة للعقار.
/// </summary>
public interface IPropertyNearbyPlaceRepository : IRepository<PropertyNearbyPlace>
{
    Task<PropertyNearbyPlace> CreateAsync(PropertyNearbyPlace nearbyPlace, CancellationToken cancellationToken = default);
    Task<PropertyNearbyPlace?> GetByIdAsync(Guid nearbyPlaceId, CancellationToken cancellationToken = default);
    Task<IEnumerable<PropertyNearbyPlace>> GetByPropertyIdAsync(Guid propertyId, CancellationToken cancellationToken = default);
    Task<IEnumerable<PropertyNearbyPlace>> SearchAsync(Guid? propertyId, string? searchTerm, bool? isActive, CancellationToken cancellationToken = default);
    Task<PropertyNearbyPlace> UpdateAsync(PropertyNearbyPlace nearbyPlace, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(Guid nearbyPlaceId, CancellationToken cancellationToken = default);
}
