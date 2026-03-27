namespace YemenBooking.Core.Entities;

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

/// <summary>
/// يمثل حساب المستخدم وبياناته الأساسية وتفضيلاته المرتبطة به.
/// Represents the user's account, core profile, and related preferences.
/// </summary>
[Display(Name = "كيان المستخدم")]
public class User : BaseEntity<Guid>
{
    /// <summary>
    /// اسم العرض أو الاسم المسجل للحساب.
    /// The display or registered name for the account.
    /// </summary>
    [Display(Name = "اسم المستخدم")]
    public string Name { get; set; }


    /// <summary>
    /// البريد الإلكتروني المعتمد للحساب.
    /// The account's registered email address.
    /// </summary>
    [Display(Name = "البريد الإلكتروني للمستخدم")]
    public string Email { get; set; }

    /// <summary>
    /// كلمة مرور الحساب.
    /// The account password.
    /// </summary>
    [Display(Name = "كلمة المرور للمستخدم")]
    public string Password { get; set; }

    /// <summary>
    /// رقم الهاتف المرتبط بالحساب.
    /// The phone number associated with the account.
    /// </summary>
    [Display(Name = "رقم هاتف المستخدم")]
    public string Phone { get; set; }

    /// <summary>
    /// مسار أو رابط صورة الملف الشخصي.
    /// The path or URL of the profile image.
    /// </summary>
    [Display(Name = "صورة المستخدم")]
    public string? ProfileImage { get; set; }

    /// <summary>
    /// رابط بديل لصورة الملف الشخصي للتوافق مع المستهلكين الذين يتوقعون هذا الاسم.
    /// Alternate profile image URL for consumers that expect this property name.
    /// </summary>
    public string? ProfileImageUrl
    {
        get => ProfileImage;
        set => ProfileImage = value;
    }

    /// <summary>
    /// تاريخ إنشاء حساب المستخدم.
    /// The date the user account was created.
    /// </summary>
    [Display(Name = "تاريخ إنشاء حساب المستخدم")]
    public DateTime CreatedAt { get; set; }

    /// <summary>
    /// يشير إلى ما إذا كان الحساب مفعلًا.
    /// Indicates whether the account is active.
    /// </summary>
    [Display(Name = "حالة تفعيل الحساب")]
    public bool IsActive { get; set; }

    /// <summary>
    /// آخر مرة سجّل فيها المستخدم الدخول.
    /// The user's most recent login time.
    /// </summary>
    [Display(Name = "تاريخ آخر تسجيل دخول")]
    public DateTime? LastLoginDate { get; set; }

    /// <summary>
    /// آخر وقت معروف لنشاط المستخدم.
    /// The most recent known user activity timestamp.
    /// </summary>
    [Display(Name = "تاريخ آخر ظهور")]
    public DateTime? LastSeen { get; set; }

    /// <summary>
    /// إجمالي الإنفاق المرتبط بالمستخدم.
    /// The user's total recorded spending.
    /// </summary>
    [Display(Name = "إجمالي المبلغ المنفق")]
    public decimal TotalSpent { get; set; } = 0;

    /// <summary>
    /// مستوى الولاء الحالي للمستخدم.
    /// The user's current loyalty tier.
    /// </summary>
    [Display(Name = "فئة الولاء")]
    public string? LoyaltyTier { get; set; }

    /// <summary>
    /// الأدوار الممنوحة لهذا المستخدم.
    /// The roles assigned to this user.
    /// </summary>
    [Display(Name = "الأدوار المرتبطة بالمستخدم")]
    public virtual ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();

    /// <summary>
    /// العقارات أو الكيانات التي يملكها المستخدم.
    /// The properties or entities owned by the user.
    /// </summary>
    [Display(Name = "الكيانات المملوكة من قبل المستخدم")]
    public virtual ICollection<Property> Properties { get; set; } = new List<Property>();

    /// <summary>
    /// حسابات المحفظة المرتبطة بالمستخدم.
    /// The wallet accounts associated with the user.
    /// </summary>
    public virtual ICollection<UserWalletAccount> WalletAccounts { get; set; } = new List<UserWalletAccount>();

    /// <summary>
    /// الحجوزات التي أنشأها المستخدم.
    /// The bookings created by the user.
    /// </summary>
    [Display(Name = "الحجوزات التي قام بها المستخدم")]
    public virtual ICollection<Booking> Bookings { get; set; } = new List<Booking>();

    /// <summary>
    /// الأدوار الوظيفية التي يشغلها المستخدم داخل المنشآت.
    /// The staff positions the user holds within properties.
    /// </summary>
    [Display(Name = "الوظائف التي يشغلها المستخدم كموظف")]
    public virtual ICollection<Staff> StaffPositions { get; set; } = new List<Staff>();

    /// <summary>
    /// يشير إلى تأكيد البريد الإلكتروني.
    /// Indicates whether the email address has been confirmed.
    /// </summary>
    [Display(Name = "هل تم تأكيد البريد الإلكتروني")]
    public bool EmailConfirmed { get; set; } = false;

    /// <summary>
    /// يشير إلى إتمام التحقق من البريد الإلكتروني.
    /// Indicates whether the email address has been verified.
    /// </summary>
    [Display(Name = "هل تم التحقق من البريد الإلكتروني")]
    public bool IsEmailVerified { get; set; } = false;

    /// <summary>
    /// وقت التحقق من البريد الإلكتروني.
    /// The time the email address was verified.
    /// </summary>
    [Display(Name = "تاريخ التحقق من البريد الإلكتروني")]
    public DateTime? EmailVerifiedAt { get; set; }

    /// <summary>
    /// رمز تأكيد البريد الإلكتروني.
    /// The email confirmation token.
    /// </summary>
    [Display(Name = "رمز تأكيد البريد الإلكتروني")]
    public string? EmailConfirmationToken { get; set; }

    /// <summary>
    /// وقت انتهاء صلاحية رمز تأكيد البريد الإلكتروني.
    /// The expiration time of the email confirmation token.
    /// </summary>
    [Display(Name = "تاريخ انتهاء صلاحية رمز تأكيد البريد الإلكتروني")]
    public DateTime? EmailConfirmationTokenExpires { get; set; }

    /// <summary>
    /// رمز إعادة تعيين كلمة المرور.
    /// The password reset token.
    /// </summary>
    [Display(Name = "رمز إعادة تعيين كلمة المرور")]
    public string? PasswordResetToken { get; set; }

    /// <summary>
    /// وقت انتهاء صلاحية رمز إعادة تعيين كلمة المرور.
    /// The expiration time of the password reset token.
    /// </summary>
    [Display(Name = "تاريخ انتهاء صلاحية رمز إعادة تعيين كلمة المرور")]
    public DateTime? PasswordResetTokenExpires { get; set; }

    /// <summary>
    /// يشير إلى تأكيد رقم الهاتف.
    /// Indicates whether the phone number has been confirmed.
    /// </summary>
    [Display(Name = "هل تم تأكيد رقم الهاتف")]
    public bool PhoneNumberConfirmed { get; set; } = false;

    /// <summary>
    /// يشير إلى إتمام التحقق من رقم الهاتف.
    /// Indicates whether the phone number has been verified.
    /// </summary>
    [Display(Name = "هل تم التحقق من رقم الهاتف")]
    public bool IsPhoneNumberVerified { get; set; } = false;

    /// <summary>
    /// وقت التحقق من رقم الهاتف.
    /// The time the phone number was verified.
    /// </summary>
    [Display(Name = "تاريخ التحقق من رقم الهاتف")]
    public DateTime? PhoneNumberVerifiedAt { get; set; }

    /// <summary>
    /// رمز تأكيد رقم الهاتف.
    /// The phone number confirmation code.
    /// </summary>
    [Display(Name = "رمز تأكيد رقم الهاتف")]
    public string? PhoneNumberConfirmationCode { get; set; }

    /// <summary>
    /// وقت انتهاء صلاحية رمز تأكيد رقم الهاتف.
    /// The expiration time of the phone number confirmation code.
    /// </summary>
    [Display(Name = "تاريخ انتهاء صلاحية رمز تأكيد رقم الهاتف")]
    public DateTime? PhoneNumberConfirmationCodeExpires { get; set; }

    /// <summary>
    /// إعدادات المستخدم المخزنة بصيغة JSON.
    /// The user's settings stored as JSON.
    /// </summary>
    [Display(Name = "إعدادات المستخدم بصيغة JSON")]
    public string SettingsJson { get; set; } = "{}";

    /// <summary>
    /// قائمة المفضلة الخاصة بالمستخدم بصيغة JSON.
    /// The user's favorites list stored as JSON.
    /// </summary>
    [Display(Name = "قائمة المفضلة للمستخدم بصيغة JSON")]
    public string FavoritesJson { get; set; } = "[]";

    /// <summary>
    /// معرّف المنطقة الزمنية المفضل للمستخدم.
    /// The user's preferred time zone identifier.
    /// </summary>
    [Display(Name = "معرف المنطقة الزمنية للمستخدم")]
    public string? TimeZoneId { get; set; }
    
    /// <summary>
    /// الدولة المرتبطة بملف المستخدم.
    /// The country associated with the user profile.
    /// </summary>
    [Display(Name = "الدولة")]
    public string? Country { get; set; }
    
    /// <summary>
    /// المدينة المرتبطة بملف المستخدم.
    /// The city associated with the user profile.
    /// </summary>
    [Display(Name = "المدينة")]
    public string? City { get; set; }

    /// <summary>
    /// البلاغات التي أنشأها المستخدم.
    /// Reports filed by the user.
    /// </summary>
    [Display(Name = "البلاغات التي قام بها المستخدم")]
    public virtual ICollection<Report> ReportsMade { get; set; } = new List<Report>();

    /// <summary>
    /// البلاغات المسجلة ضد المستخدم.
    /// Reports filed against the user.
    /// </summary>
    [Display(Name = "البلاغات المقدمة ضد المستخدم")]
    public virtual ICollection<Report> ReportsAgainstUser { get; set; } = new List<Report>();
}
