using System;
using System.Collections.Generic;

namespace YemenBooking.Application.Features.Users.DTOs {
    /// <summary>
    /// Represents a detailed user profile for administrative and operational views.
    /// يمثل ملفًا تفصيليًا للمستخدم للاستخدامات الإدارية والتشغيلية.
    /// </summary>
    public class UserDetailsDto
    {
        // Shared identity fields for all account types.
        // حقول الهوية المشتركة لكل أنواع الحسابات.
        /// <summary>
        /// Gets or sets the user identifier.
        /// يحصل أو يعيّن معرف المستخدم.
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// Gets or sets the username.
        /// يحصل أو يعيّن اسم المستخدم.
        /// </summary>
        public string UserName { get; set; }

        /// <summary>
        /// Gets or sets the user avatar URL.
        /// يحصل أو يعيّن رابط صورة المستخدم.
        /// </summary>
        public string AvatarUrl { get; set; }

        /// <summary>
        /// Gets or sets the email address.
        /// يحصل أو يعيّن البريد الإلكتروني.
        /// </summary>
        public string Email { get; set; }

        /// <summary>
        /// Gets or sets the phone number.
        /// يحصل أو يعيّن رقم الهاتف.
        /// </summary>
        public string PhoneNumber { get; set; }

        /// <summary>
        /// Gets or sets the account creation date.
        /// يحصل أو يعيّن تاريخ إنشاء الحساب.
        /// </summary>
        public DateTime CreatedAt { get; set; }

        /// <summary>
        /// Gets or sets whether the account is active.
        /// يحصل أو يعيّن ما إذا كان الحساب مفعلاً.
        /// </summary>
        public bool IsActive { get; set; }

        /// <summary>
        /// Gets or sets the last activity timestamp.
        /// يحصل أو يعيّن وقت آخر نشاط للمستخدم.
        /// </summary>
        public DateTime? LastSeen { get; set; }

        /// <summary>
        /// Gets or sets the last login date.
        /// يحصل أو يعيّن تاريخ آخر تسجيل دخول.
        /// </summary>
        public DateTime? LastLoginDate { get; set; }

        // Metrics that apply to the customer directly or to the managed property for owner/staff accounts.
        // مؤشرات تنطبق مباشرة على العميل أو على الكيان المُدار في حسابات المالك والموظف.
        /// <summary>
        /// Gets or sets the total bookings count for the customer account or managed property.
        /// يحصل أو يعيّن إجمالي عدد الحجوزات للعميل أو للكيان المُدار.
        /// </summary>
        public int BookingsCount { get; set; }

        /// <summary>
        /// Gets or sets the cancelled bookings count for the customer account or managed property.
        /// يحصل أو يعيّن عدد الحجوزات الملغاة للعميل أو للكيان المُدار.
        /// </summary>
        public int CanceledBookingsCount { get; set; }

        /// <summary>
        /// Gets or sets the pending bookings count for the customer account or managed property.
        /// يحصل أو يعيّن عدد الحجوزات المعلقة للعميل أو للكيان المُدار.
        /// </summary>
        public int PendingBookingsCount { get; set; }

        /// <summary>
        /// Gets or sets the first booking date for the customer account or managed property.
        /// يحصل أو يعيّن تاريخ أول حجز للعميل أو للكيان المُدار.
        /// </summary>
        public DateTime? FirstBookingDate { get; set; }

        /// <summary>
        /// Gets or sets the last booking date for the customer account or managed property.
        /// يحصل أو يعيّن تاريخ آخر حجز للعميل أو للكيان المُدار.
        /// </summary>
        public DateTime? LastBookingDate { get; set; }

        /// <summary>
        /// Gets or sets the number of reports created by the user or managed property team.
        /// يحصل أو يعيّن عدد البلاغات التي أنشأها المستخدم أو فريق الكيان المُدار.
        /// </summary>
        public int ReportsCreatedCount { get; set; }

        /// <summary>
        /// Gets or sets the number of reports filed against the user or managed property.
        /// يحصل أو يعيّن عدد البلاغات المقدمة ضد المستخدم أو الكيان المُدار.
        /// </summary>
        public int ReportsAgainstCount { get; set; }

        /// <summary>
        /// Gets or sets the total payments for the customer account or managed property.
        /// يحصل أو يعيّن إجمالي المدفوعات للعميل أو للكيان المُدار.
        /// </summary>
        public decimal TotalPayments { get; set; }

        /// <summary>
        /// Gets or sets the total refunds for the customer account or managed property.
        /// يحصل أو يعيّن إجمالي المردودات للعميل أو للكيان المُدار.
        /// </summary>
        public decimal TotalRefunds { get; set; }

        /// <summary>
        /// Gets or sets the total debit balance across the user's accounts.
        /// يحصل أو يعيّن إجمالي الرصيد المدين عبر حسابات المستخدم.
        /// </summary>
        public decimal TotalDebitBalance { get; set; }

        /// <summary>
        /// Gets or sets the total credit balance across the user's accounts.
        /// يحصل أو يعيّن إجمالي الرصيد الدائن عبر حسابات المستخدم.
        /// </summary>
        public decimal TotalCreditBalance { get; set; }

        /// <summary>
        /// Gets or sets the reviews count for the customer account or managed property.
        /// يحصل أو يعيّن عدد المراجعات للعميل أو للكيان المُدار.
        /// </summary>
        public int ReviewsCount { get; set; }

        // Owner and staff specific fields.
        // الحقول الخاصة بالمالك والموظف.
        /// <summary>
        /// Gets or sets the operational role, such as Owner or Staff.
        /// يحصل أو يعيّن الدور التشغيلي مثل مالك أو موظف.
        /// </summary>
        public string Role { get; set; }

        /// <summary>
        /// Gets or sets the related property identifier.
        /// يحصل أو يعيّن معرف الكيان المرتبط.
        /// </summary>
        public Guid? PropertyId { get; set; }

        /// <summary>
        /// Gets or sets the related property name.
        /// يحصل أو يعيّن اسم الكيان المرتبط.
        /// </summary>
        public string PropertyName { get; set; }

        /// <summary>
        /// Gets or sets the units count for the related property.
        /// يحصل أو يعيّن عدد الوحدات في الكيان المرتبط.
        /// </summary>
        public int? UnitsCount { get; set; }

        /// <summary>
        /// Gets or sets the number of property images.
        /// يحصل أو يعيّن عدد صور الكيان.
        /// </summary>
        public int? PropertyImagesCount { get; set; }

        /// <summary>
        /// Gets or sets the number of unit images.
        /// يحصل أو يعيّن عدد صور الوحدات.
        /// </summary>
        public int? UnitImagesCount { get; set; }

        /// <summary>
        /// Gets or sets the net revenue for the managed property.
        /// يحصل أو يعيّن صافي الإيراد للكيان المُدار.
        /// </summary>
        public decimal? NetRevenue { get; set; }

        /// <summary>
        /// Gets or sets the number of replies on reports, when available.
        /// يحصل أو يعيّن عدد الردود على البلاغات عند توفرها.
        /// </summary>
        public int? RepliesCount { get; set; }

        /// <summary>
        /// Gets or sets the wallet accounts linked to the user.
        /// يحصل أو يعيّن حسابات المحافظ المرتبطة بالمستخدم.
        /// </summary>
        public List<UserWalletAccountDto> WalletAccounts { get; set; } = new List<UserWalletAccountDto>();
    }
} 
