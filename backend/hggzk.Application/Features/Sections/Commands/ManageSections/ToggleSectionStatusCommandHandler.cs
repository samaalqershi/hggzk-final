using MediatR;
using YemenBooking.Application.Features.Sections;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Sections.Commands.ManageSections
{
    /// <summary>
    /// يعالج toggle القسم الحالة ويعيد النتيجة المطلوبة.
    /// Processes the Toggle Section Status request and returns the requested result.
    /// </summary>
    public class ToggleSectionStatusCommandHandler : IRequestHandler<ToggleSectionStatusCommand, ResultDto>
    {
        private readonly ISectionRepository _repository;

        /// <summary>
        /// ينشئ مثيلاً جديداً من ToggleSectionStatusCommandHandler.
        /// Initializes a new instance of ToggleSectionStatusCommandHandler.
        /// </summary>
        /// <param name="repository">مستودع هذا العنصر / this member repository.</param>
        public ToggleSectionStatusCommandHandler(ISectionRepository repository)
        {
            _repository = repository;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
        public async Task<ResultDto> Handle(ToggleSectionStatusCommand request, CancellationToken cancellationToken)
        {
            var entity = await _repository.GetByIdAsync(request.SectionId, cancellationToken);
            if (entity == null) return ResultDto.Failure("Section not found");
            entity.IsActive = request.IsActive;
            await _repository.UpdateAsync(entity, cancellationToken);
            await _repository.SaveChangesAsync(cancellationToken);
            return ResultDto.Ok();
        }
    }
}
