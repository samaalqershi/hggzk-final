using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Reviews.DTOs;
using YemenBooking.Application.Features.Reviews.Queries.GetPropertyReviews;

namespace YemenBooking.Application.Features.Reviews.Queries.GetReviewsSummary;

    /// <summary>
    /// يمثل استعلامًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area query.
    /// </summary>
public class ClientGetReviewsSummaryQuery : IRequest<ResultDto<ClientReviewsSummaryDto>>
{
    /// <summary>
    /// معرّف العقار المطلوب جلب ملخص المراجعات له.
    /// Identifier of the property whose review summary is requested.
    /// </summary>
    public Guid PropertyId { get; set; }
}

/// <summary>
/// ملخص المراجعات للعميل
/// Client reviews summary
/// </summary>
public class ClientReviewsSummaryDto
{
    /// <summary>
    /// إجمالي عدد المراجعات.
    /// Total number of reviews.
    /// </summary>
    public int TotalReviews { get; set; }

    /// <summary>
    /// متوسط التقييم.
    /// Average rating.
    /// </summary>
    public decimal AverageRating { get; set; }

    /// <summary>
    /// توزيع التقييمات من 1 إلى 5 نجوم.
    /// Rating distribution from 1 to 5 stars.
    /// </summary>
    public Dictionary<int, int> RatingDistribution { get; set; } = new();

    /// <summary>
    /// نسبة التقييمات حسب عدد النجوم.
    /// Rating percentages by star count.
    /// </summary>
    public Dictionary<int, decimal> RatingPercentages { get; set; } = new();

    /// <summary>
    /// عدد المراجعات التي تتضمن صورًا.
    /// Number of reviews that include images.
    /// </summary>
    public int ReviewsWithImagesCount { get; set; }

    /// <summary>
    /// عدد المراجعات الموصى بها.
    /// Number of recommended reviews.
    /// </summary>
    public int RecommendedCount { get; set; }

    /// <summary>
    /// أحدث ثلاث مراجعات.
    /// Latest three reviews.
    /// </summary>
    public List<ClientReviewDto> LatestReviews { get; set; } = new();

    /// <summary>
    /// أفضل ثلاث مراجعات من حيث التقييم.
    /// Top three reviews by rating.
    /// </summary>
    public List<ClientReviewDto> TopReviews { get; set; } = new();

    /// <summary>
    /// الكلمات المفتاحية الشائعة في المراجعات.
    /// Common keywords in reviews.
    /// </summary>
    public List<ClientReviewKeywordDto> CommonKeywords { get; set; } = new();

    /// <summary>
    /// معدل الاستجابة من الإدارة.
    /// Management response rate.
    /// </summary>
    public decimal ManagementResponseRate { get; set; }
}

/// <summary>
/// بيانات الكلمات المفتاحية في المراجعات
/// Review keywords data
/// </summary>
public class ClientReviewKeywordDto
{
    /// <summary>
    /// الكلمة المفتاحية.
    /// Keyword.
    /// </summary>
    public string Keyword { get; set; } = string.Empty;

    /// <summary>
    /// عدد مرات التكرار.
    /// Frequency count.
    /// </summary>
    public int Count { get; set; }

    /// <summary>
    /// النسبة المئوية.
    /// Percentage.
    /// </summary>
    public decimal Percentage { get; set; }

    /// <summary>
    /// نوع المشاعر (إيجابي، سلبي، محايد).
    /// Sentiment type (positive, negative, neutral).
    /// </summary>
    public string Sentiment { get; set; } = "Neutral";
}