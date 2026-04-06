using System;
using System.Collections.Generic;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.PropertyServices.DTOs;
using YemenBooking.Application.Features.Payments.DTOs;
using YemenBooking.Application.Features.Reviews.DTOs;

namespace YemenBooking.Application.Features.Bookings.DTOs {
    /// <summary>
    /// Represents the detailed booking payload returned to clients.
    /// يمثل حمولة تفاصيل الحجز المعادة للعملاء.
    /// </summary>
    public class BookingDetailsDto
    {
        // Fields expected by the mobile application handlers.
        // الحقول المتوقعة من معالجات تطبيق الجوال.
        /// <summary>
        /// Gets or sets the property address.
        /// يحصل أو يعيّن عنوان العقار.
        /// </summary>
        public string PropertyAddress { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the check-in date.
        /// يحصل أو يعيّن تاريخ الوصول.
        /// </summary>
        public DateTime CheckIn { get; set; }
        /// <summary>
        /// Gets or sets the check-out date.
        /// يحصل أو يعيّن تاريخ المغادرة.
        /// </summary>
        public DateTime CheckOut { get; set; }

        /// <summary>
        /// Gets or sets the guest count.
        /// يحصل أو يعيّن عدد الضيوف.
        /// </summary>
        public int GuestsCount { get; set; }

        /// <summary>
        /// Gets or sets the booking timestamp.
        /// يحصل أو يعيّن وقت إنشاء الحجز.
        /// </summary>
        public DateTime BookedAt { get; set; }
        /// <summary>
        /// Gets or sets the booking source.
        /// يحصل أو يعيّن مصدر الحجز.
        /// </summary>
        public string? BookingSource { get; set; }
        /// <summary>
        /// Gets or sets the cancellation reason, when present.
        /// يحصل أو يعيّن سبب الإلغاء عند توفره.
        /// </summary>
        public string? CancellationReason { get; set; }
        /// <summary>
        /// Gets or sets whether the booking was created as walk-in.
        /// يحصل أو يعيّن ما إذا كان الحجز تم كـ walk-in.
        /// </summary>
        public bool IsWalkIn { get; set; }
        /// <summary>
        /// Gets or sets the platform commission amount.
        /// يحصل أو يعيّن مبلغ عمولة المنصة.
        /// </summary>
        public decimal? PlatformCommissionAmount { get; set; }
        /// <summary>
        /// Gets or sets the actual check-in date.
        /// يحصل أو يعيّن تاريخ الوصول الفعلي.
        /// </summary>
        public DateTime? ActualCheckInDate { get; set; }
        /// <summary>
        /// Gets or sets the actual check-out date.
        /// يحصل أو يعيّن تاريخ المغادرة الفعلي.
        /// </summary>
        public DateTime? ActualCheckOutDate { get; set; }
        /// <summary>
        /// Gets or sets the final amount.
        /// يحصل أو يعيّن المبلغ النهائي.
        /// </summary>
        public decimal? FinalAmount { get; set; }
        /// <summary>
        /// Gets or sets the customer rating.
        /// يحصل أو يعيّن تقييم العميل.
        /// </summary>
        public int? CustomerRating { get; set; }
        /// <summary>
        /// Gets or sets completion notes.
        /// يحصل أو يعيّن ملاحظات الإكمال.
        /// </summary>
        public string? CompletionNotes { get; set; }

        /// <summary>
        /// Gets or sets the booked services.
        /// يحصل أو يعيّن الخدمات المحجوزة.
        /// </summary>
        public List<BookingServiceDto> Services { get; set; } = new();
        /// <summary>
        /// Gets or sets related payments.
        /// يحصل أو يعيّن المدفوعات المرتبطة.
        /// </summary>
        public List<PaymentDto> Payments { get; set; } = new();
        /// <summary>
        /// Gets or sets the unit image URLs.
        /// يحصل أو يعيّن روابط صور الوحدة.
        /// </summary>
        public List<string> UnitImages { get; set; } = new();
        /// <summary>
        /// Gets or sets the booking identifier.
        /// يحصل أو يعيّن معرف الحجز.
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// Gets or sets the booking number.
        /// يحصل أو يعيّن رقم الحجز.
        /// </summary>
        public string BookingNumber { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the user identifier.
        /// يحصل أو يعيّن معرف المستخدم.
        /// </summary>
        public Guid UserId { get; set; }

        /// <summary>
        /// Gets or sets the user name.
        /// يحصل أو يعيّن اسم المستخدم.
        /// </summary>
        public string UserName { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the property identifier.
        /// يحصل أو يعيّن معرف العقار.
        /// </summary>
        public Guid PropertyId { get; set; }

        /// <summary>
        /// Gets or sets the property name.
        /// يحصل أو يعيّن اسم العقار.
        /// </summary>
        public string PropertyName { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the unit identifier.
        /// يحصل أو يعيّن معرف الوحدة.
        /// </summary>
        public Guid? UnitId { get; set; }

        /// <summary>
        /// Gets or sets the unit name.
        /// يحصل أو يعيّن اسم الوحدة.
        /// </summary>
        public string? UnitName { get; set; }

        /// <summary>
        /// Gets or sets the planned check-in date.
        /// يحصل أو يعيّن تاريخ الوصول المخطط.
        /// </summary>
        public DateTime CheckInDate { get; set; }

        /// <summary>
        /// Gets or sets the planned check-out date.
        /// يحصل أو يعيّن تاريخ المغادرة المخطط.
        /// </summary>
        public DateTime CheckOutDate { get; set; }

        /// <summary>
        /// Gets or sets the number of nights.
        /// يحصل أو يعيّن عدد الليالي.
        /// </summary>
        public int NumberOfNights { get; set; }

        /// <summary>
        /// Gets or sets the number of adult guests.
        /// يحصل أو يعيّن عدد الضيوف البالغين.
        /// </summary>
        public int AdultGuests { get; set; }

        /// <summary>
        /// Gets or sets the number of child guests.
        /// يحصل أو يعيّن عدد الضيوف الأطفال.
        /// </summary>
        public int ChildGuests { get; set; }

        /// <summary>
        /// Gets or sets the total amount before booked services.
        /// يحصل أو يعيّن المبلغ الإجمالي قبل الخدمات.
        /// </summary>
        public decimal TotalAmount { get; set; }
        
        /// <summary>
        /// Gets the total amount including booked services.
        /// يحصل على المبلغ الإجمالي شاملاً الخدمات المحجوزة.
        /// </summary>
        public decimal TotalAmountWithServices
        {
            get
            {
                var servicesTotal = Services?.Sum(s => s.TotalPrice) ?? 0;
                return TotalAmount + servicesTotal;
            }
        }
        
        /// <summary>
        /// Gets or sets the currency code.
        /// يحصل أو يعيّن رمز العملة.
        /// </summary>
        public string Currency { get; set; } = "YER";
        
        /// <summary>
        /// Gets or sets the total price as a money object.
        /// يحصل أو يعيّن السعر الإجمالي ككائن Money.
        /// </summary>
        public MoneyDto TotalPrice { get; set; }

        /// <summary>
        /// Gets or sets the booking status.
        /// يحصل أو يعيّن حالة الحجز.
        /// </summary>
        public BookingStatus Status { get; set; }

        /// <summary>
        /// Gets or sets the booking date.
        /// يحصل أو يعيّن تاريخ الحجز.
        /// </summary>
        public DateTime BookingDate { get; set; }

        /// <summary>
        /// Gets or sets special notes.
        /// يحصل أو يعيّن الملاحظات الخاصة.
        /// </summary>
        public string? SpecialNotes { get; set; }

        /// <summary>
        /// Gets or sets contact information.
        /// يحصل أو يعيّن معلومات الاتصال.
        /// </summary>
        public ContactInfoDto ContactInfo { get; set; } = new();

        /// <summary>
        /// Gets or sets payment details.
        /// يحصل أو يعيّن تفاصيل الدفع.
        /// </summary>
        public List<YemenBooking.Application.Features.Payments.DTOs.PaymentDetailsDto> PaymentDetails { get; set; } = new();

        /// <summary>
        /// Gets or sets whether the booking is fully paid.
        /// يحصل أو يعيّن ما إذا كان الحجز مدفوعًا بالكامل.
        /// </summary>
        public bool IsPaid { get; set; }

        /// <summary>
        /// Gets or sets whether the booking can be cancelled.
        /// يحصل أو يعيّن ما إذا كان يمكن إلغاء الحجز.
        /// </summary>
        public bool CanCancel { get; set; }

        /// <summary>
        /// Gets or sets the cancellation restriction reason.
        /// يحصل أو يعيّن سبب منع الإلغاء.
        /// </summary>
        public string? CancelNotAllowedReason { get; set; }

        /// <summary>
        /// Gets or sets the cancellation restriction code.
        /// يحصل أو يعيّن كود سبب منع الإلغاء.
        /// </summary>
        public string? CancelNotAllowedCode { get; set; }

        /// <summary>
        /// Gets or sets whether the booking can be reviewed.
        /// يحصل أو يعيّن ما إذا كان يمكن تقييم الحجز.
        /// </summary>
        public bool CanReview { get; set; }

        /// <summary>
        /// Gets or sets the user's review for the booking.
        /// يحصل أو يعيّن مراجعة المستخدم للحجز.
        /// </summary>
        public BookingUserReviewDto? UserReview { get; set; }

        /// <summary>
        /// Gets or sets whether the booking can be modified.
        /// يحصل أو يعيّن ما إذا كان يمكن تعديل الحجز.
        /// </summary>
        public bool CanModify { get; set; }

        /// <summary>
        /// Gets or sets the property policy snapshot captured at booking time.
        /// يحصل أو يعيّن لقطة سياسات العقار وقت الحجز.
        /// </summary>
        public string? PolicySnapshot { get; set; }

        /// <summary>
        /// Gets or sets when the policy snapshot was captured.
        /// يحصل أو يعيّن وقت حفظ لقطة السياسات.
        /// </summary>
        public DateTime? PolicySnapshotAt { get; set; }
    }

    /// <summary>
    /// Represents the review authored by the booking user.
    /// يمثل المراجعة التي أنشأها مستخدم الحجز.
    /// </summary>
    public class BookingUserReviewDto
    {
        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        public Guid Id { get; set; }
        /// <summary>
        /// خاصية BookingId.
        /// BookingId property.
        /// </summary>
        public Guid BookingId { get; set; }
        /// <summary>
        /// خاصية PropertyId.
        /// PropertyId property.
        /// </summary>
        public Guid PropertyId { get; set; }
        /// <summary>
        /// خاصية Cleanliness.
        /// Cleanliness property.
        /// </summary>
        public int Cleanliness { get; set; }
        /// <summary>
        /// خاصية Service.
        /// Service property.
        /// </summary>
        public int Service { get; set; }
        /// <summary>
        /// خاصية Location.
        /// Location property.
        /// </summary>
        public int Location { get; set; }
        /// <summary>
        /// خاصية Value.
        /// Value property.
        /// </summary>
        public int Value { get; set; }
        /// <summary>
        /// خاصية AverageRating.
        /// AverageRating property.
        /// </summary>
        public decimal AverageRating { get; set; }
        /// <summary>
        /// خاصية Comment.
        /// Comment property.
        /// </summary>
        public string Comment { get; set; } = string.Empty;
        /// <summary>
        /// خاصية CreatedAt.
        /// CreatedAt property.
        /// </summary>
        public DateTime CreatedAt { get; set; }
        /// <summary>
        /// خاصية ResponseText.
        /// ResponseText property.
        /// </summary>
        public string? ResponseText { get; set; }
        /// <summary>
        /// خاصية ResponseDate.
        /// ResponseDate property.
        /// </summary>
        public DateTime? ResponseDate { get; set; }
        /// <summary>
        /// خاصية IsPendingApproval.
        /// IsPendingApproval property.
        /// </summary>
        public bool IsPendingApproval { get; set; }
        /// <summary>
        /// خاصية IsDisabled.
        /// IsDisabled property.
        /// </summary>
        public bool IsDisabled { get; set; }

        /// <summary>
        /// الوسائط المرفقة بالمراجعة.
        /// Review media attached to this booking review.
        /// </summary>
        public List<ReviewImageDto> Images { get; set; } = new();
    }

    /// <summary>
    /// Represents the contact information attached to a booking.
    /// يمثل معلومات الاتصال المرتبطة بالحجز.
    /// </summary>
    public class ContactInfoDto
    {
        /// <summary>
        /// Gets or sets the phone number.
        /// يحصل أو يعيّن رقم الهاتف.
        /// </summary>
        public string PhoneNumber { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the email address.
        /// يحصل أو يعيّن البريد الإلكتروني.
        /// </summary>
        public string Email { get; set; } = string.Empty;
    }
}
