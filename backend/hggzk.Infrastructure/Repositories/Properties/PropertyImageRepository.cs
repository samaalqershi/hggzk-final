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
/// Provides persistence operations for property images.
/// يوفّر عمليات الحفظ الخاصة بصور العقارات.
/// </summary>
public class PropertyImageRepository : BaseRepository<PropertyImage>, IPropertyImageRepository
{
    /// <summary>
    /// يهيئ مثيلاً جديدًا من PropertyImageRepository باستخدام سياق قاعدة البيانات المشترك.
    /// Initializes a new instance of PropertyImageRepository with the shared database context.
    /// </summary>
    public PropertyImageRepository(YemenBookingDbContext context) : base(context) { }

    /// <summary>
    /// Creates a new property image and stages it for persistence.
    /// ينشئ صورة عقار جديدة ويجهزها للحفظ.
    /// </summary>
    public async Task<PropertyImage> CreatePropertyImageAsync(PropertyImage propertyImage, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(propertyImage, cancellationToken);
        return propertyImage;
    }

    /// <summary>
    /// Retrieves the specified property image by its identifier.
    /// يسترجع صورة العقار المحددة بواسطة المعرّف.
    /// </summary>
    public async Task<PropertyImage?> GetPropertyImageByIdAsync(Guid imageId, CancellationToken cancellationToken = default)
        => await _dbSet
            .Include(pi => pi.Property)
            .Include(pi => pi.Unit)
            .FirstOrDefaultAsync(pi => pi.Id == imageId && !pi.IsDeleted, cancellationToken);

    /// <summary>
    /// Updates an existing property image.
    /// يحدّث صورة العقار الموجودة.
    /// </summary>
    public async Task<PropertyImage> UpdatePropertyImageAsync(PropertyImage propertyImage, CancellationToken cancellationToken = default)
    {
        return TrackForUpdate(_dbSet, propertyImage);
    }

    /// <summary>
    /// Deletes the specified property image.
    /// يحذف صورة العقار المحددة.
    /// </summary>
    public async Task<bool> DeletePropertyImageAsync(Guid imageId, CancellationToken cancellationToken = default)
    {
        var image = await GetPropertyImageByIdAsync(imageId, cancellationToken);
        if (image == null) return false;

        // Soft delete
        image.IsDeleted = true;
        image.DeletedAt = DateTime.UtcNow;
        
        TrackForUpdate(_dbSet, image);
        return true;
    }

    /// <summary>
    /// Permanently deletes property images for the specified property.
    /// يحذف صور العقار نهائيًا للعقار المحدد.
    /// </summary>
    public async Task<int> HardDeleteByPropertyIdAsync(Guid propertyId, CancellationToken cancellationToken = default)
    {
        var images = await _dbSet.IgnoreQueryFilters()
            .Where(pi => pi.PropertyId == propertyId)
            .ToListAsync(cancellationToken);
        if (images.Count == 0) return 0;
        _dbSet.RemoveRange(images);
        return images.Count;
    }

    /// <summary>
    /// Permanently deletes property images for the specified unit.
    /// يحذف صور العقار نهائيًا للوحدة المحددة.
    /// </summary>
    public async Task<int> HardDeleteByUnitIdAsync(Guid unitId, CancellationToken cancellationToken = default)
    {
        var images = await _dbSet.IgnoreQueryFilters()
            .Where(pi => pi.UnitId == unitId)
            .ToListAsync(cancellationToken);
        if (images.Count == 0) return 0;
        _dbSet.RemoveRange(images);
        return images.Count;
    }

    /// <summary>
    /// Retrieves property images for the specified property.
    /// يسترجع صور العقار الخاصة بالعقار المحدد.
    /// </summary>
    public async Task<IEnumerable<PropertyImage>> GetByPropertyIdAsync(Guid propertyId, CancellationToken cancellationToken = default)
        => await GetImagesByPropertyAsync(propertyId, cancellationToken);

    /// <summary>
    /// Retrieves images linked to the specified property.
    /// يسترجع الصور المرتبطة بالعقار المحدد.
    /// </summary>
    public async Task<IEnumerable<PropertyImage>> GetImagesByPropertyAsync(Guid propertyId, CancellationToken cancellationToken = default)
        => await _dbSet
            .Where(pi => pi.PropertyId.HasValue && pi.PropertyId.Value == propertyId && !pi.IsDeleted)
            .OrderBy(pi => pi.DisplayOrder)
            .ThenBy(pi => pi.CreatedAt)
            .ToListAsync(cancellationToken);

    /// <summary>
    /// Retrieves images linked to the specified unit.
    /// يسترجع الصور المرتبطة بالوحدة المحددة.
    /// </summary>
    public async Task<IEnumerable<PropertyImage>> GetImagesByUnitAsync(Guid unitId, CancellationToken cancellationToken = default)
        => await _dbSet
            .Where(pi => pi.UnitId.HasValue && pi.UnitId.Value == unitId && !pi.IsDeleted)
            .OrderBy(pi => pi.DisplayOrder)
            .ThenBy(pi => pi.CreatedAt)
            .ToListAsync(cancellationToken);

    /// <summary>
    /// Updates the main-image flag for the specified image.
    /// يحدّث حالة الصورة الأساسية للصورة المحددة.
    /// </summary>
    public async Task<bool> UpdateMainImageStatusAsync(Guid imageId, bool isMain, CancellationToken cancellationToken = default)
    {
        var image = await GetByIdAsync(imageId, cancellationToken);
        if (image == null) return false;

        // If setting as main, remove main status from other images in the same property/unit
        if (isMain)
        {
            if (image.PropertyId.HasValue)
            {
                var otherMainImages = await _dbSet
                    .Where(pi => pi.PropertyId == image.PropertyId && pi.Id != imageId && (pi.IsMainImage || pi.IsMain))
                    .ToListAsync(cancellationToken);

                foreach (var otherImage in otherMainImages)
                {
                    otherImage.IsMainImage = false;
                    otherImage.IsMain = false;
                    otherImage.UpdatedAt = DateTime.UtcNow;
                }
            }

            if (image.UnitId.HasValue)
            {
                var otherMainImages = await _dbSet
                    .Where(pi => pi.UnitId == image.UnitId && pi.Id != imageId && (pi.IsMainImage || pi.IsMain))
                    .ToListAsync(cancellationToken);

                foreach (var otherImage in otherMainImages)
                {
                    otherImage.IsMainImage = false;
                    otherImage.IsMain = false;
                    otherImage.UpdatedAt = DateTime.UtcNow;
                }
            }

            if (!string.IsNullOrWhiteSpace(image.CityName))
            {
                var otherMainImages = await _dbSet
                    .Where(pi => pi.CityName == image.CityName && pi.Id != imageId && (pi.IsMainImage || pi.IsMain))
                    .ToListAsync(cancellationToken);

                foreach (var otherImage in otherMainImages)
                {
                    otherImage.IsMainImage = false;
                    otherImage.IsMain = false;
                    otherImage.UpdatedAt = DateTime.UtcNow;
                }
            }
        }

        image.IsMainImage = isMain;
        image.IsMain = isMain;
        image.UpdatedAt = DateTime.UtcNow;

        // Also persist the main image reference into parent tables if columns exist
        try
        {
            if (image.PropertyId.HasValue)
            {
                // Try set FK column if present
                await _context.Database.ExecuteSqlRawAsync(
                    "UPDATE Properties SET ImageId = {0} WHERE PropertyId = {1}",
                    image.Id, image.PropertyId.Value);
                // Try set URL column if present (ignore if it doesn't exist)
                await _context.Database.ExecuteSqlRawAsync(
                    "BEGIN TRY UPDATE Properties SET MainImageUrl = {0} WHERE PropertyId = {1} END TRY BEGIN CATCH END",
                    image.Url, image.PropertyId.Value);
            }
            if (image.UnitId.HasValue)
            {
                await _context.Database.ExecuteSqlRawAsync(
                    "BEGIN TRY UPDATE Units SET ImageId = {0} WHERE UnitId = {1} END TRY BEGIN CATCH END",
                    image.Id, image.UnitId.Value);
                await _context.Database.ExecuteSqlRawAsync(
                    "BEGIN TRY UPDATE Units SET MainImageUrl = {0} WHERE UnitId = {1} END TRY BEGIN CATCH END",
                    image.Url, image.UnitId.Value);
            }
            if (!string.IsNullOrWhiteSpace(image.CityName))
            {
                await _context.Database.ExecuteSqlRawAsync(
                    "BEGIN TRY UPDATE Cities SET ImagesJson = ImagesJson WHERE Name = {0} END TRY BEGIN CATCH END",
                    image.CityName);
            }
        }
        catch
        {
            // Best-effort: if columns don't exist, ignore
        }
        return true;
    }

    /// <summary>
    /// Retrieves images that match the provided paths.
    /// يسترجع الصور المطابقة للمسارات المقدمة.
    /// </summary>
    public async Task<IEnumerable<PropertyImage>> GetImagesByPathAsync(IEnumerable<string> paths, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(pi => paths.Contains(pi.Url))
            .ToListAsync(cancellationToken);
    }

    /// <summary>
    /// Retrieves images associated with the specified temporary key.
    /// يسترجع الصور المرتبطة بالمفتاح المؤقت المحدد.
    /// </summary>
    public async Task<IEnumerable<PropertyImage>> GetImagesByTempKeyAsync(string tempKey, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(pi => pi.TempKey == tempKey && !pi.IsDeleted)
            .OrderBy(pi => pi.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    /// <summary>
    /// Updates image display orders in bulk.
    /// يحدّث ترتيبات عرض الصور دفعة واحدة.
    /// </summary>
    public async Task<bool> UpdateDisplayOrdersAsync(IEnumerable<(Guid imageId, int displayOrder)> assignments, CancellationToken cancellationToken = default)
    {
        // Stage the new ordering and let the caller persist the batch explicitly.
        // جهّز الترتيب الجديد ودع المستدعي ينفذ الحفظ صراحةً.
        // Minimize round-trips and reduce lock time: load all once, then update
        var ids = assignments.Select(a => a.imageId).ToList();
        var images = await _dbSet
            .Where(pi => ids.Contains(pi.Id))
            .ToListAsync(cancellationToken);

        var orderLookup = assignments.ToDictionary(a => a.imageId, a => a.displayOrder);
        foreach (var img in images)
        {
            if (orderLookup.TryGetValue(img.Id, out var newOrder))
            {
                img.DisplayOrder = newOrder;
                img.UpdatedAt = DateTime.UtcNow;
            }
        }
        return true;
    }
}
