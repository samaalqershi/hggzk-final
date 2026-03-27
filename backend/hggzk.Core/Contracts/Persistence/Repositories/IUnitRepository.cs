using System.Linq.Expressions;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع الوحدة repository.
/// Unit repository repository interface.
/// </summary>
public interface IUnitRepository : IRepository<Unit>
{
    /// <summary>
    /// ينشئ الوحدة.
    /// Creates unit.
    /// </summary>
    Task<Unit> CreateUnitAsync(Unit unit, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الوحدة حسب المعرّف.
    /// Gets unit by id.
    /// </summary>
    Task<Unit?> GetUnitByIdAsync(Guid unitId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث الوحدة.
    /// Updates unit.
    /// </summary>
    Task<Unit> UpdateUnitAsync(Unit unit, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحذف الوحدة.
    /// Deletes unit.
    /// </summary>
    Task<bool> DeleteUnitAsync(Guid unitId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الوحدات حسب العقار.
    /// Gets units by property.
    /// </summary>
    Task<IEnumerable<Unit>> GetUnitsByPropertyAsync(Guid propertyId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب النشط حسب العقار المعرّف.
    /// Gets active by property id.
    /// </summary>
    Task<IEnumerable<Unit>> GetActiveByPropertyIdAsync(Guid propertyId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب العقار حسب المعرّف.
    /// Gets property by id.
    /// </summary>
    Task<Property?> GetPropertyByIdAsync(Guid propertyId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب نوع الوحدة حسب المعرّف.
    /// Gets unit type by id.
    /// </summary>
    Task<UnitType?> GetUnitTypeByIdAsync(Guid unitTypeId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يتحقق من النشط الحجوزات.
    /// Checks active bookings.
    /// </summary>
    Task<bool> CheckActiveBookingsAsync(Guid unitId, CancellationToken cancellationToken = default);

    /// <summary>
    /// ينفذ has any الحجوزات.
    /// Performs has any bookings.
    /// </summary>
    Task<bool> HasAnyBookingsAsync(Guid unitId, CancellationToken cancellationToken = default);

    /// <summary>
    /// ينفذ has any المدفوعات.
    /// Performs has any payments.
    /// </summary>
    Task<bool> HasAnyPaymentsAsync(Guid unitId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب العنصر حسب المعرّف مع includes.
    /// Gets the item by id with includes.
    /// </summary>
    Task<Unit> GetByIdWithIncludesAsync(Guid id, params Expression<Func<Unit, object>>[] includes);
}
