using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع القسم repository.
/// Section repository repository interface.
/// </summary>
public interface ISectionRepository
{
    /// <summary>
    /// يجلب العنصر حسب المعرّف.
    /// Gets the item by id.
    /// </summary>
    Task<Section?> GetByIdAsync(Guid sectionId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب جميع .
    /// Gets all .
    /// </summary>
    Task<IEnumerable<Section>> GetAllAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// ينفذ find.
    /// Performs find.
    /// </summary>
    Task<IEnumerable<Section>> FindAsync(System.Linq.Expressions.Expression<Func<Section, bool>> predicate, CancellationToken cancellationToken = default);

	/// <summary>
	/// ينشئ .
	/// Creates .
	/// </summary>
	Task<Section> CreateAsync(Section section, CancellationToken cancellationToken = default);
	/// <summary>
	/// يحدّث .
	/// Updates .
	/// </summary>
	Task<Section> UpdateAsync(Section section, CancellationToken cancellationToken = default);
	/// <summary>
	/// يحذف .
	/// Deletes .
	/// </summary>
	Task<bool> DeleteAsync(Guid sectionId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب الأقسام على شكل صفحات مع دعم التصفية حسب الهدف والنوع والمدينة.
    /// Retrieves sections in a paged form with filtering by target, type, and city.
    /// </summary>
    Task<(IEnumerable<Section> Items, int TotalCount)> GetPagedAsync(int pageNumber, int pageSize, SectionTarget? target, SectionType? type, string? cityName, CancellationToken cancellationToken = default);
	/// <summary>
	/// يربط العقارات.
	/// Assigns properties.
	/// </summary>
	Task AssignPropertiesAsync(Guid sectionId, IEnumerable<Guid> propertyIds, CancellationToken cancellationToken = default);
	/// <summary>
	/// يربط الوحدات.
	/// Assigns units.
	/// </summary>
	Task AssignUnitsAsync(Guid sectionId, IEnumerable<Guid> unitIds, CancellationToken cancellationToken = default);
	/// <summary>
	/// يضيف العقارات.
	/// Adds properties.
	/// </summary>
	Task AddPropertiesAsync(Guid sectionId, IEnumerable<Guid> propertyIds, CancellationToken cancellationToken = default);
	/// <summary>
	/// يضيف الوحدات.
	/// Adds units.
	/// </summary>
	Task AddUnitsAsync(Guid sectionId, IEnumerable<Guid> unitIds, CancellationToken cancellationToken = default);
    /// <summary>
    /// يزيل item.
    /// Removes item.
    /// </summary>
    Task RemoveItemAsync(Guid sectionId, Guid itemId, CancellationToken cancellationToken = default);
	/// <summary>
	/// ينفذ reorder items.
	/// Performs reorder items.
	/// </summary>
	Task ReorderItemsAsync(Guid sectionId, IReadOnlyList<(Guid ItemId, int SortOrder)> orders, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحفظ التغييرات المعلقة.
    /// Saves pending changes.
    /// </summary>
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);

    // Rich content
    /// <summary>
    /// يجلب العقار items.
    /// Gets property items.
    /// </summary>
    Task<IEnumerable<PropertyInSection>> GetPropertyItemsAsync(Guid sectionId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يجلب الوحدة items.
    /// Gets unit items.
    /// </summary>
    Task<IEnumerable<UnitInSection>> GetUnitItemsAsync(Guid sectionId, CancellationToken cancellationToken = default);
    /// <summary>
    /// يربط العقار items.
    /// Assigns property items.
    /// </summary>
    Task AssignPropertyItemsAsync(Guid sectionId, IEnumerable<PropertyInSection> items, CancellationToken cancellationToken = default);
    /// <summary>
    /// يربط الوحدة items.
    /// Assigns unit items.
    /// </summary>
    Task AssignUnitItemsAsync(Guid sectionId, IEnumerable<UnitInSection> items, CancellationToken cancellationToken = default);
}
