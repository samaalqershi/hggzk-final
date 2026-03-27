using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Properties;

/// <summary>
/// Provides persistence operations for property-amenity links.
/// يوفّر عمليات الحفظ الخاصة بروابط العقار بالمرافق.
/// </summary>
public class PropertyAmenityRepository : BaseRepository<PropertyAmenity>, IPropertyAmenityRepository
{
    /// <summary>
    /// يهيئ مثيلاً جديدًا من PropertyAmenityRepository باستخدام سياق قاعدة البيانات المشترك.
    /// Initializes a new instance of PropertyAmenityRepository with the shared database context.
    /// </summary>
    public PropertyAmenityRepository(YemenBookingDbContext context) : base(context)
    {
    }

    /// <summary>
    /// Adds a property-amenity link and stages it for persistence.
    /// يضيف ربطًا بين العقار والمرفق ويجهزه للحفظ.
    /// </summary>
    public async Task<PropertyAmenity> AddAmenityToPropertyAsync(PropertyAmenity propertyAmenity, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(propertyAmenity, cancellationToken);
        return propertyAmenity;
    }

    /// <summary>
    /// Removes the specified property-amenity link.
    /// يزيل ربط العقار بالمرفق المحدد.
    /// </summary>
    public async Task<bool> RemoveAmenityFromPropertyAsync(Guid propertyId, Guid ptaId, CancellationToken cancellationToken = default)
    {
        var propertyAmenity = await _dbSet.FirstOrDefaultAsync(
            pa => pa.PropertyId == propertyId && pa.PtaId == ptaId,
            cancellationToken);
        if (propertyAmenity == null)
        {
            return false;
        }

        _dbSet.Remove(propertyAmenity);
        return true;
    }

    /// <summary>
    /// Removes multiple property-amenity links.
    /// يزيل عدة روابط بين العقار والمرافق.
    /// </summary>
    public async Task<int> RemoveAmenitiesFromPropertyAsync(Guid propertyId, IEnumerable<Guid> ptaIds, CancellationToken cancellationToken = default)
    {
        var ptaIdList = ptaIds.Distinct().ToList();
        if (ptaIdList.Count == 0)
        {
            return 0;
        }

        var propertyAmenities = await _dbSet
            .Where(pa => pa.PropertyId == propertyId && ptaIdList.Contains(pa.PtaId))
            .ToListAsync(cancellationToken);

        if (propertyAmenities.Count == 0)
        {
            return 0;
        }

        _dbSet.RemoveRange(propertyAmenities);
        return propertyAmenities.Count;
    }
}
