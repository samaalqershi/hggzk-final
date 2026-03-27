using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع نوع الوحدة repository.
/// Unit type repository repository interface.
/// </summary>
public interface IUnitTypeRepository : IRepository<UnitType>
{
    /// <summary>
    /// ينشئ نوع الوحدة.
    /// Creates unit type.
    /// </summary>
    Task<UnitType> CreateUnitTypeAsync(UnitType unitType, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب نوع الوحدة حسب المعرّف.
    /// Gets unit type by id.
    /// </summary>
    Task<UnitType?> GetUnitTypeByIdAsync(Guid unitTypeId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب أنواع الوحدات حسب نوع العقار.
    /// Gets unit types by property type.
    /// </summary>
    Task<IEnumerable<UnitType>> GetUnitTypesByPropertyTypeAsync(Guid propertyTypeId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب جميع أنواع الوحدات.
    /// Gets all unit types.
    /// </summary>
    Task<IEnumerable<UnitType>> GetAllUnitTypesAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث نوع الوحدة.
    /// Updates unit type.
    /// </summary>
    Task<UnitType> UpdateUnitTypeAsync(UnitType unitType, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحذف نوع الوحدة.
    /// Deletes unit type.
    /// </summary>
    Task<bool> DeleteUnitTypeAsync(Guid unitTypeId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب نوع العقار حسب المعرّف.
    /// Gets property type by id.
    /// </summary>
    Task<PropertyType?> GetPropertyTypeByIdAsync(Guid propertyTypeId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب العنصر حسب نوع العقار المعرّف.
    /// Gets the item by property type id.
    /// </summary>
    Task<IEnumerable<UnitType>> GetByPropertyTypeIdAsync(Guid propertyTypeId, CancellationToken cancellationToken = default);

}
