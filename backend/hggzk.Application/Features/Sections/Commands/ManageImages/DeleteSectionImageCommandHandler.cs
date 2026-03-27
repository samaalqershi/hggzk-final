using System.Threading;
using System.Threading.Tasks;
using MediatR;
using YemenBooking.Application.Features.Sections;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Sections.Commands.ManageImages
{
    /// <summary>
    /// يعالج حذف القسم الصورة ويعيد النتيجة المطلوبة.
    /// Processes the Delete Section Image request and returns the requested result.
    /// </summary>
    public class DeleteSectionImageCommandHandler : IRequestHandler<DeleteSectionImageCommand, ResultDto<bool>>
    {
        private readonly ISectionImageRepository _repo;
        private readonly IFileStorageService _files;
        /// <summary>
        /// ينشئ مثيلاً جديداً من DeleteSectionImageCommandHandler.
        /// Initializes a new instance of DeleteSectionImageCommandHandler.
        /// </summary>
        /// <param name="repo">قيمة repo / repo value.</param>
        /// <param name="files">قيمة الملفات / files value.</param>
        public DeleteSectionImageCommandHandler(ISectionImageRepository repo, IFileStorageService files)
        {
            _repo = repo;
            _files = files;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
        public async Task<ResultDto<bool>> Handle(DeleteSectionImageCommand request, CancellationToken cancellationToken)
        {
            var entity = await _repo.GetByIdAsync(request.ImageId, cancellationToken);
            if (entity == null) return ResultDto<bool>.Failed("الصورة غير موجودة");
            var url = entity.Url;
            var ok = await _repo.DeleteAsync(request.ImageId, cancellationToken);
            if (ok && request.Permanent && !string.IsNullOrWhiteSpace(url))
            {
                await _files.DeleteFileAsync(url!, cancellationToken);
            }
            return ResultDto<bool>.Ok(ok);
        }
    }
}

