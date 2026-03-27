using System;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Reviews.Commands.Review;
using YemenBooking.Application.Features.Reviews.Commands.RespondToReview;
using YemenBooking.Application.Features.Reviews.Queries.GetAllReviews;
using YemenBooking.Application.Features.Reviews.Queries.GetReviewDetails;
using YemenBooking.Application.Features.Analytics.Commands.Reviews;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Reviews.Queries.GetReviewByBooking;
using YemenBooking.Application.Features.Reviews.Commands.ReviewResponse;
using YemenBooking.Application.Features.Reviews.Queries.GetReviewResponses;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يدير المراجعات والتقييمات مع إمكانات الموافقة والرد والإخفاء.
    /// Manages reviews with approval, response, and moderation capabilities.
    /// </summary>
    public class ReviewsController : BaseAdminController
    {
        /// <summary>
        /// ينشئ نسخة من المتحكم مع وسيط الأوامر والاستعلامات.
        /// Creates the controller with the mediator dependency.
        /// </summary>
        public ReviewsController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// يعرض جميع التقييمات مع إمكانات التصفية.
        /// Returns all reviews with filtering support.
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAllReviews([FromQuery] GetAllReviewsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعرض تفاصيل تقييم محدد.
        /// Returns the details of a specific review.
        /// </summary>
        [HttpGet("{reviewId}")]
        public async Task<IActionResult> GetReviewDetails(Guid reviewId)
        {
            var result = await _mediator.Send(new GetReviewDetailsQuery { ReviewId = reviewId });
            return Ok(result);
        }

        /// <summary>
        /// يعرض التقييم المرتبط بحجز محدد.
        /// Returns the review associated with a specific booking.
        /// </summary>
        [HttpGet("by-booking/{bookingId}")]
        public async Task<IActionResult> GetReviewByBooking(Guid bookingId)
        {
            var result = await _mediator.Send(new GetReviewByBookingQuery { BookingId = bookingId });
            return Ok(result);
        }

        /// <summary>
        /// يعتمد تقييمًا للمراجعة العامة.
        /// Approves a review for public visibility.
        /// </summary>
        [HttpPost("{reviewId}/approve")]
        public async Task<IActionResult> ApproveReview(Guid reviewId, [FromBody] ApproveReviewCommand command)
        {
            command.ReviewId = reviewId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحذف تقييمًا من النظام.
        /// Deletes a review from the system.
        /// </summary>
        [HttpDelete("{reviewId}")]
        public async Task<IActionResult> DeleteReview(Guid reviewId)
        {
            var command = new DeleteReviewCommand { ReviewId = reviewId };
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعطّل تقييمًا ويستبعده من العرض والحسابات التجميعية.
        /// Disables a review and excludes it from display and aggregates.
        /// </summary>
        [HttpPost("{reviewId}/disable")]
        public async Task<IActionResult> DisableReview(Guid reviewId)
        {
            var command = new DisableReviewCommand { ReviewId = reviewId };
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يضيف ردًا إداريًا على تقييم.
        /// Adds an admin response to a review.
        /// </summary>
        [HttpPost("{reviewId}/respond")]
        public async Task<IActionResult> RespondToReview(Guid reviewId, [FromBody] RespondToReviewCommand command)
        {
            command.ReviewId = reviewId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعرض الردود المرتبطة بتقييم.
        /// Returns responses associated with a review.
        /// </summary>
        [HttpGet("{reviewId}/responses")]
        public async Task<IActionResult> GetReviewResponses(Guid reviewId)
        {
            var responses = await _mediator.Send(new GetReviewResponsesQuery { ReviewId = reviewId });
            return Ok(responses);
        }

        /// <summary>
        /// يحذف ردًا مرتبطًا بتقييم.
        /// Deletes a response associated with a review.
        /// </summary>
        [HttpDelete("responses/{responseId}")]
        public async Task<IActionResult> DeleteReviewResponse(Guid responseId)
        {
            var result = await _mediator.Send(new DeleteReviewResponseCommand { ResponseId = responseId });
            return Ok(result);
        }
    }
} 
