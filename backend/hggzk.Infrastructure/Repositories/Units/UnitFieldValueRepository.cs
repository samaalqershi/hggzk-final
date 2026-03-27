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
/// مستودع قيم حقول الوحدة.
/// Unit field value repository.
/// </summary>
public class UnitFieldValueRepository : BaseRepository<UnitFieldValue>, IUnitFieldValueRepository
{
    /// <summary>
    /// ينشئ مثيلاً جديداً من UnitFieldValueRepository.
    /// Initializes a new instance of UnitFieldValueRepository.
    /// </summary>
    public UnitFieldValueRepository(YemenBookingDbContext context) : base(context)
    {
    }

    /// <summary>
    /// ينشئ قيمة حقل للوحدة.
    /// Creates a unit field value.
    /// </summary>
    public async Task<UnitFieldValue> CreateUnitFieldValueAsync(UnitFieldValue unitFieldValue, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(unitFieldValue, cancellationToken);
        return unitFieldValue;
    }

    /// <summary>
    /// يجلب قيمة الحقل حسب المعرف.
    /// Gets the field value by identifier.
    /// </summary>
    public async Task<UnitFieldValue?> GetUnitFieldValueByIdAsync(Guid valueId, CancellationToken cancellationToken = default)
        => await _dbSet.FindAsync(new object[] { valueId }, cancellationToken);

    /// <summary>
    /// يحدّث قيمة الحقل.
    /// Updates the field value.
    /// </summary>
    public async Task<UnitFieldValue> UpdateUnitFieldValueAsync(UnitFieldValue unitFieldValue, CancellationToken cancellationToken = default)
    {
        return TrackForUpdate(_dbSet, unitFieldValue);
    }

    /// <summary>
    /// يحذف قيمة الحقل.
    /// Deletes the field value.
    /// </summary>
    public async Task<bool> DeleteUnitFieldValueAsync(Guid valueId, CancellationToken cancellationToken = default)
    {
        var entity = await GetUnitFieldValueByIdAsync(valueId, cancellationToken);
        if (entity == null) return false;
        _dbSet.Remove(entity);
        return true;
    }

    /// <summary>
    /// يجلب القيم المرتبطة بالوحدة.
    /// Gets values linked to the unit.
    /// </summary>
    public async Task<IEnumerable<UnitFieldValue>> GetValuesByUnitIdAsync(Guid unitId, CancellationToken cancellationToken = default)
        => await _dbSet
            .Include(ufv => ufv.UnitTypeField) // إضافة تحميل بيانات الحقل (اسم الحقل، اسم العرض، نوع الحقل، إلخ)
            .Where(ufv => ufv.UnitId == unitId)
            .ToListAsync(cancellationToken);

    /// <summary>
    /// يجلب القيم المرتبطة بالحقل.
    /// Gets values linked to the field.
    /// </summary>
    public async Task<IEnumerable<UnitFieldValue>> GetByFieldIdAsync(Guid fieldId, CancellationToken cancellationToken = default)
        => await _dbSet
            .Include(ufv => ufv.UnitTypeField) // إضافة تحميل بيانات الحقل
            .Where(ufv => ufv.UnitTypeFieldId == fieldId)
            .ToListAsync(cancellationToken);
}
