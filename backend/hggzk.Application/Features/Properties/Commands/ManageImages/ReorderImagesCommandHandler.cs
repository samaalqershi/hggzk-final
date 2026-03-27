using System.Threading;
using System.Threading.Tasks;
using MediatR;
using YemenBooking.Application.Features.Properties;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Interfaces;

namespace YemenBooking.Application.Features.Properties.Commands.ManageImages
{
    /// <summary>
    /// يعالج أمر إعادة ترتيب الصور.
    /// Handles the reorder images command.
    /// </summary>
    public class ReorderImagesCommandHandler : IRequestHandler<ReorderImagesCommand, ResultDto<bool>>
    {
        private readonly IPropertyImageRepository _imageRepository;
        private readonly IUnitOfWork _unitOfWork;

        /// <summary>
        /// يهيّئ مثيلاً جديداً من [ReorderImagesCommandHandler].
        /// Initializes a new instance of [ReorderImagesCommandHandler].
        /// </summary>
        public ReorderImagesCommandHandler(
            IPropertyImageRepository imageRepository,
            IUnitOfWork unitOfWork)
        {
            _imageRepository = imageRepository;
            _unitOfWork = unitOfWork;
        }
        /// <summary>
        /// يعالج أمر إعادة ترتيب الصور وفق الترتيب المطلوب.
        /// Handles reordering images to match the requested order.
        /// </summary>
        public async Task<ResultDto<bool>> Handle(ReorderImagesCommand request, CancellationToken cancellationToken)
        {
            await _unitOfWork.ExecuteInTransactionAsync(async () =>
            {
                // Batch update to minimize locks and round-trips
                var tuples = request.Assignments.ConvertAll(a => (a.ImageId, a.DisplayOrder));
                await _imageRepository.UpdateDisplayOrdersAsync(tuples, cancellationToken);
                await _imageRepository.SaveChangesAsync(cancellationToken);
            }, cancellationToken);

            return ResultDto<bool>.Ok(true, "تم إعادة ترتيب الصور بنجاح");
        }
    }
} 
