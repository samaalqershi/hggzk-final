using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Units.DTOs;
using YemenBooking.Core.Enums;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Units.Queries.GetUnitAnalytics;

/// <summary>
/// يعالج جلب الوحدة التحليلات ويعيد النتيجة المطلوبة.
/// Processes the Get Unit Analytics request and returns the requested result.
/// </summary>
public class GetUnitAnalyticsQueryHandler : IRequestHandler<GetUnitAnalyticsQuery, ResultDto<UnitAnalyticsDto>>
{
    private readonly IUnitRepository _unitRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IPaymentRepository _paymentRepository;
    private readonly IReviewRepository _reviewRepository;
    private readonly IDailyUnitScheduleRepository _dailyUnitScheduleRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<GetUnitAnalyticsQueryHandler> _logger;

    /// <summary>
    /// ينشئ مثيلاً جديداً من GetUnitAnalyticsQueryHandler.
    /// Initializes a new instance of GetUnitAnalyticsQueryHandler.
    /// </summary>
    /// <param name="unitRepository">مستودع الوحدة / unit repository.</param>
    /// <param name="bookingRepository">مستودع الحجز / booking repository.</param>
    /// <param name="paymentRepository">مستودع الدفع / payment repository.</param>
    /// <param name="reviewRepository">مستودع review / review repository.</param>
    /// <param name="dailyUnitScheduleRepository">مستودع اليومي الوحدة الجدول / daily Unit Schedule repository.</param>
    /// <param name="currentUserService">خدمة المستخدم الحالي / Current user service.</param>
    /// <param name="logger">مسجل الأحداث / Logger.</param>
    public GetUnitAnalyticsQueryHandler(
        IUnitRepository unitRepository,
        IBookingRepository bookingRepository,
        IPaymentRepository paymentRepository,
        IReviewRepository reviewRepository,
        IDailyUnitScheduleRepository dailyUnitScheduleRepository,
        ICurrentUserService currentUserService,
        ILogger<GetUnitAnalyticsQueryHandler> logger)
    {
        _unitRepository = unitRepository;
        _bookingRepository = bookingRepository;
        _paymentRepository = paymentRepository;
        _reviewRepository = reviewRepository;
        _dailyUnitScheduleRepository = dailyUnitScheduleRepository;
        _currentUserService = currentUserService;
        _logger = logger;
    }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
    public async Task<ResultDto<UnitAnalyticsDto>> Handle(GetUnitAnalyticsQuery request, CancellationToken cancellationToken)
    {
        try
        {
            if (request.UnitId == Guid.Empty)
            {
                return ResultDto<UnitAnalyticsDto>.Failed("معرف الوحدة مطلوب", "UNIT_ID_REQUIRED");
            }

            var currentUserId = _currentUserService.UserId;
            var role = _currentUserService.Role;
            var accountRole = _currentUserService.AccountRole;

            var isAdmin = string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase)
                          || string.Equals(accountRole, "Admin", StringComparison.OrdinalIgnoreCase)
                          || (_currentUserService.UserRoles?.Any(r => string.Equals(r, "Admin", StringComparison.OrdinalIgnoreCase)) ?? false);

            var unit = await _unitRepository.GetQueryable()
                .AsNoTracking()
                .Include(u => u.Property)
                .FirstOrDefaultAsync(u => u.Id == request.UnitId, cancellationToken);

            if (unit == null)
            {
                return ResultDto<UnitAnalyticsDto>.Failed("الوحدة غير موجودة", "UNIT_NOT_FOUND");
            }

            if (!isAdmin)
            {
                if (unit.Property == null)
                {
                    return ResultDto<UnitAnalyticsDto>.Failed("بيانات العقار غير متاحة", "PROPERTY_NOT_FOUND");
                }

                if (unit.Property.OwnerId != currentUserId)
                {
                    return ResultDto<UnitAnalyticsDto>.Failed("ليس لديك صلاحية لعرض تحليلات هذه الوحدة", "FORBIDDEN");
                }
            }

            var userToday = (await _currentUserService.ConvertFromUtcToUserLocalAsync(DateTime.UtcNow)).Date;
            var fromLocal = (request.FromDate?.Date) ?? userToday.AddDays(-30);
            var toLocal = (request.ToDate?.Date) ?? userToday;
            if (fromLocal > toLocal)
            {
                (fromLocal, toLocal) = (toLocal, fromLocal);
            }

            var fromUtc = await _currentUserService.ConvertFromUserLocalToUtcAsync(fromLocal);
            var toUtcExclusive = await _currentUserService.ConvertFromUserLocalToUtcAsync(toLocal.AddDays(1));

            var bookingsQuery = _bookingRepository.GetQueryable()
                .AsNoTracking()
                .Where(b => b.UnitId == request.UnitId)
                .Where(b => b.BookedAt >= fromUtc && b.BookedAt < toUtcExclusive);

            var totalBookings = await bookingsQuery.CountAsync(cancellationToken);
            var confirmedBookings = await bookingsQuery.Where(b => b.Status == BookingStatus.Confirmed).CountAsync(cancellationToken);
            var completedBookings = await bookingsQuery.Where(b => b.Status == BookingStatus.Completed).CountAsync(cancellationToken);
            var cancelledBookings = await bookingsQuery.Where(b => b.Status == BookingStatus.Cancelled).CountAsync(cancellationToken);

            var paymentsQuery = _paymentRepository.GetQueryable()
                .AsNoTracking()
                .Include(p => p.Booking)
                .Where(p => p.Booking.UnitId == request.UnitId)
                .Where(p => p.PaymentDate >= fromUtc && p.PaymentDate < toUtcExclusive);

            var totalRevenue = await paymentsQuery
                .Where(p => p.Status == PaymentStatus.Successful || p.Status == PaymentStatus.PartiallyRefunded)
                .SumAsync(p => (decimal?)p.Amount.Amount, cancellationToken) ?? 0m;

            var refunded = await paymentsQuery
                .Where(p => p.Status == PaymentStatus.Refunded)
                .SumAsync(p => (decimal?)p.Amount.Amount, cancellationToken) ?? 0m;

            var netRevenue = totalRevenue - refunded;
            if (netRevenue < 0) netRevenue = 0;

            var reviewsQuery = _reviewRepository.GetQueryable()
                .AsNoTracking()
                .Include(r => r.Booking)
                .Where(r => !r.IsDisabled)
                .Where(r => r.Booking.UnitId == request.UnitId)
                .Where(r => r.CreatedAt >= fromUtc && r.CreatedAt < toUtcExclusive);

            var totalReviews = await reviewsQuery.CountAsync(cancellationToken);
            var averageRating = totalReviews == 0
                ? 0.0
                : await reviewsQuery.AverageAsync(r => (double?)r.AverageRating, cancellationToken) ?? 0.0;

            var schedules = (await _dailyUnitScheduleRepository.GetByUnitAndDateRangeAsync(
                request.UnitId,
                fromUtc.Date,
                toUtcExclusive.AddDays(-1).Date)).ToList();

            var totalDays = schedules.Count;
            var bookedDays = schedules.Count(s => string.Equals(s.Status, "Booked", StringComparison.OrdinalIgnoreCase));
            var occupancyRate = totalDays > 0 ? (double)bookedDays / totalDays : 0.0;

            var dto = new UnitAnalyticsDto
            {
                UnitId = unit.Id,
                FromDate = fromLocal,
                ToDate = toLocal,
                Currency = unit.Property?.Currency ?? "YER",
                TotalBookings = totalBookings,
                ConfirmedBookings = confirmedBookings,
                CompletedBookings = completedBookings,
                CancelledBookings = cancelledBookings,
                TotalRevenue = decimal.Round(netRevenue, 2),
                OccupancyRate = occupancyRate,
                TotalDays = totalDays,
                BookedDays = bookedDays,
                AverageRating = averageRating,
                TotalReviews = totalReviews,
                ViewCount = unit.ViewCount,
                BookingCount = unit.BookingCount
            };

            return ResultDto<UnitAnalyticsDto>.Ok(dto, "تم جلب تحليلات الوحدة بنجاح");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب تحليلات الوحدة. UnitId={UnitId}", request.UnitId);
            return ResultDto<UnitAnalyticsDto>.Failed($"حدث خطأ أثناء جلب تحليلات الوحدة: {ex.Message}", "GET_UNIT_ANALYTICS_ERROR");
        }
    }
}
