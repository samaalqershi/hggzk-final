using System;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Users.Commands.CreateUser;
using YemenBooking.Application.Features.Users.Commands.UpdateUser;
using YemenBooking.Application.Features.Users.Commands.ManageUserStatus;
using YemenBooking.Application.Features.Users.Commands.ManageRoles;
using YemenBooking.Application.Features.Users.Queries.SearchUsers;
using YemenBooking.Application.Features.Users.Queries.GetAllUsers;
using YemenBooking.Application.Features.Users.Queries.GetUserById;
using YemenBooking.Application.Features.Users.Queries.GetUserDetails;
using YemenBooking.Application.Features.Users.Queries.GetUsersByRole;
using YemenBooking.Application.Features.Users.Queries.GetUserStatistics;
using YemenBooking.Application.Features.Notifications.Queries.GetUserNotifications;
using YemenBooking.Application.Features.Authentication.Commands.RegisterOwner;
using YemenBooking.Application.Features.Analytics.Queries.UserAnalytics;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يدير المستخدمين وعمليات التسجيل والتعديل وتغيير الحالة وتخصيص الأدوار.
    /// Manages users, registration, edits, status changes, and role assignment.
    /// </summary>
    public class UsersController : BaseAdminController
    {
        /// <summary>
        /// ينشئ المتحكم مع حقن الوسيط.
        /// Creates the controller with the mediator dependency.
        /// </summary>
        public UsersController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// يبحث عن المستخدمين مع الفلاتر والفرز والصفحات.
        /// Searches users with filters, sorting, and pagination.
        /// </summary>
        [HttpGet("search")]
        public async Task<IActionResult> SearchUsers([FromQuery] SearchUsersQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعرض جميع المستخدمين مع خيارات البحث والفرز والصفحات.
        /// Returns all users with optional search, sorting, and pagination.
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAllUsers([FromQuery] GetAllUsersQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعرض بيانات مستخدم بحسب المعرف.
        /// Returns user details by identifier.
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetUserById(Guid id)
        {
            var query = new GetUserByIdQuery { UserId = id };
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// ينشئ مستخدمًا جديدًا.
        /// Creates a new user.
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreateUser([FromBody] CreateUserCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يسجل مالك عقار جديدًا وينشئ العقار المرتبط به.
        /// Registers a new property owner and creates the linked property.
        /// </summary>
        [AllowAnonymous]
        [HttpPost("register-owner")]
        public async Task<IActionResult> RegisterPropertyOwner([FromBody] RegisterPropertyOwnerCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحدث بيانات مستخدم موجود.
        /// Updates an existing user.
        /// </summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateUser(Guid id, [FromBody] UpdateUserCommand command)
        {
            command.UserId = id;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يفعّل حساب المستخدم.
        /// Activates a user account.
        /// </summary>
        [HttpPost("{id}/activate")]
        public async Task<IActionResult> ActivateUser(Guid id)
        {
            var command = new ActivateUserCommand { UserId = id };
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعطّل حساب المستخدم.
        /// Deactivates a user account.
        /// </summary>
        [HttpPost("{id}/deactivate")]
        public async Task<IActionResult> DeactivateUser(Guid id)
        {
            var command = new DeactivateUserCommand { UserId = id };
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يخصص دورًا لمستخدم.
        /// Assigns a role to a user.
        /// </summary>
        [HttpPost("{id}/assign-role")]
        public async Task<IActionResult> AssignUserRole(Guid id, [FromBody] AssignUserRoleCommand command)
        {
            command.UserId = id;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعرض المستخدمين بحسب الدور.
        /// Returns users by role.
        /// </summary>
        [HttpGet("by-role")]
        public async Task<IActionResult> GetUsersByRole([FromQuery] GetUsersByRoleQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعرض إحصاءات المستخدم عبر كامل الفترة.
        /// Returns lifetime statistics for a user.
        /// </summary>
        [HttpGet("{id}/lifetime-stats")]
        public async Task<IActionResult> GetUserLifetimeStats(Guid id)
        {
            var query = new GetUserLifetimeStatsQuery(id);
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعرض إشعارات المستخدم.
        /// Returns user notifications.
        /// </summary>
        [HttpGet("{id}/notifications")]
        public async Task<IActionResult> GetUserNotifications(Guid id, [FromQuery] GetUserNotificationsQuery query)
        {
            query.UserId = id;
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعرض تفاصيل مستخدم إضافية بحسب المعرف.
        /// Returns additional user details by identifier.
        /// </summary>
        [HttpGet("{id}/details")]
        public async Task<IActionResult> GetUserDetails(Guid id)
        {
            var query = new GetUserDetailsQuery { UserId = id };
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
} 
