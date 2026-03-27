using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Properties
{
    /// <summary>
    /// Provides persistence operations for property types.
    /// يوفّر عمليات الحفظ الخاصة بأنواع العقارات.
    /// </summary>
    public class PropertyTypeRepository : BaseRepository<PropertyType>, IPropertyTypeRepository
    {
        /// <summary>
        /// يهيئ مثيلاً جديدًا من PropertyTypeRepository باستخدام سياق قاعدة البيانات المشترك.
        /// Initializes a new instance of PropertyTypeRepository with the shared database context.
        /// </summary>
        public PropertyTypeRepository(YemenBookingDbContext context) : base(context) { }

    /// <summary>
    /// Creates a new property type and stages it for persistence.
    /// ينشئ نوع عقار جديدًا ويجهزه للحفظ.
    /// </summary>
    public async Task<PropertyType> CreatePropertyTypeAsync(PropertyType propertyType, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(propertyType, cancellationToken);
        return propertyType;
    }

        /// <summary>
        /// Retrieves the specified property type by its identifier.
        /// يسترجع نوع العقار المحدد بواسطة المعرّف.
        /// </summary>
        public async Task<PropertyType?> GetPropertyTypeByIdAsync(Guid propertyTypeId, CancellationToken cancellationToken = default)
            => await _dbSet.FindAsync(new object[]{propertyTypeId}, cancellationToken);

        /// <summary>
        /// Retrieves all property types.
        /// يسترجع جميع أنواع العقارات.
        /// </summary>
        public async Task<IEnumerable<PropertyType>> GetAllPropertyTypesAsync(CancellationToken cancellationToken = default)
            => await _dbSet.Include(pt => pt.UnitTypes).ToListAsync(cancellationToken);

        /// <summary>
        /// Retrieves the specified property type together with its linked amenities.
        /// يسترجع نوع العقار المحدد مع المرافق المرتبطة به.
        /// </summary>
        public async Task<PropertyType?> GetPropertyTypeWithAmenitiesAsync(Guid propertyTypeId, CancellationToken cancellationToken = default)
            => await _dbSet.Include(pt => pt.PropertyTypeAmenities)
                .ThenInclude(pta => pta.Amenity)
                .FirstOrDefaultAsync(pt => pt.Id == propertyTypeId, cancellationToken);

    /// <summary>
    /// Updates an existing property type.
    /// يحدّث نوع العقار الموجود.
    /// </summary>
    public async Task<PropertyType> UpdatePropertyTypeAsync(PropertyType propertyType, CancellationToken cancellationToken = default)
    {
        return TrackForUpdate(_dbSet, propertyType);
    }

    /// <summary>
    /// Deletes the specified property type.
    /// يحذف نوع العقار المحدد.
    /// </summary>
    public async Task<bool> DeletePropertyTypeAsync(Guid propertyTypeId, CancellationToken cancellationToken = default)
    {
        var pt = await GetPropertyTypeByIdAsync(propertyTypeId, cancellationToken);
        if (pt == null) return false;
        _dbSet.Remove(pt);
        return true;
    }
    }
} 
