using System;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Users.Commands.ManageRoles;
using YemenBooking.Application.Features.Users.Queries.GetAllRoles;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يدير أدوار المستخدمين وصلاحيات الوصول المرتبطة بها.
    /// Manages user roles and their associated access permissions.
    /// </summary>
    public class RolesController : BaseAdminController
    {
        /// <summary>
        /// ينشئ المتحكم مع وسيط التنفيذ المشترك.
        /// Creates the controller with the shared mediator.
        /// </summary>
        public RolesController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// ينشئ دورًا جديدًا في النظام.
        /// Creates a new role in the system.
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreateRole([FromBody] CreateRoleCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحدث بيانات دور موجود.
        /// Updates an existing role.
        /// </summary>
        [HttpPut("{roleId}")]
        public async Task<IActionResult> UpdateRole(Guid roleId, [FromBody] UpdateRoleCommand command)
        {
            command.RoleId = roleId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحذف دورًا من النظام.
        /// Deletes a role from the system.
        /// </summary>
        [HttpDelete("{roleId}")]
        public async Task<IActionResult> DeleteRole(Guid roleId)
        {
            var command = new DeleteRoleCommand { RoleId = roleId };
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعرض جميع الأدوار مع دعم الصفحات.
        /// Returns all roles with pagination support.
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAllRoles([FromQuery] GetAllRolesQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
} 
