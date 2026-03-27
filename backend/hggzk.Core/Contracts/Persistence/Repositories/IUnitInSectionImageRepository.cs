using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;
namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع الوحدة in القسم الصورة repository.
/// Unit in section image repository repository interface.
/// </summary>
public interface IUnitInSectionImageRepository
{
    /// <summary>
    /// ينشئ .
    /// Creates .
    /// </summary>
    Task<UnitInSectionImage> CreateAsync(UnitInSectionImage image, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب العنصر حسب المعرّف.
    /// Gets the item by id.
    /// </summary>
    Task<UnitInSectionImage?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    /// <summary>
    /// يعيد مصدر استعلام قابلًا للتجميع.
    /// Returns a queryable source.
    /// </summary>
    IQueryable<UnitInSectionImage> GetQueryable();
    /// <summary>
    /// يحدّث .
    /// Updates .
    /// </summary>
    Task<UnitInSectionImage> UpdateAsync(UnitInSectionImage image, CancellationToken cancellationToken = default);
    /// <summary>
    /// يحذف .
    /// Deletes .
    /// </summary>
    Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب العنصر حسب الوحدة in القسم المعرّف.
    /// Gets the item by unit in section id.
    /// </summary>
    Task<IEnumerable<UnitInSectionImage>> GetByUnitInSectionIdAsync(Guid unitInSectionId, CancellationToken cancellationToken = default);
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
    /// <param name="cancellationToken">رمز الإلغاء / Cancellation token.</param>
    /// <returns>عدد السجلات المتأثرة / Number of affected records.</returns>
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
