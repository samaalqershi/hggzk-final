using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;
namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع العقار in القسم الصورة repository.
/// Property in section image repository repository interface.
/// </summary>
public interface IPropertyInSectionImageRepository
{
    /// <summary>
    /// ينشئ .
    /// Creates .
    /// </summary>
    Task<PropertyInSectionImage> CreateAsync(PropertyInSectionImage image, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب العنصر حسب المعرّف.
    /// Gets the item by id.
    /// </summary>
    Task<PropertyInSectionImage?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    /// <summary>
    /// يعيد مصدر استعلام قابلًا للتجميع.
    /// Returns a queryable source.
    /// </summary>
    IQueryable<PropertyInSectionImage> GetQueryable();
    /// <summary>
    /// يحدّث .
    /// Updates .
    /// </summary>
    Task<PropertyInSectionImage> UpdateAsync(PropertyInSectionImage image, CancellationToken cancellationToken = default);
    /// <summary>
    /// يحذف .
    /// Deletes .
    /// </summary>
    Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب العنصر حسب العقار in القسم المعرّف.
    /// Gets the item by property in section id.
    /// </summary>
    Task<IEnumerable<PropertyInSectionImage>> GetByPropertyInSectionIdAsync(Guid propertyInSectionId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يحدّث العرض orders.
    /// Updates display orders.
    /// </summary>
    Task<bool> UpdateDisplayOrdersAsync(IEnumerable<(Guid imageId, int displayOrder)> assignments, CancellationToken cancellationToken = default);
    /// <summary>
    /// يحدّث الرئيسية الصورة status.
    /// Updates main image status.
    /// </summary>
    Task<bool> UpdateMainImageStatusAsync(Guid imageId, bool isMain, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحفظ التغييرات المعلقة.
    /// Saves pending changes.
    /// </summary>
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
