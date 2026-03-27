using System;
using MediatR;
using YemenBooking.Application.Features.Analytics;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Analytics.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Analytics.Queries;

/// <summary>
/// يجلب تحليل مشاعر التقييمات لعقار محدد.
/// Retrieves review sentiment analysis for a specific property.
/// </summary>
public class GetReviewSentimentAnalysisQuery : IRequest<ResultDto<ReviewSentimentDto>>
{
    /// <summary>
    /// معرف العقار المستهدف.
    /// Target property identifier.
    /// </summary>
    public Guid PropertyId { get; set; }

    /// <summary>
    /// يُهيِّئ هذا الاستعلام بالمعرف المطلوب.
    /// Initializes this query with the required identifier.
    /// </summary>
    public GetReviewSentimentAnalysisQuery(Guid propertyId)
    {
        PropertyId = propertyId;
    }
} 
