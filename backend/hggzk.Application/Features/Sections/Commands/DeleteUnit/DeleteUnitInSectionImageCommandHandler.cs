using System.Threading;
using System.Threading.Tasks;
using MediatR;
using YemenBooking.Application.Features.Sections;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Entities;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.AuditLog.Services;

namespace YemenBooking.Application.Features.Sections.Commands.DeleteUnit
{
    /// <summary>
    /// يعالج حذف الوحدة in القسم الصورة ويعيد النتيجة المطلوبة.
    /// Processes the Delete Unit In Section Image request and returns the requested result.
    /// </summary>
    public class DeleteUnitInSectionImageCommandHandler : IRequestHandler<DeleteUnitInSectionImageCommand, ResultDto<bool>>
    {
        private readonly IUnitInSectionImageRepository _repo;
        private readonly IFileStorageService _files;
        private readonly IAuditService _auditService;
        private readonly ICurrentUserService _currentUserService;
        /// <summary>
        /// ينشئ مثيلاً جديداً من DeleteUnitInSectionImageCommandHandler.
        /// Initializes a new instance of DeleteUnitInSectionImageCommandHandler.
        /// </summary>
        /// <param name="repo">قيمة repo / repo value.</param>
        /// <param name="files">قيمة الملفات / files value.</param>
        /// <param name="auditService">خدمة التدقيق / Audit service.</param>
        /// <param name="currentUserService">خدمة المستخدم الحالي / Current user service.</param>
        public DeleteUnitInSectionImageCommandHandler(IUnitInSectionImageRepository repo, IFileStorageService files, IAuditService auditService, ICurrentUserService currentUserService)
        {
            _repo = repo;
            _files = files;
            _auditService = auditService;
            _currentUserService = currentUserService;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
        public async Task<ResultDto<bool>> Handle(DeleteUnitInSectionImageCommand request, CancellationToken cancellationToken)
        {
            var entity = await _repo.GetByIdAsync(request.ImageId, cancellationToken);
            if (entity == null) return ResultDto<bool>.Failed("الصورة غير موجودة");
            var url = entity.Url;
            var ok = await _repo.DeleteAsync(request.ImageId, cancellationToken);
            if (ok)
            {
                await _repo.SaveChangesAsync(cancellationToken);
            }
            if (ok && request.Permanent && !string.IsNullOrWhiteSpace(url))
            {
                await _files.DeleteFileAsync(url!, cancellationToken);
            }
            if (ok)
            {
                await _auditService.LogAuditAsync(
                    entityType: nameof(UnitInSectionImage),
                    entityId: entity.UnitInSectionId ?? System.Guid.Empty,
                    action: AuditAction.DELETE,
                    oldValues: System.Text.Json.JsonSerializer.Serialize(new { entity.Id, entity.Name, entity.Url }),
                    newValues: null,
                    performedBy: _currentUserService.UserId,
                    notes: $"تم حذف صورة عنصر وحدة في القسم بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})",
                    cancellationToken: cancellationToken);
            }
            return ResultDto<bool>.Ok(ok);
        }
    }
}
