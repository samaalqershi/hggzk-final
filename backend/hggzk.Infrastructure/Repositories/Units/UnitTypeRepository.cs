using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;
using System.Linq;

namespace YemenBooking.Infrastructure.Repositories.Units
{
    /// <summary>
    /// مستودع أنواع الوحدات.
    /// Unit type repository.
    /// </summary>
    public class UnitTypeRepository : BaseRepository<UnitType>, IUnitTypeRepository
    {
        /// <summary>
        /// ينشئ مثيلاً جديداً من UnitTypeRepository.
        /// Initializes a new instance of UnitTypeRepository.
        /// </summary>
        public UnitTypeRepository(YemenBookingDbContext context) : base(context) { }

        /// <summary>
        /// ينشئ نوع وحدة جديدًا.
        /// Creates a new unit type.
        /// </summary>
    public async Task<UnitType> CreateUnitTypeAsync(UnitType unitType, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(unitType, cancellationToken);
        return unitType;
    }

        /// <summary>
        /// يجلب نوع الوحدة حسب المعرف.
        /// Gets the unit type by identifier.
        /// </summary>
        public async Task<UnitType?> GetUnitTypeByIdAsync(Guid unitTypeId, CancellationToken cancellationToken = default)
            => await _dbSet.FindAsync(new object[]{unitTypeId}, cancellationToken);

        /// <summary>
        /// يجلب أنواع الوحدات حسب نوع العقار.
        /// Gets unit types by property type.
        /// </summary>
        public async Task<IEnumerable<UnitType>> GetByPropertyTypeIdAsync(Guid propertyTypeId, CancellationToken cancellationToken = default)
            => await GetUnitTypesByPropertyTypeAsync(propertyTypeId, cancellationToken);

        /// <summary>
        /// يجلب أنواع الوحدات حسب نوع العقار.
        /// Gets unit types by property type.
        /// </summary>
        public async Task<IEnumerable<UnitType>> GetUnitTypesByPropertyTypeAsync(Guid propertyTypeId, CancellationToken cancellationToken = default)
            => await _dbSet
                .Include(ut => ut.UnitTypeFields)
                .Where(ut => ut.PropertyTypeId == propertyTypeId)
                .ToListAsync(cancellationToken);

        /// <summary>
        /// يجلب جميع أنواع الوحدات.
        /// Gets all unit types.
        /// </summary>
        public async Task<IEnumerable<UnitType>> GetAllUnitTypesAsync(CancellationToken cancellationToken = default)
            => await _dbSet.ToListAsync(cancellationToken);

        /// <summary>
        /// يحدّث نوع الوحدة.
        /// Updates the unit type.
        /// </summary>
    public async Task<UnitType> UpdateUnitTypeAsync(UnitType unitType, CancellationToken cancellationToken = default)
    {
        return TrackForUpdate(_dbSet, unitType);
    }

        /// <summary>
        /// يحذف نوع الوحدة.
        /// Deletes the unit type.
        /// </summary>
        public async Task<bool> DeleteUnitTypeAsync(Guid unitTypeId, CancellationToken cancellationToken = default)
        {
        var ut = await GetUnitTypeByIdAsync(unitTypeId, cancellationToken);
        if (ut == null) return false;
        _dbSet.Remove(ut);
        return true;
    }

        /// <summary>
        /// يجلب نوع العقار حسب المعرف.
        /// Gets the property type by identifier.
        /// </summary>
        public async Task<PropertyType?> GetPropertyTypeByIdAsync(Guid propertyTypeId, CancellationToken cancellationToken = default)
            => await _context.Set<PropertyType>().FirstOrDefaultAsync(pt => pt.Id == propertyTypeId, cancellationToken);
    }
} 
