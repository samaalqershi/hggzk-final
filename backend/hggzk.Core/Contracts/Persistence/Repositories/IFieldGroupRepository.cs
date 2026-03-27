using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع مجموعة الحقول repository.
/// Field group repository repository interface.
/// </summary>
public interface IFieldGroupRepository : IRepository<FieldGroup>
{
    /// <summary>
    /// ينشئ مجموعة الحقول.
    /// Creates field group.
    /// </summary>
    Task<FieldGroup> CreateFieldGroupAsync(FieldGroup fieldGroup, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب مجموعة الحقول حسب المعرّف.
    /// Gets field group by id.
    /// </summary>
    Task<FieldGroup?> GetFieldGroupByIdAsync(Guid groupId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث مجموعة الحقول.
    /// Updates field group.
    /// </summary>
    Task<FieldGroup> UpdateFieldGroupAsync(FieldGroup fieldGroup, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحذف مجموعة الحقول.
    /// Deletes field group.
    /// </summary>
    Task<bool> DeleteFieldGroupAsync(Guid groupId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب المجموعات حسب نوع الوحدة المعرّف.
    /// Gets groups by unit type id.
    /// </summary>
    Task<IEnumerable<FieldGroup>> GetGroupsByUnitTypeIdAsync(Guid propertyTypeId, CancellationToken cancellationToken = default);
} 
