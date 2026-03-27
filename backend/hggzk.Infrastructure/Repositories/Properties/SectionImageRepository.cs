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
/// Provides persistence operations for section images.
/// يوفّر عمليات الحفظ الخاصة بصور الأقسام.
/// </summary>
public class SectionImageRepository : ISectionImageRepository
{
    private readonly YemenBookingDbContext _context;
    private readonly DbSet<SectionImage> _images;

    /// <summary>
    /// يهيئ مثيلاً جديدًا من SectionImageRepository باستخدام سياق قاعدة البيانات المشترك.
    /// Initializes a new instance of SectionImageRepository with the shared database context.
    /// </summary>
    public SectionImageRepository(YemenBookingDbContext context)
    {
        _context = context;
        _images = context.Set<SectionImage>();
    }

    /// <summary>
    /// Creates a new section image and stages it for persistence.
    /// ينشئ صورة قسم جديدة ويجهزها للحفظ.
    /// </summary>
    public async Task<SectionImage> CreateAsync(SectionImage image, CancellationToken cancellationToken = default)
    {
        await _images.AddAsync(image, cancellationToken);
        return image;
    }

    /// <summary>
    /// Retrieves the specified section image by its identifier.
    /// يسترجع صورة القسم المحددة بواسطة المعرّف.
    /// </summary>
    public async Task<SectionImage?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
        => await GetQueryable().FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

    /// <summary>
    /// Returns a queryable set for section images.
    /// يعيد مجموعة قابلة للاستعلام لصور الأقسام.
    /// </summary>
    public IQueryable<SectionImage> GetQueryable()
        => _images.Where(x => !x.IsDeleted);

    /// <summary>
    /// Updates an existing section image.
    /// يحدّث صورة القسم الموجودة.
    /// </summary>
    public async Task<SectionImage> UpdateAsync(SectionImage image, CancellationToken cancellationToken = default)
    {
        return TrackForUpdate(_images, image);
    }

    /// <summary>
    /// Deletes the specified section image.
    /// يحذف صورة القسم المحددة.
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
    /// Updates image display orders in bulk.
    /// يحدّث ترتيبات عرض الصور دفعة واحدة.
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
    /// Updates the main-image flag for the specified image.
    /// يحدّث حالة الصورة الأساسية للصورة المحددة.
    /// </summary>
    public async Task<bool> UpdateMainImageStatusAsync(Guid imageId, bool isMain, CancellationToken cancellationToken = default)
    {
        var current = await GetQueryable().FirstOrDefaultAsync(x => x.Id == imageId, cancellationToken);
        if (current == null) return false;
        var sectionId = current.SectionId;
        var siblings = await GetQueryable().Where(x => x.SectionId == sectionId).ToListAsync(cancellationToken);
        foreach (var s in siblings) s.IsMainImage = s.Id == imageId ? isMain : false;
        return true;
    }

    /// <summary>
    /// Persists the pending changes to the database.
    /// يحفظ التغييرات المعلّقة في قاعدة البيانات.
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
