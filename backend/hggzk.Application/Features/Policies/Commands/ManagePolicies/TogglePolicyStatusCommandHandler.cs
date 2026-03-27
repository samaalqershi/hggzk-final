using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Common.Authorization;

namespace YemenBooking.Application.Features.Policies.Commands.ManagePolicies
{
    /// <summary>
    /// يعالج طلب تبديل حالة السياسة.
    /// Processes the policy status toggle request.
    /// </summary>
    public class TogglePolicyStatusCommandHandler : IRequestHandler<TogglePolicyStatusCommand, ResultDto<bool>>
    {
        private readonly IPolicyRepository _policyRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly PropertyAuthorizationHelper _authHelper;
        private readonly ILogger<TogglePolicyStatusCommandHandler> _logger;

        /// <summary>
        /// يهيّئ مثيلاً جديداً من [TogglePolicyStatusCommandHandler].
        /// Initializes a new instance of [TogglePolicyStatusCommandHandler].
        /// </summary>
        public TogglePolicyStatusCommandHandler(
            IPolicyRepository policyRepository,
            ICurrentUserService currentUserService,
            PropertyAuthorizationHelper authHelper,
            ILogger<TogglePolicyStatusCommandHandler> logger)
        {
            _policyRepository = policyRepository;
            _currentUserService = currentUserService;
            _authHelper = authHelper;
            _logger = logger;
        }

        /// <summary>
        /// يعالج Toggle Policy Status الوارد.
        /// Processes the incoming toggle policy status request.
        /// </summary>
        public async Task<ResultDto<bool>> Handle(TogglePolicyStatusCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("بدء تغيير حالة السياسة: PolicyId={PolicyId}", request.PolicyId);

            // التحقق من وجود السياسة / Validate that the policy exists.
            var policy = await _policyRepository.GetByIdAsync(request.PolicyId, cancellationToken);
            if (policy == null || policy.IsDeleted)
                return ResultDto<bool>.Failed("السياسة غير موجودة");

            // التحقق من الوصول إلى العقار / Validate access to the property.
            var authResult = await _authHelper.VerifyPropertyAccessAsync(
                policy.PropertyId,
                allowStaff: false,
                cancellationToken);

            if (!authResult.IsSuccess)
            {
                _logger.LogWarning(
                    "User {UserId} attempted unauthorized toggle of policy {PolicyId} status",
                    _currentUserService.UserId, request.PolicyId);
                return ResultDto<bool>.Failed(authResult.Message ?? "غير مصرح بالوصول", authResult.ErrorCode);
            }

            // تبديل الحالة الفعلية / Apply the real status toggle on the existing IsActive field.
            var previousStatus = policy.IsActive;
            policy.IsActive = !policy.IsActive;
            policy.UpdatedBy = _currentUserService.UserId;
            policy.UpdatedAt = DateTime.UtcNow;

            await _policyRepository.UpdatePropertyPolicyAsync(policy, cancellationToken);
            await _policyRepository.SaveChangesAsync(cancellationToken);

            _logger.LogInformation(
                "تم تغيير حالة السياسة {PolicyId} من {PreviousStatus} إلى {CurrentStatus}",
                request.PolicyId,
                previousStatus,
                policy.IsActive);

            return ResultDto<bool>.Succeeded(
                true,
                policy.IsActive ? "تم تفعيل السياسة بنجاح" : "تم تعطيل السياسة بنجاح",
                policy.IsActive ? "Policy activated successfully" : "Policy deactivated successfully");
        }
    }
}
