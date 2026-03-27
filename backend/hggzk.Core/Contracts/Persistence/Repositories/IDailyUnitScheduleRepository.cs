namespace YemenBooking.Core.Interfaces.Repositories;

using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;

/// <summary>
/// واجهة مستودع اليومية الوحدة الجدول repository.
/// Daily unit schedule repository repository interface.
/// </summary>
public interface IDailyUnitScheduleRepository : IRepository<DailyUnitSchedule>
{
    /// <summary>
    /// يجلب العنصر حسب الوحدة and التاريخ range.
    /// Gets the item by unit and date range.
    /// </summary>
    /// <param name="unitId">معرف الوحدة</param>
    /// <param name="startDate">تاريخ البداية</param>
    /// <param name="endDate">تاريخ النهاية</param>
    /// <returns>قائمة الجداول اليومية</returns>
    Task<IEnumerable<DailyUnitSchedule>> GetByUnitAndDateRangeAsync(
        Guid unitId, 
        DateTime startDate, 
        DateTime endDate);

    /// <summary>
    /// يجلب العنصر حسب الوحدة and التاريخ.
    /// Gets the item by unit and date.
    /// </summary>
    /// <param name="unitId">معرف الوحدة</param>
    /// <param name="date">التاريخ</param>
    /// <returns>الجدول اليومي أو null</returns>
    Task<DailyUnitSchedule?> GetByUnitAndDateAsync(Guid unitId, DateTime date);

    /// <summary>
    /// ينفذ عملية جماعية على insert.
    /// Performs a bulk operation on insert.
    /// </summary>
    /// <param name="schedules">قائمة الجداول اليومية</param>
    Task BulkInsertAsync(IEnumerable<DailyUnitSchedule> schedules);

    /// <summary>
    /// ينفذ عملية جماعية على التحديث.
    /// Performs a bulk operation on update.
    /// </summary>
    /// <param name="schedules">قائمة الجداول اليومية للتحديث</param>
    Task BulkUpdateAsync(IEnumerable<DailyUnitSchedule> schedules);

    /// <summary>
    /// يحذف range.
    /// Deletes range.
    /// </summary>
    /// <param name="unitId">معرف الوحدة</param>
    /// <param name="startDate">تاريخ البداية</param>
    /// <param name="endDate">تاريخ النهاية</param>
    Task DeleteRangeAsync(Guid unitId, DateTime startDate, DateTime endDate);

    /// <summary>
    /// يجلب المتاحة days.
    /// Gets available days.
    /// </summary>
    /// <param name="unitId">معرف الوحدة</param>
    /// <param name="startDate">تاريخ البداية</param>
    /// <param name="endDate">تاريخ النهاية</param>
    /// <returns>قائمة الجداول اليومية المتاحة</returns>
    Task<IEnumerable<DailyUnitSchedule>> GetAvailableDaysAsync(
        Guid unitId, 
        DateTime startDate, 
        DateTime endDate);

    /// <summary>
    /// ينفذ is الوحدة المتاحة.
    /// Performs is unit available.
    /// </summary>
    /// <param name="unitId">معرف الوحدة</param>
    /// <param name="startDate">تاريخ البداية</param>
    /// <param name="endDate">تاريخ النهاية</param>
    /// <returns>true إذا كانت متاحة بالكامل، false خلاف ذلك</returns>
    Task<bool> IsUnitAvailableAsync(Guid unitId, DateTime startDate, DateTime endDate);

    /// <summary>
    /// يجلب pricing لـ period.
    /// Gets pricing for period.
    /// </summary>
    /// <param name="unitId">معرف الوحدة</param>
    /// <param name="startDate">تاريخ البداية</param>
    /// <param name="endDate">تاريخ النهاية</param>
    /// <returns>قائمة الجداول اليومية مع الأسعار</returns>
    Task<IEnumerable<DailyUnitSchedule>> GetPricingForPeriodAsync(
        Guid unitId, 
        DateTime startDate, 
        DateTime endDate);

    /// <summary>
    /// يجلب العنصر حسب الحجز المعرّف.
    /// Gets the item by booking id.
    /// </summary>
    /// <param name="bookingId">معرف الحجز</param>
    /// <returns>قائمة الجداول اليومية</returns>
    Task<IEnumerable<DailyUnitSchedule>> GetByBookingIdAsync(Guid bookingId);

    /// <summary>
    /// يحفظ التغييرات المعلقة.
    /// Saves pending changes.
    /// </summary>
    Task SaveChangesAsync();

    /// <summary>
    /// ينفذ عملية جماعية على create.
    /// Performs a bulk operation on create.
    /// </summary>
    /// <param name="schedules">قائمة الجداول اليومية</param>
    Task BulkCreateAsync(IEnumerable<DailyUnitSchedule> schedules);
}
