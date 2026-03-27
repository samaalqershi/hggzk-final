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
    /// Provides persistence operations for amenities and amenity links.
    /// يوفّر عمليات الحفظ الخاصة بالمرافق وروابط المرافق.
    /// </summary>
    public class AmenityRepository : BaseRepository<Amenity>, IAmenityRepository
    {
        /// <summary>
        /// يهيئ مثيلاً جديدًا من AmenityRepository باستخدام سياق قاعدة البيانات المشترك.
        /// Initializes a new instance of AmenityRepository with the shared database context.
        /// </summary>
        public AmenityRepository(YemenBookingDbContext context) : base(context) { }

    /// <summary>
    /// Creates a new amenity and stages it for persistence.
    /// ينشئ مرفقًا جديدًا ويجهزه للحفظ.
    /// </summary>
    public async Task<Amenity> CreateAmenityAsync(Amenity amenity, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(amenity, cancellationToken);
        return amenity;
    }

        /// <summary>
        /// Retrieves the specified amenity by its identifier.
        /// يسترجع المرفق المحدد بواسطة المعرّف.
        /// </summary>
        public async Task<Amenity?> GetAmenityByIdAsync(Guid amenityId, CancellationToken cancellationToken = default)
            => await _dbSet.FindAsync(new object[]{amenityId}, cancellationToken);

    /// <summary>
    /// Updates an existing amenity.
    /// يحدّث المرفق الموجود.
    /// </summary>
    public async Task<Amenity> UpdateAmenityAsync(Amenity amenity, CancellationToken cancellationToken = default)
    {
        return TrackForUpdate(_dbSet, amenity);
    }

    /// <summary>
    /// Deletes the specified amenity.
    /// يحذف المرفق المحدد.
    /// </summary>
    public async Task<bool> DeleteAmenityAsync(Guid amenityId, CancellationToken cancellationToken = default)
    {
        var amenity = await GetAmenityByIdAsync(amenityId, cancellationToken);
        if (amenity == null) return false;
        _dbSet.Remove(amenity);
        return true;
    }

        /// <summary>
        /// Retrieves all amenities.
        /// يسترجع جميع المرافق.
        /// </summary>
        public async Task<IEnumerable<Amenity>> GetAllAmenitiesAsync(CancellationToken cancellationToken = default)
            => await _dbSet.ToListAsync(cancellationToken);

        /// <summary>
        /// Retrieves the property type identified by the given ID.
        /// يسترجع نوع العقار المحدد بواسطة المعرّف.
        /// </summary>
        public async Task<PropertyType?> GetPropertyTypeByIdAsync(Guid propertyTypeId, CancellationToken cancellationToken = default)
            => await _context.Set<PropertyType>().FirstOrDefaultAsync(pt => pt.Id == propertyTypeId, cancellationToken);

    /// <summary>
    /// Assigns an amenity to the specified property type.
    /// يربط مرفقًا بنوع العقار المحدد.
    /// </summary>
    public async Task<PropertyTypeAmenity> AssignAmenityToPropertyTypeAsync(Guid propertyTypeId, Guid amenityId, bool isDefault = false, CancellationToken cancellationToken = default)
    {
        var entity = new PropertyTypeAmenity { PropertyTypeId = propertyTypeId, AmenityId = amenityId, IsDefault = isDefault };
        await _context.Set<PropertyTypeAmenity>().AddAsync(entity, cancellationToken);
        return entity;
    }

        /// <summary>
        /// Retrieves amenities linked to the specified property type.
        /// يسترجع المرافق المرتبطة بنوع العقار المحدد.
        /// </summary>
        public async Task<IEnumerable<PropertyTypeAmenity>> GetAmenitiesByPropertyTypeAsync(Guid propertyTypeId, CancellationToken cancellationToken = default)
            => await _context.Set<PropertyTypeAmenity>().Where(a => a.PropertyTypeId == propertyTypeId).ToListAsync(cancellationToken);

        /// <summary>
        /// Retrieves amenities linked to the specified property.
        /// يسترجع المرافق المرتبطة بالعقار المحدد.
        /// </summary>
        public async Task<IEnumerable<PropertyAmenity>> GetAmenitiesByPropertyAsync(Guid propertyId, CancellationToken cancellationToken = default)
        {
            return await _context.Set<PropertyAmenity>()
                .Include(pa => pa.PropertyTypeAmenity).ThenInclude(pta => pta.Amenity)
                .Where(pa => pa.PropertyId == propertyId)
                .ToListAsync(cancellationToken);
        }

        // Retrieves all property-amenity assignments including navigation for filtering
        /// <summary>
        /// Retrieves all property-amenity links.
        /// يسترجع جميع روابط العقار بالمرافق.
        /// </summary>
        public async Task<IEnumerable<PropertyAmenity>> GetAllPropertyAmenitiesAsync(CancellationToken cancellationToken = default)
        {
            return await _context.Set<PropertyAmenity>()
                .Include(pa => pa.PropertyTypeAmenity).ThenInclude(pta => pta.Amenity)
                .ToListAsync(cancellationToken);
        }
    }
} 
