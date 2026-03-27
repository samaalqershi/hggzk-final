using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Reviews.Commands.Review;

    /// <summary>
    /// يمثل أمرًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area command.
    /// </summary>
public class DeleteReviewCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف التقييم المراد حذفه.
    /// Identifier of the review to delete.
    /// </summary>
    public Guid ReviewId { get; set; }
} 