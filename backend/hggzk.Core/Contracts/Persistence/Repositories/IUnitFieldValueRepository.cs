using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع الوحدة الحقل value repository.
/// Unit field value repository repository interface.
/// </summary>
public interface IUnitFieldValueRepository : IRepository<UnitFieldValue>
{
    /// <summary>
    /// ينشئ الوحدة الحقل value.
    /// Creates unit field value.
    /// </summary>
    Task<UnitFieldValue> CreateUnitFieldValueAsync(UnitFieldValue unitFieldValue, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الوحدة الحقل value حسب المعرّف.
    /// Gets unit field value by id.
    /// </summary>
    Task<UnitFieldValue?> GetUnitFieldValueByIdAsync(Guid valueId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث الوحدة الحقل value.
    /// Updates unit field value.
    /// </summary>
    Task<UnitFieldValue> UpdateUnitFieldValueAsync(UnitFieldValue unitFieldValue, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحذف الوحدة الحقل value.
    /// Deletes unit field value.
    /// </summary>
    Task<bool> DeleteUnitFieldValueAsync(Guid valueId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب values حسب الوحدة المعرّف.
    /// Gets values by unit id.
    /// </summary>
    Task<IEnumerable<UnitFieldValue>> GetValuesByUnitIdAsync(Guid unitId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب العنصر حسب الحقل المعرّف.
    /// Gets the item by field id.
    /// </summary>
    Task<IEnumerable<UnitFieldValue>> GetByFieldIdAsync(Guid fieldId, CancellationToken cancellationToken = default);
}
