using MediatR;
using YemenBooking.Application.Features.Sections;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Sections.Commands.ManageSectionItems
{
	/// <summary>
	/// يعالج assign القسم العناصر ويعيد النتيجة المطلوبة.
	/// Processes the Assign Section Items request and returns the requested result.
	/// </summary>
	public class AssignSectionItemsCommandHandler : IRequestHandler<AssignSectionItemsCommand, ResultDto>
	{
		private readonly ISectionRepository _repository;

		/// <summary>
		/// ينشئ مثيلاً جديداً من AssignSectionItemsCommandHandler.
		/// Initializes a new instance of AssignSectionItemsCommandHandler.
		/// </summary>
		/// <param name="repository">مستودع هذا العنصر / this member repository.</param>
		public AssignSectionItemsCommandHandler(ISectionRepository repository)
		{
			_repository = repository;
		}

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
        public async Task<ResultDto> Handle(AssignSectionItemsCommand request, CancellationToken cancellationToken)
        {
            if (request.PropertyIds.Count > 0)
            {
                await _repository.AssignPropertiesAsync(request.SectionId, request.PropertyIds, cancellationToken);
            }
            else if (request.UnitIds.Count > 0)
            {
                await _repository.AssignUnitsAsync(request.SectionId, request.UnitIds, cancellationToken);
            }
            else
            {
                // Clear rich items when both lists are empty
                await _repository.AssignPropertyItemsAsync(request.SectionId, Array.Empty<PropertyInSection>(), cancellationToken);
                await _repository.AssignUnitItemsAsync(request.SectionId, Array.Empty<UnitInSection>(), cancellationToken);
            }
            await _repository.SaveChangesAsync(cancellationToken);
            return ResultDto.Ok();
        }
	}
}
