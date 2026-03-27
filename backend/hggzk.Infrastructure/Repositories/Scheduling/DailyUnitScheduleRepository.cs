namespace YemenBooking.Infrastructure.Repositories.Scheduling;

using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

/// <summary>
/// Provides persistence operations and scheduling queries for daily unit schedules.
/// يوفّر عمليات الحفظ واستعلامات الجدولة الخاصة بجداول الوحدات اليومية.
/// </summary>
public class DailyUnitScheduleRepository : BaseRepository<DailyUnitSchedule>, IDailyUnitScheduleRepository
{
    /// <summary>
    /// يهيئ مثيلاً جديدًا من DailyUnitScheduleRepository باستخدام سياق قاعدة البيانات المشترك.
    /// Initializes a new instance of DailyUnitScheduleRepository with the shared database context.
    /// </summary>
    public DailyUnitScheduleRepository(YemenBookingDbContext context) : base(context)
    {
    }

    /// <summary>
    /// Retrieves daily unit schedules for the specified unit and date range.
    /// يسترجع جداول الوحدة اليومية للوحدة ونطاق التاريخ المحددين.
    /// </summary>
    public async Task<IEnumerable<DailyUnitSchedule>> GetByUnitAndDateRangeAsync(
        Guid unitId, 
        DateTime startDate, 
        DateTime endDate)
    {
        // Normalize dates to date-only values.
        // تحويل التواريخ إلى قيم تاريخ فقط.
        var start = startDate.Date;
        var end = endDate.Date;

        return await _context.DailyUnitSchedules
            .Where(s => s.UnitId == unitId && s.Date >= start && s.Date <= end)
            .Include(s => s.Booking)
            .OrderBy(s => s.Date)
            .ToListAsync();
    }

    /// <summary>
    /// Retrieves the daily unit schedule for the specified unit and date.
    /// يسترجع جدول الوحدة اليومي للوحدة والتاريخ المحددين.
    /// </summary>
    public async Task<DailyUnitSchedule?> GetByUnitAndDateAsync(Guid unitId, DateTime date)
    {
        var dateOnly = date.Date;
        
        return await _context.DailyUnitSchedules
            .FirstOrDefaultAsync(s => s.UnitId == unitId && s.Date == dateOnly);
    }

    /// <summary>
    /// Inserts multiple daily unit schedules in one operation.
    /// يدرج عدة جداول وحدات يومية في عملية واحدة.
    /// </summary>
    public async Task BulkInsertAsync(IEnumerable<DailyUnitSchedule> schedules)
    {
        if (schedules == null || !schedules.Any())
            return;

        await _context.DailyUnitSchedules.AddRangeAsync(schedules);
    }

    /// <summary>
    /// Updates multiple daily unit schedules in one operation.
    /// يحدّث عدة جداول وحدات يومية في عملية واحدة.
    /// </summary>
    public Task BulkUpdateAsync(IEnumerable<DailyUnitSchedule> schedules)
    {
        if (schedules == null || !schedules.Any())
            return Task.CompletedTask;

        foreach (var schedule in schedules)
        {
            TrackForUpdate(_context.DailyUnitSchedules, schedule);
        }
        return Task.CompletedTask;
    }

    /// <summary>
    /// Deletes daily unit schedules within the specified date range.
    /// يحذف جداول الوحدات اليومية ضمن نطاق التاريخ المحدد.
    /// </summary>
    public async Task DeleteRangeAsync(Guid unitId, DateTime startDate, DateTime endDate)
    {
        var start = startDate.Date;
        var end = endDate.Date;

        var schedulesToDelete = await _context.DailyUnitSchedules
            .Where(s => s.UnitId == unitId && s.Date >= start && s.Date <= end)
            .ToListAsync();

        if (schedulesToDelete.Any())
        {
            _context.DailyUnitSchedules.RemoveRange(schedulesToDelete);
        }
    }

    /// <summary>
    /// Retrieves the available days for the specified unit and date range.
    /// يسترجع الأيام المتاحة للوحدة ونطاق التاريخ المحددين.
    /// </summary>
    public async Task<IEnumerable<DailyUnitSchedule>> GetAvailableDaysAsync(
        Guid unitId, 
        DateTime startDate, 
        DateTime endDate)
    {
        var start = startDate.Date;
        var end = endDate.Date;

        return await _context.DailyUnitSchedules
            .Where(s => s.UnitId == unitId 
                     && s.Date >= start 
                     && s.Date <= end
                     && s.Status == "Available")
            .OrderBy(s => s.Date)
            .ToListAsync();
    }

    /// <summary>
    /// Retrieves the booked days for the specified unit and date range.
    /// يسترجع الأيام المحجوزة للوحدة ونطاق التاريخ المحددين.
    /// </summary>
    public async Task<IEnumerable<DailyUnitSchedule>> GetBookedDaysAsync(
        Guid unitId, 
        DateTime startDate, 
        DateTime endDate)
    {
        var start = startDate.Date;
        var end = endDate.Date;

        return await _context.DailyUnitSchedules
            .Where(s => s.UnitId == unitId 
                     && s.Date >= start 
                     && s.Date <= end
                     && s.Status == "Booked")
            .OrderBy(s => s.Date)
            .Include(s => s.Booking)
            .ToListAsync();
    }

    /// <summary>
    /// Checks whether the unit is available for the requested period.
    /// يتحقق مما إذا كانت الوحدة متاحة للفترة المطلوبة.
    /// </summary>
    public async Task<bool> IsUnitAvailableAsync(Guid unitId, DateTime startDate, DateTime endDate)
    {
        var start = startDate.Date;
        var end = endDate.Date;

        // Count the requested days.
        // حساب عدد الأيام المطلوبة.
        var totalDays = (end - start).Days + 1;

        // Count the available days.
        // حساب عدد الأيام المتاحة.
        var availableDays = await _context.DailyUnitSchedules
            .CountAsync(s => s.UnitId == unitId 
                          && s.Date >= start 
                          && s.Date <= end
                          && s.Status == "Available");

        // Treat missing rows as available by default.
        // إذا لم توجد سجلات، نفترض أن الوحدة متاحة.
        if (availableDays == 0)
        {
            var hasAnyRecords = await _context.DailyUnitSchedules
                .AnyAsync(s => s.UnitId == unitId && s.Date >= start && s.Date <= end);
            
            return !hasAnyRecords; // Available if no records exist at all. / متاح إذا لم توجد سجلات على الإطلاق.
        }

        return availableDays == totalDays;
    }

    /// <summary>
    /// Retrieves pricing records for the requested period.
    /// يسترجع سجلات التسعير للفترة المطلوبة.
    /// </summary>
    public async Task<IEnumerable<DailyUnitSchedule>> GetPricingForPeriodAsync(
        Guid unitId, 
        DateTime startDate, 
        DateTime endDate)
    {
        var start = startDate.Date;
        var end = endDate.Date;

        return await _context.DailyUnitSchedules
            .Where(s => s.UnitId == unitId 
                     && s.Date >= start 
                     && s.Date <= end
                     && s.PriceAmount.HasValue)
            .OrderBy(s => s.Date)
            .ToListAsync();
    }

    /// <summary>
    /// Counts the available days for the specified unit and date range.
    /// يعدّ الأيام المتاحة للوحدة ونطاق التاريخ المحددين.
    /// </summary>
    public async Task<int> CountAvailableDaysAsync(Guid unitId, DateTime startDate, DateTime endDate)
    {
        var start = startDate.Date;
        var end = endDate.Date;

        return await _context.DailyUnitSchedules
            .CountAsync(s => s.UnitId == unitId 
                          && s.Date >= start 
                          && s.Date <= end
                          && s.Status == "Available");
    }

    /// <summary>
    /// Retrieves daily schedules linked to the specified booking.
    /// يسترجع الجداول اليومية المرتبطة بالحجز المحدد.
    /// </summary>
    public async Task<IEnumerable<DailyUnitSchedule>> GetByBookingIdAsync(Guid bookingId)
    {
        return await _context.DailyUnitSchedules
            .Where(s => s.BookingId == bookingId)
            .OrderBy(s => s.Date)
            .ToListAsync();
    }

    /// <summary>
    /// Persists the pending changes to the database.
    /// يحفظ التغييرات المعلّقة في قاعدة البيانات.
    /// </summary>
    public async Task SaveChangesAsync()
    {
        await _context.SaveChangesAsync();
    }

    /// <summary>
    /// Creates multiple daily unit schedules in one operation.
    /// ينشئ عدة جداول وحدات يومية في عملية واحدة.
    /// </summary>
    public async Task BulkCreateAsync(IEnumerable<DailyUnitSchedule> schedules)
    {
        if (schedules == null || !schedules.Any())
            return;

        await _context.DailyUnitSchedules.AddRangeAsync(schedules);
    }
}
