using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Reviews.DTOs;

namespace YemenBooking.Application.Features.Reviews.Commands.RespondToReview
{
    /// <summary>
    /// يمثل أمرًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area command.
    /// </summary>
    public class RespondToReviewCommand : IRequest<ResultDto<ReviewResponseDto>>
    {
        /// <summary>
        /// معرّف التقييم المراد الرد عليه.
        /// Identifier of the review being responded to.
        /// </summary>
        public Guid ReviewId { get; set; }
        /// <summary>
        /// نص الرد على التقييم.
        /// Response text for the review.
        /// </summary>
        public string ResponseText { get; set; } = string.Empty;
        /// <summary>
        /// معرّف مالك العقار المسؤول عن الرد.
        /// Identifier of the property owner replying to the review.
        /// </summary>
        public Guid OwnerId { get; set; }
    }
}
