using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;
using YemenBooking.Core.ValueObjects;
using YemenBooking.Core.Enums;

namespace YemenBooking.Infrastructure.Repositories.Bookings
{
/// <summary>
/// يمثل مستودعًا للوصول إلى الحجوزات.
/// Represents a repository for accessing bookings.
/// </summary>
    public class BookingRepository : BaseRepository<Booking>, IBookingRepository
    {
/// <summary>
/// ينشئ المستودع مع سياق قاعدة البيانات المشترك.
/// Creates the repository with the shared database context.
/// </summary>
        public BookingRepository(YemenBookingDbContext context) : base(context) { }

/// <summary>
/// ينشئ سجلًا جديدًا في المستودع.
/// Creates a new record in the repository.
/// </summary>
        public async Task<Booking> CreateBookingAsync(Booking booking, CancellationToken cancellationToken = default)
        {
            await _dbSet.AddAsync(booking, cancellationToken);
            return booking;
        }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<Booking?> GetBookingByIdAsync(Guid bookingId, CancellationToken cancellationToken = default)
            => await _dbSet.FirstOrDefaultAsync(b => b.Id == bookingId, cancellationToken);

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<Booking?> GetBookingWithUserAsync(Guid bookingId, CancellationToken cancellationToken = default)
            => await _dbSet
                .Include(b => b.User)
                .FirstOrDefaultAsync(b => b.Id == bookingId, cancellationToken);

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<Booking?> GetBookingWithUnitAsync(Guid bookingId, CancellationToken cancellationToken = default)
            => await _dbSet
                .Include(b => b.Unit)
                .ThenInclude(u => u.Property)
                .FirstOrDefaultAsync(b => b.Id == bookingId, cancellationToken);

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<Booking?> GetBookingWithServicesAsync(Guid bookingId, CancellationToken cancellationToken = default)
            => await _dbSet
                .Include(b => b.BookingServices)
                .ThenInclude(bs => bs.Service)
                .FirstOrDefaultAsync(b => b.Id == bookingId, cancellationToken);

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<Booking?> GetBookingWithPaymentsAsync(Guid bookingId, CancellationToken cancellationToken = default)
            => await _dbSet
                .Include(b => b.Payments)
                .FirstOrDefaultAsync(b => b.Id == bookingId, cancellationToken);

/// <summary>
/// يحدّث السجل المطلوب في المستودع.
/// Updates the requested record in the repository.
/// </summary>
        public Task<Booking> UpdateBookingAsync(Booking booking, CancellationToken cancellationToken = default)
        {
            return Task.FromResult(TrackForUpdate(_dbSet, booking));
        }

/// <summary>
/// ينفذ العملية المطلوبة على البيانات المخزنة.
/// Performs the requested operation on the persisted data.
/// </summary>
        public async Task<bool> ConfirmBookingAsync(Guid bookingId, CancellationToken cancellationToken = default)
        {
            var booking = await GetBookingByIdAsync(bookingId, cancellationToken);
            if (booking == null) return false;
            booking.Status = BookingStatus.Confirmed;
            TrackForUpdate(_dbSet, booking);
            return true;
        }

/// <summary>
/// ينفذ العملية المطلوبة على البيانات المخزنة.
/// Performs the requested operation on the persisted data.
/// </summary>
        public async Task<bool> CancelBookingAsync(Guid bookingId, string reason, CancellationToken cancellationToken = default)
        {
            var booking = await GetBookingByIdAsync(bookingId, cancellationToken);
            if (booking == null) return false;
            booking.Status = BookingStatus.Cancelled;
            booking.CancellationReason = reason;
            TrackForUpdate(_dbSet, booking);
            return true;
        }

/// <summary>
/// ينفذ العملية المطلوبة على البيانات المخزنة.
/// Performs the requested operation on the persisted data.
/// </summary>
        public async Task<bool> CompleteBookingAsync(Guid bookingId, CancellationToken cancellationToken = default)
        {
            var booking = await GetBookingByIdAsync(bookingId, cancellationToken);
            if (booking == null) return false;
            booking.Status = BookingStatus.Completed;
            TrackForUpdate(_dbSet, booking);
            return true;
        }

/// <summary>
/// ينفذ العملية المطلوبة على البيانات المخزنة.
/// Performs the requested operation on the persisted data.
/// </summary>
        public async Task<bool> CheckActiveBookingsAsync(Guid unitId, CancellationToken cancellationToken = default)
            => await _dbSet.AnyAsync(b => b.UnitId == unitId && b.Status == BookingStatus.Confirmed, cancellationToken);

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<IEnumerable<Booking>> GetConflictingBookingsAsync(Guid unitId, DateTime checkIn, DateTime checkOut, CancellationToken cancellationToken = default)
            => await _dbSet
                .Where(b => b.UnitId == unitId &&
                            (b.Status == BookingStatus.Pending || b.Status == BookingStatus.Confirmed) &&
                            !(b.CheckOut <= checkIn || b.CheckIn >= checkOut))
                .ToListAsync(cancellationToken);

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<IEnumerable<Booking>> GetBookingsByUserAsync(Guid userId, CancellationToken cancellationToken = default)
            => await _dbSet.Where(b => b.UserId == userId).ToListAsync(cancellationToken);

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<IEnumerable<Booking>> GetBookingsByPropertyAsync(Guid propertyId, DateTime? fromDate = null, DateTime? toDate = null, CancellationToken cancellationToken = default)
        {
            var query = _dbSet
                .Include(b => b.Unit)
                .Where(b => b.Unit.PropertyId == propertyId);
            if (fromDate.HasValue) query = query.Where(b => b.CheckIn >= fromDate.Value);
            if (toDate.HasValue) query = query.Where(b => b.CheckOut <= toDate.Value);
            return await query.ToListAsync(cancellationToken);
        }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<IEnumerable<Booking>> GetBookingsByUnitAsync(Guid unitId, DateTime? fromDate = null, DateTime? toDate = null, CancellationToken cancellationToken = default)
        {
            var query = _dbSet.Where(b => b.UnitId == unitId);
            if (fromDate.HasValue) query = query.Where(b => b.CheckIn >= fromDate.Value);
            if (toDate.HasValue) query = query.Where(b => b.CheckOut <= toDate.Value);
            return await query.ToListAsync(cancellationToken);
        }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<IEnumerable<Booking>> GetBookingsByStatusAsync(BookingStatus status, CancellationToken cancellationToken = default)
            => await _dbSet.Where(b => b.Status == status).ToListAsync(cancellationToken);

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<IEnumerable<Booking>> GetBookingsByDateRangeAsync(DateTime fromDate, DateTime toDate, CancellationToken cancellationToken = default)
            => await _dbSet.Where(b => b.CheckIn >= fromDate && b.CheckOut <= toDate).ToListAsync(cancellationToken);

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<IEnumerable<BookingService>> GetBookingServicesAsync(Guid bookingId, CancellationToken cancellationToken = default)
            => await _context.Set<BookingService>().Where(bs => bs.BookingId == bookingId).ToListAsync(cancellationToken);

/// <summary>
/// يضيف السجل المطلوب إلى المستودع.
/// Adds the requested record to the repository.
/// </summary>
        public async Task<bool> AddServiceToBookingAsync(Guid bookingId, Guid serviceId, int quantity = 1, CancellationToken cancellationToken = default)
        {
            var entity = new BookingService { BookingId = bookingId, ServiceId = serviceId, Quantity = quantity };
            await _context.Set<BookingService>().AddAsync(entity, cancellationToken);
            return true;
        }

/// <summary>
/// يزيل السجل المطلوب من المستودع.
/// Removes the requested record from the repository.
/// </summary>
        public async Task<bool> RemoveServiceFromBookingAsync(Guid bookingId, Guid serviceId, CancellationToken cancellationToken = default)
        {
            var entity = await _context.Set<BookingService>().FirstOrDefaultAsync(bs => bs.BookingId == bookingId && bs.ServiceId == serviceId, cancellationToken);
            if (entity == null) return false;
            _context.Set<BookingService>().Remove(entity);
            return true;
        }

/// <summary>
/// ينفذ العملية المطلوبة على البيانات المخزنة.
/// Performs the requested operation on the persisted data.
/// </summary>
        public async Task<decimal> RecalculatePriceAsync(Guid bookingId, CancellationToken cancellationToken = default)
        {
            var booking = await GetBookingByIdAsync(bookingId, cancellationToken);
            if (booking == null) return 0m;
            return booking.TotalPrice.Amount;
        }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<int> GetTotalBookingsCountAsync(Guid? propertyId, DateTime fromDate, DateTime toDate, CancellationToken cancellationToken = default)
        {
            var query = GetPagedAsync(1, int.MaxValue, b => (!propertyId.HasValue || b.Unit.PropertyId == propertyId.Value) && b.BookedAt >= fromDate && b.BookedAt <= toDate, null, true, cancellationToken);
            return (await query).TotalCount;
        }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<decimal> GetTotalRevenueAsync(Guid? propertyId, DateTime fromDate, DateTime toDate, CancellationToken cancellationToken = default)
        {
            var bookings = await GetBookingsByDateRangeAsync(fromDate, toDate, cancellationToken);
            return bookings.Where(b => !propertyId.HasValue || b.Unit.PropertyId == propertyId.Value).Sum(b => b.TotalPrice.Amount);
        }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<IEnumerable<Booking>> GetUpcomingCheckInsAsync(Guid propertyId, int days, CancellationToken cancellationToken = default)
        {
            var today = DateTime.UtcNow.Date;
            var target = today.AddDays(days);
            return await _dbSet.Where(b => b.Unit.PropertyId == propertyId && b.CheckIn >= today && b.CheckIn <= target).ToListAsync(cancellationToken);
        }

        /// <summary>
        /// جلب أول تاريخ حجز لكل مستخدم
        /// </summary>
        public async Task<Dictionary<Guid, DateTime>> GetFirstBookingDateForUsersAsync(IEnumerable<Guid> userIds, CancellationToken cancellationToken = default)
        {
            return await _dbSet
                .Where(b => userIds.Contains(b.UserId))
                .GroupBy(b => b.UserId)
                .Select(g => new { UserId = g.Key, Date = g.Min(b => b.BookedAt) })
                .ToDictionaryAsync(x => x.UserId, x => x.Date, cancellationToken);
        }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<decimal> GetTotalCommissionAsync(DateTime startDate, DateTime endDate, CancellationToken cancellationToken = default)
        {
            return await _dbSet
                .Where(b => b.BookedAt >= startDate && b.BookedAt <= endDate)
                .SumAsync(b => b.PlatformCommissionAmount, cancellationToken);
        }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<IEnumerable<CancellationReasonSummary>> GetCancellationReasonsSummaryAsync(DateTime startDate, DateTime endDate, CancellationToken cancellationToken = default)
            => await _dbSet
                .Where(b => b.CancellationReason != null && b.BookedAt >= startDate && b.BookedAt <= endDate)
                .GroupBy(b => b.CancellationReason)
                .Select(g => new CancellationReasonSummary { Reason = g.Key!, Count = g.Count() })
                .ToListAsync(cancellationToken);
    }
} 
