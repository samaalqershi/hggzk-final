using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;
using YemenBooking.Core.Enums;

namespace YemenBooking.Infrastructure.Repositories.Bookings
{
/// <summary>
/// يمثل مستودعًا للوصول إلى المدفوعات.
/// Represents a repository for accessing payments.
/// </summary>
    public class PaymentRepository : BaseRepository<Payment>, IPaymentRepository
    {
/// <summary>
/// ينشئ المستودع مع سياق قاعدة البيانات المشترك.
/// Creates the repository with the shared database context.
/// </summary>
        public PaymentRepository(YemenBookingDbContext context) : base(context) { }

/// <summary>
/// يعالج العملية المطلوبة ويحدّث الحالة المخزنة.
/// Processes the requested operation and updates the persisted state.
/// </summary>
        public async Task<Payment> ProcessPaymentAsync(Payment payment, CancellationToken cancellationToken = default)
        {
            await _dbSet.AddAsync(payment, cancellationToken);
            return payment;
        }

/// <summary>
/// يحدّث السجل المطلوب في المستودع.
/// Updates the requested record in the repository.
/// </summary>
        public async Task<Payment> UpdatePaymentAsync(Payment payment, CancellationToken cancellationToken = default)
        {
            return TrackForUpdate(_dbSet, payment);
        }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<IEnumerable<Payment>> GetPaymentsByBookingAsync(Guid bookingId, CancellationToken cancellationToken = default)
            => await _dbSet.Where(p => p.BookingId == bookingId).ToListAsync(cancellationToken);

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<IEnumerable<Payment>> GetPaymentsByUserAsync(Guid userId, DateTime? fromDate = null, DateTime? toDate = null, CancellationToken cancellationToken = default)
        {
            var query = _dbSet.Include(p => p.Booking).Where(p => p.Booking.UserId == userId);
            if (fromDate.HasValue) query = query.Where(p => p.PaymentDate >= fromDate.Value);
            if (toDate.HasValue) query = query.Where(p => p.PaymentDate <= toDate.Value);
            return await query.ToListAsync(cancellationToken);
        }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
        public async Task<decimal> GetTotalPaidAmountAsync(Guid bookingId, CancellationToken cancellationToken = default)
        {
            var totals = await _dbSet
                .Where(p => p.BookingId == bookingId)
                .GroupBy(p => 1)
                .Select(g => new
                {
                    Paid = g.Where(p => p.Status == PaymentStatus.Successful || p.Status == PaymentStatus.PartiallyRefunded)
                              .Sum(p => (decimal?)p.Amount.Amount) ?? 0m,
                    Refunded = g.Where(p => p.Status == PaymentStatus.Refunded)
                                 .Sum(p => (decimal?)p.Amount.Amount) ?? 0m
                })
                .FirstOrDefaultAsync(cancellationToken);

            var netPaid = totals == null ? 0m : totals.Paid - totals.Refunded;
            return netPaid < 0 ? 0 : netPaid;
        }

    }
} 
