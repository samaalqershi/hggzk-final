using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Properties.Commands.PropertyToWishlist;
using YemenBooking.Application.Features.Properties.Commands.UpdateProperty;
using YemenBooking.Application.Features.Properties.Queries.SearchProperties;
using YemenBooking.Application.Features.Properties.Queries.GetPropertyDetails;
using YemenBooking.Application.Features.Properties.Queries.GetNearbyProperties;
using YemenBooking.Application.Features.Properties.Queries.GetCheckPropertyAvailability;
using YemenBooking.Application.Features.Policies.Queries.GetPropertyPolicies;
using YemenBooking.Application.Features.Policies.DTOs;
using YemenBooking.Application.Features.SearchAndFilters.DTOs;
using YemenBooking.Application.Features.Properties.DTOs;
using PropertyDetailsDto = YemenBooking.Application.Features.Properties.DTOs.PropertyDetailsDto;
using NearbyPropertyDto = YemenBooking.Application.Features.Properties.DTOs.NearbyPropertyDto;
using YemenBooking.Application.Common.Models;
using System.Collections.Generic;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// متحكم إدارة العقارات المخصص للعملاء.
    /// Client property management controller.
    /// </summary>
    public class PropertiesController : BaseClientController
    {
        /// <summary>
        /// المسجل التشخيصي للمتحكم.
        /// Diagnostic logger for the controller.
        /// </summary>
        private readonly ILogger<PropertiesController> _logger;

        /// <summary>
        /// يهيئ نسخة جديدة من [PropertiesController].
        /// Initializes a new instance of [PropertiesController].
        /// </summary>
        /// <param name="mediator">وسيط MediatR المستخدم لمعالجة الطلبات. MediatR mediator used to handle requests.</param>
        /// <param name="logger">المسجل التشخيصي. Diagnostic logger.</param>
        public PropertiesController(IMediator mediator, ILogger<PropertiesController> logger) : base(mediator)
        {
            _logger = logger;
        }

        /// <summary>
        /// يضيف عقارًا إلى قائمة الرغبات الخاصة بالعميل.
        /// Adds a property to the client's wishlist.
        /// </summary>
        /// <param name="command">بيانات الإضافة إلى قائمة الرغبات. Wishlist entry details.</param>
        /// <returns>نتيجة الإضافة. Add result.</returns>
        [HttpPost("wishlist")]
        public async Task<ActionResult<ResultDto<bool>>> AddToWishlist([FromBody] ClientAddPropertyToWishlistCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحدّث عدد مشاهدات العقار.
        /// Updates the property view count.
        /// </summary>
        /// <param name="command">بيانات العقار. Property details.</param>
        /// <returns>نتيجة التحديث. Update result.</returns>
        [HttpPost("view-count")]
        public async Task<ActionResult<ResultDto<bool>>> UpdateViewCount([FromBody] ClientUpdatePropertyViewCountCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يبحث في العقارات عبر GET.
        /// Searches properties using GET.
        /// </summary>
        /// <param name="query">معايير البحث. Search parameters.</param>
        /// <returns>نتائج البحث. Search results.</returns>
        [HttpGet("search")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<SearchPropertiesResponse>>> SearchProperties([FromQuery] SearchPropertiesQuery query)
        {
            // ━━━ Logging تشخيصي للحقول الديناميكية عند استقبال الطلب ━━━
            _logger.LogInformation("🔍 [Controller] استقبال طلب البحث GET /api/client/properties/search");
            
            if (query.DynamicFieldFilters != null)
            {
                _logger.LogInformation(
                    "📥 [Controller] DynamicFieldFilters استُقبل بـ {Count} حقل",
                    query.DynamicFieldFilters.Count);
                
                foreach (var filter in query.DynamicFieldFilters)
                {
                    _logger.LogInformation(
                        "   • [{Key}] = [{Value}] (Type: {Type})",
                        filter.Key,
                        filter.Value,
                        filter.Value?.GetType().Name ?? "null");
                }
            }
            else
            {
                _logger.LogWarning("⚠️ [Controller] DynamicFieldFilters = NULL في الطلب!");
            }
            
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يبحث في العقارات عبر POST مع دعم الفلاتر المعقدة في جسم الطلب.
        /// Searches properties via POST and supports complex filters in the request body.
        /// </summary>
        /// <param name="query">معايير البحث. Search parameters.</param>
        /// <returns>نتائج البحث. Search results.</returns>
        [HttpPost("search")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<SearchPropertiesResponse>>> SearchPropertiesPost([FromBody] SearchPropertiesQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعيد تفاصيل عقار محدد.
        /// Returns the details of a specific property.
        /// </summary>
        /// <param name="id">معرف العقار. Property identifier.</param>
        /// <param name="userId">معرف المستخدم اختياريًا. Optional user identifier.</param>
        /// <returns>تفاصيل العقار. Property details.</returns>
        [HttpGet("{id}")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<PropertyDetailsDto>>> GetPropertyDetails(Guid id, [FromQuery] Guid? userId = null)
        {
            // استخراج دور المستخدم من JWT Token إن وجد
            string? userRole = User.Identity?.IsAuthenticated == true 
                ? User.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value 
                : null;
            
            var query = new GetPropertyDetailsQuery 
            { 
                PropertyId = id, 
                UserId = userId,
                UserRole = userRole
            };
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعيد سياسات العقار.
        /// Returns the property policies.
        /// </summary>
        [HttpGet("{id}/policies")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<IEnumerable<PolicyDto>>>> GetPropertyPolicies(Guid id)
        {
            var query = new GetPropertyPoliciesQuery { PropertyId = id };
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعيد العقارات القريبة.
        /// Returns nearby properties.
        /// </summary>
        /// <param name="query">معايير الموقع. Location parameters.</param>
        /// <returns>قائمة العقارات القريبة. Nearby properties list.</returns>
        [HttpGet("nearby")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<List<NearbyPropertyDto>>>> GetNearbyProperties([FromQuery] GetNearbyPropertiesQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يتحقق من توفر العقار.
        /// Checks property availability.
        /// </summary>
        /// <param name="query">معايير التحقق. Availability parameters.</param>
        /// <returns>حالة التوفر. Availability status.</returns>
        [HttpGet("availability")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<PropertyAvailabilityResponse>>> CheckAvailability([FromQuery] CheckPropertyAvailabilityQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

    }
}
