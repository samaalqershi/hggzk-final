using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Sections.Commands.ManageSections
{
	/// <summary>
	/// أمر حذف القسم.
	/// Delete Section command.
	/// </summary>
	public class DeleteSectionCommand : IRequest<ResultDto>
	{
		/// <summary>
		/// معرّف القسم.
		/// Section identifier.
		/// </summary>
		public Guid SectionId { get; set; }
	}
}