using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Sections.Commands.ManageSectionItems
{
	/// <summary>
	/// أمر add الوحدة to الأقسام.
	/// Add Unit To Sections command.
	/// </summary>
	public class AddUnitToSectionsCommand : IRequest<ResultDto>
	{
		/// <summary>
		/// معرّف الوحدة.
		/// Unit identifier.
		/// </summary>
		public Guid UnitId { get; set; }
		/// <summary>
		/// معرّفات القسم.
		/// Section identifiers.
		/// </summary>
		public List<Guid> SectionIds { get; set; } = new();
	}
}