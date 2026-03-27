using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Common.Authorization
{
    /// <summary>
    /// معالج تفويض يجيز الوصول إلى العقار للمالك أو الموظف أو المسؤول وفق الإعدادات المطلوبة. Authorization handler that allows property access for owners, staff members, or administrators based on the requirement settings.
    /// </summary>
    public class PropertyOwnershipHandler : AuthorizationHandler<PropertyOwnershipRequirement>
    {
        /// <summary>
        /// حقل _currentUserService.
        /// _currentUserService field.
        /// </summary>
        private readonly ICurrentUserService _currentUserService;
        /// <summary>
        /// حقل _propertyRepository.
        /// _propertyRepository field.
        /// </summary>
        private readonly IPropertyRepository _propertyRepository;
        /// <summary>
        /// حقل _httpContextAccessor.
        /// _httpContextAccessor field.
        /// </summary>
        private readonly IHttpContextAccessor _httpContextAccessor;
        /// <summary>
        /// حقل _logger.
        /// _logger field.
        /// </summary>
        private readonly ILogger<PropertyOwnershipHandler> _logger;

        /// <summary>
        /// يهيئ معالج التفويض بالخدمات اللازمة لقراءة الطلب والتحقق من ملكية العقار. Initializes the authorization handler with the services needed to inspect the request and validate property ownership.
        /// </summary>
        /// <param name="currentUserService">خدمة المستخدم الحالي. Current user service.</param>
        /// <param name="propertyRepository">مستودع العقارات. Property repository.</param>
        /// <param name="httpContextAccessor">موفر الوصول إلى سياق HTTP. HTTP context accessor.</param>
        /// <param name="logger">مسجل التفويض. Authorization logger.</param>
        public PropertyOwnershipHandler(
            ICurrentUserService currentUserService,
            IPropertyRepository propertyRepository,
            IHttpContextAccessor httpContextAccessor,
            ILogger<PropertyOwnershipHandler> logger)
        {
            _currentUserService = currentUserService;
            _propertyRepository = propertyRepository;
            _httpContextAccessor = httpContextAccessor;
            _logger = logger;
        }

        /// <summary>
        /// يتحقق من أن المستخدم الحالي مخول للوصول إلى العقار المطلوب بحسب المتطلب المحدد. Verifies that the current user is authorized to access the target property according to the provided requirement.
        /// </summary>
        /// <param name="context">سياق التفويض الحالي. Current authorization context.</param>
        /// <param name="requirement">متطلب التفويض المطلوب تطبيقه. Authorization requirement to enforce.</param>
        protected override async Task HandleRequirementAsync(
            AuthorizationHandlerContext context,
            PropertyOwnershipRequirement requirement)
        {
            var userId = _currentUserService.UserId;
            var userRole = _currentUserService.Role;

            if (userId == Guid.Empty)
            {
                _logger.LogWarning("Authorization failed: User is not authenticated");
                context.Fail();
                return;
            }

            // السماح للمسؤول. Allow administrators when the requirement permits it.
            if (requirement.AllowAdmin && string.Equals(userRole, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                _logger.LogInformation("Authorization succeeded: User {UserId} is Admin", userId);
                context.Succeed(requirement);
                return;
            }

            // محاولة الحصول على معرف العقار من المسار أو الاستعلام أو الجسم أو الرؤوس. Attempt to resolve the property identifier from route, query, body, or headers.
            var propertyId = GetPropertyIdFromRequest();

            if (!propertyId.HasValue || propertyId.Value == Guid.Empty)
            {
                _logger.LogWarning("Authorization failed: PropertyId not found in request");
                context.Fail();
                return;
            }

            // التحقق من ملكية العقار. Validate that the property exists and can be checked.
            var property = await _propertyRepository.GetPropertyByIdAsync(propertyId.Value);
            if (property == null)
            {
                _logger.LogWarning("Authorization failed: Property {PropertyId} not found", propertyId.Value);
                context.Fail();
                return;
            }

            // التحقق من المالك. Verify owner access.
            if (property.OwnerId == userId)
            {
                _logger.LogInformation("Authorization succeeded: User {UserId} owns property {PropertyId}", 
                    userId, propertyId.Value);
                context.Succeed(requirement);
                return;
            }

            // التحقق من الموظف إذا كان مسموحاً. Verify staff access when allowed by the requirement.
            if (requirement.AllowStaff && _currentUserService.IsStaffInProperty(propertyId.Value))
            {
                _logger.LogInformation("Authorization succeeded: User {UserId} is staff in property {PropertyId}", 
                    userId, propertyId.Value);
                context.Succeed(requirement);
                return;
            }

            _logger.LogWarning(
                "Authorization failed: User {UserId} does not have access to property {PropertyId}", 
                userId, propertyId.Value);
            context.Fail();
        }

        /// <summary>
        /// يحاول استخراج معرف العقار من المسار أو الاستعلام أو الفورم أو رؤوس الطلب. Attempts to resolve the property identifier from route values, query string, form content, or request headers.
        /// </summary>
        /// <returns>معرف العقار إن تم العثور عليه، وإلا <see langword="null"/>. Property identifier when found; otherwise <see langword="null"/>.</returns>
        private Guid? GetPropertyIdFromRequest()
        {
            var httpContext = _httpContextAccessor.HttpContext;
            if (httpContext == null) return null;

            // من قيم المسار. From route values.
            if (httpContext.Request.RouteValues.TryGetValue("propertyId", out var routePropertyId))
            {
                if (Guid.TryParse(routePropertyId?.ToString(), out var propId))
                    return propId;
            }

            // من قيم الاستعلام. From query string values.
            if (httpContext.Request.Query.TryGetValue("propertyId", out var queryPropertyId))
            {
                if (Guid.TryParse(queryPropertyId.ToString(), out var propId))
                    return propId;
            }

            // من بيانات النموذج في الطلب. From form data in the request body.
            if (httpContext.Request.HasFormContentType)
            {
                if (httpContext.Request.Form.TryGetValue("propertyId", out var formPropertyId))
                {
                    if (Guid.TryParse(formPropertyId.ToString(), out var propId))
                        return propId;
                }
            }

            // من رؤوس الطلب. From request headers.
            if (httpContext.Request.Headers.TryGetValue("X-Property-Id", out var headerPropertyId))
            {
                if (Guid.TryParse(headerPropertyId.ToString(), out var propId))
                    return propId;
            }

            return null;
        }
    }
}
