using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع نوع العقار الميزة repository.
/// Property type amenity repository repository interface.
/// </summary>
public interface IPropertyTypeAmenityRepository : IRepository<PropertyTypeAmenity>
{
    /// <summary>
    /// ينشئ نوع العقار الميزة.
    /// Creates property type amenity.
    /// </summary>
    Task<PropertyTypeAmenity> CreatePropertyTypeAmenityAsync(PropertyTypeAmenity propertyTypeAmenity, CancellationToken cancellationToken = default);
}
