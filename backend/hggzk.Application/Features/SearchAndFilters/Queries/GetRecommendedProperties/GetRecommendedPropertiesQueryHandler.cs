using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.SearchAndFilters;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Features.SearchAndFilters.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.SearchAndFilters.Queries.GetRecommendedProperties;

/// <summary>
/// يعالج جلب الموصى بها العقارات ويعيد النتيجة المطلوبة.
/// Processes the Get Recommended Properties request and returns the requested result.
/// </summary>
public class GetRecommendedPropertiesQueryHandler : IRequestHandler<GetRecommendedPropertiesQuery, ResultDto<PaginatedResult<PropertySearchResultDto>>>
{
    private readonly IUserRepository _userRepository;
    private readonly IPropertyRepository _propertyRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IFavoriteRepository _favoriteRepository;
    private readonly IReviewRepository _reviewRepository;
    private readonly IPropertyImageRepository _propertyImageRepository;
    private readonly IUnitRepository _unitRepository;
    private readonly ILogger<GetRecommendedPropertiesQueryHandler> _logger;

    /// <summary>
    /// ينشئ مثيلاً جديداً من GetRecommendedPropertiesQueryHandler.
    /// Initializes a new instance of GetRecommendedPropertiesQueryHandler.
    /// </summary>
    public GetRecommendedPropertiesQueryHandler(
        IUserRepository userRepository,
        IPropertyRepository propertyRepository,
        IBookingRepository bookingRepository,
        IFavoriteRepository favoriteRepository,
        IReviewRepository reviewRepository,
        IPropertyImageRepository propertyImageRepository,
        IUnitRepository unitRepository,
        ILogger<GetRecommendedPropertiesQueryHandler> logger)
    {
        _userRepository = userRepository;
        _propertyRepository = propertyRepository;
        _bookingRepository = bookingRepository;
        _favoriteRepository = favoriteRepository;
        _reviewRepository = reviewRepository;
        _propertyImageRepository = propertyImageRepository;
        _unitRepository = unitRepository;
        _logger = logger;
    }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
    public async Task<ResultDto<PaginatedResult<PropertySearchResultDto>>> Handle(GetRecommendedPropertiesQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء استعلام العقارات الموصى بها. معرف المستخدم: {UserId}, العدد: {Count}, المدينة: {City}", 
                request.UserId, request.Count, request.City);

            var validationResult = ValidateRequest(request);
            if (!validationResult.IsSuccess)
            {
                return validationResult;
            }

            var user = await _userRepository.GetByIdAsync(request.UserId, cancellationToken);
            if (user == null)
            {
                _logger.LogWarning("المستخدم غير موجود. معرف المستخدم: {UserId}", request.UserId);
                return ResultDto<PaginatedResult<PropertySearchResultDto>>.Failed("المستخدم غير موجود", "USER_NOT_FOUND");
            }

            var activeProperties = await _propertyRepository.GetActivePropertiesAsync(cancellationToken);
            
            if (activeProperties == null || !activeProperties.Any())
            {
                _logger.LogInformation("لا توجد عقارات نشطة في النظام");
                return ResultDto<PaginatedResult<PropertySearchResultDto>>.Ok(
                    new PaginatedResult<PropertySearchResultDto>
                    {
                        Items = new List<PropertySearchResultDto>(),
                        TotalCount = 0,
                        PageNumber = 1,
                        PageSize = request.Count
                    }, 
                    "لا توجد عقارات متاحة للتوصية"
                );
            }

            if (!string.IsNullOrWhiteSpace(request.City))
            {
                activeProperties = activeProperties.Where(p => 
                    p.City != null && p.City.Equals(request.City, StringComparison.OrdinalIgnoreCase));
            }

            var propertiesList = activeProperties.ToList();

            var userPreferences = await GetUserPreferences(request.UserId, cancellationToken);

            var recommendedProperties = new List<(Core.Entities.Property property, double score)>();

            foreach (var property in propertiesList)
            {
                var score = await CalculateRecommendationScore(property, userPreferences, cancellationToken);
                recommendedProperties.Add((property, score));
            }

            var sortedProperties = recommendedProperties
                .OrderByDescending(p => p.score)
                .Take(request.Count)
                .Select(p => p.property)
                .ToList();

            // تحويل إلى DTOs
            var propertyDtos = new List<PropertySearchResultDto>();

            foreach (var property in sortedProperties)
            {
                var propertyDto = await ConvertToPropertySearchResultDto(property, cancellationToken);
                if (propertyDto != null)
                {
                    propertyDtos.Add(propertyDto);
                }
            }

            var result = new PaginatedResult<PropertySearchResultDto>
            {
                Items = propertyDtos,
                TotalCount = propertyDtos.Count,
                PageNumber = 1,
                PageSize = request.Count
            };

            _logger.LogInformation("تم العثور على {Count} عقار موصى به للمستخدم", propertyDtos.Count);

            return ResultDto<PaginatedResult<PropertySearchResultDto>>.Ok(
                result, 
                $"تم العثور على {propertyDtos.Count} عقار موصى به"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب العقارات الموصى بها للمستخدم: {UserId}", request.UserId);
            return ResultDto<PaginatedResult<PropertySearchResultDto>>.Failed(
                $"حدث خطأ أثناء جلب العقارات الموصى بها: {ex.Message}", 
                "GET_RECOMMENDED_PROPERTIES_ERROR"
            );
        }
    }

    private ResultDto<PaginatedResult<PropertySearchResultDto>> ValidateRequest(GetRecommendedPropertiesQuery request)
    {
        if (request.UserId == Guid.Empty)
        {
            _logger.LogWarning("معرف المستخدم غير صحيح");
            return ResultDto<PaginatedResult<PropertySearchResultDto>>.Failed("معرف المستخدم مطلوب", "INVALID_USER_ID");
        }

        if (request.Count < 1 || request.Count > 50)
        {
            _logger.LogWarning("عدد العقارات المطلوبة غير صحيح: {Count}", request.Count);
            return ResultDto<PaginatedResult<PropertySearchResultDto>>.Failed(
                "عدد العقارات يجب أن يكون بين 1 و 50", 
                "INVALID_COUNT"
            );
        }

        return ResultDto<PaginatedResult<PropertySearchResultDto>>.Ok(null, "البيانات صحيحة");
    }

    private async Task<UserPreferences> GetUserPreferences(Guid userId, CancellationToken cancellationToken)
    {
        try
        {
            var preferences = new UserPreferences();

            var userBookings = await _bookingRepository.GetByUserIdAsync(userId, cancellationToken);
            if (userBookings != null && userBookings.Any())
            {
                var completedBookings = userBookings.Where(b => b.Status == BookingStatus.Completed).ToList();
                
                if (completedBookings.Any())
                {
                    preferences.PreferredCities = completedBookings
                        .Where(b => b.Unit?.Property?.City != null)
                        .GroupBy(b => b.Unit!.Property!.City!)
                        .OrderByDescending(g => g.Count())
                        .Take(3)
                        .Select(g => g.Key)
                        .ToList();

                    preferences.PreferredPropertyTypes = completedBookings
                        .GroupBy(b => b.Unit?.Property?.TypeId)
                        .Where(g => g.Key.HasValue)
                        .OrderByDescending(g => g.Count())
                        .Take(3)
                        .Select(g => g.Key!.Value)
                        .ToList();

                    preferences.AverageBudget = (decimal)completedBookings.Average(b => b.TotalPrice.Amount);
                }
            }

            var userFavorites = await _favoriteRepository.GetByUserIdAsync(userId, cancellationToken);
            if (userFavorites != null && userFavorites.Any())
            {
                preferences.FavoritePropertyIds = userFavorites.Select(f => f.PropertyId).ToList();
            }

            return preferences;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب تفضيلات المستخدم: {UserId}", userId);
            return new UserPreferences();
        }
    }

    private async Task<double> CalculateRecommendationScore(Core.Entities.Property property, UserPreferences userPreferences, CancellationToken cancellationToken)
    {
        try
        {
            double score = 0;

            var reviews = await _reviewRepository.GetByPropertyIdAsync(property.Id, cancellationToken);
            if (reviews != null && reviews.Any())
            {
                var averageRating = reviews.Average(r => r.AverageRating);
                score += (double)averageRating * 20; // Rating weight
                score += Math.Min(reviews.Count(), 10) * 5; // Review-count weight, capped at 50 points
            }

            // Boost properties in the user's favorites
            if (userPreferences.FavoritePropertyIds.Contains(property.Id))
            {
                score += 100; // Large bonus for favorites
            }

            // Boost properties in preferred cities
            if (property.City != null && userPreferences.PreferredCities.Contains(property.City))
            {
                var cityIndex = userPreferences.PreferredCities.IndexOf(property.City);
                score += (3 - cityIndex) * 30; // Higher bonus for more preferred cities
            }

            // Boost properties with preferred property types
            if (userPreferences.PreferredPropertyTypes.Contains(property.TypeId))
            {
                var typeIndex = userPreferences.PreferredPropertyTypes.IndexOf(property.TypeId);
                score += (3 - typeIndex) * 25;
            }

            var units = await _unitRepository.GetActiveByPropertyIdAsync(property.Id, cancellationToken);

            var daysSinceCreated = (DateTime.UtcNow - property.CreatedAt).Days;
            if (daysSinceCreated <= 30)
            {
                score += 20; // New-property bonus
            }

            // Reward high-rated properties
            if (property.StarRating >= 4)
            {
                score += property.StarRating * 10;
            }

            return Math.Max(0, score);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء حساب درجة التوصية للعقار: {PropertyId}", property.Id);
            return 0;
        }
    }

    private async Task<PropertySearchResultDto?> ConvertToPropertySearchResultDto(Core.Entities.Property property, CancellationToken cancellationToken)
    {
        try
        {
            var images = await _propertyImageRepository.GetByPropertyIdAsync(property.Id, cancellationToken);
            var mainImageUrl = images?.FirstOrDefault(img => img.IsMain)?.Url ?? 
                              images?.FirstOrDefault()?.Url;

            var reviews = await _reviewRepository.GetByPropertyIdAsync(property.Id, cancellationToken);
            var averageRating = reviews?.Any() == true ? reviews.Average(r => r.AverageRating) : 0;
            var reviewsCount = reviews?.Count() ?? 0;

            var units = await _unitRepository.GetActiveByPropertyIdAsync(property.Id, cancellationToken);
            var minPrice = 0m;

            return new PropertySearchResultDto
            {
                Id = property.Id,
                Name = property.Name ?? string.Empty,
                Description = property.Description ?? string.Empty,
                Address = property.Address ?? string.Empty,
                City = property.City ?? string.Empty,
                StarRating = property.StarRating,
                AverageRating = Math.Round(averageRating, 1),
                ReviewsCount = reviewsCount,
                MinPrice = minPrice,
                Currency = "YER",
                MainImageUrl = mainImageUrl,
                IsRecommended = true, // All returned results are recommended
                DistanceKm = null // Distance is not calculated for recommendations
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء تحويل العقار إلى DTO: {PropertyId}", property.Id);
            return null;
        }
    }

    private class UserPreferences
    {
        /// <summary>
        /// القيمة الخاصة بـ preferred cities.
        /// Preferred Cities value.
        /// </summary>
        public List<string> PreferredCities { get; set; } = new();
        /// <summary>
        /// القيمة الخاصة بـ preferred العقار types.
        /// Preferred Property Types value.
        /// </summary>
        public List<Guid> PreferredPropertyTypes { get; set; } = new();
        /// <summary>
        /// معرّفات favorite العقار.
        /// Favorite Property identifiers.
        /// </summary>
        public List<Guid> FavoritePropertyIds { get; set; } = new();
        /// <summary>
        /// القيمة الخاصة بـ المتوسط budget.
        /// Average Budget value.
        /// </summary>
        public decimal AverageBudget { get; set; } = 0;
    }
}
