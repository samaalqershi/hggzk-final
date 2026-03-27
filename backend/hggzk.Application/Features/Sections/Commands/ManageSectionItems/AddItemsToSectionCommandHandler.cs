using MediatR;
using YemenBooking.Application.Features.Sections;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Sections.Commands.ManageSectionItems
{
    /// <summary>
    /// يعالج add العناصر to القسم ويعيد النتيجة المطلوبة.
    /// Processes the Add Items To Section request and returns the requested result.
    /// </summary>
    public class AddItemsToSectionCommandHandler : IRequestHandler<AddItemsToSectionCommand, ResultDto>
    {
        private readonly ISectionRepository _repository;

        /// <summary>
        /// ينشئ مثيلاً جديداً من AddItemsToSectionCommandHandler.
        /// Initializes a new instance of AddItemsToSectionCommandHandler.
        /// </summary>
        /// <param name="repository">مستودع هذا العنصر / this member repository.</param>
        public AddItemsToSectionCommandHandler(ISectionRepository repository)
        {
            _repository = repository;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
        public async Task<ResultDto> Handle(AddItemsToSectionCommand request, CancellationToken cancellationToken)
        {
            if (request.PropertyIds?.Count > 0)
                await _repository.AddPropertiesAsync(request.SectionId, request.PropertyIds, cancellationToken);
            if (request.UnitIds?.Count > 0)
                await _repository.AddUnitsAsync(request.SectionId, request.UnitIds, cancellationToken);
            if ((request.PropertyIds?.Count ?? 0) > 0 || (request.UnitIds?.Count ?? 0) > 0)
                await _repository.SaveChangesAsync(cancellationToken);
            return ResultDto.Ok();
        }
    }
}
