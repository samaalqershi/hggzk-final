using System;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using YemenBooking.Application.Features.Policies.Commands.ManagePolicies;
using YemenBooking.Application.Features.Policies.Commands.CreateProperty;
using YemenBooking.Application.Features.Policies.Commands.UpdateProperty;
using YemenBooking.Application.Features.Policies.Commands.DeleteProperty;
using YemenBooking.Application.Features.Policies.Queries.GetPropertyPolicies;
using YemenBooking.Application.Features.Policies.Queries.GetAllPolicies;
using YemenBooking.Application.Features.Policies.Queries.GetPoliciesByType;
using YemenBooking.Application.Features.Policies.Queries.GetPolicyStats;
using YemenBooking.Application.Features.Policies.Queries.GetPolicyById;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يدير السياسات التشغيلية الخاصة بالعقار مثل الدفع والإلغاء والدخول.
    /// Manages property operational policies such as payment, cancellation, and check-in.
    /// </summary>
    [ApiController]
    [Route("api/admin/[controller]")]
    [Authorize(Roles = "Admin,Owner")]
    public class PropertyPoliciesController : ControllerBase
    {
        /// <summary>
        /// وسيط تنفيذ الأوامر والاستعلامات.
        /// Mediator for commands and queries.
        /// </summary>
        private readonly IMediator _mediator;

        /// <summary>
        /// ينشئ المتحكم مع حقن الوسيط.
        /// Creates the controller with the mediator dependency.
        /// </summary>
        public PropertyPoliciesController(IMediator mediator)
        {
            _mediator = mediator;
        }

        /// <summary>
        /// ينشئ سياسة عقار جديدة.
        /// Creates a new property policy.
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreatePropertyPolicy([FromBody] CreatePropertyPolicyCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحدث سياسة عقار موجودة.
        /// Updates an existing property policy.
        /// </summary>
        [HttpPut("{policyId}")]
        public async Task<IActionResult> UpdatePropertyPolicy(Guid policyId, [FromBody] UpdatePropertyPolicyCommand command)
        {
            command.PolicyId = policyId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحذف سياسة عقار من النظام.
        /// Deletes a property policy from the system.
        /// </summary>
        [HttpDelete("{policyId}")]
        public async Task<IActionResult> DeletePropertyPolicy(Guid policyId)
        {
            var command = new DeletePropertyPolicyCommand { PolicyId = policyId };
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعرض سياسات العقار المرتبطة بمعيار البحث الحالي.
        /// Returns property policies matching the current query.
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetPropertyPolicies([FromQuery] GetPropertyPoliciesQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعرض سياسة عقار محددة بحسب المعرف.
        /// Returns a property policy by identifier.
        /// </summary>
        [HttpGet("{policyId}")]
        public async Task<IActionResult> GetPolicyById(Guid policyId)
        {
            var query = new GetPolicyByIdQuery { PolicyId = policyId };
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعرض السياسات بحسب النوع مع دعم الصفحات.
        /// Returns policies by type with pagination support.
        /// </summary>
        [HttpGet("by-type")]
        public async Task<IActionResult> GetPoliciesByType([FromQuery] GetPoliciesByTypeQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعرض جميع السياسات مع دعم الصفحات.
        /// Returns all policies with pagination support.
        /// </summary>
        [HttpGet("all")]
        public async Task<IActionResult> GetAllPolicies([FromQuery] GetAllPoliciesQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يبدّل حالة تفعيل السياسة.
        /// Toggles the policy's active status.
        /// </summary>
        [HttpPatch("{policyId}/toggle-status")]
        public async Task<IActionResult> TogglePolicyStatus(Guid policyId)
        {
            var command = new TogglePolicyStatusCommand { PolicyId = policyId };
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعرض إحصاءات السياسات وملخصاتها.
        /// Returns policy statistics and summaries.
        /// </summary>
        [HttpGet("stats")]
        public async Task<IActionResult> GetPolicyStats([FromQuery] GetPolicyStatsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
} 
