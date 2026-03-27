using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Authentication.Commands.UpdateUser;

    /// <summary>
    /// طلب تحديث ملف العميل الشخصي.
    /// client profile update request.
    /// </summary>
public class ClientUpdateUserProfileCommand : IRequest<ResultDto<ClientUserProfileResponse>>
{
    /// <summary>
    /// معرّف المستخدم
    /// user ID
    /// </summary>
    public Guid UserId { get; set; }

    /// <summary>
    /// الاسم الأول
    /// first name
    /// </summary>
    public string FirstName { get; set; } = string.Empty;

    /// <summary>
    /// اسم العائلة
    /// last name
    /// </summary>
    public string LastName { get; set; } = string.Empty;

    /// <summary>
    /// رقم الهاتف
    /// phone number
    /// </summary>
    public string? PhoneNumber { get; set; }

    /// <summary>
    /// تاريخ الميلاد
    /// date of birth
    /// </summary>
    public DateTime? DateOfBirth { get; set; }

    /// <summary>
    /// النوع
    /// gender
    /// </summary>
    public string? Gender { get; set; }

    /// <summary>
    /// الدولة
    /// country
    /// </summary>
    public string? Country { get; set; }

    /// <summary>
    /// المدينة
    /// city
    /// </summary>
    public string? City { get; set; }

    /// <summary>
    /// العنوان
    /// address
    /// </summary>
    public string? Address { get; set; }

    /// <summary>
    /// رابط صورة الملف الشخصي
    /// profile picture URL
    /// </summary>
    public string? ProfilePictureUrl { get; set; }

    /// <summary>
    /// اللغة المفضلة
    /// preferred language
    /// </summary>
    public string? PreferredLanguage { get; set; }

    /// <summary>
    /// العملة المفضلة
    /// preferred currency
    /// </summary>
    public string? PreferredCurrency { get; set; }

    /// <summary>
    /// استقبال الإشعارات
    /// receive notifications
    /// </summary>
    public bool ReceiveNotifications { get; set; } = true;

    /// <summary>
    /// استقبال العروض
    /// receive promotions
    /// </summary>
    public bool ReceivePromotions { get; set; } = true;
}

/// <summary>
/// نتيجة Client User Profile.
/// client user profile response.
/// </summary>
public class ClientUserProfileResponse
{
    /// <summary>
    /// معرّف المستخدم
    /// user ID
    /// </summary>
    public Guid UserId { get; set; }

    /// <summary>
    /// الاسم الكامل
    /// full name
    /// </summary>
    public string FullName { get; set; } = string.Empty;

    /// <summary>
    /// البريد الإلكتروني
    /// email address
    /// </summary>
    public string Email { get; set; } = string.Empty;

    /// <summary>
    /// رقم الهاتف
    /// phone number
    /// </summary>
    public string? PhoneNumber { get; set; }

    /// <summary>
    /// رابط صورة الملف الشخصي
    /// profile picture URL
    /// </summary>
    public string? ProfilePictureUrl { get; set; }

    /// <summary>
    /// وقت آخر تحديث للملف الشخصي.
    /// timestamp indicating when the profile was last updated.
    /// </summary>
    public DateTime UpdatedAt { get; set; }

    /// <summary>
    /// اكتمال الملف الشخصي
    /// profile completion status
    /// </summary>
    public bool IsProfileComplete { get; set; }

    /// <summary>
    /// نسبة الاكتمال
    /// completion percentage
    /// </summary>
    public decimal CompletionPercentage { get; set; }
}
