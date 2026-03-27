using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع نوع العقار repository.
/// Property type repository repository interface.
/// </summary>
public interface IPropertyTypeRepository : IRepository<PropertyType>
{
    /// <summary>
    /// ينشئ نوع العقار.
    /// Creates property type.
    /// </summary>
    Task<PropertyType> CreatePropertyTypeAsync(PropertyType propertyType, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب نوع العقار حسب المعرّف.
    /// Gets property type by id.
    /// </summary>
    Task<PropertyType?> GetPropertyTypeByIdAsync(Guid propertyTypeId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب جميع أنواع العقارات.
    /// Gets all property types.
    /// </summary>
    Task<IEnumerable<PropertyType>> GetAllPropertyTypesAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب نوع العقار مع المزايا.
    /// Gets property type with amenities.
    /// </summary>
    Task<PropertyType?> GetPropertyTypeWithAmenitiesAsync(Guid propertyTypeId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث نوع العقار.
    /// Updates property type.
    /// </summary>
    Task<PropertyType> UpdatePropertyTypeAsync(PropertyType propertyType, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحذف نوع العقار.
    /// Deletes property type.
    /// </summary>
    Task<bool> DeletePropertyTypeAsync(Guid propertyTypeId, CancellationToken cancellationToken = default);
}
