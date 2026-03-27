using MediatR;
using YemenBooking.Application.Features.Sections;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Sections.Commands.ManageSectionItems
{
    /// <summary>
    /// يعالج إزالة العناصر from القسم ويعيد النتيجة المطلوبة.
    /// Processes the Remove Items From Section request and returns the requested result.
    /// </summary>
    public class RemoveItemsFromSectionCommandHandler : IRequestHandler<RemoveItemsFromSectionCommand, ResultDto>
    {
        private readonly ISectionRepository _repository;

        /// <summary>
        /// ينشئ مثيلاً جديداً من RemoveItemsFromSectionCommandHandler.
        /// Initializes a new instance of RemoveItemsFromSectionCommandHandler.
        /// </summary>
        /// <param name="repository">مستودع هذا العنصر / this member repository.</param>
        public RemoveItemsFromSectionCommandHandler(ISectionRepository repository)
        {
            _repository = repository;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
        public async Task<ResultDto> Handle(RemoveItemsFromSectionCommand request, CancellationToken cancellationToken)
        {
            foreach (var id in request.ItemIds)
            {
                await _repository.RemoveItemAsync(request.SectionId, id, cancellationToken);
            }
            await _repository.SaveChangesAsync(cancellationToken);
            return ResultDto.Ok();
        }
    }
}
