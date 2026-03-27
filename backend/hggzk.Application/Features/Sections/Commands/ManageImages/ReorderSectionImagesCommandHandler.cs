using System.Threading;
using System.Threading.Tasks;
using MediatR;
using YemenBooking.Application.Features.Sections;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Sections.Commands.ManageImages
{
    /// <summary>
    /// يعالج reorder القسم الصور ويعيد النتيجة المطلوبة.
    /// Processes the Reorder Section Images request and returns the requested result.
    /// </summary>
    public class ReorderSectionImagesCommandHandler : IRequestHandler<ReorderSectionImagesCommand, ResultDto<bool>>
    {
        private readonly ISectionImageRepository _repo;
        /// <summary>
        /// ينشئ مثيلاً جديداً من ReorderSectionImagesCommandHandler.
        /// Initializes a new instance of ReorderSectionImagesCommandHandler.
        /// </summary>
        /// <param name="repo">قيمة repo / repo value.</param>
        public ReorderSectionImagesCommandHandler(ISectionImageRepository repo) { _repo = repo; }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
        public async Task<ResultDto<bool>> Handle(ReorderSectionImagesCommand request, CancellationToken cancellationToken)
        {
            var tuples = request.Assignments.ConvertAll(a => (a.ImageId, a.DisplayOrder));
            var ok = await _repo.UpdateDisplayOrdersAsync(tuples, cancellationToken);
            if (ok)
            {
                await _repo.SaveChangesAsync(cancellationToken);
            }
            return ok ? ResultDto<bool>.Ok(true) : ResultDto<bool>.Failed("فشل إعادة الترتيب");
        }
    }
}
