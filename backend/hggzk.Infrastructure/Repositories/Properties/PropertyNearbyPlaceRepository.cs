using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Properties;

/// <summary>
/// Provides persistence operations for property nearby places.
/// يوفّر عمليات الحفظ الخاصة بالأماكن القريبة للعقار.
/// </summary>
public class PropertyNearbyPlaceRepository : BaseRepository<PropertyNearbyPlace>, IPropertyNearbyPlaceRepository
{
    public PropertyNearbyPlaceRepository(YemenBookingDbContext context) : base(context)
    {
    }

    public async Task<PropertyNearbyPlace> CreateAsync(PropertyNearbyPlace nearbyPlace, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(nearbyPlace, cancellationToken);
        return nearbyPlace;
    }

    public async Task<PropertyNearbyPlace?> GetByIdAsync(Guid nearbyPlaceId, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(place => place.Property)
            .FirstOrDefaultAsync(place => place.Id == nearbyPlaceId, cancellationToken);
    }

    public async Task<IEnumerable<PropertyNearbyPlace>> GetByPropertyIdAsync(Guid propertyId, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(place => place.Property)
            .Where(place => place.PropertyId == propertyId)
            .OrderBy(place => place.DisplayOrder)
            .ThenBy(place => place.DistanceInMeters)
            .ThenBy(place => place.Name)
            .ToListAsync(cancellationToken);
    }

    public async Task<IEnumerable<PropertyNearbyPlace>> SearchAsync(Guid? propertyId, string? searchTerm, bool? isActive, CancellationToken cancellationToken = default)
    {
        IQueryable<PropertyNearbyPlace> query = _dbSet.Include(place => place.Property);

        if (propertyId.HasValue && propertyId.Value != Guid.Empty)
        {
            query = query.Where(place => place.PropertyId == propertyId.Value);
        }

        if (isActive.HasValue)
        {
            query = query.Where(place => place.IsActive == isActive.Value);
        }

        if (!string.IsNullOrWhiteSpace(searchTerm))
        {
            var term = searchTerm.Trim();
            query = query.Where(place =>
                EF.Functions.Like(place.Name, $"%{term}%") ||
                (place.NameEn != null && EF.Functions.Like(place.NameEn, $"%{term}%")) ||
                EF.Functions.Like(place.Category, $"%{term}%"));
        }

        return await query
            .OrderBy(place => place.Property.Name)
            .ThenBy(place => place.DisplayOrder)
            .ThenBy(place => place.DistanceInMeters)
            .ToListAsync(cancellationToken);
    }

    public Task<PropertyNearbyPlace> UpdateAsync(PropertyNearbyPlace nearbyPlace, CancellationToken cancellationToken = default)
    {
        return Task.FromResult(TrackForUpdate(_dbSet, nearbyPlace));
    }

    public async Task<bool> DeleteAsync(Guid nearbyPlaceId, CancellationToken cancellationToken = default)
    {
        var entity = await GetByIdAsync(nearbyPlaceId, cancellationToken);
        if (entity == null)
        {
            return false;
        }

        _dbSet.Remove(entity);
        return true;
    }
}
