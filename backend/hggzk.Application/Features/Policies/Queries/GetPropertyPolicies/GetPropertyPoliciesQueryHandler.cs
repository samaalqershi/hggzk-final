using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Common.Exceptions;
using YemenBooking.Application.Features.Policies;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features.Policies.DTOs;
using YemenBooking.Application.Features;
 using YemenBooking.Application.Common.Interfaces;

namespace YemenBooking.Application.Features.Policies.Queries.GetPropertyPolicies
{
    /// <summary>
    /// يسترجع سياسات عقار محدد مع التحقق من الصلاحيات.
    /// Retrieves a property's policies while enforcing access rules.
    /// </summary>
    public class GetPropertyPoliciesQueryHandler : IRequestHandler<GetPropertyPoliciesQuery, ResultDto<IEnumerable<PolicyDto>>>
    {
        private readonly IPolicyRepository _policyRepository;
        private readonly IPropertyRepository _propertyRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly ILogger<GetPropertyPoliciesQueryHandler> _logger;

        /// <summary>
        /// يهيئ معالج جلب سياسات العقار.
        /// Initializes the property policies query handler.
        /// </summary>
        public GetPropertyPoliciesQueryHandler(
            IPolicyRepository policyRepository,
            IPropertyRepository propertyRepository,
            ICurrentUserService currentUserService,
            ILogger<GetPropertyPoliciesQueryHandler> logger)
        {
            _policyRepository = policyRepository;
            _propertyRepository = propertyRepository;
            _currentUserService = currentUserService;
            _logger = logger;
        }

        /// <summary>
        /// يعالج Get Property Policies الوارد.
        /// Processes the incoming get property policies query.
        /// </summary>
        public async Task<ResultDto<IEnumerable<PolicyDto>>> Handle(GetPropertyPoliciesQuery request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("جاري معالجة استعلام سياسات الكيان: {PropertyId}", request.PropertyId);

            var isAdmin = string.Equals(_currentUserService.Role, "Admin", StringComparison.OrdinalIgnoreCase);
            var effectivePropertyId = request.PropertyId;

            // هذا الاستعلام مرتبط بعقار محدد: يجب تمرير PropertyId
            if (effectivePropertyId == Guid.Empty)
                throw new ValidationException(nameof(request.PropertyId), "معرف الكيان غير صالح");

            // Authorization for non-admins: must be the owner of the property
            if (!isAdmin)
            {
                var property = await _propertyRepository.GetPropertyByIdAsync(effectivePropertyId, cancellationToken);
                if (property == null || property.OwnerId != _currentUserService.UserId)
                    return ResultDto<IEnumerable<PolicyDto>>.Failed("غير مصرح لك بعرض سياسات هذا الكيان");
            }

            var policies = await _policyRepository.GetPropertyPoliciesAsync(effectivePropertyId, cancellationToken);

            var dtos = policies.Select(p => new PolicyDto
            {
                Id = p.Id,
                PropertyId = p.PropertyId,
                PolicyType = p.Type,
                Description = p.Description,
                DescriptionEn = p.DescriptionEn,
                Rules = PolicyRulesMapper.BuildRulesJson(p),
                RulesEn = p.RulesEn,
                CancellationFreeCancel = p.CancellationFreeCancel,
                CancellationFullRefund = p.CancellationFullRefund,
                CancellationRefundPercentage = p.CancellationRefundPercentage,
                CancellationDaysBeforeCheckIn = p.CancellationDaysBeforeCheckIn,
                CancellationHoursBeforeCheckIn = p.CancellationHoursBeforeCheckIn,
                CancellationNonRefundable = p.CancellationNonRefundable,
                CancellationPenaltyAfterDeadline = p.CancellationPenaltyAfterDeadline,
                CancellationPenaltyAfterDeadlineEn = p.CancellationPenaltyAfterDeadlineEn,

                PaymentDepositRequired = p.PaymentDepositRequired,
                PaymentFullPaymentRequired = p.PaymentFullPaymentRequired,
                PaymentDepositPercentage = p.PaymentDepositPercentage,
                PaymentAcceptCash = p.PaymentAcceptCash,
                PaymentAcceptCard = p.PaymentAcceptCard,
                PaymentPayAtProperty = p.PaymentPayAtProperty,
                PaymentCashPreferred = p.PaymentCashPreferred,
                PaymentAcceptedMethods = p.PaymentAcceptedMethods,

                CheckInTime = p.CheckInTime,
                CheckOutTime = p.CheckOutTime,
                CheckInFrom = p.CheckInFrom,
                CheckInUntil = p.CheckInUntil,
                CheckInFlexible = p.CheckInFlexible,
                CheckInFlexibleCheckIn = p.CheckInFlexibleCheckIn,
                CheckInRequiresCoordination = p.CheckInRequiresCoordination,
                CheckInContactOwner = p.CheckInContactOwner,
                CheckInEarlyCheckInNote = p.CheckInEarlyCheckInNote,
                CheckInEarlyCheckInNoteEn = p.CheckInEarlyCheckInNoteEn,
                CheckInLateCheckOutNote = p.CheckInLateCheckOutNote,
                CheckInLateCheckOutNoteEn = p.CheckInLateCheckOutNoteEn,
                CheckInLateCheckOutFee = p.CheckInLateCheckOutFee,
                CheckInLateCheckOutFeeEn = p.CheckInLateCheckOutFeeEn,

                ChildrenAllowed = p.ChildrenAllowed,
                ChildrenFreeUnderAge = p.ChildrenFreeUnderAge,
                ChildrenHalfPriceUnderAge = p.ChildrenHalfPriceUnderAge,
                ChildrenMaxChildrenPerRoom = p.ChildrenMaxChildrenPerRoom,
                ChildrenMaxChildren = p.ChildrenMaxChildren,
                ChildrenCribsNote = p.ChildrenCribsNote,
                ChildrenCribsNoteEn = p.ChildrenCribsNoteEn,
                ChildrenPlaygroundAvailable = p.ChildrenPlaygroundAvailable,
                ChildrenKidsMenuAvailable = p.ChildrenKidsMenuAvailable,

                PetsAllowed = p.PetsAllowed,
                PetsReason = p.PetsReason,
                PetsReasonEn = p.PetsReasonEn,
                PetsFeeAmount = p.PetsFeeAmount,
                PetsMaxWeight = p.PetsMaxWeight,
                PetsMaxWeightEn = p.PetsMaxWeightEn,
                PetsRequiresApproval = p.PetsRequiresApproval,
                PetsNoFees = p.PetsNoFees,
                PetsPetFriendly = p.PetsPetFriendly,
                PetsOutdoorSpace = p.PetsOutdoorSpace,
                PetsStrict = p.PetsStrict,

                ModificationAllowed = p.ModificationAllowed,
                ModificationFreeModificationHours = p.ModificationFreeModificationHours,
                ModificationFeesAfter = p.ModificationFeesAfter,
                ModificationFeesAfterEn = p.ModificationFeesAfterEn,
                ModificationFlexible = p.ModificationFlexible,
                ModificationReason = p.ModificationReason,
                ModificationReasonEn = p.ModificationReasonEn,
                CancellationWindowDays = p.CancellationWindowDays,
                RequireFullPaymentBeforeConfirmation = p.RequireFullPaymentBeforeConfirmation,
                MinimumDepositPercentage = p.MinimumDepositPercentage,
                MinHoursBeforeCheckIn = p.MinHoursBeforeCheckIn,
                CreatedAt = p.CreatedAt,
                UpdatedAt = p.UpdatedAt,
                IsActive = true
            }).ToList();

            return ResultDto<IEnumerable<PolicyDto>>.Ok(dtos, "تم جلب سياسات الكيان بنجاح");
        }
    }
}
 
