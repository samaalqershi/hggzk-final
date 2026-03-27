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
    /// Provides persistence operations for property services.
    /// يوفّر عمليات الحفظ الخاصة بخدمات العقار.
    /// </summary>
    public class PropertyServiceRepository : BaseRepository<PropertyService>, IPropertyServiceRepository
    {
        /// <summary>
        /// يهيئ مثيلاً جديدًا من PropertyServiceRepository باستخدام سياق قاعدة البيانات المشترك.
        /// Initializes a new instance of PropertyServiceRepository with the shared database context.
        /// </summary>
        public PropertyServiceRepository(YemenBookingDbContext context) : base(context) { }

        /// <summary>
        /// Creates a new property service and stages it for persistence.
        /// ينشئ خدمة عقار جديدة ويجهزها للحفظ.
        /// </summary>
        public async Task<PropertyService> CreatePropertyServiceAsync(PropertyService propertyService, CancellationToken cancellationToken = default)
        {
            await _dbSet.AddAsync(propertyService, cancellationToken);
            return propertyService;
        }

        /// <summary>
        /// Retrieves the specified property service by its identifier.
        /// يسترجع خدمة العقار المحددة بواسطة المعرّف.
        /// </summary>
        public async Task<PropertyService?> GetPropertyServiceByIdAsync(Guid propertyServiceId, CancellationToken cancellationToken = default)
            => await _dbSet.FindAsync(new object[]{propertyServiceId}, cancellationToken);

        /// <summary>
        /// Retrieves the service identified by the given ID.
        /// يسترجع الخدمة المحددة بواسطة المعرّف.
        /// </summary>
        public async Task<PropertyService?> GetServiceByIdAsync(Guid serviceId, CancellationToken cancellationToken = default)
            => await _dbSet.FirstOrDefaultAsync(s => s.Id == serviceId, cancellationToken);

        /// <summary>
        /// Updates an existing property service.
        /// يحدّث خدمة العقار الموجودة.
        /// </summary>
        public async Task<PropertyService> UpdatePropertyServiceAsync(PropertyService propertyService, CancellationToken cancellationToken = default)
        {
            return TrackForUpdate(_dbSet, propertyService);
        }

        /// <summary>
        /// Deletes the specified property service.
        /// يحذف خدمة العقار المحددة.
        /// </summary>
        public async Task<bool> DeletePropertyServiceAsync(Guid propertyServiceId, CancellationToken cancellationToken = default)
        {
            var ps = await GetPropertyServiceByIdAsync(propertyServiceId, cancellationToken);
            if (ps == null) return false;
            _dbSet.Remove(ps);
            return true;
        }

        /// <summary>
        /// Retrieves the services linked to the specified property.
        /// يسترجع الخدمات المرتبطة بالعقار المحدد.
        /// </summary>
        public async Task<IEnumerable<PropertyService>> GetPropertyServicesAsync(Guid propertyId, CancellationToken cancellationToken = default)
            => await _dbSet
                .Include(ps => ps.Property)
                .Where(ps => ps.PropertyId == propertyId)
                .ToListAsync(cancellationToken);

        /// <summary>
        /// Retrieves services that match the specified service type.
        /// يسترجع الخدمات المطابقة لنوع الخدمة المحدد.
        /// </summary>
        public async Task<IEnumerable<PropertyService>> GetServicesByTypeAsync(string serviceType, CancellationToken cancellationToken = default)
        {
            // If no type provided or explicitly requesting all, return all services
            if (string.IsNullOrWhiteSpace(serviceType) || string.Equals(serviceType, "all", StringComparison.OrdinalIgnoreCase))
            {
                return await _dbSet
                    .Include(ps => ps.Property)
                    .ToListAsync(cancellationToken);
            }

            var term = serviceType.Trim();
            // Case-insensitive contains to make filtering more user-friendly
            return await _dbSet
                .Include(ps => ps.Property)
                .Where(ps => EF.Functions.Like(ps.Name, $"%{term}%"))
                .ToListAsync(cancellationToken);
        }

        /// <summary>
        /// Retrieves the property identified by the given ID.
        /// يسترجع العقار المحدد بواسطة المعرّف.
        /// </summary>
        public async Task<Property?> GetPropertyByIdAsync(Guid propertyId, CancellationToken cancellationToken = default)
            => await _context.Set<Property>().FirstOrDefaultAsync(p => p.Id == propertyId, cancellationToken);

        /// <summary>
        /// Checks whether the service is referenced by any bookings.
        /// يتحقق مما إذا كانت الخدمة مستخدمة في أي حجوزات.
        /// </summary>
        public async Task<bool> ServiceHasBookingReferencesAsync(Guid serviceId, CancellationToken cancellationToken = default)
            => await _context.Set<BookingService>().AnyAsync(bs => bs.ServiceId == serviceId, cancellationToken);
    }
}
