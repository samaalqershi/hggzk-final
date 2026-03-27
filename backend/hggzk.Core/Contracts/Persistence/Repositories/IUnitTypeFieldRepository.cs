using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع نوع الوحدة الحقل repository.
/// Unit type field repository repository interface.
/// </summary>
public interface IUnitTypeFieldRepository : IRepository<UnitTypeField>
{
    /// <summary>
    /// ينشئ نوع الوحدة الحقل.
    /// Creates unit type field.
    /// </summary>
    Task<UnitTypeField> CreateUnitTypeFieldAsync(UnitTypeField unitTypeField, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب نوع الوحدة الحقل حسب المعرّف.
    /// Gets unit type field by id.
    /// </summary>
    Task<UnitTypeField?> GetUnitTypeFieldByIdAsync(Guid fieldId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث نوع الوحدة الحقل.
    /// Updates unit type field.
    /// </summary>
    Task<UnitTypeField> UpdateUnitTypeFieldAsync(UnitTypeField unitTypeField, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحذف نوع الوحدة الحقل.
    /// Deletes unit type field.
    /// </summary>
    Task<bool> DeleteUnitTypeFieldAsync(Guid fieldId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الحقول حسب نوع الوحدة المعرّف.
    /// Gets fields by unit type id.
    /// </summary>
    Task<IEnumerable<UnitTypeField>> GetFieldsByUnitTypeIdAsync(Guid unitTypeId, CancellationToken cancellationToken = default);
} 
