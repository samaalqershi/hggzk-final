using MediatR;
using YemenBooking.Application.Features.Sections;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Sections.Commands.ManageSectionItems
{
    /// <summary>
    /// يعالج تحديث العنصر الترتيب ويعيد النتيجة المطلوبة.
    /// Processes the Update Item Order request and returns the requested result.
    /// </summary>
    public class UpdateItemOrderCommandHandler : IRequestHandler<UpdateItemOrderCommand, ResultDto>
    {
        private readonly ISectionRepository _repository;

        /// <summary>
        /// ينشئ مثيلاً جديداً من UpdateItemOrderCommandHandler.
        /// Initializes a new instance of UpdateItemOrderCommandHandler.
        /// </summary>
        /// <param name="repository">مستودع هذا العنصر / this member repository.</param>
        public UpdateItemOrderCommandHandler(ISectionRepository repository)
        {
            _repository = repository;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
        public async Task<ResultDto> Handle(UpdateItemOrderCommand request, CancellationToken cancellationToken)
        {
            var orders = request.Orders.Select(o => (o.ItemId, o.SortOrder)).ToList();
            await _repository.ReorderItemsAsync(request.SectionId, orders, cancellationToken);
            await _repository.SaveChangesAsync(cancellationToken);
            return ResultDto.Ok();
        }
    }
}
