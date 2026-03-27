using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;
using YemenBooking.Core.Enums;
using System.Linq.Expressions;

namespace YemenBooking.Infrastructure.Repositories.Units
{
    /// <summary>
    /// مستودع الوحدات.
    /// Unit repository.
    /// </summary>
    public class UnitRepository : BaseRepository<Unit>, IUnitRepository
    {
        /// <summary>
        /// ينشئ مثيلاً جديداً من UnitRepository.
        /// Initializes a new instance of UnitRepository.
        /// </summary>
        public UnitRepository(YemenBookingDbContext context) : base(context) { }

        /// <summary>
        /// ينشئ وحدة جديدة.
        /// Creates a new unit.
        /// </summary>
        public async Task<Unit> CreateUnitAsync(Unit unit, CancellationToken cancellationToken = default)
        {
            await _dbSet.AddAsync(unit, cancellationToken);
            return unit;
        }

        /// <summary>
        /// يجلب الوحدة حسب المعرف.
        /// Gets the unit by identifier.
        /// </summary>
        public async Task<Unit?> GetUnitByIdAsync(Guid unitId, CancellationToken cancellationToken = default)
            => await _dbSet.FindAsync(new object[] { unitId }, cancellationToken);

        /// <summary>
        /// يجلب الوحدة مع بياناتها المرتبطة.
        /// Gets the unit with its related data.
        /// </summary>
        public async Task<Unit?> GetByIdWithRelatedDataAsync(Guid unitId, CancellationToken cancellationToken = default)
        {
            // الحصول على الوحدة مع البيانات المرتبطة (الحقول الديناميكية، الجداول اليومية)
            return await _dbSet
                .Include(u => u.FieldValues)
                    .ThenInclude(fv => fv.UnitTypeField)
                .Include(u => u.Property)
                .Include(u => u.UnitType)
                .FirstOrDefaultAsync(u => u.Id == unitId, cancellationToken);
        }

        /// <summary>
        /// يحدّث الوحدة.
        /// Updates the unit.
        /// </summary>
        public async Task<Unit> UpdateUnitAsync(Unit unit, CancellationToken cancellationToken = default)
        {
            return TrackForUpdate(_dbSet, unit);
        }

        /// <summary>
        /// يحذف الوحدة.
        /// Deletes the unit.
        /// </summary>
        public async Task<bool> DeleteUnitAsync(Guid unitId, CancellationToken cancellationToken = default)
        {
            var unit = await GetUnitByIdAsync(unitId, cancellationToken);
            if (unit == null) return false;
            _dbSet.Remove(unit);
            return true;
        }

        /// <summary>
        /// يجلب الوحدات حسب العقار.
        /// Gets units by property.
        /// </summary>
        public async Task<IEnumerable<Unit>> GetUnitsByPropertyAsync(Guid propertyId, CancellationToken cancellationToken = default)
            => await _dbSet
                .AsNoTracking()
                .Where(u => u.PropertyId == propertyId && !u.IsDeleted)
                .ToListAsync(cancellationToken);

        /// <summary>
        /// يجلب الوحدات المتاحة للعقار ضمن الفترة المحددة.
        /// Gets available units for the property within the specified period.
        /// </summary>
        public async Task<IEnumerable<Unit>> GetAvailableUnitsAsync(Guid propertyId, DateTime checkIn, DateTime checkOut, int guestCount, CancellationToken cancellationToken = default)
        {
            var units = await GetUnitsByPropertyAsync(propertyId, cancellationToken);
            var result = new List<Unit>();
            foreach (var u in units)
            {
                var overlapping = await _context.Bookings.AnyAsync(b => b.UnitId == u.Id && b.CheckIn < checkOut && b.CheckOut > checkIn, cancellationToken);
                if (!overlapping) result.Add(u);
            }
            return result;
        }

        /// <summary>
        /// يجلب الوحدات حسب النوع.
        /// Gets units by type.
        /// </summary>
        public async Task<IEnumerable<Unit>> GetUnitsByTypeAsync(Guid unitTypeId, CancellationToken cancellationToken = default)
            => await _dbSet.Where(u => u.UnitTypeId == unitTypeId).ToListAsync(cancellationToken);

        /// <summary>
        /// يجلب الوحدات النشطة للعقار المحدد.
        /// Gets active units for the specified property.
        /// </summary>
        public async Task<IEnumerable<Unit>> GetActiveByPropertyIdAsync(Guid propertyId, CancellationToken cancellationToken = default)
            => await _dbSet.Where(u => u.PropertyId == propertyId && !u.IsDeleted).ToListAsync(cancellationToken);

        /// <summary>
        /// يجلب العقار حسب المعرف.
        /// Gets the property by identifier.
        /// </summary>
        public async Task<Property?> GetPropertyByIdAsync(Guid propertyId, CancellationToken cancellationToken = default)
            => await _context.Set<Property>().FirstOrDefaultAsync(p => p.Id == propertyId, cancellationToken);

        /// <summary>
        /// يجلب نوع الوحدة حسب المعرف.
        /// Gets the unit type by identifier.
        /// </summary>
        public async Task<UnitType?> GetUnitTypeByIdAsync(Guid unitTypeId, CancellationToken cancellationToken = default)
            => await _context.Set<UnitType>().FirstOrDefaultAsync(ut => ut.Id == unitTypeId, cancellationToken);

        /// <summary>
        /// يحدّث التوفر للفترة المحددة.
        /// Updates availability for the specified period.
        /// </summary>
        public async Task<bool> UpdateAvailabilityAsync(Guid unitId, DateTime fromDate, DateTime toDate, bool isAvailable, CancellationToken cancellationToken = default)
        {
            // ملاحظة: تم حذف IsAvailable - نستخدم DailyUnitSchedule بدلاً منه
            // تحديث حالة التوفر في الجدول اليومي
            var unit = await GetUnitByIdAsync(unitId, cancellationToken);
            if (unit == null) return false;

            // تحديث الجداول اليومية للفترة المحددة
            for (var date = fromDate.Date; date <= toDate.Date; date = date.AddDays(1))
            {
                var schedule = await _context.Set<DailyUnitSchedule>()
                    .FirstOrDefaultAsync(s => s.UnitId == unitId && s.Date.Date == date, cancellationToken);

                if (schedule == null)
                {
                    // إنشاء جدول جديد
                    schedule = new DailyUnitSchedule
                    {
                        UnitId = unitId,
                        Date = date,
                        Status = isAvailable ? "Available" : "Blocked",
                        CreatedAt = DateTime.UtcNow
                    };
                    await _context.Set<DailyUnitSchedule>().AddAsync(schedule, cancellationToken);
                }
                else
                {
                    // تحديث الجدول الموجود
                    schedule.Status = isAvailable ? "Available" : "Blocked";
                    schedule.UpdatedAt = DateTime.UtcNow;
                }
            }

            return true;
        }

        /// <summary>
        /// يتحقق من وجود حجوزات نشطة للوحدة.
        /// Checks whether the unit has active bookings.
        /// </summary>
        public async Task<bool> CheckActiveBookingsAsync(Guid unitId, CancellationToken cancellationToken = default)
            => await _context.Bookings.AnyAsync(b => b.UnitId == unitId && b.Status == BookingStatus.Confirmed, cancellationToken);

        /// <summary>
        /// يتحقق من وجود أي حجوزات للوحدة.
        /// Checks whether the unit has any bookings.
        /// </summary>
        public async Task<bool> HasAnyBookingsAsync(Guid unitId, CancellationToken cancellationToken = default)
        {
            return await _context.Bookings.AnyAsync(b => b.UnitId == unitId, cancellationToken);
        }

        /// <summary>
        /// يتحقق من وجود أي مدفوعات مرتبطة بحجوزات الوحدة.
        /// Checks whether the unit has any payments linked to its bookings.
        /// </summary>
        public async Task<bool> HasAnyPaymentsAsync(Guid unitId, CancellationToken cancellationToken = default)
        {
            return await _context.Payments
                .Include(p => p.Booking)
                .AnyAsync(p => p.Booking.UnitId == unitId, cancellationToken);
        }

        /// <summary>
        /// يجلب حالة توفر الوحدة للفترة المحددة.
        /// Gets the unit availability for the specified period.
        /// </summary>
        public async Task<IDictionary<DateTime, bool>> GetUnitAvailabilityAsync(Guid unitId, DateTime fromDate, DateTime toDate, CancellationToken cancellationToken = default)
        {
            var dict = new Dictionary<DateTime, bool>();
            for (var date = fromDate.Date; date <= toDate.Date; date = date.AddDays(1))
            {
                var overlapping = await _context.Bookings.AnyAsync(b => b.UnitId == unitId && b.CheckIn <= date && b.CheckOut > date, cancellationToken);
                dict[date] = !overlapping;
            }
            return dict;
        }

        /// <summary>
        /// يجلب الكيان مع العلاقات المحددة.
        /// Gets the entity with the specified includes.
        /// </summary>
        public async Task<Unit> GetByIdWithIncludesAsync(Guid id, params Expression<Func<Unit, object>>[] includes)
        {
            IQueryable<Unit> query = _dbSet;

            foreach (var include in includes)
            {
                query = query.Include(include);
            }

            return await query.FirstOrDefaultAsync(u => u.Id == id && !u.IsDeleted);
        }

        /// <summary>
        /// يجلب الوحدة مع نوعها.
        /// Gets the unit with its type.
        /// </summary>
        public async Task<Unit> GetByIdWithUnitTypeAsync(Guid id)
        {
            return await _dbSet
                .Include(u => u.UnitType)
                .FirstOrDefaultAsync(u => u.Id == id && !u.IsDeleted);
        }
        


    }
} 
