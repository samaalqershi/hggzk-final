using MediatR;
using YemenBooking.Application.Features.Sections;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Sections.Commands.ManageSectionItems
{
	/// <summary>
	/// يعالج add العقار to الأقسام ويعيد النتيجة المطلوبة.
	/// Processes the Add Property To Sections request and returns the requested result.
	/// </summary>
	public class AddPropertyToSectionsCommandHandler : IRequestHandler<AddPropertyToSectionsCommand, ResultDto>
	{
		private readonly ISectionRepository _repository;

		/// <summary>
		/// ينشئ مثيلاً جديداً من AddPropertyToSectionsCommandHandler.
		/// Initializes a new instance of AddPropertyToSectionsCommandHandler.
		/// </summary>
		/// <param name="repository">مستودع هذا العنصر / this member repository.</param>
		public AddPropertyToSectionsCommandHandler(ISectionRepository repository)
		{
			_repository = repository;
		}

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
		public async Task<ResultDto> Handle(AddPropertyToSectionsCommand request, CancellationToken cancellationToken)
		{
			foreach (var sectionId in request.SectionIds)
			{
				await _repository.AddPropertiesAsync(sectionId, new[] { request.PropertyId }, cancellationToken);
			}
			return ResultDto.Ok();
		}
	}
}