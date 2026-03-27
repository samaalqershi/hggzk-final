using System.Threading;
using System.Threading.Tasks;
using MediatR;
using YemenBooking.Application.Features.Sections;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Sections.Commands.DeleteProperty
{
    /// <summary>
    /// يعالج حذف العقار in القسم الصورة ويعيد النتيجة المطلوبة.
    /// Processes the Delete Property In Section Image request and returns the requested result.
    /// </summary>
    public class DeletePropertyInSectionImageCommandHandler : IRequestHandler<DeletePropertyInSectionImageCommand, ResultDto<bool>>
    {
        private readonly IPropertyInSectionImageRepository _repo;
        private readonly IFileStorageService _files;
        /// <summary>
        /// ينشئ مثيلاً جديداً من DeletePropertyInSectionImageCommandHandler.
        /// Initializes a new instance of DeletePropertyInSectionImageCommandHandler.
        /// </summary>
        /// <param name="repo">قيمة repo / repo value.</param>
        /// <param name="files">قيمة الملفات / files value.</param>
        public DeletePropertyInSectionImageCommandHandler(IPropertyInSectionImageRepository repo, IFileStorageService files)
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
        public async Task<ResultDto<bool>> Handle(DeletePropertyInSectionImageCommand request, CancellationToken cancellationToken)
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

