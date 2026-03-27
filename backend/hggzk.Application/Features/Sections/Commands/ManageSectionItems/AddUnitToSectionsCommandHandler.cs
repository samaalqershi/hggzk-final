using MediatR;
using YemenBooking.Application.Features.Sections;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Sections.Commands.ManageSectionItems
{
	/// <summary>
	/// يعالج add الوحدة to الأقسام ويعيد النتيجة المطلوبة.
	/// Processes the Add Unit To Sections request and returns the requested result.
	/// </summary>
	public class AddUnitToSectionsCommandHandler : IRequestHandler<AddUnitToSectionsCommand, ResultDto>
	{
		private readonly ISectionRepository _repository;

		/// <summary>
		/// ينشئ مثيلاً جديداً من AddUnitToSectionsCommandHandler.
		/// Initializes a new instance of AddUnitToSectionsCommandHandler.
		/// </summary>
		/// <param name="repository">مستودع هذا العنصر / this member repository.</param>
		public AddUnitToSectionsCommandHandler(ISectionRepository repository)
		{
			_repository = repository;
		}

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
		public async Task<ResultDto> Handle(AddUnitToSectionsCommand request, CancellationToken cancellationToken)
		{
			foreach (var sectionId in request.SectionIds)
			{
				await _repository.AddUnitsAsync(sectionId, new[] { request.UnitId }, cancellationToken);
			}
			return ResultDto.Ok();
		}
	}
}