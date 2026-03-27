using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Reviews.Commands.ReviewResponse
{
    /// <summary>
    /// أمر لحذف رد تقييم
    /// </summary>
    public class DeleteReviewResponseCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// معرّف رد التقييم المراد حذفه.
        /// Identifier of the review response to delete.
        /// </summary>
        public Guid ResponseId { get; set; }
    }
}
