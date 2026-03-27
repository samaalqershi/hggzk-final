using System.Threading;
using System.Threading.Tasks;
using MediatR;
using YemenBooking.Application.Features.Sections;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Entities;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.AuditLog.Services;

namespace YemenBooking.Application.Features.Sections.Commands.ManageImages
{
    /// <summary>
    /// يعالج reorder الوحدة in القسم الصور ويعيد النتيجة المطلوبة.
    /// Processes the Reorder Unit In Section Images request and returns the requested result.
    /// </summary>
    public class ReorderUnitInSectionImagesCommandHandler : IRequestHandler<ReorderUnitInSectionImagesCommand, ResultDto<bool>>
    {
        private readonly IUnitInSectionImageRepository _repo;
        private readonly IAuditService _auditService;
        private readonly ICurrentUserService _currentUserService;
        /// <summary>
        /// ينشئ مثيلاً جديداً من ReorderUnitInSectionImagesCommandHandler.
        /// Initializes a new instance of ReorderUnitInSectionImagesCommandHandler.
        /// </summary>
        /// <param name="repo">قيمة repo / repo value.</param>
        /// <param name="auditService">خدمة التدقيق / Audit service.</param>
        /// <param name="currentUserService">خدمة المستخدم الحالي / Current user service.</param>
        public ReorderUnitInSectionImagesCommandHandler(IUnitInSectionImageRepository repo, IAuditService auditService, ICurrentUserService currentUserService)
        {
            _repo = repo;
            _auditService = auditService;
            _currentUserService = currentUserService;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
        public async Task<ResultDto<bool>> Handle(ReorderUnitInSectionImagesCommand request, CancellationToken cancellationToken)
        {
            var tuples = request.Assignments.ConvertAll(a => (a.ImageId, a.DisplayOrder));
            var ok = await _repo.UpdateDisplayOrdersAsync(tuples, cancellationToken);
            if (ok)
            {
                await _repo.SaveChangesAsync(cancellationToken);
            }
            if (ok)
            {
                await _auditService.LogAuditAsync(
                    entityType: nameof(UnitInSectionImage),
                    entityId: System.Guid.Empty,
                    action: AuditAction.UPDATE,
                    oldValues: null,
                    newValues: System.Text.Json.JsonSerializer.Serialize(new { Reordered = true, Count = tuples.Count }),
                    performedBy: _currentUserService.UserId,
                    notes: $"تم إعادة ترتيب صور عنصر وحدة في القسم بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})",
                    cancellationToken: cancellationToken);
            }
            return ok ? ResultDto<bool>.Ok(true) : ResultDto<bool>.Failed("فشل إعادة الترتيب");
        }
    }
}
