using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Reviews.Commands.Review;

    /// <summary>
    /// يمثل أمرًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area command.
    /// </summary>
public class DisableReviewCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف التقييم المراد تعطيله.
    /// Identifier of the review to disable.
    /// </summary>
    public Guid ReviewId { get; set; }
}