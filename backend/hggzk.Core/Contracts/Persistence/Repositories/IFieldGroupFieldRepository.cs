using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع مجموعة الحقول الحقل repository.
/// Field group field repository repository interface.
/// </summary>
public interface IFieldGroupFieldRepository : IRepository<FieldGroupField>
{
    /// <summary>
    /// يربط الحقل إلى المجموعة.
    /// Assigns field to group.
    /// </summary>
    Task<FieldGroupField> AssignFieldToGroupAsync(FieldGroupField fieldGroupField, CancellationToken cancellationToken = default);

    /// <summary>
    /// يزيل الحقل من المجموعة.
    /// Removes field from group.
    /// </summary>
    Task<bool> RemoveFieldFromGroupAsync(Guid fieldId, Guid groupId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب المجموعات حسب الحقل المعرّف.
    /// Gets groups by field id.
    /// </summary>
    Task<IEnumerable<FieldGroupField>> GetGroupsByFieldIdAsync(Guid fieldId, CancellationToken cancellationToken = default);

}
