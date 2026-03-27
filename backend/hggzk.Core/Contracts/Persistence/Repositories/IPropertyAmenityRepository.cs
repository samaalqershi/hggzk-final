using YemenBooking.Core.Entities;
using System.Collections.Generic;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع ميزة العقار repository.
/// Property amenity repository repository interface.
/// </summary>
public interface IPropertyAmenityRepository : IRepository<PropertyAmenity>
{
    /// <summary>
    /// يضيف الميزة إلى العقار.
    /// Adds amenity to property.
    /// </summary>
    Task<PropertyAmenity> AddAmenityToPropertyAsync(PropertyAmenity propertyAmenity, CancellationToken cancellationToken = default);

    /// <summary>
    /// يزيل الميزة من العقار.
    /// Removes amenity from property.
    /// </summary>
    Task<bool> RemoveAmenityFromPropertyAsync(Guid propertyId, Guid ptaId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يزيل المزايا من العقار.
    /// Removes amenities from property.
    /// </summary>
    Task<int> RemoveAmenitiesFromPropertyAsync(Guid propertyId, IEnumerable<Guid> ptaIds, CancellationToken cancellationToken = default);
}
