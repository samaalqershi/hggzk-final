using System;
using System.Collections.Generic;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Sections.Commands.ManageSectionItems
{
	/// <summary>
	/// أمر assign القسم العناصر.
	/// Assign Section Items command.
	/// </summary>
	public class AssignSectionItemsCommand : IRequest<ResultDto>
	{
		/// <summary>
		/// معرّف القسم.
		/// Section identifier.
		/// </summary>
		public Guid SectionId { get; set; }
		/// <summary>
		/// معرّفات العقار.
		/// Property identifiers.
		/// </summary>
		public List<Guid> PropertyIds { get; set; } = new();
		/// <summary>
		/// معرّفات الوحدة.
		/// Unit identifiers.
		/// </summary>
		public List<Guid> UnitIds { get; set; } = new();
	}
}