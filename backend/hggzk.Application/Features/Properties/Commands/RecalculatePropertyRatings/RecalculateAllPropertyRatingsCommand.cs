using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Properties.Commands.RecalculatePropertyRatings
{
    /// <summary>
    /// طلب إعادة احتساب جميع Property Ratings.
    /// Request to recalculate all propertyratings.
    /// </summary>
    public class RecalculateAllPropertyRatingsCommand : IRequest<ResultDto<int>>
    {
    }
}
