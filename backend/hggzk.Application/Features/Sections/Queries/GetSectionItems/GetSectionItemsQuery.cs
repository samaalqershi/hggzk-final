using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.SearchAndFilters;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Sections.Queries.GetSectionItems
{
	/// <summary>
	/// استعلام جلب القسم العناصر.
	/// Get Section Items query.
	/// </summary>
	public class GetSectionItemsQuery : PaginationDto, IRequest<PaginatedResult<object>>
	{
		/// <summary>
		/// معرّف القسم.
		/// Section identifier.
		/// </summary>
		public Guid SectionId { get; set; }
	}
}