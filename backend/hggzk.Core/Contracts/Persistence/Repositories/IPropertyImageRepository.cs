using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع العقار الصورة repository.
/// Property image repository repository interface.
/// </summary>
public interface IPropertyImageRepository : IRepository<PropertyImage>
{
    /// <summary>
    /// ينشئ العقار الصورة.
    /// Creates property image.
    /// </summary>
    Task<PropertyImage> CreatePropertyImageAsync(PropertyImage propertyImage, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب العنصر حسب العقار المعرّف.
    /// Gets the item by property id.
    /// </summary>
    Task<IEnumerable<PropertyImage>> GetByPropertyIdAsync(Guid propertyId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب العقار الصورة حسب المعرّف.
    /// Gets property image by id.
    /// </summary>
    Task<PropertyImage?> GetPropertyImageByIdAsync(Guid imageId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث العقار الصورة.
    /// Updates property image.
    /// </summary>
    Task<PropertyImage> UpdatePropertyImageAsync(PropertyImage propertyImage, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحذف العقار الصورة.
    /// Deletes property image.
    /// </summary>
    Task<bool> DeletePropertyImageAsync(Guid imageId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الصور حسب العقار.
    /// Gets images by property.
    /// </summary>
    Task<IEnumerable<PropertyImage>> GetImagesByPropertyAsync(Guid propertyId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الصور حسب الوحدة.
    /// Gets images by unit.
    /// </summary>
    Task<IEnumerable<PropertyImage>> GetImagesByUnitAsync(Guid unitId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث الرئيسية الصورة status.
    /// Updates main image status.
    /// </summary>
    Task<bool> UpdateMainImageStatusAsync(Guid imageId, bool isMain, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الصور حسب path.
    /// Gets images by path.
    /// </summary>
    Task<IEnumerable<PropertyImage>> GetImagesByPathAsync(IEnumerable<string> paths, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب الصور حسب temp key.
    /// Gets images by temp key.
    /// </summary>
    Task<IEnumerable<PropertyImage>> GetImagesByTempKeyAsync(string tempKey, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث العرض orders.
    /// Updates display orders.
    /// </summary>
    Task<bool> UpdateDisplayOrdersAsync(IEnumerable<(Guid imageId, int displayOrder)> assignments, CancellationToken cancellationToken = default);

    /// <summary>
    /// ينفذ hard delete حسب العقار المعرّف.
    /// Performs hard delete by property id.
    /// </summary>
    Task<int> HardDeleteByPropertyIdAsync(Guid propertyId, CancellationToken cancellationToken = default);

    /// <summary>
    /// ينفذ hard delete حسب الوحدة المعرّف.
    /// Performs hard delete by unit id.
    /// </summary>
    Task<int> HardDeleteByUnitIdAsync(Guid unitId, CancellationToken cancellationToken = default);

}
