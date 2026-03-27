// Core contracts for unit-level indexing.
// العقود الأساسية للفهرسة على مستوى الوحدة.
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Core.Indexing.Models;

namespace YemenBooking.Application.Features.SearchAndFilters.Services;

/// <summary>
/// Unit-level indexing contract used by the search subsystem.
/// عقد الفهرسة على مستوى الوحدة المستخدم من طبقة البحث.
/// </summary>
public interface IUnitIndexingService
{
    #region Unit Operations | عمليات الوحدة

    /// <summary>Indexes a single unit and its related data. يفهرس وحدة واحدة وبياناتها المرتبطة.</summary>
    Task<bool> OnUnitCreatedAsync(Guid unitId, CancellationToken cancellationToken = default);

    /// <summary>Refreshes a unit index entry. يحدّث سجل فهرسة لوحدة.</summary>
    Task<bool> OnUnitUpdatedAsync(Guid unitId, CancellationToken cancellationToken = default);

    /// <summary>Removes a unit index entry. يحذف سجل فهرسة لوحدة.</summary>
    Task<bool> OnUnitDeletedAsync(Guid unitId, Guid propertyId, CancellationToken cancellationToken = default);

    #endregion

    #region Unit Type Operations | عمليات نوع الوحدة

    /// <summary>Reindexes units after a unit type is deleted. يعيد فهرسة الوحدات بعد حذف نوع وحدة.</summary>
    Task<int> OnUnitTypeDeletedAsync(Guid unitTypeId, CancellationToken cancellationToken = default);

    /// <summary>Updates a dynamic field across affected units. يحدّث حقلاً ديناميكياً عبر الوحدات المتأثرة.</summary>
    Task<int> OnUnitTypeFieldUpdatedAsync(string oldFieldName, string newFieldName, string newFieldType, bool isPrimary, Guid unitTypeId, CancellationToken cancellationToken = default);

    /// <summary>Removes a dynamic field across affected units. يحذف حقلاً ديناميكياً عبر الوحدات المتأثرة.</summary>
    Task<int> OnUnitTypeFieldDeletedAsync(string fieldName, Guid unitTypeId, CancellationToken cancellationToken = default);

    #endregion

    #region Property Operations | عمليات العقار

    /// <summary>Indexes all units for a property. يفهرس جميع وحدات عقار معيّن.</summary>
    Task<int> OnPropertyCreatedAsync(Guid propertyId, CancellationToken cancellationToken = default);

    /// <summary>Refreshes property data across its units. يحدّث بيانات العقار داخل جميع وحداته.</summary>
    Task<int> OnPropertyUpdatedAsync(Guid propertyId, CancellationToken cancellationToken = default);

    /// <summary>Removes all units of a property from the index. يحذف جميع وحدات العقار من الفهرس.</summary>
    Task<int> OnPropertyDeletedAsync(Guid propertyId, CancellationToken cancellationToken = default);

    #endregion

    #region Availability and Pricing | الإتاحة والتسعير

    /// <summary>Updates unit availability data. يحدّث بيانات الإتاحة للوحدة.</summary>
    Task<bool> OnAvailabilityChangedAsync(Guid unitId, CancellationToken cancellationToken = default);

    /// <summary>Updates unit daily schedule and pricing. يحدّث الجدول اليومي وتسعير الوحدة.</summary>
    Task<bool> OnDailyScheduleChangedAsync(Guid unitId, CancellationToken cancellationToken = default);

    #endregion

    #region Search Operations | عمليات البحث

    /// <summary>Searches for units using the current index. يبحث عن الوحدات باستخدام الفهرس الحالي.</summary>
    Task<UnitSearchResult> SearchUnitsAsync(UnitSearchRequest request, CancellationToken cancellationToken = default);

    /// <summary>Searches for properties and returns matching units. يبحث عن العقارات ويعيد الوحدات المطابقة.</summary>
    Task<PropertyWithUnitsSearchResult> SearchPropertiesWithUnitsAsync(PropertyWithUnitsSearchRequest request, CancellationToken cancellationToken = default);

    #endregion

    #region Maintenance | الصيانة

    /// <summary>Rebuilds a single unit index. يعيد بناء فهرس وحدة واحدة.</summary>
    Task<bool> RebuildUnitIndexAsync(Guid unitId, CancellationToken cancellationToken = default);

    /// <summary>Rebuilds all unit indexes for a property. يعيد بناء جميع فهارس وحدات عقار.</summary>
    Task<int> RebuildPropertyUnitsIndexAsync(Guid propertyId, CancellationToken cancellationToken = default);

    /// <summary>Rebuilds all unit indexes. يعيد بناء جميع فهارس الوحدات.</summary>
    Task<int> RebuildAllIndexesAsync(int batchSize = 100, CancellationToken cancellationToken = default);

    /// <summary>Cleans stale or orphaned index data. ينظّف بيانات الفهرس القديمة أو اليتيمة.</summary>
    Task<int> CleanupIndexesAsync(CancellationToken cancellationToken = default);

    #endregion

    #region Statistics | الإحصائيات

    /// <summary>Returns index statistics for monitoring and diagnostics. يعيد إحصائيات الفهرس للمراقبة والتشخيص.</summary>
    Task<Dictionary<string, object>> GetIndexStatisticsAsync(CancellationToken cancellationToken = default);

    #endregion
}
