namespace YemenBooking.Core.Entities;

using System;
using System.ComponentModel.DataAnnotations;
using YemenBooking.Core.Enums;

/// <summary>
/// يمثل سياسة تشغيلية مرتبطة بعقار، مثل الإلغاء والدفع والدخول وقيود الأطفال والحيوانات.
/// Represents an operational policy tied to a property, including cancellation, payment, check-in, and child/pet rules.
/// </summary>
[Display(Name = "كيان سياسة الكيان")]
public class PropertyPolicy : BaseEntity<Guid>
{
    /// <summary>
    /// معرّف العقار الذي تنطبق عليه هذه السياسة.
    /// Identifier of the property this policy applies to.
    /// </summary>
    [Display(Name = "معرف الكيان")]
    public Guid PropertyId { get; set; }
    
    /// <summary>
    /// فئة السياسة التشغيلية التي يمثلها هذا السجل.
    /// Operational policy category represented by this record.
    /// </summary>
    [Display(Name = "نوع السياسة")]
    public PolicyType Type { get; set; }
    
    /// <summary>
    /// عدد الأيام المسموح خلالها بالإلغاء قبل الوصول.
    /// Number of days before arrival during which cancellation remains allowed.
    /// </summary>
    [Display(Name = "عدد أيام نافذة الإلغاء قبل تاريخ الوصول")]
    public int CancellationWindowDays { get; set; }
    
    /// <summary>
    /// يحدد ما إذا كان يجب سداد المبلغ كاملًا قبل تأكيد الحجز.
    /// Indicates whether full payment is required before booking confirmation.
    /// </summary>
    [Display(Name = "يتطلب الدفع الكامل قبل التأكيد")]
    public bool RequireFullPaymentBeforeConfirmation { get; set; }
    
    /// <summary>
    /// أقل نسبة دفع مقدمة مطلوبة قبل التأكيد.
    /// Minimum deposit percentage required before confirmation.
    /// </summary>
    [Display(Name = "الحد الأدنى لنسبة الدفع المقدمة")]
    public decimal MinimumDepositPercentage { get; set; }
    
    /// <summary>
    /// الحد الأدنى لعدد الساعات قبل تسجيل الوصول المسموح خلالها بالتعديل.
    /// Minimum number of hours before check-in during which modification is allowed.
    /// </summary>
    [Display(Name = "الحد الأدنى للساعات قبل تسجيل الوصول لتعديل الحجز")]
    public int MinHoursBeforeCheckIn { get; set; }
    
    /// <summary>
    /// وصف تفصيلي يشرح هذه السياسة التشغيلية.
    /// Detailed description explaining this operational policy.
    /// </summary>
    [Display(Name = "وصف السياسة")]
    public string Description { get; set; }

    /// <summary>
    /// وصف السياسة باللغة الإنجليزية.
    /// English policy description.
    /// </summary>
    [Display(Name = "وصف السياسة بالإنجليزية")]
    public string? DescriptionEn { get; set; }
    
    /// <summary>
    /// قواعد السياسة المخزنة بصيغة JSON لاستهلاكها من الواجهة أو الخدمات.
    /// Policy rules stored as JSON for use by the UI or services.
    /// </summary>
    [Display(Name = "قواعد السياسة")]
    public string? Rules { get; set; }

    /// <summary>
    /// قواعد السياسة باللغة الإنجليزية بصيغة JSON.
    /// English policy rules stored as JSON.
    /// </summary>
    [Display(Name = "قواعد السياسة بالإنجليزية")]
    public string? RulesEn { get; set; }

    /// <summary>
    /// يحدد ما إذا كان الإلغاء مجانيًا بالكامل.
    /// Indicates whether cancellation is completely free.
    /// </summary>
    public bool? CancellationFreeCancel { get; set; }
    /// <summary>
    /// يحدد ما إذا كان الإلغاء يمنح استردادًا كاملًا.
    /// Indicates whether cancellation results in a full refund.
    /// </summary>
    public bool? CancellationFullRefund { get; set; }
    /// <summary>
    /// نسبة الاسترداد المستحقة عند الإلغاء.
    /// Refund percentage granted upon cancellation.
    /// </summary>
    public int? CancellationRefundPercentage { get; set; }
    /// <summary>
    /// عدد الأيام قبل تسجيل الوصول التي يظل فيها الإلغاء متاحًا.
    /// Number of days before check-in during which cancellation remains available.
    /// </summary>
    public int? CancellationDaysBeforeCheckIn { get; set; }
    /// <summary>
    /// عدد الساعات قبل تسجيل الوصول التي يظل فيها الإلغاء متاحًا.
    /// Number of hours before check-in during which cancellation remains available.
    /// </summary>
    public int? CancellationHoursBeforeCheckIn { get; set; }
    /// <summary>
    /// يحدد ما إذا كان الإلغاء غير قابل للاسترداد.
    /// Indicates whether the cancellation is non-refundable.
    /// </summary>
    public bool? CancellationNonRefundable { get; set; }
    /// <summary>
    /// وصف الجزاء المطبق بعد انتهاء مهلة الإلغاء.
    /// Description of the penalty applied after the cancellation deadline.
    /// </summary>
    public string? CancellationPenaltyAfterDeadline { get; set; }

    /// <summary>
    /// وصف جزاء الإلغاء بعد المهلة باللغة الإنجليزية.
    /// English cancellation penalty description after deadline.
    /// </summary>
    public string? CancellationPenaltyAfterDeadlineEn { get; set; }

    /// <summary>
    /// يحدد ما إذا كان مطلوبًا دفع عربون.
    /// Indicates whether a deposit is required.
    /// </summary>
    public bool? PaymentDepositRequired { get; set; }
    /// <summary>
    /// يحدد ما إذا كان الدفع الكامل مطلوبًا.
    /// Indicates whether full payment is required.
    /// </summary>
    public bool? PaymentFullPaymentRequired { get; set; }
    /// <summary>
    /// نسبة العربون المطلوبة من إجمالي المبلغ.
    /// Deposit percentage required from the total amount.
    /// </summary>
    public decimal? PaymentDepositPercentage { get; set; }
    /// <summary>
    /// يحدد ما إذا كان الدفع النقدي مقبولًا.
    /// Indicates whether cash payment is accepted.
    /// </summary>
    public bool? PaymentAcceptCash { get; set; }
    /// <summary>
    /// يحدد ما إذا كان الدفع بالبطاقة مقبولًا.
    /// Indicates whether card payment is accepted.
    /// </summary>
    public bool? PaymentAcceptCard { get; set; }
    /// <summary>
    /// يحدد ما إذا كان الدفع عند الوصول إلى العقار مقبولًا.
    /// Indicates whether pay-at-property is accepted.
    /// </summary>
    public bool? PaymentPayAtProperty { get; set; }
    /// <summary>
    /// يحدد ما إذا كان الدفع النقدي هو الخيار المفضل.
    /// Indicates whether cash is the preferred payment method.
    /// </summary>
    public bool? PaymentCashPreferred { get; set; }
    /// <summary>
    /// طرق الدفع المقبولة بصيغة مصفوفة.
    /// Accepted payment methods as an array.
    /// </summary>
    public string[]? PaymentAcceptedMethods { get; set; }

    /// <summary>
    /// وقت تسجيل الوصول الافتراضي.
    /// Default check-in time.
    /// </summary>
    public TimeOnly? CheckInTime { get; set; }
    /// <summary>
    /// وقت تسجيل المغادرة الافتراضي.
    /// Default check-out time.
    /// </summary>
    public TimeOnly? CheckOutTime { get; set; }
    /// <summary>
    /// بداية نافذة تسجيل الوصول المسموح بها.
    /// Start of the allowed check-in window.
    /// </summary>
    public TimeOnly? CheckInFrom { get; set; }
    /// <summary>
    /// نهاية نافذة تسجيل الوصول المسموح بها.
    /// End of the allowed check-in window.
    /// </summary>
    public TimeOnly? CheckInUntil { get; set; }
    /// <summary>
    /// يحدد ما إذا كان تسجيل الوصول مرنًا.
    /// Indicates whether check-in is flexible.
    /// </summary>
    public bool? CheckInFlexible { get; set; }
    /// <summary>
    /// يحدد ما إذا كان تسجيل الوصول المرن مسموحًا به عند الوصول المبكر أو المتأخر.
    /// Indicates whether flexible check-in is allowed for early or late arrivals.
    /// </summary>
    public bool? CheckInFlexibleCheckIn { get; set; }
    /// <summary>
    /// يحدد ما إذا كان تسجيل الوصول يتطلب تنسيقًا مسبقًا.
    /// Indicates whether check-in requires prior coordination.
    /// </summary>
    public bool? CheckInRequiresCoordination { get; set; }
    /// <summary>
    /// يحدد ما إذا كان يجب التواصل مع المالك قبل تسجيل الوصول.
    /// Indicates whether the owner must be contacted before check-in.
    /// </summary>
    public bool? CheckInContactOwner { get; set; }
    /// <summary>
    /// ملاحظة تتعلق بالتسجيل المبكر للوصول.
    /// Note related to early check-in.
    /// </summary>
    public string? CheckInEarlyCheckInNote { get; set; }

    /// <summary>
    /// ملاحظة تسجيل الوصول المبكر باللغة الإنجليزية.
    /// English early check-in note.
    /// </summary>
    public string? CheckInEarlyCheckInNoteEn { get; set; }
    /// <summary>
    /// ملاحظة تتعلق بالتسجيل المتأخر للمغادرة.
    /// Note related to late check-out.
    /// </summary>
    public string? CheckInLateCheckOutNote { get; set; }

    /// <summary>
    /// ملاحظة تسجيل المغادرة المتأخر باللغة الإنجليزية.
    /// English late check-out note.
    /// </summary>
    public string? CheckInLateCheckOutNoteEn { get; set; }
    /// <summary>
    /// وصف أو قيمة الرسوم الخاصة بالمغادرة المتأخرة.
    /// Description or amount of the late check-out fee.
    /// </summary>
    public string? CheckInLateCheckOutFee { get; set; }

    /// <summary>
    /// وصف رسوم المغادرة المتأخرة باللغة الإنجليزية.
    /// English late check-out fee description.
    /// </summary>
    public string? CheckInLateCheckOutFeeEn { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت الإقامة مع الأطفال مسموحة.
    /// Indicates whether children are allowed.
    /// </summary>
    public bool? ChildrenAllowed { get; set; }
    /// <summary>
    /// السن الذي يكون تحته الطفل مجانيًا.
    /// Age under which a child stays free.
    /// </summary>
    public int? ChildrenFreeUnderAge { get; set; }
    /// <summary>
    /// السن الذي يكون تحته الطفل بنصف السعر.
    /// Age under which a child is charged half price.
    /// </summary>
    public int? ChildrenHalfPriceUnderAge { get; set; }
    /// <summary>
    /// الحد الأقصى لعدد الأطفال في الغرفة الواحدة.
    /// Maximum number of children allowed per room.
    /// </summary>
    public int? ChildrenMaxChildrenPerRoom { get; set; }
    /// <summary>
    /// الحد الأقصى لعدد الأطفال الإجمالي المسموح به.
    /// Maximum total number of children allowed.
    /// </summary>
    public int? ChildrenMaxChildren { get; set; }
    /// <summary>
    /// ملاحظة تخص الأسرّة أو المهد للأطفال.
    /// Note about cribs or children's beds.
    /// </summary>
    public string? ChildrenCribsNote { get; set; }

    /// <summary>
    /// ملاحظة أسرّة الأطفال باللغة الإنجليزية.
    /// English note about children's beds or cribs.
    /// </summary>
    public string? ChildrenCribsNoteEn { get; set; }
    /// <summary>
    /// يحدد ما إذا كانت مساحة لعب الأطفال متاحة.
    /// Indicates whether a children's playground is available.
    /// </summary>
    public bool? ChildrenPlaygroundAvailable { get; set; }
    /// <summary>
    /// يحدد ما إذا كانت قائمة الأطفال متاحة.
    /// Indicates whether a kids' menu is available.
    /// </summary>
    public bool? ChildrenKidsMenuAvailable { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت الحيوانات الأليفة مسموحة.
    /// Indicates whether pets are allowed.
    /// </summary>
    public bool? PetsAllowed { get; set; }
    /// <summary>
    /// سبب أو توضيح متعلق بسياسة الحيوانات الأليفة.
    /// Reason or explanation related to the pet policy.
    /// </summary>
    public string? PetsReason { get; set; }

    /// <summary>
    /// سبب سياسة الحيوانات الأليفة باللغة الإنجليزية.
    /// English reason for the pet policy.
    /// </summary>
    public string? PetsReasonEn { get; set; }
    /// <summary>
    /// رسوم الحيوانات الأليفة إن وجدت.
    /// Pet fee amount, when applicable.
    /// </summary>
    public decimal? PetsFeeAmount { get; set; }
    /// <summary>
    /// الحد الأقصى لوزن الحيوان الأليف المسموح.
    /// Maximum allowed pet weight.
    /// </summary>
    public string? PetsMaxWeight { get; set; }

    /// <summary>
    /// الحد الأقصى لوزن الحيوانات الأليفة باللغة الإنجليزية.
    /// English maximum pet weight description.
    /// </summary>
    public string? PetsMaxWeightEn { get; set; }
    /// <summary>
    /// يحدد ما إذا كانت موافقة مسبقة مطلوبة للحيوانات الأليفة.
    /// Indicates whether prior approval is required for pets.
    /// </summary>
    public bool? PetsRequiresApproval { get; set; }
    /// <summary>
    /// يحدد ما إذا كانت الحيوانات الأليفة معفاة من الرسوم.
    /// Indicates whether pets are exempt from fees.
    /// </summary>
    public bool? PetsNoFees { get; set; }
    /// <summary>
    /// يحدد ما إذا كان العقار مناسبًا للحيوانات الأليفة.
    /// Indicates whether the property is pet-friendly.
    /// </summary>
    public bool? PetsPetFriendly { get; set; }
    /// <summary>
    /// يحدد ما إذا كانت هناك مساحة خارجية للحيوانات الأليفة.
    /// Indicates whether outdoor space is available for pets.
    /// </summary>
    public bool? PetsOutdoorSpace { get; set; }
    /// <summary>
    /// يحدد ما إذا كانت السياسة تجاه الحيوانات الأليفة صارمة.
    /// Indicates whether the pet policy is strict.
    /// </summary>
    public bool? PetsStrict { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت التعديلات على الحجز مسموحة.
    /// Indicates whether booking modifications are allowed.
    /// </summary>
    public bool? ModificationAllowed { get; set; }
    /// <summary>
    /// عدد الساعات التي تظل خلالها التعديلات مجانية.
    /// Number of hours during which modifications remain free.
    /// </summary>
    public int? ModificationFreeModificationHours { get; set; }
    /// <summary>
    /// وصف الرسوم المطبقة بعد تجاوز المهلة المجانية.
    /// Description of fees applied after the free modification window.
    /// </summary>
    public string? ModificationFeesAfter { get; set; }

    /// <summary>
    /// وصف رسوم التعديل بعد المهلة باللغة الإنجليزية.
    /// English modification fee description after the free window.
    /// </summary>
    public string? ModificationFeesAfterEn { get; set; }
    /// <summary>
    /// يحدد ما إذا كانت التعديلات تتم بمرونة.
    /// Indicates whether modifications are flexible.
    /// </summary>
    public bool? ModificationFlexible { get; set; }
    /// <summary>
    /// سبب أو شرح متعلق بسياسة التعديل.
    /// Reason or explanation related to the modification policy.
    /// </summary>
    public string? ModificationReason { get; set; }

    /// <summary>
    /// سبب سياسة التعديل باللغة الإنجليزية.
    /// English reason for the modification policy.
    /// </summary>
    public string? ModificationReasonEn { get; set; }
    
    /// <summary>
    /// المرجع الملاحي إلى العقار المرتبط بهذه السياسة.
    /// Navigation reference to the property associated with this policy.
     /// </summary>
    [Display(Name = "الكيان المرتبط بالسياسة")]
    public virtual Property Property { get; set; }
}
