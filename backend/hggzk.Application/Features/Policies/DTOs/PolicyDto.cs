using System;
using YemenBooking.Core.Enums;

namespace YemenBooking.Application.Features.Policies.DTOs {
    /// <summary>
    /// DTO لبيانات سياسة الكيان
    /// DTO for property policy data
    /// </summary>
    public class PolicyDto
    {
        /// <summary>
        /// معرف السياسة
        /// Policy identifier
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// معرف الكيان
        /// Property identifier
        /// </summary>
        public Guid PropertyId { get; set; }

        /// <summary>
        /// اسم الكيان
        /// Property name
        /// </summary>
        public string? PropertyName { get; set; }
        public string? PropertyNameEn { get; set; }

        /// <summary>
        /// نوع السياسة
        /// Policy type
        /// </summary>
        public PolicyType PolicyType { get; set; }

        /// <summary>
        /// وصف السياسة
        /// Policy description
        /// </summary>
        public string Description { get; set; } = string.Empty;
        public string? DescriptionEn { get; set; }

        /// <summary>
        /// قواعد السياسة (JSON)
        /// Policy rules (JSON)
        /// </summary>
        public string Rules { get; set; } = string.Empty;
        public string? RulesEn { get; set; }

        /// <summary>
        /// خاصية CancellationFreeCancel.
        /// CancellationFreeCancel property.
        /// </summary>
        public bool? CancellationFreeCancel { get; set; }
        /// <summary>
        /// خاصية CancellationFullRefund.
        /// CancellationFullRefund property.
        /// </summary>
        public bool? CancellationFullRefund { get; set; }
        /// <summary>
        /// خاصية CancellationRefundPercentage.
        /// CancellationRefundPercentage property.
        /// </summary>
        public int? CancellationRefundPercentage { get; set; }
        /// <summary>
        /// خاصية CancellationDaysBeforeCheckIn.
        /// CancellationDaysBeforeCheckIn property.
        /// </summary>
        public int? CancellationDaysBeforeCheckIn { get; set; }
        /// <summary>
        /// خاصية CancellationHoursBeforeCheckIn.
        /// CancellationHoursBeforeCheckIn property.
        /// </summary>
        public int? CancellationHoursBeforeCheckIn { get; set; }
        /// <summary>
        /// خاصية CancellationNonRefundable.
        /// CancellationNonRefundable property.
        /// </summary>
        public bool? CancellationNonRefundable { get; set; }
        /// <summary>
        /// خاصية CancellationPenaltyAfterDeadline.
        /// CancellationPenaltyAfterDeadline property.
        /// </summary>
        public string? CancellationPenaltyAfterDeadline { get; set; }
        public string? CancellationPenaltyAfterDeadlineEn { get; set; }

        /// <summary>
        /// خاصية PaymentDepositRequired.
        /// PaymentDepositRequired property.
        /// </summary>
        public bool? PaymentDepositRequired { get; set; }
        /// <summary>
        /// خاصية PaymentFullPaymentRequired.
        /// PaymentFullPaymentRequired property.
        /// </summary>
        public bool? PaymentFullPaymentRequired { get; set; }
        /// <summary>
        /// خاصية PaymentDepositPercentage.
        /// PaymentDepositPercentage property.
        /// </summary>
        public decimal? PaymentDepositPercentage { get; set; }
        /// <summary>
        /// خاصية PaymentAcceptCash.
        /// PaymentAcceptCash property.
        /// </summary>
        public bool? PaymentAcceptCash { get; set; }
        /// <summary>
        /// خاصية PaymentAcceptCard.
        /// PaymentAcceptCard property.
        /// </summary>
        public bool? PaymentAcceptCard { get; set; }
        /// <summary>
        /// خاصية PaymentPayAtProperty.
        /// PaymentPayAtProperty property.
        /// </summary>
        public bool? PaymentPayAtProperty { get; set; }
        /// <summary>
        /// خاصية PaymentCashPreferred.
        /// PaymentCashPreferred property.
        /// </summary>
        public bool? PaymentCashPreferred { get; set; }
        /// <summary>
        /// خاصية PaymentAcceptedMethods.
        /// PaymentAcceptedMethods property.
        /// </summary>
        public string[]? PaymentAcceptedMethods { get; set; }

        /// <summary>
        /// خاصية CheckInTime.
        /// CheckInTime property.
        /// </summary>
        public TimeOnly? CheckInTime { get; set; }
        /// <summary>
        /// خاصية CheckOutTime.
        /// CheckOutTime property.
        /// </summary>
        public TimeOnly? CheckOutTime { get; set; }
        /// <summary>
        /// خاصية CheckInFrom.
        /// CheckInFrom property.
        /// </summary>
        public TimeOnly? CheckInFrom { get; set; }
        /// <summary>
        /// خاصية CheckInUntil.
        /// CheckInUntil property.
        /// </summary>
        public TimeOnly? CheckInUntil { get; set; }
        /// <summary>
        /// خاصية CheckInFlexible.
        /// CheckInFlexible property.
        /// </summary>
        public bool? CheckInFlexible { get; set; }
        /// <summary>
        /// خاصية CheckInFlexibleCheckIn.
        /// CheckInFlexibleCheckIn property.
        /// </summary>
        public bool? CheckInFlexibleCheckIn { get; set; }
        /// <summary>
        /// خاصية CheckInRequiresCoordination.
        /// CheckInRequiresCoordination property.
        /// </summary>
        public bool? CheckInRequiresCoordination { get; set; }
        /// <summary>
        /// خاصية CheckInContactOwner.
        /// CheckInContactOwner property.
        /// </summary>
        public bool? CheckInContactOwner { get; set; }
        /// <summary>
        /// خاصية CheckInEarlyCheckInNote.
        /// CheckInEarlyCheckInNote property.
        /// </summary>
        public string? CheckInEarlyCheckInNote { get; set; }
        public string? CheckInEarlyCheckInNoteEn { get; set; }
        /// <summary>
        /// خاصية CheckInLateCheckOutNote.
        /// CheckInLateCheckOutNote property.
        /// </summary>
        public string? CheckInLateCheckOutNote { get; set; }
        public string? CheckInLateCheckOutNoteEn { get; set; }
        /// <summary>
        /// خاصية CheckInLateCheckOutFee.
        /// CheckInLateCheckOutFee property.
        /// </summary>
        public string? CheckInLateCheckOutFee { get; set; }
        public string? CheckInLateCheckOutFeeEn { get; set; }

        /// <summary>
        /// خاصية ChildrenAllowed.
        /// ChildrenAllowed property.
        /// </summary>
        public bool? ChildrenAllowed { get; set; }
        /// <summary>
        /// خاصية ChildrenFreeUnderAge.
        /// ChildrenFreeUnderAge property.
        /// </summary>
        public int? ChildrenFreeUnderAge { get; set; }
        /// <summary>
        /// خاصية ChildrenHalfPriceUnderAge.
        /// ChildrenHalfPriceUnderAge property.
        /// </summary>
        public int? ChildrenHalfPriceUnderAge { get; set; }
        /// <summary>
        /// خاصية ChildrenMaxChildrenPerRoom.
        /// ChildrenMaxChildrenPerRoom property.
        /// </summary>
        public int? ChildrenMaxChildrenPerRoom { get; set; }
        /// <summary>
        /// خاصية ChildrenMaxChildren.
        /// ChildrenMaxChildren property.
        /// </summary>
        public int? ChildrenMaxChildren { get; set; }
        /// <summary>
        /// خاصية ChildrenCribsNote.
        /// ChildrenCribsNote property.
        /// </summary>
        public string? ChildrenCribsNote { get; set; }
        public string? ChildrenCribsNoteEn { get; set; }
        /// <summary>
        /// خاصية ChildrenPlaygroundAvailable.
        /// ChildrenPlaygroundAvailable property.
        /// </summary>
        public bool? ChildrenPlaygroundAvailable { get; set; }
        /// <summary>
        /// خاصية ChildrenKidsMenuAvailable.
        /// ChildrenKidsMenuAvailable property.
        /// </summary>
        public bool? ChildrenKidsMenuAvailable { get; set; }

        /// <summary>
        /// خاصية PetsAllowed.
        /// PetsAllowed property.
        /// </summary>
        public bool? PetsAllowed { get; set; }
        /// <summary>
        /// خاصية PetsReason.
        /// PetsReason property.
        /// </summary>
        public string? PetsReason { get; set; }
        public string? PetsReasonEn { get; set; }
        /// <summary>
        /// خاصية PetsFeeAmount.
        /// PetsFeeAmount property.
        /// </summary>
        public decimal? PetsFeeAmount { get; set; }
        /// <summary>
        /// خاصية PetsMaxWeight.
        /// PetsMaxWeight property.
        /// </summary>
        public string? PetsMaxWeight { get; set; }
        public string? PetsMaxWeightEn { get; set; }
        /// <summary>
        /// خاصية PetsRequiresApproval.
        /// PetsRequiresApproval property.
        /// </summary>
        public bool? PetsRequiresApproval { get; set; }
        /// <summary>
        /// خاصية PetsNoFees.
        /// PetsNoFees property.
        /// </summary>
        public bool? PetsNoFees { get; set; }
        /// <summary>
        /// خاصية PetsPetFriendly.
        /// PetsPetFriendly property.
        /// </summary>
        public bool? PetsPetFriendly { get; set; }
        /// <summary>
        /// خاصية PetsOutdoorSpace.
        /// PetsOutdoorSpace property.
        /// </summary>
        public bool? PetsOutdoorSpace { get; set; }
        /// <summary>
        /// خاصية PetsStrict.
        /// PetsStrict property.
        /// </summary>
        public bool? PetsStrict { get; set; }

        /// <summary>
        /// خاصية ModificationAllowed.
        /// ModificationAllowed property.
        /// </summary>
        public bool? ModificationAllowed { get; set; }
        /// <summary>
        /// خاصية ModificationFreeModificationHours.
        /// ModificationFreeModificationHours property.
        /// </summary>
        public int? ModificationFreeModificationHours { get; set; }
        /// <summary>
        /// خاصية ModificationFeesAfter.
        /// ModificationFeesAfter property.
        /// </summary>
        public string? ModificationFeesAfter { get; set; }
        public string? ModificationFeesAfterEn { get; set; }
        /// <summary>
        /// خاصية ModificationFlexible.
        /// ModificationFlexible property.
        /// </summary>
        public bool? ModificationFlexible { get; set; }
        /// <summary>
        /// خاصية ModificationReason.
        /// ModificationReason property.
        /// </summary>
        public string? ModificationReason { get; set; }
        public string? ModificationReasonEn { get; set; }

        /// <summary>
        /// عدد أيام نافذة الإلغاء قبل تاريخ الوصول
        /// Number of days before check-in to allow cancellation
        /// </summary>
        public int CancellationWindowDays { get; set; }

        /// <summary>
        /// يتطلب الدفع الكامل قبل التأكيد
        /// Requires full payment before confirmation
        /// </summary>
        public bool RequireFullPaymentBeforeConfirmation { get; set; }

        /// <summary>
        /// الحد الأدنى لنسبة الدفع المقدمة (كنسبة مئوية)
        /// Minimum deposit percentage (as percentage)
        /// </summary>
        public decimal MinimumDepositPercentage { get; set; }

        /// <summary>
        /// الحد الأدنى للساعات قبل تسجيل الوصول لتعديل الحجز
        /// Minimum hours before check-in to allow modification
        /// </summary>
        public int MinHoursBeforeCheckIn { get; set; }

        /// <summary>
        /// تاريخ الإنشاء
        /// Creation date
        /// </summary>
        public DateTime? CreatedAt { get; set; }

        /// <summary>
        /// تاريخ آخر تحديث
        /// Last update date
        /// </summary>
        public DateTime? UpdatedAt { get; set; }

        /// <summary>
        /// حالة السياسة
        /// Policy status
        /// </summary>
        public bool IsActive { get; set; } = true;
    }
} 
