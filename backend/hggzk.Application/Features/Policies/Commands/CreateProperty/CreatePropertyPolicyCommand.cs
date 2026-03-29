using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Enums;

namespace YemenBooking.Application.Features.Policies.Commands.CreateProperty
{
    /// <summary>
    /// يمثل طلب إنشاء سياسة خاصة بعقار.
    /// Creates a policy for a property.
    /// </summary>
    public class CreatePropertyPolicyCommand : IRequest<ResultDto<Guid>>
    {
        /// <summary>
        /// معرّف العقار.
        /// Property identifier.
        /// </summary>
        public Guid PropertyId { get; set; }
        /// <summary>
        /// نوع السياسة المرتبطة بالعقار.
        /// Policy type associated with the property.
        /// </summary>
        public PolicyType Type { get; set; }
        /// <summary>
        /// وصف السياسة بصورة واضحة ومختصرة.
        /// Clear, concise policy description.
        /// </summary>
        public string Description { get; set; }
        /// <summary>
        /// نص القواعد التفصيلية لهذه السياسة.
        /// Detailed rule text for this policy.
        /// </summary>
        public string? Rules { get; set; }
        /// <summary>
        /// وصف السياسة باللغة الإنجليزية.
        /// Policy description in English.
        /// </summary>
        public string? DescriptionEn { get; set; }
        /// <summary>
        /// نص القواعد باللغة الإنجليزية.
        /// Detailed rule text in English.
        /// </summary>
        public string? RulesEn { get; set; }
        /// <summary>
        /// عدد الأيام المسموح بها قبل بدء الإلغاء.
        /// Number of days allowed before cancellation starts.
        /// </summary>
        public int CancellationWindowDays { get; set; }
        /// <summary>
        /// يحدد ما إذا كان السداد الكامل مطلوبًا قبل تأكيد الحجز.
        /// Indicates whether full payment is required before booking confirmation.
        /// </summary>
        public bool RequireFullPaymentBeforeConfirmation { get; set; }
        /// <summary>
        /// الحد الأدنى لنسبة الدفعة المقدمة.
        /// Minimum deposit percentage.
        /// </summary>
        public decimal MinimumDepositPercentage { get; set; }
        /// <summary>
        /// الحد الأدنى للساعات قبل تسجيل الوصول.
        /// Minimum hours before check-in.
        /// </summary>
        public int MinHoursBeforeCheckIn { get; set; }
        /// <summary>
        /// يحدد ما إذا كان الإلغاء المجاني متاحًا.
        /// Indicates whether free cancellation is available.
        /// </summary>
        public bool? CancellationFreeCancel { get; set; }
        /// <summary>
        /// يحدد ما إذا كان الإلغاء يمنح استردادًا كاملًا.
        /// Indicates whether cancellation grants a full refund.
        /// </summary>
        public bool? CancellationFullRefund { get; set; }
        /// <summary>
        /// نسبة الاسترداد عند الإلغاء.
        /// Refund percentage on cancellation.
        /// </summary>
        public int? CancellationRefundPercentage { get; set; }
        /// <summary>
        /// عدد الأيام قبل الوصول التي يبدأ عندها شرط الإلغاء.
        /// Number of days before check-in when the cancellation rule applies.
        /// </summary>
        public int? CancellationDaysBeforeCheckIn { get; set; }
        /// <summary>
        /// عدد الساعات قبل الوصول التي يبدأ عندها شرط الإلغاء.
        /// Number of hours before check-in when the cancellation rule applies.
        /// </summary>
        public int? CancellationHoursBeforeCheckIn { get; set; }
        /// <summary>
        /// يحدد أن الحجز غير قابل للاسترداد.
        /// Marks the booking as non-refundable.
        /// </summary>
        public bool? CancellationNonRefundable { get; set; }
        /// <summary>
        /// وصف الجزاء المطبق بعد انتهاء مهلة الإلغاء.
        /// Penalty description applied after the cancellation deadline.
        /// </summary>
        public string? CancellationPenaltyAfterDeadline { get; set; }
        /// <summary>
        /// وصف الجزاء بعد المهلة بالإنجليزية.
        /// English cancellation penalty description applied after the deadline.
        /// </summary>
        public string? CancellationPenaltyAfterDeadlineEn { get; set; }
        /// <summary>
        /// يحدد أن الدفعة المقدمة مطلوبة.
        /// Indicates that a deposit is required.
        /// </summary>
        public bool? PaymentDepositRequired { get; set; }
        /// <summary>
        /// يحدد أن السداد الكامل مطلوب.
        /// Indicates that full payment is required.
        /// </summary>
        public bool? PaymentFullPaymentRequired { get; set; }
        /// <summary>
        /// نسبة الدفعة المقدمة المطلوبة.
        /// Required deposit percentage.
        /// </summary>
        public decimal? PaymentDepositPercentage { get; set; }
        /// <summary>
        /// يحدد قبول الدفع النقدي.
        /// Indicates cash payment is accepted.
        /// </summary>
        public bool? PaymentAcceptCash { get; set; }
        /// <summary>
        /// يحدد قبول الدفع بالبطاقة.
        /// Indicates card payment is accepted.
        /// </summary>
        public bool? PaymentAcceptCard { get; set; }
        /// <summary>
        /// يحدد السماح بالدفع عند العقار.
        /// Indicates pay-at-property is allowed.
        /// </summary>
        public bool? PaymentPayAtProperty { get; set; }
        /// <summary>
        /// يحدد أن الدفع النقدي هو الخيار المفضل.
        /// Indicates cash is the preferred payment option.
        /// </summary>
        public bool? PaymentCashPreferred { get; set; }
        /// <summary>
        /// طرق الدفع المقبولة.
        /// Accepted payment methods.
        /// </summary>
        public string[]? PaymentAcceptedMethods { get; set; }
        /// <summary>
        /// وقت تسجيل الوصول.
        /// Check-in time.
        /// </summary>
        public TimeOnly? CheckInTime { get; set; }
        /// <summary>
        /// وقت تسجيل المغادرة.
        /// Check-out time.
        /// </summary>
        public TimeOnly? CheckOutTime { get; set; }
        /// <summary>
        /// بداية فترة تسجيل الوصول.
        /// Earliest allowed check-in time.
        /// </summary>
        public TimeOnly? CheckInFrom { get; set; }
        /// <summary>
        /// نهاية فترة تسجيل الوصول.
        /// Latest allowed check-in time.
        /// </summary>
        public TimeOnly? CheckInUntil { get; set; }
        /// <summary>
        /// يحدد ما إذا كان تسجيل الوصول مرنًا.
        /// Indicates whether check-in is flexible.
        /// </summary>
        public bool? CheckInFlexible { get; set; }
        /// <summary>
        /// خيار تسجيل الوصول المرن.
        /// Flexible check-in option.
        /// </summary>
        public bool? CheckInFlexibleCheckIn { get; set; }
        /// <summary>
        /// يتطلب تنسيقًا مسبقًا لتسجيل الوصول.
        /// Requires advance coordination for check-in.
        /// </summary>
        public bool? CheckInRequiresCoordination { get; set; }
        /// <summary>
        /// يحدد ضرورة التواصل مع المالك عند الوصول.
        /// Indicates the owner must be contacted on arrival.
        /// </summary>
        public bool? CheckInContactOwner { get; set; }
        /// <summary>
        /// ملاحظة خاصة بتسجيل الوصول المبكر.
        /// Note for early check-in.
        /// </summary>
        public string? CheckInEarlyCheckInNote { get; set; }
        /// <summary>
        /// ملاحظة تسجيل الوصول المبكر بالإنجليزية.
        /// Early check-in note in English.
        /// </summary>
        public string? CheckInEarlyCheckInNoteEn { get; set; }
        /// <summary>
        /// ملاحظة خاصة بتسجيل المغادرة المتأخر.
        /// Note for late check-out.
        /// </summary>
        public string? CheckInLateCheckOutNote { get; set; }
        /// <summary>
        /// ملاحظة تسجيل المغادرة المتأخر بالإنجليزية.
        /// Late check-out note in English.
        /// </summary>
        public string? CheckInLateCheckOutNoteEn { get; set; }
        /// <summary>
        /// رسوم تسجيل المغادرة المتأخر.
        /// Late check-out fee.
        /// </summary>
        public string? CheckInLateCheckOutFee { get; set; }
        /// <summary>
        /// رسوم المغادرة المتأخرة بالإنجليزية.
        /// Late check-out fee in English.
        /// </summary>
        public string? CheckInLateCheckOutFeeEn { get; set; }
        /// <summary>
        /// يحدد ما إذا كان الأطفال مسموحًا بهم.
        /// Indicates whether children are allowed.
        /// </summary>
        public bool? ChildrenAllowed { get; set; }
        /// <summary>
        /// العمر الذي يكون دونه الطفل مجانيًا.
        /// Age below which children stay free.
        /// </summary>
        public int? ChildrenFreeUnderAge { get; set; }
        /// <summary>
        /// العمر الذي يكون دونه الطفل بنصف السعر.
        /// Age below which children pay half price.
        /// </summary>
        public int? ChildrenHalfPriceUnderAge { get; set; }
        /// <summary>
        /// الحد الأقصى للأطفال في الغرفة الواحدة.
        /// Maximum number of children per room.
        /// </summary>
        public int? ChildrenMaxChildrenPerRoom { get; set; }
        /// <summary>
        /// الحد الأقصى المسموح به للأطفال.
        /// Maximum allowed number of children.
        /// </summary>
        public int? ChildrenMaxChildren { get; set; }
        /// <summary>
        /// ملاحظة تتعلق بأسرّة الأطفال.
        /// Note about cribs.
        /// </summary>
        public string? ChildrenCribsNote { get; set; }
        /// <summary>
        /// ملاحظة أسرّة الأطفال بالإنجليزية.
        /// Cribs note in English.
        /// </summary>
        public string? ChildrenCribsNoteEn { get; set; }
        /// <summary>
        /// يحدد توفر ملعب للأطفال.
        /// Indicates whether a children’s playground is available.
        /// </summary>
        public bool? ChildrenPlaygroundAvailable { get; set; }
        /// <summary>
        /// يحدد توفر قائمة مخصصة للأطفال.
        /// Indicates whether a kids’ menu is available.
        /// </summary>
        public bool? ChildrenKidsMenuAvailable { get; set; }
        /// <summary>
        /// يحدد ما إذا كانت الحيوانات الأليفة مسموحة.
        /// Indicates whether pets are allowed.
        /// </summary>
        public bool? PetsAllowed { get; set; }
        /// <summary>
        /// سبب سياسة الحيوانات الأليفة.
        /// Reason for the pet policy.
        /// </summary>
        public string? PetsReason { get; set; }
        /// <summary>
        /// سبب سياسة الحيوانات الأليفة بالإنجليزية.
        /// Pet policy reason in English.
        /// </summary>
        public string? PetsReasonEn { get; set; }
        /// <summary>
        /// قيمة رسوم الحيوانات الأليفة.
        /// Pet fee amount.
        /// </summary>
        public decimal? PetsFeeAmount { get; set; }
        /// <summary>
        /// الحد الأقصى لوزن الحيوانات الأليفة.
        /// Maximum pet weight.
        /// </summary>
        public string? PetsMaxWeight { get; set; }
        /// <summary>
        /// الحد الأقصى لوزن الحيوانات الأليفة بالإنجليزية.
        /// Maximum pet weight in English.
        /// </summary>
        public string? PetsMaxWeightEn { get; set; }
        /// <summary>
        /// يحدد أن الحيوانات الأليفة تتطلب موافقة مسبقة.
        /// Indicates pets require prior approval.
        /// </summary>
        public bool? PetsRequiresApproval { get; set; }
        /// <summary>
        /// يحدد عدم فرض رسوم على الحيوانات الأليفة.
        /// Indicates no pet fees apply.
        /// </summary>
        public bool? PetsNoFees { get; set; }
        /// <summary>
        /// يحدد أن العقار ملائم للحيوانات الأليفة.
        /// Indicates the property is pet-friendly.
        /// </summary>
        public bool? PetsPetFriendly { get; set; }
        /// <summary>
        /// يحدد توفر مساحة خارجية للحيوانات الأليفة.
        /// Indicates outdoor space is available for pets.
        /// </summary>
        public bool? PetsOutdoorSpace { get; set; }
        /// <summary>
        /// يحدد وجود سياسة صارمة للحيوانات الأليفة.
        /// Indicates a strict pet policy.
        /// </summary>
        public bool? PetsStrict { get; set; }
        /// <summary>
        /// يحدد ما إذا كان التعديل مسموحًا.
        /// Indicates whether modifications are allowed.
        /// </summary>
        public bool? ModificationAllowed { get; set; }
        /// <summary>
        /// ساعات التعديل المجاني المسموح بها.
        /// Free modification hours allowed.
        /// </summary>
        public int? ModificationFreeModificationHours { get; set; }
        /// <summary>
        /// الرسوم المطبقة بعد انتهاء فترة التعديل المجاني.
        /// Fees applied after the free modification window.
        /// </summary>
        public string? ModificationFeesAfter { get; set; }
        /// <summary>
        /// الرسوم المطبقة بعد التعديل المجاني بالإنجليزية.
        /// Fees applied after the free modification window in English.
        /// </summary>
        public string? ModificationFeesAfterEn { get; set; }
        /// <summary>
        /// يحدد أن سياسة التعديل مرنة.
        /// Indicates a flexible modification policy.
        /// </summary>
        public bool? ModificationFlexible { get; set; }
        /// <summary>
        /// سبب سياسة التعديل.
        /// Reason for the modification policy.
        /// </summary>
        public string? ModificationReason { get; set; }
        /// <summary>
        /// سبب سياسة التعديل بالإنجليزية.
        /// Reason for the modification policy in English.
        /// </summary>
        public string? ModificationReasonEn { get; set; }
    }
}
