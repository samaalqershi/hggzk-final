using System;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Staffs.Commands.ManageStaff;
using YemenBooking.Application.Features.Staffs.Queries.GetStaffByUser;
using YemenBooking.Application.Features.Staffs.Queries.GetStaffByProperty;
using YemenBooking.Application.Features.Staffs.Queries.GetStaffByPosition;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يدير سجلات الموظفين وعمليات الإضافة والتعديل والحذف والاستعلام.
    /// Manages staff records for create, update, delete, and lookup operations.
    /// </summary>
    public class StaffController : BaseAdminController
    {
        /// <summary>
        /// ينشئ المتحكم مع حقن الوسيط.
        /// Creates the controller with the mediator dependency.
        /// </summary>
        public StaffController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// يضيف عضوًا جديدًا إلى طاقم العمل.
        /// Adds a new staff member.
        /// </summary>
        [HttpPost("add")]
        public async Task<IActionResult> AddStaff([FromBody] AddStaffCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحدث بيانات موظف موجود.
        /// Updates an existing staff member.
        /// </summary>
        [HttpPut("update")]
        public async Task<IActionResult> UpdateStaff([FromBody] UpdateStaffCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يزيل موظفًا من السجل.
        /// Removes a staff member from the system.
        /// </summary>
        [HttpPost("remove")]
        public async Task<IActionResult> RemoveStaff([FromBody] RemoveStaffCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعرض الموظفين بحسب المنصب.
        /// Returns staff members by position.
        /// </summary>
        [HttpGet("by-position")]
        public async Task<IActionResult> GetStaffByPosition([FromQuery] GetStaffByPositionQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعرض الموظفين المرتبطين بعقار محدد.
        /// Returns staff members linked to a specific property.
        /// </summary>
        [HttpGet("by-property")]
        public async Task<IActionResult> GetStaffByProperty([FromQuery] GetStaffByPropertyQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعرض الموظفين المرتبطين بمستخدم محدد، عادةً المالك.
        /// Returns staff members linked to a specific user, typically the owner.
        /// </summary>
        [HttpGet("by-user")]
        public async Task<IActionResult> GetStaffByUser([FromQuery] GetStaffByUserQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
} 
