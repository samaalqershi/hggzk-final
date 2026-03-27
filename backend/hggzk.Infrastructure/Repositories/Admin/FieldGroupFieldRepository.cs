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
/// يمثل مستودعًا للوصول إلى عناصر مجموعات الحقول.
/// Represents a repository for accessing field-group field links.
/// </summary>
public class FieldGroupFieldRepository : BaseRepository<FieldGroupField>, IFieldGroupFieldRepository
{
/// <summary>
/// ينشئ المستودع مع سياق قاعدة البيانات المشترك.
/// Creates the repository with the shared database context.
/// </summary>
    public FieldGroupFieldRepository(YemenBookingDbContext context) : base(context)
    {
    }

/// <summary>
/// يعيّن الكيان المطلوب للعلاقة المحددة.
/// Assigns the requested entity to the target relation.
/// </summary>
    public async Task<FieldGroupField> AssignFieldToGroupAsync(FieldGroupField fieldGroupField, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(fieldGroupField, cancellationToken);
        return fieldGroupField;
    }

/// <summary>
/// يزيل السجل المطلوب من المستودع.
/// Removes the requested record from the repository.
/// </summary>
    public async Task<bool> RemoveFieldFromGroupAsync(Guid fieldId, Guid groupId, CancellationToken cancellationToken = default)
    {
        var entity = await _dbSet.FindAsync(new object[] { fieldId, groupId }, cancellationToken);
        if (entity == null) return false;
        _dbSet.Remove(entity);
        return true;
    }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<IEnumerable<FieldGroupField>> GetGroupsByFieldIdAsync(Guid fieldId, CancellationToken cancellationToken = default)
        => await _dbSet.Where(fgf => fgf.FieldId == fieldId).ToListAsync(cancellationToken);
} 
