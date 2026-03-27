using System.Linq;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Features.Units.DTOs;
using YemenBooking.Application.Features.Units.Commands.BulkOperations;
using YemenBooking.Application.Contracts.Services.Scheduling;
using YemenBooking.Core.Interfaces.Repositories;
using Microsoft.Extensions.Logging;

namespace YemenBooking.Infrastructure.Services.Scheduling;

/// <summary>
/// Provides unit availability checks and daily schedule management workflows.
/// يوفر عمليات التحقق من توفر الوحدات وإدارة الجداول اليومية.
/// </summary>
public class AvailabilityService : IAvailabilityService
{
    private readonly IDailyUnitScheduleRepository _scheduleRepository;
    private readonly IUnitRepository _unitRepository;
    private readonly ILogger<AvailabilityService> _logger;

    /// <summary>
    /// Initializes the service with repository dependencies and a logger.
    /// يهيئ الخدمة مع المستودعات المطلوبة ومسجل الأحداث.
    /// </summary>
    public AvailabilityService(
        IDailyUnitScheduleRepository scheduleRepository,
        IUnitRepository unitRepository,
        ILogger<AvailabilityService> logger)
    {
        _scheduleRepository = scheduleRepository;
        _unitRepository = unitRepository;
        _logger = logger;
    }

    /// <summary>
    /// Initializes the service without a logger for backward compatibility.
    /// يهيئ الخدمة بدون مسجل أحداث للحفاظ على التوافق مع الاستخدامات القديمة.
    /// </summary>
    public AvailabilityService(
        IDailyUnitScheduleRepository scheduleRepository,
        IUnitRepository unitRepository)
    {
        _scheduleRepository = scheduleRepository;
        _unitRepository = unitRepository;
        _logger = null!; // Logger remains null here, so calls must stay null-safe. / يظل المسجل فارغًا هنا، لذا يجب أن تبقى الاستدعاءات آمنة مع null.
    }

    /// <summary>
    /// Checks whether a unit is available for the requested stay range.
    /// يتحقق مما إذا كانت الوحدة متاحة لفترة الإقامة المطلوبة.
    /// </summary>
    public async Task<bool> CheckAvailabilityAsync(Guid unitId, DateTime checkIn, DateTime checkOut, Guid? excludeBookingId = null)
    {
        _logger?.LogDebug("التحقق من توفر الوحدة {UnitId} من {CheckIn} إلى {CheckOut}، استثناء الحجز: {ExcludeBookingId}", 
            unitId, checkIn, checkOut, excludeBookingId);
        
        // Check that the unit exists before evaluating its daily schedule.
        // تحقق من وجود الوحدة قبل تقييم جدولها اليومي.
        var unit = await _unitRepository.GetByIdAsync(unitId);
        if (unit == null)
        {
            _logger?.LogWarning("الوحدة {UnitId} غير موجودة", unitId);
            return false;
        }

        var lastOccupiedDate = checkOut.Date > checkIn.Date
            ? checkOut.Date.AddDays(-1)
            : checkIn.Date;
        var schedules = await _scheduleRepository.GetByUnitAndDateRangeAsync(
            unitId,
            checkIn.Date,
            lastOccupiedDate);

        bool isAvailable;
        if (schedules == null || !schedules.Any())
        {
            isAvailable = true;
        }
        else if (excludeBookingId.HasValue)
        {
            // Treat the excluded booking days as available while still blocking overlaps with other bookings or statuses.
            // اعتبر أيام الحجز المستثنى متاحة مع الاستمرار في منع التداخل مع الحجوزات أو الحالات الأخرى.
            isAvailable = schedules.All(s =>
                IsStaleBookedSchedule(s) ||
                s.Status == "Available" ||
                (s.Status == "Booked" && s.BookingId == excludeBookingId));
        }
        else
        {
            isAvailable = schedules.All(s => IsStaleBookedSchedule(s) || s.Status == "Available");
        }
        
        _logger?.LogInformation("نتيجة التحقق من توفر الوحدة {UnitId}: {IsAvailable}", unitId, isAvailable);
        
        return isAvailable;
    }

    /// <summary>
    /// Blocks the requested date range for a booking by creating or updating daily schedule records.
    /// يحجز الفترة المطلوبة لحجز معين عبر إنشاء أو تحديث سجلات الجدول اليومي.
    /// </summary>
    public async Task BlockForBookingAsync(Guid unitId, Guid bookingId, DateTime checkIn, DateTime checkOut)
    {
        // UnitAvailability has been replaced by DailyUnitSchedule.
        // تم استبدال UnitAvailability بـ DailyUnitSchedule.
        // Create daily records for the requested stay range.
        // يتم الآن إنشاء سجلات يومية للفترة المطلوبة.
        var currentDate = checkIn.Date;
        while (currentDate < checkOut.Date)
        {
            var schedule = await _scheduleRepository.GetByUnitAndDateAsync(unitId, currentDate);
            if (schedule == null)
            {
                schedule = new DailyUnitSchedule
                {
                    Id = Guid.NewGuid(),
                    UnitId = unitId,
                    Date = currentDate,
                    Status = "Booked",
                    BookingId = bookingId,
                    Reason = "Customer Booking",
                    CreatedAt = DateTime.UtcNow
                };
                await _scheduleRepository.AddAsync(schedule);
            }
            else if (schedule.Status == "Available")
            {
                schedule.Status = "Booked";
                schedule.BookingId = bookingId;
                schedule.Reason = "Customer Booking";
                schedule.UpdatedAt = DateTime.UtcNow;
                await _scheduleRepository.UpdateAsync(schedule);
            }
            
            currentDate = currentDate.AddDays(1);
        }
        
        await _scheduleRepository.SaveChangesAsync();
    }

    /// <summary>
    /// Releases all daily schedule entries linked to the specified booking.
    /// يحرر جميع سجلات الجدول اليومي المرتبطة بالحجز المحدد.
    /// </summary>
    public async Task ReleaseBookingAsync(Guid bookingId)
    {
        // Update all daily records linked to this booking.
        // حدّث جميع السجلات المرتبطة بهذا الحجز.
        var schedules = await _scheduleRepository.GetByBookingIdAsync(bookingId);
        
        foreach (var schedule in schedules)
        {
            schedule.Status = "Available";
            schedule.BookingId = null;
            schedule.Reason = null;
            schedule.UpdatedAt = DateTime.UtcNow;
            await _scheduleRepository.UpdateAsync(schedule);
        }
        
        await _scheduleRepository.SaveChangesAsync();
    }

    /// <summary>
    /// Returns a day-by-day availability calendar for the requested month.
    /// يعيد تقويم التوفر اليومي للشهر المطلوب.
    /// </summary>
    public async Task<Dictionary<DateTime, string>> GetMonthlyCalendarAsync(Guid unitId, int year, int month)
    {
        var startDate = new DateTime(year, month, 1);
        var endDate = startDate.AddMonths(1).AddDays(-1);
        
        var schedules = await _scheduleRepository.GetByUnitAndDateRangeAsync(unitId, startDate, endDate);
        
        var calendar = new Dictionary<DateTime, string>();
        var currentDate = startDate;
        while (currentDate <= endDate)
        {
            var schedule = schedules?.FirstOrDefault(s => s.Date.Date == currentDate.Date);
            calendar[currentDate] = schedule?.Status ?? "Available";
            currentDate = currentDate.AddDays(1);
        }
        
        return calendar;
    }

    /// <summary>
    /// Applies bulk availability periods by generating daily schedule entries.
    /// يطبق فترات التوفر المجمعة عبر إنشاء سجلات يومية للجدول.
    /// </summary>
    public async Task ApplyBulkAvailabilityAsync(Guid unitId, List<AvailabilityPeriodDto> periods)
    {
        var schedules = new List<DailyUnitSchedule>();

        foreach (var period in periods)
        {
            // Remove existing entries in the range when overwrite is requested.
            // احذف السجلات الموجودة في هذا النطاق عند طلب الاستبدال.
            if (period.OverwriteExisting)
            {
                await _scheduleRepository.DeleteRangeAsync(unitId, period.StartDate, period.EndDate);
            }

            // Create daily records for the requested period.
            // أنشئ سجلات يومية للفترة المطلوبة.
            var currentDate = period.StartDate.Date;
            while (currentDate <= period.EndDate.Date)
            {
                var schedule = new DailyUnitSchedule
                {
                    Id = Guid.NewGuid(),
                    UnitId = unitId,
                    Date = currentDate,
                    Status = period.Status,
                    Reason = period.Reason,
                    Notes = period.Notes,
                    CreatedAt = DateTime.UtcNow
                };

                schedules.Add(schedule);
                currentDate = currentDate.AddDays(1);
            }
        }

        // Persist the generated batch in a single repository call.
        // احفظ الدفعة الناتجة في استدعاء واحد للمستودع.
        await _scheduleRepository.BulkCreateAsync(schedules);
        await _scheduleRepository.SaveChangesAsync();
    }
    
    /// <summary>
    /// Returns the identifiers of units that remain searchable and available for the requested stay range.
    /// يعيد معرّفات الوحدات التي تبقى قابلة للبحث ومتاحة ضمن فترة الإقامة المطلوبة.
    /// </summary>
    public async Task<IEnumerable<Guid>> GetAvailableUnitsInPropertyAsync(Guid propertyId, DateTime checkIn, DateTime checkOut, int guestCount, CancellationToken cancellationToken = default)
    {
        var units = await _unitRepository.GetUnitsByPropertyAsync(propertyId, cancellationToken);
        var available = new List<Guid>();
        foreach (var unit in units)
        {
            // For search and filtering, treat a unit as unavailable only when the days are truly blocked
            // by confirmed/completed/checked-in bookings or explicit blocked days.
            // من أجل البحث والفلترة، اعتبر الوحدة غير متاحة فقط إذا كانت الأيام محجوزة فعليًا
            // بحجوزات مؤكدة أو مكتملة أو CheckedIn أو بأيام Blocked صريحة.
            var lastOccupiedDate = checkOut.Date > checkIn.Date
                ? checkOut.Date.AddDays(-1)
                : checkIn.Date;
            var schedules = await _scheduleRepository.GetByUnitAndDateRangeAsync(unit.Id, checkIn.Date, lastOccupiedDate);

            if (schedules == null || !schedules.Any())
            {
                // No DailyUnitSchedule records exist for the range, so treat the unit as searchable/available.
                // لا توجد سجلات في DailyUnitSchedule للفترة، لذا تُعتبر الوحدة متاحة في البحث.
                available.Add(unit.Id);
                continue;
            }

            var hasBlockingDay = schedules.Any(s =>
                s.Status == "Blocked" ||
                (s.Status == "Booked" &&
                 !IsStaleBookedSchedule(s) &&
                 (
                     s.BookingId == null ||
                     s.Booking == null ||
                     s.Booking.Status is BookingStatus.Confirmed or BookingStatus.Completed or BookingStatus.CheckedIn
                 ))
            );

            if (!hasBlockingDay)
            {
                available.Add(unit.Id);
            }
        }
        return available;
    }

    private static bool IsStaleBookedSchedule(DailyUnitSchedule schedule)
    {
        if (schedule.Status != "Booked" || schedule.BookingId == null || schedule.Booking == null)
        {
            return false;
        }

        var bookingStart = schedule.Booking.CheckIn.Date;
        var bookingEndExclusive = schedule.Booking.CheckOut.Date;
        return schedule.Date < bookingStart || schedule.Date >= bookingEndExclusive;
    }
}
