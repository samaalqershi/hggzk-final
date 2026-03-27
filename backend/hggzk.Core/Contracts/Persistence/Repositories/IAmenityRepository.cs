using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع الميزة repository.
/// Amenity repository repository interface.
/// </summary>
public interface IAmenityRepository : IRepository<Amenity>
{
    /// <summary>
    /// ينشئ الميزة.
    /// Creates amenity.
    /// </summary>
    Task<Amenity> CreateAmenityAsync(Amenity amenity, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الميزة حسب المعرّف.
    /// Gets amenity by id.
    /// </summary>
    Task<Amenity?> GetAmenityByIdAsync(Guid amenityId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث الميزة.
    /// Updates amenity.
    /// </summary>
    Task<Amenity> UpdateAmenityAsync(Amenity amenity, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحذف الميزة.
    /// Deletes amenity.
    /// </summary>
    Task<bool> DeleteAmenityAsync(Guid amenityId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب جميع المزايا.
    /// Gets all amenities.
    /// </summary>
    Task<IEnumerable<Amenity>> GetAllAmenitiesAsync(CancellationToken cancellationToken = default);

        /// <summary>
        /// يجلب نوع العقار حسب المعرّف.
        /// Gets property type by id.
        /// </summary>
    Task<PropertyType?> GetPropertyTypeByIdAsync(Guid propertyTypeId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يربط الميزة إلى نوع العقار.
    /// Assigns amenity to property type.
    /// </summary>
    Task<PropertyTypeAmenity> AssignAmenityToPropertyTypeAsync(
        Guid propertyTypeId, 
        Guid amenityId, 
        bool isDefault = false, 
        CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب المزايا حسب نوع العقار.
    /// Gets amenities by property type.
    /// </summary>
    Task<IEnumerable<PropertyTypeAmenity>> GetAmenitiesByPropertyTypeAsync(Guid propertyTypeId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب المزايا حسب العقار.
    /// Gets amenities by property.
    /// </summary>
    Task<IEnumerable<PropertyAmenity>> GetAmenitiesByPropertyAsync(Guid propertyId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب جميع مزايا العقار.
    /// Gets all property amenities.
    /// </summary>
    Task<IEnumerable<PropertyAmenity>> GetAllPropertyAmenitiesAsync(CancellationToken cancellationToken = default);
}
