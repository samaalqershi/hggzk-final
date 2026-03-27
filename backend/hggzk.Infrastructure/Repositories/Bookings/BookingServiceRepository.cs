using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Bookings
{
/// <summary>
/// يمثل مستودعًا للوصول إلى خدمات الحجز.
/// Represents a repository for accessing booking services.
/// </summary>
    public class BookingServiceRepository : BaseRepository<BookingService>, IBookingServiceRepository
    {
/// <summary>
/// ينشئ المستودع مع سياق قاعدة البيانات المشترك.
/// Creates the repository with the shared database context.
/// </summary>
        public BookingServiceRepository(YemenBookingDbContext context) : base(context) { }

/// <summary>
/// يضيف السجل المطلوب إلى المستودع.
/// Adds the requested record to the repository.
/// </summary>
        public async Task<BookingService> AddServiceToBookingAsync(BookingService bookingService, CancellationToken cancellationToken = default)
        {
            await _dbSet.AddAsync(bookingService, cancellationToken);
            return bookingService;
        }

/// <summary>
/// يزيل السجل المطلوب من المستودع.
/// Removes the requested record from the repository.
/// </summary>
        public async Task<bool> RemoveServiceFromBookingAsync(Guid bookingId, Guid serviceId, CancellationToken cancellationToken = default)
        {
            var bs = await _dbSet.FirstOrDefaultAsync(b => b.BookingId == bookingId && b.ServiceId == serviceId, cancellationToken);
            if (bs == null) return false;
            _dbSet.Remove(bs);
            return true;
        }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<IEnumerable<BookingService>> GetBookingServicesAsync(Guid bookingId, CancellationToken cancellationToken = default)
            => await _dbSet
                .Include(bs => bs.Service)
                .Where(bs => bs.BookingId == bookingId)
                .ToListAsync(cancellationToken);

/// <summary>
/// يحدّث السجل المطلوب في المستودع.
/// Updates the requested record in the repository.
/// </summary>
        public Task<BookingService> UpdateBookingServiceAsync(BookingService bookingService, CancellationToken cancellationToken = default)
        {
            return Task.FromResult(TrackForUpdate(_dbSet, bookingService));
        }
    }
} 
