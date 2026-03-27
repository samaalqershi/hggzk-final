using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;

namespace YemenBooking.Application.Features.Bookings.Queries.GetUserBookingSummary;

    /// <summary>
    /// يعالج مكوّن الحجوزات ويعيد النتيجة المطلوبة.
    /// Handles a booking-related component and returns the requested result.
    /// </summary>
public class GetUserBookingSummaryQueryHandler : IRequestHandler<GetUserBookingSummaryQuery, ResultDto<UserBookingSummaryDto>>
{
    private readonly IBookingRepository _bookingRepository;
    private readonly IUserRepository _userRepository;
    private readonly ILogger<GetUserBookingSummaryQueryHandler> _logger;
    private readonly ICurrentUserService _currentUserService;

/// <summary>
/// ينشئ مثيلًا جديدًا مع الاعتمادات المطلوبة.
/// Creates a new instance with its required dependencies.
/// </summary>
    public GetUserBookingSummaryQueryHandler(
        IBookingRepository bookingRepository,
        IUserRepository userRepository,
        ILogger<GetUserBookingSummaryQueryHandler> logger,
        ICurrentUserService currentUserService)
    {
        _bookingRepository = bookingRepository;
        _userRepository = userRepository;
        _logger = logger;
        _currentUserService = currentUserService;
    }

/// <summary>
/// يعالج هذا المكوّن المرتبط بـ الحجوزات ويعيد النتيجة المطلوبة.
/// Handles the corresponding booking-related command or query and returns the requested result.
/// </summary>
    public async Task<ResultDto<UserBookingSummaryDto>> Handle(GetUserBookingSummaryQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء استعلام ملخص حجوزات المستخدم. معرف المستخدم: {UserId}, السنة: {Year}", 
                request.UserId, request.Year ?? DateTime.Now.Year);

            // Validate the input payload.
            var validationResult = ValidateRequest(request);
            if (!validationResult.IsSuccess)
            {
                return validationResult;
            }

            // Ensure that the target user exists.
            var user = await _userRepository.GetByIdAsync(request.UserId, cancellationToken);
            if (user == null)
            {
                _logger.LogWarning("لم يتم العثور على المستخدم: {UserId}", request.UserId);
                return ResultDto<UserBookingSummaryDto>.Failed("المستخدم غير موجود", "USER_NOT_FOUND");
            }

            // Resolve the target year.
            var targetYear = request.Year ?? DateTime.Now.Year;

            // Load the user's bookings once and reuse them across all calculations.
            var userBookings = (await _bookingRepository.GetBookingsByUserAsync(request.UserId, cancellationToken))?
                .ToList() ?? new List<YemenBooking.Core.Entities.Booking>();

            var monthlyBookings = await GetMonthlyBookingSummary(userBookings, targetYear);
            var topBookedProperties = GetTopBookedProperties(userBookings, 5);
            var topVisitedCities = GetTopVisitedCities(userBookings, 5);

            // Build the response DTO.
            var summaryDto = new UserBookingSummaryDto
            {
                MonthlyBookings = monthlyBookings,
                TopBookedProperties = topBookedProperties,
                TopVisitedCities = topVisitedCities
            };

            _logger.LogInformation("تم الحصول على ملخص حجوزات المستخدم بنجاح. معرف المستخدم: {UserId}", request.UserId);

            return ResultDto<UserBookingSummaryDto>.Ok(
                summaryDto, 
                "تم الحصول على ملخص حجوزات المستخدم بنجاح"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء الحصول على ملخص حجوزات المستخدم. معرف المستخدم: {UserId}", request.UserId);
            return ResultDto<UserBookingSummaryDto>.Failed(
                $"حدث خطأ أثناء الحصول على ملخص الحجوزات: {ex.Message}", 
                "GET_USER_BOOKING_SUMMARY_ERROR"
            );
        }
    }

    private ResultDto<UserBookingSummaryDto> ValidateRequest(GetUserBookingSummaryQuery request)
    {
        if (request.UserId == Guid.Empty)
        {
            _logger.LogWarning("معرف المستخدم مطلوب");
            return ResultDto<UserBookingSummaryDto>.Failed("معرف المستخدم مطلوب", "USER_ID_REQUIRED");
        }

        if (request.Year.HasValue && (request.Year < 2020 || request.Year > DateTime.Now.Year + 1))
        {
            _logger.LogWarning("السنة المحددة غير صالحة: {Year}", request.Year);
            return ResultDto<UserBookingSummaryDto>.Failed("السنة المحددة غير صالحة", "INVALID_YEAR");
        }

        return ResultDto<UserBookingSummaryDto>.Ok(null, "البيانات صحيحة");
    }

    private async Task<List<MonthlyBookingSummaryDto>> GetMonthlyBookingSummary(
        IReadOnlyCollection<YemenBooking.Core.Entities.Booking> userBookings,
        int year)
    {
        var monthlyBookings = new List<MonthlyBookingSummaryDto>();

        for (int month = 1; month <= 12; month++)
        {
            // Build the local boundary, then convert it to UTC for querying.
            var localStart = new DateTime(year, month, 1, 0, 0, 0);
            var localEnd = localStart.AddMonths(1).AddMilliseconds(-1);
            var startDate = await _currentUserService.ConvertFromUserLocalToUtcAsync(localStart);
            var endDate = await _currentUserService.ConvertFromUserLocalToUtcAsync(localEnd);

            // Filter the preloaded bookings within the current month boundaries.
            var bookings = userBookings.Where(b =>
                b.CheckIn >= startDate && 
                b.CheckOut <= endDate);

            var bookingsCount = bookings.Count();
            var amountSpent = bookings.Sum(b => b.TotalPrice.Amount);

            monthlyBookings.Add(new MonthlyBookingSummaryDto
            {
                Month = month,
                Year = year,
                BookingsCount = bookingsCount,
                AmountSpent = amountSpent
            });
        }

        return monthlyBookings;
    }

    private List<PropertyBookingFrequencyDto> GetTopBookedProperties(
        IReadOnlyCollection<YemenBooking.Core.Entities.Booking> userBookings,
        int limit)
    {
        var topProperties = userBookings
            .GroupBy(b => b.Unit.PropertyId)
            .OrderByDescending(g => g.Count())
            .Take(limit)
            .Select(g => g.First().Unit.Property);
        
        if (topProperties == null || !topProperties.Any())
        {
            return new List<PropertyBookingFrequencyDto>();
        }

        var result = new List<PropertyBookingFrequencyDto>();

        foreach (var property in topProperties)
        {
            result.Add(new PropertyBookingFrequencyDto
            {
                PropertyName = property?.Name ?? "غير متاح",
                City = property?.City ?? "غير متاح",
                BookingsCount = userBookings.Count(b => b.Unit.PropertyId == property.Id)
            });
        }

        return result.OrderByDescending(p => p.BookingsCount).ToList();
    }

    private List<CityVisitFrequencyDto> GetTopVisitedCities(
        IReadOnlyCollection<YemenBooking.Core.Entities.Booking> userBookings,
        int limit)
    {
        var topCities = userBookings
            .GroupBy(b => b.Unit.Property.City)
            .OrderByDescending(g => g.Count())
            .Take(limit)
            .Select(g => g.Key);
        
        if (topCities == null || !topCities.Any())
        {
            return new List<CityVisitFrequencyDto>();
        }

        return topCities.Select(city => new CityVisitFrequencyDto
        {
            CityName = city ?? "غير متاح",
            VisitsCount = userBookings.Count(b => b.Unit.Property.City == city)
        }).OrderByDescending(c => c.VisitsCount).ToList();
    }
}
