using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Reviews.Commands.SubmitReview;
using YemenBooking.Application.Features.Reviews.Queries.GetPropertyReviews;
using YemenBooking.Application.Features.Reviews.Queries.GetReviewsSummary;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// يوفر واجهات إنشاء التقييمات وعرضها للعملاء.
    /// Exposes review creation and retrieval endpoints for clients.
    /// </summary>
    public class ReviewsController : BaseClientController
    {
        /// <summary>
        /// ينشئ مثيلاً جديداً من <see cref="ReviewsController"/>.
        /// Creates a new <see cref="ReviewsController"/> instance.
        /// </summary>
        public ReviewsController(IMediator mediator) : base(mediator)
        {
        }

        /// <summary>
        /// يرسل تقييماً جديداً.
        /// Submits a new review.
        /// </summary>
        /// <param name="command">بيانات التقييم.</param>
        /// <returns>نتيجة إرسال التقييم.</returns>
        [HttpPost]
        public async Task<ActionResult<ResultDto<SubmitReviewResponse>>> SubmitReview([FromBody] SubmitReviewCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يجلب تقييمات عقار محدد.
        /// Retrieves reviews for a specific property.
        /// </summary>
        /// <param name="query">معايير الاستعلام.</param>
        /// <returns>قائمة التقييمات.</returns>
        [HttpGet("property")]
        public async Task<ActionResult<ResultDto<PaginatedResult<ClientReviewDto>>>> GetPropertyReviews([FromQuery] ClientGetPropertyReviewsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب ملخص التقييمات.
        /// Retrieves a reviews summary.
        /// </summary>
        /// <param name="query">معايير الملخص.</param>
        /// <returns>ملخص التقييمات.</returns>
        [HttpGet("summary")]
        public async Task<ActionResult<ResultDto<ClientReviewsSummaryDto>>> GetReviewsSummary([FromQuery] ClientGetReviewsSummaryQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
}
