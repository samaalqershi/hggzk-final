using System;
using System.ComponentModel.DataAnnotations;
using YemenBooking.Core.Enums;

namespace YemenBooking.Core.Entities
{
    /// <summary>
    /// يمثل عرضًا ترويجيًا يمكن تطبيقه على العقارات أو الحجوزات وفق شروط محددة.
    /// Represents a promotional offer that can be applied to properties or bookings under defined conditions.
    /// </summary>
    public class SpecialOffer : BaseEntity<Guid>
    {
        /// <summary>
        /// العنوان الظاهر للعرض في الواجهة.
        /// Display title of the offer in the UI.
        /// </summary>
        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;

        /// <summary>
        /// وصف تفصيلي للعرض وما يقدمه.
        /// Detailed description of what the offer provides.
        /// </summary>
        [MaxLength(1000)]
        public string Description { get; set; } = string.Empty;

        /// <summary>
        /// تصنيف العرض وفق نمطه التسويقي.
        /// Offer classification based on its marketing pattern.
        /// </summary>
        public OfferType OfferType { get; set; }

        /// <summary>
        /// قيمة الخصم المعتمدة لهذا العرض.
        /// Discount value defined for this offer.
        /// </summary>
        public decimal DiscountValue { get; set; }

        /// <summary>
        /// يحدد ما إذا كان الخصم نسبة مئوية أم مبلغًا ثابتًا.
        /// Indicates whether the discount is percentage-based or a fixed amount.
        /// </summary>
        public DiscountType DiscountType { get; set; }

        /// <summary>
        /// نسبة الخصم عند استخدام نوع الخصم المئوي.
        /// Discount percentage when the offer uses percentage-based pricing.
        /// </summary>
        public decimal DiscountPercentage { get; set; }

        /// <summary>
        /// مبلغ الخصم الثابت عند استخدام نوع الخصم الثابت.
        /// Fixed discount amount when the offer uses fixed-value pricing.
        /// </summary>
        public decimal DiscountAmount { get; set; }

        /// <summary>
        /// تاريخ انتهاء صلاحية العرض عند استخدامه.
        /// Expiration date of the offer when applicable.
        /// </summary>
        public DateTime? ExpiryDate { get; set; }

        /// <summary>
        /// لون الشارة أو التمييز البصري المرتبط بالعرض.
        /// Badge or highlight color associated with the offer.
        /// </summary>
        public string? Color { get; set; } = "#FF6B6B";

        /// <summary>
        /// الحد الأدنى للمبلغ المطلوب لتفعيل العرض.
        /// Minimum amount required to qualify for the offer.
        /// </summary>
        public decimal? MinimumAmount { get; set; }

        /// <summary>
        /// الحد الأقصى لقيمة الخصم المسموح بها.
        /// Maximum discount amount allowed.
        /// </summary>
        public decimal? MaxDiscountAmount { get; set; }

        /// <summary>
        /// تاريخ بدء سريان العرض.
        /// Date when the offer becomes active.
        /// </summary>
        public DateTime StartDate { get; set; }

        /// <summary>
        /// تاريخ انتهاء سريان العرض.
        /// Date when the offer stops being active.
        /// </summary>
        public DateTime EndDate { get; set; }

        /// <summary>
        /// الحد الأقصى لعدد مرات استخدام العرض.
        /// Maximum number of times the offer can be used.
        /// </summary>
        public int? MaxUsageCount { get; set; }

        /// <summary>
        /// العدد الحالي لمرات استخدام العرض.
        /// Current number of times the offer has been used.
        /// </summary>
        public int CurrentUsageCount { get; set; } = 0;

        /// <summary>
        /// يحدد ما إذا كان العرض متاحًا للاستخدام حاليًا.
        /// Indicates whether the offer is currently available for use.
        /// </summary>
        public bool IsActive { get; set; } = true;

        /// <summary>
        /// الرمز الترويجي المستخدم لتطبيق العرض يدويًا عند الحاجة.
        /// Promotional code used to apply the offer manually when needed.
        /// </summary>
        [MaxLength(50)]
        public string? OfferCode { get; set; }

        /// <summary>
        /// معرّف العقار المرتبط بهذا العرض عند تخصيصه لعقار محدد.
        /// Identifier of the property linked to this offer when it is property-specific.
        /// </summary>
        public Guid? PropertyId { get; set; }

        /// <summary>
        /// المرجع الملاحي إلى العقار المرتبط بهذا العرض.
        /// Navigation reference to the property associated with this offer.
        /// </summary>
        public virtual Property? Property { get; set; }

        /// <summary>
        /// رابط الصورة المستخدمة لعرض العرض بصريًا.
        /// Image URL used to visually present the offer.
        /// </summary>
        [MaxLength(500)]
        public string? ImageUrl { get; set; }

        /// <summary>
        /// أولوية العرض عند ترتيبه ضمن العروض الأخرى.
        /// Offer priority used when sorting against other offers.
        /// </summary>
        public int Priority { get; set; } = 0;

        /// <summary>
        /// الشروط والأحكام المرتبطة بالعرض.
        /// Terms and conditions associated with the offer.
        /// </summary>
        [MaxLength(2000)]
        public string? TermsAndConditions { get; set; }
    }

    /// <summary>
    /// نوع العرض
    /// Offer type enumeration
    /// </summary>
    public enum OfferType
    {
        /// <summary>
        /// عرض عام
        /// General offer
        /// </summary>
        General = 1,

        /// <summary>
        /// عرض للحجز المبكر
        /// Early booking offer
        /// </summary>
        EarlyBooking = 2,

        /// <summary>
        /// عرض اللحظة الأخيرة
        /// Last minute offer
        /// </summary>
        LastMinute = 3,

        /// <summary>
        /// عرض الإقامة الطويلة
        /// Long stay offer
        /// </summary>
        LongStay = 4,

        /// <summary>
        /// عرض موسمي
        /// Seasonal offer
        /// </summary>
        Seasonal = 5,

        /// <summary>
        /// عرض للعملاء الجدد
        /// New customer offer
        /// </summary>
        NewCustomer = 6,

        /// <summary>
        /// عرض الولاء
        /// Loyalty offer
        /// </summary>
        Loyalty = 7
    }

    /// <summary>
    /// نوع الخصم
    /// Discount type enumeration
    /// </summary>
    public enum DiscountType
    {
        /// <summary>
        /// نسبة مئوية
        /// Percentage
        /// </summary>
        Percentage = 1,

        /// <summary>
        /// مبلغ ثابت
        /// Fixed amount
        /// </summary>
        FixedAmount = 2
    }
}
