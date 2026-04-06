using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using System.Text.RegularExpressions;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features.Reviews.DTOs;
using YemenBooking.Application.Features.Reviews.Queries.GetPropertyReviews;

namespace YemenBooking.Application.Features.Reviews.Queries.GetReviewsSummary;

    /// <summary>
    /// يعالج مكوّن النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles a current feature area component and returns the requested result.
    /// </summary>
public class ClientGetReviewsSummaryQueryHandler : IRequestHandler<ClientGetReviewsSummaryQuery, ResultDto<ClientReviewsSummaryDto>>
{
    private readonly IReviewRepository _reviewRepository;
    private readonly IPropertyRepository _propertyRepository;
    private readonly ILogger<ClientGetReviewsSummaryQueryHandler> _logger;
    private readonly ICurrentUserService _currentUserService;

    /// <summary>
    /// يُهيِّئ المعالج بالاعتمادات المطلوبة.
    /// Initializes the handler with the required dependencies.
    /// </summary>
    public ClientGetReviewsSummaryQueryHandler(
        IReviewRepository reviewRepository,
        IPropertyRepository propertyRepository,
        ILogger<ClientGetReviewsSummaryQueryHandler> logger,
        ICurrentUserService currentUserService)
    {
        _reviewRepository = reviewRepository;
        _propertyRepository = propertyRepository;
        _logger = logger;
        _currentUserService = currentUserService;
    }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة.
    /// Processes the reviews summary query and returns the result.
    /// </summary>
    public async Task<ResultDto<ClientReviewsSummaryDto>> Handle(ClientGetReviewsSummaryQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء استعلام ملخص المراجعات للعميل. معرف العقار: {PropertyId}", request.PropertyId);

            // Ensure that the property exists.
            var property = await _propertyRepository.GetByIdAsync(request.PropertyId, cancellationToken);
            if (property == null)
            {
                _logger.LogWarning("العقار غير موجود. معرف العقار: {PropertyId}", request.PropertyId);
                return ResultDto<ClientReviewsSummaryDto>.Failed("العقار غير موجود", "PROPERTY_NOT_FOUND");
            }

            // Load all reviews for the requested property.
            var reviews = await _reviewRepository.GetByPropertyIdAsync(request.PropertyId, cancellationToken);
            
            if (reviews == null || !reviews.Any())
            {
                _logger.LogInformation("لا توجد مراجعات للعقار: {PropertyId}", request.PropertyId);
                return ResultDto<ClientReviewsSummaryDto>.Ok(GetEmptyReviewsSummary(), "لا توجد مراجعات لهذا العقار");
            }

            // The client-facing summary must only include approved and active reviews.
            var reviewsList = reviews
                .Where(r => !r.IsPendingApproval && !r.IsDisabled)
                .ToList();

            if (!reviewsList.Any())
            {
                _logger.LogInformation("لا توجد مراجعات معتمدة وفعّالة للعقار: {PropertyId}", request.PropertyId);
                return ResultDto<ClientReviewsSummaryDto>.Ok(GetEmptyReviewsSummary(), "لا توجد مراجعات معتمدة لهذا العقار");
            }
            var summary = new ClientReviewsSummaryDto();

            // Compute the base statistics.
            CalculateBasicStatistics(summary, reviewsList);

            // Compute the rating distribution.
            CalculateRatingDistribution(summary, reviewsList);

            // Populate latest and top reviews.
            await PopulateLatestAndTopReviews(summary, reviewsList, cancellationToken);

            // Extract the most common keywords.
            ExtractCommonKeywords(summary, reviewsList);

            // Calculate the management response rate.
            CalculateManagementResponseRate(summary, reviewsList);

            _logger.LogInformation("تم جلب ملخص المراجعات بنجاح. إجمالي المراجعات: {TotalReviews}, متوسط التقييم: {AverageRating}", 
                summary.TotalReviews, summary.AverageRating);

            return ResultDto<ClientReviewsSummaryDto>.Ok(summary, "تم جلب ملخص المراجعات بنجاح");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب ملخص المراجعات للعقار: {PropertyId}", request.PropertyId);
            return ResultDto<ClientReviewsSummaryDto>.Failed(
                $"حدث خطأ أثناء جلب ملخص المراجعات: {ex.Message}", 
                "GET_REVIEWS_SUMMARY_ERROR"
            );
        }
    }

    private void CalculateBasicStatistics(ClientReviewsSummaryDto summary, List<Core.Entities.Review> reviews)
    {
        try
        {
            summary.TotalReviews = reviews.Count;
            summary.AverageRating = reviews.Any() ? Math.Round(reviews.Average(r => r.AverageRating), 1) : 0;

            // Count reviews that contain images.
            summary.ReviewsWithImagesCount = reviews.Count(r => r.Images != null && r.Images.Any());

            // Count recommended reviews where the rating is 4 or higher.
            summary.RecommendedCount = reviews.Count(r => r.AverageRating >= 4);

            _logger.LogDebug("تم حساب الإحصائيات الأساسية. إجمالي: {Total}, متوسط: {Average}, مع صور: {WithImages}, موصى بها: {Recommended}", 
                summary.TotalReviews, summary.AverageRating, summary.ReviewsWithImagesCount, summary.RecommendedCount);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء حساب الإحصائيات الأساسية");
        }
    }

    private void CalculateRatingDistribution(ClientReviewsSummaryDto summary, List<Core.Entities.Review> reviews)
    {
        try
        {
            // Initialize distribution buckets with default values.
            for (int i = 1; i <= 5; i++)
            {
                summary.RatingDistribution[i] = 0;
                summary.RatingPercentages[i] = 0;
            }

            if (!reviews.Any()) return;

            // Aggregate the reviews into distribution buckets.
            var ratingGroups = reviews
                .GroupBy(r => Math.Round(r.AverageRating))
                .ToDictionary(g => (int)g.Key, g => g.Count());

            foreach (var group in ratingGroups)
            {
                if (group.Key >= 1 && group.Key <= 5)
                {
                    summary.RatingDistribution[group.Key] = group.Value;
                    summary.RatingPercentages[group.Key] = Math.Round((decimal)group.Value / reviews.Count * 100, 1);
                }
            }

            _logger.LogDebug("تم حساب توزيع التقييمات بنجاح");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء حساب توزيع التقييمات");
        }
    }

    private async Task PopulateLatestAndTopReviews(ClientReviewsSummaryDto summary, List<Core.Entities.Review> reviews, CancellationToken cancellationToken)
    {
        try
        {
            // Select the latest three reviews.
            var latestReviews = reviews
                .OrderByDescending(r => r.CreatedAt)
                .Take(3)
                .ToList();

            summary.LatestReviews = await ConvertToClientReviewDtos(latestReviews, cancellationToken);

            // Select the top three reviews by rating, then by recency.
            var topReviews = reviews
                .OrderByDescending(r => r.AverageRating)
                .ThenByDescending(r => r.CreatedAt)
                .Take(3)
                .ToList();

            summary.TopReviews = await ConvertToClientReviewDtos(topReviews, cancellationToken);

            _logger.LogDebug("تم جلب أحدث {LatestCount} مراجعة وأفضل {TopCount} مراجعة", 
                summary.LatestReviews.Count, summary.TopReviews.Count);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء جلب أحدث المراجعات وأفضلها");
            summary.LatestReviews = new List<ClientReviewDto>();
            summary.TopReviews = new List<ClientReviewDto>();
        }
    }

    private async Task<List<ClientReviewDto>> ConvertToClientReviewDtos(List<Core.Entities.Review> reviews, CancellationToken cancellationToken)
    {
        var clientReviews = new List<ClientReviewDto>();

        foreach (var review in reviews)
        {
            try
            {
                // Resolve the visible reviewer information.
                var user = review.Booking?.User;
                var userName = user?.Name ?? "مستخدم مجهول";
                var userAvatar = user?.ProfileImageUrl;

                var clientReview = new ClientReviewDto
                {
                    Id = review.Id,
                    UserId = review.Booking?.UserId ?? Guid.Empty,
                    BookingId = review.BookingId,
                    PropertyName = review.Property?.Name ?? string.Empty,
                    UserName = userName,
                    UserAvatar = userAvatar,
                    Rating = (int)Math.Round(review.AverageRating),
                    Cleanliness = review.Cleanliness,
                    Service = review.Service,
                    Location = review.Location,
                    Value = review.Value,
                    AverageRating = review.AverageRating,
                    // Title removed: entity lacks Title property
                    //Title = review.Title ?? string.Empty,
                    Comment = review.Comment ?? string.Empty,
                    CreatedAt = review.CreatedAt,
                    ResponseText = review.ResponseText,
                    ResponseDate = review.ResponseDate,
                    Images = review.Images?.Select(img => new ClientReviewImageDto
                    {
                        Id = img.Id,
                        ReviewId = img.ReviewId,
                        Name = img.Name,
                        Url = img.Url ?? string.Empty,
                        ThumbnailUrl = ReviewImageMetadataHelper.GetThumbnailUrl(img),
                        Caption = img.Caption,
                        DisplayOrder = img.DisplayOrder,
                        SizeBytes = img.SizeBytes,
                        Type = img.Type,
                        AltText = img.AltText,
                        UploadedAt = img.UploadedAt
                    }).OrderBy(img => img.DisplayOrder).ToList() ?? new List<ClientReviewImageDto>(),
                    IsUserReview = false, // يمكن تحديدها لاحقاً حسب المستخدم الحالي. Can be resolved later for the current user.
                    LikesCount = 0, // يمكن إضافتها لاحقاً. Can be added later.
                    IsLikedByUser = false,
                    ManagementReply = !string.IsNullOrEmpty(review.ResponseText) ? new ClientReviewReplyDto
                    {
                        Id = Guid.NewGuid(),
                        Content = review.ResponseText,
                        CreatedAt = review.ResponseDate ?? DateTime.UtcNow,
                        ReplierName = "إدارة العقار",
                        ReplierPosition = "ممثل خدمة العملاء"
                    } : null,
                    BookingType = "Standard",
                    IsRecommended = review.AverageRating >= 4,
                    IsPendingApproval = review.IsPendingApproval,
                    IsDisabled = review.IsDisabled
                };

                // Convert timestamps into the current user's timezone.
                clientReview.CreatedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(clientReview.CreatedAt);
                if (clientReview.ManagementReply != null)
                {
                    clientReview.ManagementReply.CreatedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(clientReview.ManagementReply.CreatedAt);
                }

                clientReviews.Add(clientReview);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء تحويل المراجعة: {ReviewId}", review.Id);
            }
        }

        return clientReviews;
    }

    private void ExtractCommonKeywords(ClientReviewsSummaryDto summary, List<Core.Entities.Review> reviews)
    {
        try
        {
            var allComments = reviews
                .Where(r => !string.IsNullOrWhiteSpace(r.Comment))
                .Select(r => r.Comment!)
                .ToList();

            if (!allComments.Any())
            {
                summary.CommonKeywords = new List<ClientReviewKeywordDto>();
                return;
            }

            // Common Arabic keywords expected in review comments.
            var commonKeywords = new[]
            {
                "ممتاز", "رائع", "جيد", "سيء", "نظيف", "قذر", "مريح", "غير مريح",
                "خدمة", "موقع", "سعر", "جودة", "نظافة", "طعام", "غرفة", "حمام",
                "موظفين", "استقبال", "إفطار", "واي فاي", "مكيف", "سرير"
            };

            var keywordCounts = new Dictionary<string, int>();
            var totalWords = 0;

            foreach (var comment in allComments)
            {
                var words = Regex.Split(comment.ToLower(), @"\W+")
                    .Where(w => !string.IsNullOrWhiteSpace(w) && w.Length > 2)
                    .ToList();

                totalWords += words.Count;

                foreach (var keyword in commonKeywords)
                {
                    var count = words.Count(w => w.Contains(keyword.ToLower()));
                    if (count > 0)
                    {
                        keywordCounts[keyword] = keywordCounts.GetValueOrDefault(keyword, 0) + count;
                    }
                }
            }

            // Keep the top ten keywords only.
            summary.CommonKeywords = keywordCounts
                .Where(kv => kv.Value > 0)
                .OrderByDescending(kv => kv.Value)
                .Take(10)
                .Select(kv => new ClientReviewKeywordDto
                {
                    Keyword = kv.Key,
                    Count = kv.Value,
                    Percentage = totalWords > 0 ? Math.Round((decimal)kv.Value / totalWords * 100, 1) : 0,
                    Sentiment = DetermineSentiment(kv.Key)
                })
                .ToList();

            _logger.LogDebug("تم استخراج {Count} كلمة مفتاحية شائعة", summary.CommonKeywords.Count);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء استخراج الكلمات المفتاحية");
            summary.CommonKeywords = new List<ClientReviewKeywordDto>();
        }
    }

    private string DetermineSentiment(string keyword)
    {
        var positiveKeywords = new[] { "ممتاز", "رائع", "جيد", "نظيف", "مريح", "جودة" };
        var negativeKeywords = new[] { "سيء", "قذر", "غير مريح" };

        if (positiveKeywords.Contains(keyword))
            return "Positive";
        else if (negativeKeywords.Contains(keyword))
            return "Negative";
        else
            return "Neutral";
    }

    private void CalculateManagementResponseRate(ClientReviewsSummaryDto summary, List<Core.Entities.Review> reviews)
    {
        try
        {
            if (!reviews.Any())
            {
                summary.ManagementResponseRate = 0;
                return;
            }

            var reviewsWithResponse = reviews.Count(r => !string.IsNullOrWhiteSpace(r.ResponseText));
            summary.ManagementResponseRate = Math.Round((decimal)reviewsWithResponse / reviews.Count * 100, 1);

            _logger.LogDebug("معدل الاستجابة من الإدارة: {ResponseRate}%", summary.ManagementResponseRate);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء حساب معدل الاستجابة من الإدارة");
            summary.ManagementResponseRate = 0;
        }
    }

    private ClientReviewsSummaryDto GetEmptyReviewsSummary()
    {
        var summary = new ClientReviewsSummaryDto();
        
        // Initialize default rating buckets.
        for (int i = 1; i <= 5; i++)
        {
            summary.RatingDistribution[i] = 0;
            summary.RatingPercentages[i] = 0;
        }

        return summary;
    }
}
