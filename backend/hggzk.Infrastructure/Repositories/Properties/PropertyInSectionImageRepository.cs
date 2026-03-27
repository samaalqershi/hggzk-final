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
/// Provides persistence operations for property-in-section images.
/// يوفّر عمليات الحفظ الخاصة بصور العقار داخل القسم.
/// </summary>
public class PropertyInSectionImageRepository : IPropertyInSectionImageRepository
{
    private readonly YemenBookingDbContext _context;
    private readonly DbSet<PropertyInSectionImage> _images;

    /// <summary>
    /// يهيئ مثيلاً جديدًا من PropertyInSectionImageRepository باستخدام سياق قاعدة البيانات المشترك.
    /// Initializes a new instance of PropertyInSectionImageRepository with the shared database context.
    /// </summary>
    public PropertyInSectionImageRepository(YemenBookingDbContext context)
    {
        _context = context;
        _images = context.Set<PropertyInSectionImage>();
    }

    /// <summary>
    /// Creates a new property-in-section image and stages it for persistence.
    /// ينشئ صورة عقار داخل قسم جديدة ويجهزها للحفظ.
    /// </summary>
    public async Task<PropertyInSectionImage> CreateAsync(PropertyInSectionImage image, CancellationToken cancellationToken = default)
    {
        await _images.AddAsync(image, cancellationToken);
        return image;
    }

    /// <summary>
    /// Retrieves the specified property-in-section image by its identifier.
    /// يسترجع صورة العقار داخل القسم المحددة بواسطة المعرّف.
    /// </summary>
    public async Task<PropertyInSectionImage?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
        => await GetQueryable().FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

    /// <summary>
    /// Returns a queryable set for property-in-section images.
    /// يعيد مجموعة قابلة للاستعلام لصور العقار داخل القسم.
    /// </summary>
    public IQueryable<PropertyInSectionImage> GetQueryable()
        => _images.Where(x => !x.IsDeleted);

    /// <summary>
    /// Updates an existing property-in-section image.
    /// يحدّث صورة العقار داخل القسم الموجودة.
    /// </summary>
    public async Task<PropertyInSectionImage> UpdateAsync(PropertyInSectionImage image, CancellationToken cancellationToken = default)
    {
        return TrackForUpdate(_images, image);
    }

    /// <summary>
    /// Deletes the specified property-in-section image.
    /// يحذف صورة العقار داخل القسم المحددة.
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
    /// Retrieves images linked to the specified property-in-section record.
    /// يسترجع الصور المرتبطة بسجل العقار داخل القسم المحدد.
    /// </summary>
    public async Task<IEnumerable<PropertyInSectionImage>> GetByPropertyInSectionIdAsync(Guid propertyInSectionId, CancellationToken cancellationToken = default)
        => await GetQueryable().Where(x => x.PropertyInSectionId == propertyInSectionId)
            .OrderBy(x => x.DisplayOrder).ThenBy(x => x.UploadedAt)
            .ToListAsync(cancellationToken);

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
        var groupId = current.PropertyInSectionId;
        var siblings = await GetQueryable().Where(x => x.PropertyInSectionId == groupId).ToListAsync(cancellationToken);
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
