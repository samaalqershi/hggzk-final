using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Units;

/// <summary>
/// مستودع حقول نوع الوحدة.
/// Unit type field repository.
/// </summary>
public class UnitTypeFieldRepository : BaseRepository<UnitTypeField>, IUnitTypeFieldRepository
{
    /// <summary>
    /// ينشئ مثيلاً جديداً من UnitTypeFieldRepository.
    /// Initializes a new instance of UnitTypeFieldRepository.
    /// </summary>
    public UnitTypeFieldRepository(YemenBookingDbContext context) : base(context)
    {
    }

    /// <summary>
    /// ينشئ حقل نوع وحدة جديدًا.
    /// Creates a new unit type field.
    /// </summary>
    public async Task<UnitTypeField> CreateUnitTypeFieldAsync(UnitTypeField unitTypeField, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(unitTypeField, cancellationToken);
        return unitTypeField;
    }

    /// <summary>
    /// يجلب حقل نوع الوحدة حسب المعرف.
    /// Gets the unit type field by identifier.
    /// </summary>
    public async Task<UnitTypeField?> GetUnitTypeFieldByIdAsync(Guid fieldId, CancellationToken cancellationToken = default)
        => await _dbSet.FindAsync(new object[] { fieldId }, cancellationToken);

    /// <summary>
    /// يحدّث حقل نوع الوحدة.
    /// Updates the unit type field.
    /// </summary>
    public async Task<UnitTypeField> UpdateUnitTypeFieldAsync(UnitTypeField unitTypeField, CancellationToken cancellationToken = default)
    {
        return TrackForUpdate(_dbSet, unitTypeField);
    }

    /// <summary>
    /// يحذف حقل نوع الوحدة.
    /// Deletes the unit type field.
    /// </summary>
    public async Task<bool> DeleteUnitTypeFieldAsync(Guid fieldId, CancellationToken cancellationToken = default)
    {
        var entity = await GetUnitTypeFieldByIdAsync(fieldId, cancellationToken);
        if (entity == null) return false;
        _dbSet.Remove(entity);
        return true;
    }

    /// <summary>
    /// يجلب الحقول المرتبطة بنوع الوحدة.
    /// Gets fields linked to the unit type.
    /// </summary>
    public async Task<IEnumerable<UnitTypeField>> GetFieldsByUnitTypeIdAsync(Guid unitTypeId, CancellationToken cancellationToken = default)
        => await _dbSet.Where(ptf => ptf.UnitTypeId == unitTypeId).ToListAsync(cancellationToken);
} 
