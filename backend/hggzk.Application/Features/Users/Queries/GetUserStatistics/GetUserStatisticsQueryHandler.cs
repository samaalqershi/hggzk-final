using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Features.Users.DTOs;

namespace YemenBooking.Application.Features.Users.Queries.GetUserStatistics;

/// <summary>
/// معالج إحصائيات المستخدم.
/// user statistics handler.
/// </summary>
public class GetUserStatisticsQueryHandler : IRequestHandler<GetUserStatisticsQuery, ResultDto<UserStatisticsDto>>
{
    private readonly IUserRepository _userRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IReviewRepository _reviewRepository;
    private readonly IFavoriteRepository _favoriteRepository;
    private readonly IPaymentRepository _paymentRepository;
    private readonly ILogger<GetUserStatisticsQueryHandler> _logger;

    /// <summary>
    /// يهيئ هذا المكوّن بالاعتماديات المطلوبة.
    /// Initializes this component with the required dependencies.
    /// </summary>
    /// <param name="userRepository">مستودع المستخدمين. User repository.</param>
    /// <param name="bookingRepository">مستودع الحجوزات. Booking repository.</param>
    /// <param name="reviewRepository">مستودع المراجعات. Review repository.</param>
    /// <param name="favoriteRepository">مستودع المفضلات. Favorites repository.</param>
    /// <param name="paymentRepository">مستودع المدفوعات. Payments repository.</param>
    /// <param name="logger">مسجل الأحداث. Logger.</param>
    public GetUserStatisticsQueryHandler(
        IUserRepository userRepository,
        IBookingRepository bookingRepository,
        IReviewRepository reviewRepository,
        IFavoriteRepository favoriteRepository,
        IPaymentRepository paymentRepository,
        ILogger<GetUserStatisticsQueryHandler> logger)
    {
        _userRepository = userRepository;
        _bookingRepository = bookingRepository;
        _reviewRepository = reviewRepository;
        _favoriteRepository = favoriteRepository;
        _paymentRepository = paymentRepository;
        _logger = logger;
    }

    /// <summary>
    /// ينفذ منطق المعالجة لهذا الطلب.
    /// executes the handling logic for this request.
    /// </summary>
    public async Task<ResultDto<UserStatisticsDto>> Handle(GetUserStatisticsQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء استعلام إحصائيات المستخدم. معرف المستخدم: {UserId}", request.UserId);

            // Ensure that the target user exists.
            var user = await _userRepository.GetByIdAsync(request.UserId, cancellationToken);
            if (user == null)
            {
                _logger.LogWarning("المستخدم غير موجود. معرف المستخدم: {UserId}", request.UserId);
                return ResultDto<UserStatisticsDto>.Failed("المستخدم غير موجود", "USER_NOT_FOUND");
            }

            var statistics = new UserStatisticsDto
            {
                MemberSince = user.CreatedAt
            };

            // Load booking statistics.
            await PopulateBookingStatistics(statistics, request.UserId, cancellationToken);

            // Load review statistics.
            await PopulateReviewStatistics(statistics, request.UserId, cancellationToken);

            // Load favorites statistics.
            await PopulateFavoriteStatistics(statistics, request.UserId, cancellationToken);

            // Load payment statistics.
            await PopulatePaymentStatistics(statistics, request.UserId, cancellationToken);

            // Calculate loyalty tier and points.
            CalculateLoyaltyInfo(statistics);

            _logger.LogInformation("تم جلب إحصائيات المستخدم بنجاح. إجمالي الحجوزات: {TotalBookings}, المراجعات: {ReviewsWritten}, المفضلات: {FavoritePropertiesCount}", 
                statistics.TotalBookings, statistics.ReviewsWritten, statistics.FavoritePropertiesCount);

            return ResultDto<UserStatisticsDto>.Ok(statistics, "تم جلب إحصائيات المستخدم بنجاح");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب إحصائيات المستخدم. معرف المستخدم: {UserId}", request.UserId);
            return ResultDto<UserStatisticsDto>.Failed(
                $"حدث خطأ أثناء جلب إحصائيات المستخدم: {ex.Message}", 
                "GET_USER_STATISTICS_ERROR"
            );
        }
    }

    private async Task PopulateBookingStatistics(UserStatisticsDto statistics, Guid userId, CancellationToken cancellationToken)
    {
        try
        {
            var userBookings = await _bookingRepository.GetByUserIdAsync(userId, cancellationToken);
            
            if (userBookings != null && userBookings.Any())
            {
                statistics.TotalBookings = userBookings.Count();
                statistics.CompletedBookings = userBookings.Count(b => b.Status == BookingStatus.Completed);
                statistics.ActiveBookings = userBookings.Count(b => 
                    b.Status == BookingStatus.Confirmed || 
                    b.Status == BookingStatus.CheckedIn);
                statistics.CancelledBookings = userBookings.Count(b => b.Status == BookingStatus.Cancelled);

                // Count distinct cities visited through completed bookings.
                var visitedCities = userBookings
                    .Where(b => b.Status == BookingStatus.Completed && 
                               b.Unit?.Property != null && 
                               !string.IsNullOrWhiteSpace(b.Unit.Property.City))
                    .Select(b => b.Unit!.Property!.City!)
                    .Distinct()
                    .Count();

                statistics.CitiesVisited = visitedCities;
            }

            _logger.LogDebug("تم جلب إحصائيات الحجوزات. إجمالي: {Total}, مكتملة: {Completed}, نشطة: {Active}, ملغية: {Cancelled}", 
                statistics.TotalBookings, statistics.CompletedBookings, statistics.ActiveBookings, statistics.CancelledBookings);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب إحصائيات الحجوزات للمستخدم: {UserId}", userId);
        }
    }

    private async Task PopulateReviewStatistics(UserStatisticsDto statistics, Guid userId, CancellationToken cancellationToken)
    {
        try
        {
            var userReviews = await _reviewRepository.GetByUserIdAsync(userId, cancellationToken);
            
            if (userReviews != null)
            {
                statistics.ReviewsWritten = userReviews.Count();
            }

            _logger.LogDebug("تم جلب إحصائيات المراجعات. عدد المراجعات: {ReviewsCount}", statistics.ReviewsWritten);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب إحصائيات المراجعات للمستخدم: {UserId}", userId);
        }
    }

    private async Task PopulateFavoriteStatistics(UserStatisticsDto statistics, Guid userId, CancellationToken cancellationToken)
    {
        try
        {
            var userFavorites = await _favoriteRepository.GetByUserIdAsync(userId, cancellationToken);
            
            if (userFavorites != null)
            {
                statistics.FavoritePropertiesCount = userFavorites.Count();
            }

            _logger.LogDebug("تم جلب إحصائيات المفضلات. عدد المفضلات: {FavoritesCount}", statistics.FavoritePropertiesCount);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب إحصائيات المفضلات للمستخدم: {UserId}", userId);
        }
    }

    private async Task PopulatePaymentStatistics(UserStatisticsDto statistics, Guid userId, CancellationToken cancellationToken)
    {
        try
        {
            var allPayments = await _paymentRepository.GetAllAsync(cancellationToken);
            var userPayments = allPayments.Where(p => p.Booking != null && p.Booking.UserId == userId);
            
            if (userPayments.Any())
            {
                // Calculate total spending from successful payments only.
                var completedPayments = userPayments.Where(p => p.Status == Core.Enums.PaymentStatus.Successful);
                
                statistics.TotalSpent = completedPayments.Sum(p => p.Amount.Amount);
                statistics.Currency = completedPayments.FirstOrDefault()?.Amount.Currency ?? "YER";

                // Calculate total savings using a simplified placeholder implementation.
                statistics.TotalSaved = 0; // Will be implemented later once discount support is available.
            }

            _logger.LogDebug("تم جلب إحصائيات المدفوعات. إجمالي المنفق: {TotalSpent} {Currency}, الموفر: {TotalSaved}", 
                statistics.TotalSpent, statistics.Currency, statistics.TotalSaved);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب إحصائيات المدفوعات للمستخدم: {UserId}", userId);
            statistics.Currency = "YER";
        }
    }

    private void CalculateLoyaltyInfo(UserStatisticsDto statistics)
    {
        try
        {
            // Derive loyalty points from the user's overall activity.
            var loyaltyPoints = 0;

            // Award 10 points for each completed booking.
            loyaltyPoints += statistics.CompletedBookings * 10;

            // Award 5 points for each written review.
            loyaltyPoints += statistics.ReviewsWritten * 5;

            // Award one point for each 1000 currency units spent.
            loyaltyPoints += (int)(statistics.TotalSpent / 1000);

            statistics.LoyaltyPoints = loyaltyPoints;

            // Determine the loyalty tier (this can be added to UserStatisticsDto later).
            var loyaltyTier = loyaltyPoints switch
            {
                >= 1000 => "بلاتيني",
                >= 500 => "ذهبي",
                >= 200 => "فضي",
                >= 50 => "برونزي",
                _ => "عادي"
            };

            _logger.LogDebug("تم حساب معلومات الولاء. النقاط: {LoyaltyPoints}, الفئة: {LoyaltyTier}", 
                statistics.LoyaltyPoints, loyaltyTier);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء حساب معلومات الولاء");
            statistics.LoyaltyPoints = 0;
            // statistics.LoyaltyTier = "عادي"; // خاصية غير موجودة
        }
    }
}
