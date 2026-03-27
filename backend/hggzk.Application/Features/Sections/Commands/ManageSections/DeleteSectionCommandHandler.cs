using MediatR;
using YemenBooking.Application.Features.Sections;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Sections.Commands.ManageSections
{
	/// <summary>
	/// يعالج حذف القسم ويعيد النتيجة المطلوبة.
	/// Processes the Delete Section request and returns the requested result.
	/// </summary>
	public class DeleteSectionCommandHandler : IRequestHandler<DeleteSectionCommand, ResultDto>
	{
		private readonly ISectionRepository _repository;

		/// <summary>
		/// ينشئ مثيلاً جديداً من DeleteSectionCommandHandler.
		/// Initializes a new instance of DeleteSectionCommandHandler.
		/// </summary>
		/// <param name="repository">مستودع هذا العنصر / this member repository.</param>
		public DeleteSectionCommandHandler(ISectionRepository repository)
		{
			_repository = repository;
		}

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
		public async Task<ResultDto> Handle(DeleteSectionCommand request, CancellationToken cancellationToken)
		{
			var ok = await _repository.DeleteAsync(request.SectionId, cancellationToken);
            if (ok)
            {
                await _repository.SaveChangesAsync(cancellationToken);
            }
			return ok ? ResultDto.Ok() : ResultDto.Failure("Section not found");
		}
	}
}
