using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Sections.Queries.GetActiveSectionsForHome;
using YemenBooking.Application.Features.Sections.Queries.GetSectionItems;

namespace YemenBooking.Api.Controllers.Client
{
	/// <summary>
	/// يوفر أقسام الصفحة الرئيسية والعناصر التابعة لها.
	/// Exposes home sections and their items.
	/// </summary>
	public class SectionsController : BaseClientController
	{
		/// <summary>
		/// ينشئ مثيلاً جديداً من <see cref="SectionsController"/>.
		/// Creates a new <see cref="SectionsController"/> instance.
		/// </summary>
		public SectionsController(IMediator mediator) : base(mediator) { }


		

		/// <summary>
		/// يجلب الأقسام النشطة للصفحة الرئيسية.
		/// Retrieves the active home sections.
		/// </summary>
		[HttpGet]
		[AllowAnonymous]
		public async Task<IActionResult> GetSections([FromQuery] GetActiveSectionsForHomeQuery query)
		{
			var result = await _mediator.Send(query);
			return Ok(result);
		}

        /// <summary>
        /// يجلب عناصر قسم محدد.
        /// Retrieves items for a specific section.
        /// </summary>
        [HttpGet("{sectionId}/items")]
        [AllowAnonymous]
        public async Task<IActionResult> GetSectionItems(Guid sectionId, [FromQuery] GetSectionItemsQuery query)
        {
            query.SectionId = sectionId;
            var result = await _mediator.Send(query);
            return Ok(result);
        }
		
	}
}
