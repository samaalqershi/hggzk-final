using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Sections;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Features.Sections.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Sections.Queries.GetSections
{
	/// <summary>
	/// استعلام جلب الأقسام.
	/// Get Sections query.
	/// </summary>
	public class GetSectionsQuery : PaginationDto, IRequest<PaginatedResult<SectionDto>>
	{
		/// <summary>
		/// القيمة الخاصة بـ target.
		/// Target value.
		/// </summary>
		public SectionTarget? Target { get; set; }
		/// <summary>
		/// النوع.
		/// Type.
		/// </summary>
		public SectionType? Type { get; set; }
		/// <summary>
		/// نوع المحتوى.
		/// Content type.
		/// </summary>
		public ContentType? ContentType { get; set; }
		/// <summary>
		/// اسم المدينة.
		/// City name.
		/// </summary>
		public string? CityName { get; set; }
	}
}