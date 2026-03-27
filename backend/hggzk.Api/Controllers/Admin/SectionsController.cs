using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Sections.Commands.ManageSections;
using YemenBooking.Application.Features.Sections.Commands.ManageSectionItems;
using YemenBooking.Application.Features.Sections.Queries.GetSections;
using YemenBooking.Application.Features.Sections.Queries.GetSectionById;

namespace YemenBooking.Api.Controllers.Admin
{
	/// <summary>
	/// يدير الأقسام وإسناد العناصر وإعادة ترتيبها.
	/// Manages sections, item assignments, and ordering.
	/// </summary>
	public class SectionsController : BaseAdminController
	{
		/// <summary>
		/// ينشئ المتحكم مع حقن الوسيط.
		/// Creates the controller with the mediator dependency.
		/// </summary>
		public SectionsController(IMediator mediator) : base(mediator) { }

		/// <summary>
		/// يعرض قائمة الأقسام.
		/// Returns the section list.
		/// </summary>
		[HttpGet]
		public async Task<IActionResult> GetSections([FromQuery] GetSectionsQuery query)
		{
			var result = await _mediator.Send(query);
			return Ok(result);
		}

		/// <summary>
		/// يعرض قسمًا محددًا بحسب المعرف.
		/// Returns a specific section by identifier.
		/// </summary>
		[HttpGet("{sectionId}")]
		public async Task<IActionResult> GetSectionById(Guid sectionId)
		{
			var result = await _mediator.Send(new GetSectionByIdQuery { SectionId = sectionId });
			return Ok(result);
		}

		/// <summary>
		/// ينشئ قسمًا جديدًا.
		/// Creates a new section.
		/// </summary>
		[HttpPost]
		public async Task<IActionResult> CreateSection([FromBody] CreateSectionCommand command)
		{
			var result = await _mediator.Send(command);
			return Ok(result);
		}

		/// <summary>
		/// يبدّل حالة القسم.
		/// Toggles the section status.
		/// </summary>
		[HttpPost("{sectionId}/toggle-status")]
		public async Task<IActionResult> ToggleStatus(Guid sectionId, [FromBody] ToggleSectionStatusCommand command)
		{
			command.SectionId = sectionId;
			var result = await _mediator.Send(command);
			return Ok(result);
		}

		/// <summary>
		/// يحدث بيانات قسم موجود.
		/// Updates an existing section.
		/// </summary>
		[HttpPut("{sectionId}")]
		public async Task<IActionResult> UpdateSection(Guid sectionId, [FromBody] UpdateSectionCommand command)
		{
			command.SectionId = sectionId;
			var result = await _mediator.Send(command);
			return Ok(result);
		}

		/// <summary>
		/// يحذف قسمًا من النظام.
		/// Deletes a section from the system.
		/// </summary>
		[HttpDelete("{sectionId}")]
		public async Task<IActionResult> DeleteSection(Guid sectionId)
		{
			var result = await _mediator.Send(new DeleteSectionCommand { SectionId = sectionId });
			return Ok(result);
		}

        /// <summary>
        /// يخصص عناصر للقسم.
        /// Assigns items to a section.
        /// </summary>
        [HttpPost("{sectionId}/assign-items")]
        public async Task<IActionResult> AssignItems(Guid sectionId, [FromBody] AssignSectionItemsCommand command)
        {
            command.SectionId = sectionId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

		/// <summary>
		/// يضيف عناصر إلى القسم.
		/// Adds items to the section.
		/// </summary>
		[HttpPost("{sectionId}/add-items")]
		public async Task<IActionResult> AddItems(Guid sectionId, [FromBody] AddItemsToSectionCommand command)
		{
			command.SectionId = sectionId;
			var result = await _mediator.Send(command);
			return Ok(result);
		}

        /// <summary>
        /// يزيل عناصر من القسم.
        /// Removes items from the section.
        /// </summary>
        [HttpPost("{sectionId}/remove-items")]
        public async Task<IActionResult> RemoveItems(Guid sectionId, [FromBody] RemoveItemsFromSectionCommand command)
        {
            command.SectionId = sectionId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

		/// <summary>
		/// يعيد ترتيب عناصر القسم.
		/// Reorders the section items.
		/// </summary>
		[HttpPost("{sectionId}/reorder-items")]
		public async Task<IActionResult> ReorderItems(Guid sectionId, [FromBody] UpdateItemOrderCommand command)
		{
			command.SectionId = sectionId;
			var result = await _mediator.Send(command);
			return Ok(result);
		}
	}
}
