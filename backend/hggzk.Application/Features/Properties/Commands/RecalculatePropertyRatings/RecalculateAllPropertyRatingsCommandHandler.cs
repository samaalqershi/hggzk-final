using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Properties.Commands.RecalculatePropertyRatings
{
    /// <summary>
    /// يعالج إعادة احتساب تقييمات العقارات ويحفظ المتوسطات الجديدة.
    /// Handles recomputing property ratings and persisting updated averages.
    /// </summary>
    public class RecalculateAllPropertyRatingsCommandHandler : IRequestHandler<RecalculateAllPropertyRatingsCommand, ResultDto<int>>
    {
        private readonly IPropertyRepository _propertyRepository;
        private readonly IReviewRepository _reviewRepository;
        private readonly ILogger<RecalculateAllPropertyRatingsCommandHandler> _logger;

        /// <summary>
        /// يهيّئ مثيلاً جديداً من [RecalculateAllPropertyRatingsCommandHandler].
        /// Initializes a new instance of [RecalculateAllPropertyRatingsCommandHandler].
        /// </summary>
        public RecalculateAllPropertyRatingsCommandHandler(
            IPropertyRepository propertyRepository,
            IReviewRepository reviewRepository,
            ILogger<RecalculateAllPropertyRatingsCommandHandler> logger)
        {
            _propertyRepository = propertyRepository;
            _reviewRepository = reviewRepository;
            _logger = logger;
        }
        /// <summary>
        /// يعالج إعادة احتساب متوسطات تقييم العقارات.
        /// Handles recalculating property rating averages.
        /// </summary>
        public async Task<ResultDto<int>> Handle(RecalculateAllPropertyRatingsCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var properties = await _propertyRepository.GetAllAsync(cancellationToken);
                int updated = 0;

                foreach (var property in properties)
                {
                    var (avg, total) = await _reviewRepository.GetPropertyRatingStatsAsync(property.Id, cancellationToken);
                    var newAvg = (decimal)avg;
                    if (property.AverageRating != newAvg)
                    {
                        property.AverageRating = newAvg;
                        await _propertyRepository.UpdatePropertyAsync(property, cancellationToken);
                        updated++;
                    }
                }

                if (updated > 0)
                {
                    await _propertyRepository.SaveChangesAsync(cancellationToken);
                }

                _logger.LogInformation("اكتملت عملية إعادة احتساب متوسطات التقييم. تم تحديث {Count} عقاراً.", updated);
                return ResultDto<int>.Ok(updated, $"تم تحديث {updated} عقاراً");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "فشل أمر إعادة احتساب متوسطات التقييم");
                return ResultDto<int>.Failed("حدث خطأ أثناء إعادة الاحتساب", "RECALC_ERROR");
            }
        }
    }
}
