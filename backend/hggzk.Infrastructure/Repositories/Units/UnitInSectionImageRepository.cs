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
/// مستودع صور العناصر داخل الأقسام.
/// Unit-in-section image repository.
/// </summary>
public class UnitInSectionImageRepository : IUnitInSectionImageRepository
{
    private readonly YemenBookingDbContext _context;
    private readonly DbSet<UnitInSectionImage> _images;

    /// <summary>
    /// ينشئ مثيلاً جديداً من UnitInSectionImageRepository.
    /// Initializes a new instance of UnitInSectionImageRepository.
    /// </summary>
    public UnitInSectionImageRepository(YemenBookingDbContext context)
    {
        _context = context;
        _images = context.Set<UnitInSectionImage>();
    }

    /// <summary>
    /// ينشئ الكيان.
    /// Creates the entity.
    /// </summary>
    public async Task<UnitInSectionImage> CreateAsync(UnitInSectionImage image, CancellationToken cancellationToken = default)
    {
        await _images.AddAsync(image, cancellationToken);
        return image;
    }

    /// <summary>
    /// يجلب السجل حسب المعرف.
    /// Gets the record by identifier.
    /// </summary>
    public async Task<UnitInSectionImage?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
        => await GetQueryable().FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

    /// <summary>
    /// يعيد مصدر الاستعلام الفعّال.
    /// Returns the active queryable source.
    /// </summary>
    public IQueryable<UnitInSectionImage> GetQueryable()
        => _images.Where(x => !x.IsDeleted);

    /// <summary>
    /// يحدّث الكيان.
    /// Updates the entity.
    /// </summary>
    public async Task<UnitInSectionImage> UpdateAsync(UnitInSectionImage image, CancellationToken cancellationToken = default)
    {
        return TrackForUpdate(_images, image);
    }

    /// <summary>
    /// يحذف الكيان.
    /// Deletes the entity.
    /// </summary>
    public async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var entity = await GetByIdAsync(id, cancellationToken);
        if (entity == null) return false;
        entity.IsDeleted = true;
        entity.DeletedAt = DateTime.UtcNow;
        TrackForUpdate(_images, entity);
        return true;
    }

    /// <summary>
    /// يجلب الصور المرتبطة بالعنصر داخل القسم.
    /// Gets images linked to the unit-in-section item.
    /// </summary>
    public async Task<IEnumerable<UnitInSectionImage>> GetByUnitInSectionIdAsync(Guid unitInSectionId, CancellationToken cancellationToken = default)
        => await GetQueryable().Where(x => x.UnitInSectionId == unitInSectionId)
            .OrderBy(x => x.DisplayOrder).ThenBy(x => x.UploadedAt)
            .ToListAsync(cancellationToken);

    /// <summary>
    /// يحدّث ترتيبات العرض.
    /// Updates display orders.
    /// </summary>
    public async Task<bool> UpdateDisplayOrdersAsync(IEnumerable<(Guid imageId, int displayOrder)> assignments, CancellationToken cancellationToken = default)
    {
        var ids = assignments.Select(a => a.imageId).ToList();
        var items = await GetQueryable().Where(x => ids.Contains(x.Id)).ToListAsync(cancellationToken);
        var map = assignments.ToDictionary(a => a.imageId, a => a.displayOrder);
        foreach (var i in items) if (map.TryGetValue(i.Id, out var order)) i.DisplayOrder = order;
        return true;
    }

    /// <summary>
    /// يحدّث حالة الصورة الرئيسية.
    /// Updates the main image status.
    /// </summary>
    public async Task<bool> UpdateMainImageStatusAsync(Guid imageId, bool isMain, CancellationToken cancellationToken = default)
    {
        var current = await GetQueryable().FirstOrDefaultAsync(x => x.Id == imageId, cancellationToken);
        if (current == null) return false;
        var groupId = current.UnitInSectionId;
        var siblings = await GetQueryable().Where(x => x.UnitInSectionId == groupId).ToListAsync(cancellationToken);
        foreach (var s in siblings) s.IsMainImage = s.Id == imageId ? isMain : false;
        return true;
    }

    /// <summary>
    /// يحفظ التغييرات.
    /// Saves changes.
    /// </summary>
    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        => _context.SaveChangesAsync(cancellationToken);

    private TEntity TrackForUpdate<TEntity>(DbSet<TEntity> dbSet, TEntity entity) where TEntity : class
    {
        var entry = _context.Entry(entity);
        if (entry.State == EntityState.Detached)
        {
            dbSet.Attach(entity);
            entry = _context.Entry(entity);
        }

        if (entry.State != EntityState.Added)
        {
            entry.State = EntityState.Modified;
        }

        return entity;
    }
}
