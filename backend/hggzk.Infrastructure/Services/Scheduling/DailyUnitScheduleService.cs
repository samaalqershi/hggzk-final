namespace YemenBooking.Infrastructure.Services.Scheduling;

using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// Provides daily pricing and availability operations for unit schedules.
/// يوفر عمليات التسعير والتوفر اليومية لجداول الوحدات.
/// </summary>
public class DailyUnitScheduleService : IDailyUnitScheduleService
{
    private readonly IDailyUnitScheduleRepository _scheduleRepository;
    private readonly ILogger<DailyUnitScheduleService> _logger;

    /// <summary>
    /// Initializes the daily schedule service with repository access and logging.
    /// يهيئ خدمة الجدول اليومي مع الوصول إلى المستودع وتسجيل الأحداث.
    /// </summary>
    public DailyUnitScheduleService(
        IDailyUnitScheduleRepository scheduleRepository,
        ILogger<DailyUnitScheduleService> logger)
    {
        _scheduleRepository = scheduleRepository;
        _logger = logger;
    }

    /// <summary>
    /// Sets pricing for a date range by materializing daily schedule records.
    /// يضبط التسعير لفترة زمنية عبر تحويلها إلى سجلات يومية.
    /// </summary>
    public async Task<int> SetPricingForPeriodAsync(
        Guid unitId,
        DateTime startDate,
        DateTime endDate,
        decimal priceAmount,
        string currency,
        string? priceType = null,
        string? pricingTier = null,
        decimal? percentageChange = null,
        decimal? minPrice = null,
        decimal? maxPrice = null,
        bool overwriteExisting = false,
        string? createdBy = null)
    {
        try
        {
            var start = startDate.Date;
            var end = endDate.Date;

            // Load the existing daily schedule records for the requested range.
            // حمّل سجلات الجدول اليومي الموجودة للفترة المطلوبة.
            var existingSchedules = (await _scheduleRepository.GetByUnitAndDateRangeAsync(unitId, start, end))
                .ToDictionary(s => s.Date);

            var schedulesToCreate = new List<DailyUnitSchedule>();
            var schedulesToUpdate = new List<DailyUnitSchedule>();

            // Create daily schedule records for the target range.
            // أنشئ سجلات يومية للفترة المستهدفة.
            for (var date = start; date <= end; date = date.AddDays(1))
            {
                if (existingSchedules.TryGetValue(date, out var existingSchedule))
                {
                    // Update the existing record when overwriting is allowed or pricing is still missing.
                    // حدّث السجل الموجود عند السماح بالاستبدال أو عند غياب التسعير.
                    if (overwriteExisting || !existingSchedule.PriceAmount.HasValue)
                    {
                        existingSchedule.PriceAmount = priceAmount;
                        existingSchedule.Currency = currency;
                        existingSchedule.PriceType = priceType;
                        existingSchedule.PricingTier = pricingTier;
                        existingSchedule.PercentageChange = percentageChange;
                        existingSchedule.MinPrice = minPrice;
                        existingSchedule.MaxPrice = maxPrice;
                        existingSchedule.ModifiedBy = createdBy;
                        existingSchedule.UpdatedAt = DateTime.UtcNow;
                        
                        schedulesToUpdate.Add(existingSchedule);
                    }
                }
                else
                {
                    // Create a new daily schedule record for dates with no existing entry.
                    // أنشئ سجلًا يوميًا جديدًا للتواريخ التي لا تملك إدخالًا سابقًا.
                    var newSchedule = new DailyUnitSchedule
                    {
                        Id = Guid.NewGuid(),
                        UnitId = unitId,
                        Date = date,
                        Status = "Available", // Default status. / الحالة الافتراضية.
                        PriceAmount = priceAmount,
                        Currency = currency,
                        PriceType = priceType,
                        PricingTier = pricingTier,
                        PercentageChange = percentageChange,
                        MinPrice = minPrice,
                        MaxPrice = maxPrice,
                        CreatedBy = createdBy,
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    };

                    schedulesToCreate.Add(newSchedule);
                }
            }

            // Persist all accumulated changes in bulk operations.
            // احفظ جميع التغييرات المتراكمة عبر عمليات مجمعة.
            if (schedulesToCreate.Any())
            {
                await _scheduleRepository.BulkInsertAsync(schedulesToCreate);
            }

            if (schedulesToUpdate.Any())
            {
                await _scheduleRepository.BulkUpdateAsync(schedulesToUpdate);
            }

            await _scheduleRepository.SaveChangesAsync();

            _logger.LogInformation(
                "Set pricing for unit {UnitId} from {StartDate} to {EndDate}. Created: {Created}, Updated: {Updated}",
                unitId, start, end, schedulesToCreate.Count, schedulesToUpdate.Count);

            return schedulesToCreate.Count + schedulesToUpdate.Count;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error setting pricing for unit {UnitId}", unitId);
            throw;
        }
    }

    /// <summary>
    /// Sets availability state for a date range by materializing daily schedule records.
    /// يضبط حالة الإتاحة لفترة زمنية عبر تحويلها إلى سجلات يومية.
    /// </summary>
    public async Task<int> SetAvailabilityForPeriodAsync(
        Guid unitId,
        DateTime startDate,
        DateTime endDate,
        string status,
        string? reason = null,
        string? notes = null,
        Guid? bookingId = null,
        bool overwriteExisting = false,
        string? createdBy = null)
    {
        try
        {
            var start = startDate.Date;
            var end = endDate.Date;

            var existingSchedules = (await _scheduleRepository.GetByUnitAndDateRangeAsync(unitId, start, end))
                .ToDictionary(s => s.Date);

            var schedulesToCreate = new List<DailyUnitSchedule>();
            var schedulesToUpdate = new List<DailyUnitSchedule>();

            for (var date = start; date <= end; date = date.AddDays(1))
            {
                if (existingSchedules.TryGetValue(date, out var existingSchedule))
                {
                    if (overwriteExisting)
                    {
                        existingSchedule.Status = status;
                        existingSchedule.Reason = reason;
                        existingSchedule.Notes = notes;
                        existingSchedule.BookingId = bookingId;
                        existingSchedule.ModifiedBy = createdBy;
                        existingSchedule.UpdatedAt = DateTime.UtcNow;

                        schedulesToUpdate.Add(existingSchedule);
                    }
                }
                else
                {
                    var newSchedule = new DailyUnitSchedule
                    {
                        Id = Guid.NewGuid(),
                        UnitId = unitId,
                        Date = date,
                        Status = status,
                        Reason = reason,
                        Notes = notes,
                        BookingId = bookingId,
                        CreatedBy = createdBy,
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    };

                    schedulesToCreate.Add(newSchedule);
                }
            }

            if (schedulesToCreate.Any())
            {
                await _scheduleRepository.BulkInsertAsync(schedulesToCreate);
            }

            if (schedulesToUpdate.Any())
            {
                await _scheduleRepository.BulkUpdateAsync(schedulesToUpdate);
            }

            await _scheduleRepository.SaveChangesAsync();

            _logger.LogInformation(
                "Set availability for unit {UnitId} from {StartDate} to {EndDate} as {Status}. Created: {Created}, Updated: {Updated}",
                unitId, start, end, status, schedulesToCreate.Count, schedulesToUpdate.Count);

            return schedulesToCreate.Count + schedulesToUpdate.Count;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error setting availability for unit {UnitId}", unitId);
            throw;
        }
    }

    /// <summary>
    /// Returns daily schedule entries for a unit within the requested period.
    /// يعيد سجلات الجدول اليومي للوحدة ضمن الفترة المطلوبة.
    /// </summary>
    public async Task<IEnumerable<DailyUnitSchedule>> GetScheduleForPeriodAsync(
        Guid unitId,
        DateTime startDate,
        DateTime endDate,
        bool includeUnit = false,
        bool includeBooking = false)
    {
        return await _scheduleRepository.GetByUnitAndDateRangeAsync(unitId, startDate.Date, endDate.Date);
    }

    /// <summary>
    /// Checks whether a unit is available for the requested date range.
    /// يتحقق مما إذا كانت الوحدة متاحة للفترة الزمنية المطلوبة.
    /// </summary>
    public async Task<AvailabilityCheckResult> CheckAvailabilityAsync(
        Guid unitId,
        DateTime startDate,
        DateTime endDate,
        Guid? excludeBookingId = null)
    {
        var start = startDate.Date;
        var end = endDate.Date;
        var totalDays = (end - start).Days + 1;

        var schedules = await _scheduleRepository.GetByUnitAndDateRangeAsync(unitId, start, end);
        var schedulesDict = schedules.ToDictionary(s => s.Date);

        var unavailableDates = new List<DateTime>();
        var availableDays = 0;

        for (var date = start; date <= end; date = date.AddDays(1))
        {
            if (schedulesDict.TryGetValue(date, out var schedule))
            {
                // A day is considered available when it is explicitly available
                // or booked by the same excluded booking.
                // يُعد اليوم متاحًا إذا كان متاحًا صراحةً
                // أو محجوزًا لنفس الحجز المستثنى.
                if (schedule.Status == "Available" || (excludeBookingId != null && schedule.BookingId == excludeBookingId))
                {
                    availableDays++;
                }
                else
                {
                    unavailableDates.Add(date);
                }
            }
            else
            {
                // If no record exists for the day, treat it as available.
                // إذا لم يوجد سجل لليوم، فاعتبره متاحًا.
                availableDays++;
            }
        }

        var isAvailable = availableDays == totalDays;
        var unavailableDays = totalDays - availableDays;

        return new AvailabilityCheckResult
        {
            IsAvailable = isAvailable,
            TotalDays = totalDays,
            AvailableDays = availableDays,
            UnavailableDays = unavailableDays,
            UnavailableDates = unavailableDates,
            Message = isAvailable 
                ? "الوحدة متاحة للفترة المحددة" 
                : $"الوحدة غير متاحة في {unavailableDays} يوم/أيام"
        };
    }

    /// <summary>
    /// Calculates total pricing for a period using daily overrides when present.
    /// يحسب السعر الإجمالي لفترة زمنية باستخدام التجاوزات اليومية عند وجودها.
    /// </summary>
    public async Task<PricingCalculationResult> CalculatePriceForPeriodAsync(
        Guid unitId,
        DateTime startDate,
        DateTime endDate,
        decimal basePriceAmount,
        string baseCurrency)
    {
        var start = startDate.Date;
        var end = endDate.Date;
        var totalDays = (end - start).Days + 1;

        var schedules = await _scheduleRepository.GetByUnitAndDateRangeAsync(unitId, start, end);
        var schedulesDict = schedules.ToDictionary(s => s.Date);

        decimal totalPrice = 0;
        var daysWithCustomPricing = 0;
        var dailyPrices = new List<DailyPriceInfo>();

        for (var date = start; date <= end; date = date.AddDays(1))
        {
            decimal dayPrice;
            string? priceType = null;
            bool isCustomPrice;

            if (schedulesDict.TryGetValue(date, out var schedule) && schedule.PriceAmount.HasValue)
            {
                dayPrice = schedule.PriceAmount.Value;
                priceType = schedule.PriceType;
                isCustomPrice = true;
                daysWithCustomPricing++;
            }
            else
            {
                dayPrice = basePriceAmount;
                isCustomPrice = false;
            }

            totalPrice += dayPrice;
            dailyPrices.Add(new DailyPriceInfo
            {
                Date = date,
                Price = dayPrice,
                PriceType = priceType,
                IsCustomPrice = isCustomPrice
            });
        }

        var daysWithBasePrice = totalDays - daysWithCustomPricing;
        var averagePerDay = totalDays > 0 ? totalPrice / totalDays : 0;

        return new PricingCalculationResult
        {
            TotalPrice = totalPrice,
            Currency = baseCurrency,
            TotalDays = totalDays,
            DaysWithCustomPricing = daysWithCustomPricing,
            DaysWithBasePrice = daysWithBasePrice,
            AveragePerDay = averagePerDay,
            DailyPrices = dailyPrices
        };
    }

    /// <summary>
    /// Deletes all schedule entries for a unit within the specified period.
    /// يحذف جميع سجلات الجدول الخاصة بوحدة ضمن الفترة المحددة.
    /// </summary>
    public async Task DeleteScheduleForPeriodAsync(Guid unitId, DateTime startDate, DateTime endDate)
    {
        await _scheduleRepository.DeleteRangeAsync(unitId, startDate.Date, endDate.Date);
        await _scheduleRepository.SaveChangesAsync();
        _logger.LogInformation("Deleted schedule for unit {UnitId} from {StartDate} to {EndDate}", 
            unitId, startDate.Date, endDate.Date);
    }

    /// <summary>
    /// Updates selected fields on a single daily schedule record.
    /// يحدّث حقولًا محددة في سجل جدول يومي واحد.
    /// </summary>
    public async Task<DailyUnitSchedule?> UpdateDailyScheduleAsync(
        Guid scheduleId,
        decimal? priceAmount = null,
        string? status = null,
        string? reason = null,
        string? notes = null,
        string? modifiedBy = null)
    {
        var schedule = await _scheduleRepository.GetByIdAsync(scheduleId);
        if (schedule == null)
        {
            _logger.LogWarning("Schedule {ScheduleId} not found", scheduleId);
            return null;
        }

        if (priceAmount.HasValue)
            schedule.PriceAmount = priceAmount;

        if (!string.IsNullOrEmpty(status))
            schedule.Status = status;

        if (reason != null)
            schedule.Reason = reason;

        if (notes != null)
            schedule.Notes = notes;

        schedule.ModifiedBy = modifiedBy;
        schedule.UpdatedAt = DateTime.UtcNow;

        await _scheduleRepository.UpdateAsync(schedule);
        await _scheduleRepository.SaveChangesAsync();

        _logger.LogInformation("Updated schedule {ScheduleId} for unit {UnitId} on {Date}",
            scheduleId, schedule.UnitId, schedule.Date);

        return schedule;
    }

    /// <summary>
    /// Creates or updates the daily schedule for a specific unit date.
    /// ينشئ أو يحدّث الجدول اليومي لتاريخ محدد للوحدة.
    /// </summary>
    public async Task<DailyUnitSchedule> UpsertDailyScheduleAsync(
        Guid unitId,
        DateTime date,
        DailyUnitSchedule schedule)
    {
        var dateOnly = date.Date;
        var existing = await _scheduleRepository.GetByUnitAndDateAsync(unitId, dateOnly);

        if (existing != null)
        {
            // Update the existing record for the same unit and date.
            // حدّث السجل الموجود لنفس الوحدة والتاريخ.
            existing.Status = schedule.Status;
            existing.PriceAmount = schedule.PriceAmount;
            existing.Currency = schedule.Currency;
            existing.PriceType = schedule.PriceType;
            existing.PricingTier = schedule.PricingTier;
            existing.PercentageChange = schedule.PercentageChange;
            existing.MinPrice = schedule.MinPrice;
            existing.MaxPrice = schedule.MaxPrice;
            existing.Reason = schedule.Reason;
            existing.Notes = schedule.Notes;
            existing.BookingId = schedule.BookingId;
            existing.ModifiedBy = schedule.ModifiedBy;
            existing.UpdatedAt = DateTime.UtcNow;

            await _scheduleRepository.UpdateAsync(existing);
            await _scheduleRepository.SaveChangesAsync();
            return existing;
        }
        else
        {
            // Create a new record when no schedule exists for the date.
            // أنشئ سجلًا جديدًا عند عدم وجود جدول لهذا التاريخ.
            schedule.Id = Guid.NewGuid();
            schedule.UnitId = unitId;
            schedule.Date = dateOnly;
            schedule.CreatedAt = DateTime.UtcNow;
            schedule.UpdatedAt = DateTime.UtcNow;

            await _scheduleRepository.AddAsync(schedule);
            await _scheduleRepository.SaveChangesAsync();
            return schedule;
        }
    }
}
