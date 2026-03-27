using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Admin;

/// <summary>
/// يمثل مستودعًا للوصول إلى مجموعات الحقول.
/// Represents a repository for accessing field groups.
/// </summary>
public class FieldGroupRepository : BaseRepository<FieldGroup>, IFieldGroupRepository
{
/// <summary>
/// ينشئ المستودع مع سياق قاعدة البيانات المشترك.
/// Creates the repository with the shared database context.
/// </summary>
    public FieldGroupRepository(YemenBookingDbContext context) : base(context)
    {
    }

/// <summary>
/// ينشئ سجلًا جديدًا في المستودع.
/// Creates a new record in the repository.
/// </summary>
    public async Task<FieldGroup> CreateFieldGroupAsync(FieldGroup fieldGroup, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(fieldGroup, cancellationToken);
        return fieldGroup;
    }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<FieldGroup?> GetFieldGroupByIdAsync(Guid groupId, CancellationToken cancellationToken = default)
        => await _dbSet.FindAsync(new object[] { groupId }, cancellationToken);

/// <summary>
/// يحدّث السجل المطلوب في المستودع.
/// Updates the requested record in the repository.
/// </summary>
    public async Task<FieldGroup> UpdateFieldGroupAsync(FieldGroup fieldGroup, CancellationToken cancellationToken = default)
    {
        return TrackForUpdate(_dbSet, fieldGroup);
    }

/// <summary>
/// يحذف السجل المطلوب من المستودع.
/// Deletes the requested record from the repository.
/// </summary>
    public async Task<bool> DeleteFieldGroupAsync(Guid groupId, CancellationToken cancellationToken = default)
    {
        var entity = await GetFieldGroupByIdAsync(groupId, cancellationToken);
        if (entity == null) return false;

        _dbSet.Remove(entity);
        return true;
    }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<IEnumerable<FieldGroup>> GetGroupsByUnitTypeIdAsync(Guid propertyTypeId, CancellationToken cancellationToken = default)
        => await _dbSet.Where(fg => fg.UnitTypeId == propertyTypeId).ToListAsync(cancellationToken);
} 
