using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Common.Authorization
{
    /// <summary>
    /// خدمة مساعدة لتقييم صلاحيات الوصول إلى العقار للمالك أو الموظف أو المسؤول. Helper service that evaluates property access for owners, staff members, and administrators.
    /// </summary>
    public class PropertyAuthorizationHelper
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
        /// حقل _logger.
        /// _logger field.
        /// </summary>
        private readonly ILogger<PropertyAuthorizationHelper> _logger;

        /// <summary>
        /// يهيئ مساعد التفويض بالخدمات اللازمة للتحقق من وصول المستخدم إلى العقار. Initializes the authorization helper with the services required to validate user access to properties.
        /// </summary>
        /// <param name="currentUserService">خدمة المستخدم الحالي. Current user service.</param>
        /// <param name="propertyRepository">مستودع العقارات. Property repository.</param>
        /// <param name="logger">مسجل العمليات. Operation logger.</param>
        public PropertyAuthorizationHelper(
            ICurrentUserService currentUserService,
            IPropertyRepository propertyRepository,
            ILogger<PropertyAuthorizationHelper> logger)
        {
            _currentUserService = currentUserService;
            _propertyRepository = propertyRepository;
            _logger = logger;
        }

        /// <summary>
        /// يتحقق من صلاحية المستخدم الحالي للوصول إلى عقار معين مع دعم مرور المسؤول والموظف عند الحاجة. Verifies whether the current user may access a specific property, including optional admin and staff pass-through.
        /// </summary>
        /// <param name="propertyId">معرف العقار المستهدف. Target property identifier.</param>
        /// <param name="allowStaff">يشير إلى السماح لموظفي العقار بالمرور. Indicates whether property staff access is allowed.</param>
        /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
        /// <returns>نتيجة التحقق من صلاحية الوصول. Result indicating whether access is authorized.</returns>
        public async Task<ResultDto<bool>> VerifyPropertyAccessAsync(
            Guid propertyId,
            bool allowStaff = false,
            CancellationToken cancellationToken = default)
        {
            var userId = _currentUserService.UserId;
            var userRole = _currentUserService.Role;

            // السماح للمسؤول دائماً. Always allow administrators.
            if (string.Equals(userRole, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                _logger.LogDebug("Authorization succeeded: User {UserId} is Admin", userId);
                return ResultDto<bool>.Succeeded(true);
            }

            // التحقق من وجود العقار. Verify that the property exists.
            var property = await _propertyRepository.GetPropertyByIdAsync(propertyId, cancellationToken);
            if (property == null)
            {
                _logger.LogWarning("Property {PropertyId} not found", propertyId);
                return ResultDto<bool>.Failed("العقار غير موجود", errorCode: "PROPERTY_NOT_FOUND");
            }

            // التحقق من المالك. Verify owner access.
            if (property.OwnerId == userId)
            {
                _logger.LogDebug("Authorization succeeded: User {UserId} owns property {PropertyId}", 
                    userId, propertyId);
                return ResultDto<bool>.Succeeded(true);
            }

            // التحقق من الموظف إذا كان مسموحاً. Verify staff access when enabled.
            if (allowStaff && _currentUserService.IsStaffInProperty(propertyId))
            {
                _logger.LogDebug("Authorization succeeded: User {UserId} is staff in property {PropertyId}", 
                    userId, propertyId);
                return ResultDto<bool>.Succeeded(true);
            }

            _logger.LogWarning(
                "Authorization failed: User {UserId} does not have access to property {PropertyId}", 
                userId, propertyId);
            return ResultDto<bool>.Failed(
                "غير مصرح لك بالوصول إلى هذا العقار",
                errorCode: "UNAUTHORIZED_PROPERTY_ACCESS");
        }

        /// <summary>
        /// يحدد معرف العقار الفعال الذي يجب أن تعتمد عليه الطبقة التطبيقية للمستخدم الحالي. Resolves the effective property identifier that the application layer should operate on for the current user.
        /// </summary>
        /// <param name="requestedPropertyId">معرف العقار المطلوب من المستدعي إن وجد. Requested property identifier from the caller, when provided.</param>
        /// <returns>معرف العقار النهائي المستخدم في الطبقة التطبيقية. Effective property identifier used by the application layer.</returns>
        public Guid? GetEffectivePropertyId(Guid? requestedPropertyId = null)
        {
            var userRole = _currentUserService.Role;

            // المسؤول يمكنه استخدام أي propertyId. Administrators may use any requested property identifier.
            if (string.Equals(userRole, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                return requestedPropertyId;
            }

            // المالك أو الموظف يجب أن يستخدم معرف العقار المرتبط به. Owners or staff members must use their associated property identifier.
            var userPropertyId = _currentUserService.PropertyId;
            
            if (!userPropertyId.HasValue)
            {
                _logger.LogWarning("User {UserId} has no associated property", _currentUserService.UserId);
                return null;
            }

            // تجاهل المعرف المطلوب وإرجاع معرف عقار المستخدم. Ignore the requested identifier and return the user's property identifier.
            if (requestedPropertyId.HasValue && requestedPropertyId.Value != userPropertyId.Value)
            {
                _logger.LogInformation(
                    "Overriding requested property {RequestedId} with user's property {UserPropertyId}", 
                    requestedPropertyId.Value, userPropertyId.Value);
            }

            return userPropertyId.Value;
        }

        /// <summary>
        /// يتحقق من قدرة المستخدم الحالي على الوصول إلى جميع العقارات المحددة دفعة واحدة. Verifies whether the current user can access all specified properties in a single operation.
        /// </summary>
        /// <param name="propertyIds">معرفات العقارات المطلوب التحقق منها. Property identifiers to validate.</param>
        /// <param name="allowStaff">يشير إلى السماح للموظفين بالمرور. Indicates whether staff access is allowed.</param>
        /// <param name="cancellationToken">رمز الإلغاء. Cancellation token.</param>
        /// <returns>نتيجة موحدة تشير إلى حالة الوصول لكافة العقارات. Aggregate result describing access across all requested properties.</returns>
        public async Task<ResultDto<bool>> VerifyMultiplePropertiesAccessAsync(
            Guid[] propertyIds,
            bool allowStaff = false,
            CancellationToken cancellationToken = default)
        {
            foreach (var propertyId in propertyIds)
            {
                var result = await VerifyPropertyAccessAsync(propertyId, allowStaff, cancellationToken);
                if (!result.IsSuccess)
                {
                    return result;
                }
            }

            return ResultDto<bool>.Succeeded(true);
        }
    }
}
