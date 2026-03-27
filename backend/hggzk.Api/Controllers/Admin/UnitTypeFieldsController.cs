using System.Collections.Generic;
using System.Threading.Tasks;
using CsvHelper.Configuration.Attributes;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.DynamicFields.Commands.CreateUnit;
using YemenBooking.Application.Features.DynamicFields.Commands.UpdateUnit;
using YemenBooking.Application.Features.DynamicFields.Commands.DeleteUnit;
using YemenBooking.Application.Features.DynamicFields.Commands.ManageFields;
using YemenBooking.Application.Features.DynamicFields.Queries.GetUnitTypeFields;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يدير الحقول الديناميكية المرتبطة بأنواع الوحدات.
    /// Manages dynamic fields associated with unit types.
    /// </summary>
    [Route("api/admin/unit-type-fields")]
    [Authorize(Roles = "Admin,Owner")]
    public class UnitTypeFieldsController : BaseAdminController
    {
        /// <summary>
        /// ينشئ المتحكم مع حقن الوسيط.
        /// Creates the controller with the mediator dependency.
        /// </summary>
        public UnitTypeFieldsController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// ينشئ حقلاً ديناميكيًا جديدًا لنوع الوحدة.
        /// Creates a new dynamic field for a unit type.
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreateUnitTypeField([FromBody] CreateUnitTypeFieldCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحدث تعريف حقل ديناميكي تابع لنوع الوحدة.
        /// Updates a dynamic field definition for the unit type.
        /// </summary>
        [HttpPut("{fieldId}")]
        public async Task<IActionResult> UpdateUnitTypeField(string fieldId, [FromBody] UpdateUnitTypeFieldCommand command)
        {
            command.FieldId = fieldId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحذف حقلًا ديناميكيًا من النظام.
        /// Deletes a dynamic field from the system.
        /// </summary>
        [HttpDelete("{fieldId}")]
        public async Task<IActionResult> DeleteUnitTypeField(string fieldId)
        {
            var command = new DeleteUnitTypeFieldCommand { FieldId = fieldId };
            var result = await _mediator.Send(command);
            return Ok(result);
        }


        /// <summary>
        /// يعيد ترتيب الحقول الديناميكية لنوع الوحدة.
        /// Reorders the dynamic fields for a unit type.
        /// </summary>
        [HttpPost("reorder")]
        public async Task<IActionResult> ReorderUnitTypeFields([FromBody] ReorderUnitTypeFieldsCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعرض الحقول الخاصة بنوع وحدة محدد مع الفلاتر المطلوبة.
        /// Returns the fields for a given unit type with the requested filters.
        /// </summary>
        [HttpGet("unit-type/{unitTypeId}")]
        public async Task<IActionResult> GetUnitTypeFields(
            string unitTypeId,
            [FromQuery] bool? isActive,
            [FromQuery] bool? isSearchable,
            [FromQuery] bool? isPublic,
            [FromQuery] bool? isForUnits,
            [FromQuery] string? category,
            [FromQuery] string? searchTerm)
        {
            var query = new GetUnitTypeFieldsQuery
            {
                unitTypeId = unitTypeId,
                IsActive = isActive,
                IsSearchable = isSearchable,
                IsPublic = isPublic,
                IsForUnits = isForUnits,
                Category = category,
                SearchTerm = searchTerm
            };
            var result = await _mediator.Send(query);
            return Ok(result);
        }

    }
} 
