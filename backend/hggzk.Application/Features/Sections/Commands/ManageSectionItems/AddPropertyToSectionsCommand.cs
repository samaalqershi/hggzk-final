using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Sections.Commands.ManageSectionItems
{
	/// <summary>
	/// أمر add العقار to الأقسام.
	/// Add Property To Sections command.
	/// </summary>
	public class AddPropertyToSectionsCommand : IRequest<ResultDto>
	{
		/// <summary>
		/// معرّف العقار.
		/// Property identifier.
		/// </summary>
		public Guid PropertyId { get; set; }
		/// <summary>
		/// معرّفات القسم.
		/// Section identifiers.
		/// </summary>
		public List<Guid> SectionIds { get; set; } = new();
	}
}