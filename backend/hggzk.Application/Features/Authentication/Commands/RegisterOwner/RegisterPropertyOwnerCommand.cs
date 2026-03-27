using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Authentication;
using YemenBooking.Application.Features.Authentication.DTOs;
using YemenBooking.Core.Enums;
using System.Collections.Generic;

namespace YemenBooking.Application.Features.Authentication.Commands.RegisterOwner;

    /// <summary>
    /// طلب تسجيل مالك عقار.
    /// property owner registration request.
    /// </summary>
public class RegisterPropertyOwnerCommand : IRequest<ResultDto<RegisterPropertyOwnerResponse>>
{
    // User fields
    /// <summary>
    /// الاسم
    /// name
    /// </summary>
    public string Name { get; set; } = string.Empty;
    /// <summary>
    /// البريد الإلكتروني
    /// email address
    /// </summary>
    public string Email { get; set; } = string.Empty;
    /// <summary>
    /// كلمة المرور
    /// password
    /// </summary>
    public string Password { get; set; } = string.Empty;
    /// <summary>
    /// رقم الهاتف
    /// phone number
    /// </summary>
    public string Phone { get; set; } = string.Empty;

    /// <summary>
    /// حسابات المحفظة
    /// wallet accounts
    /// </summary>
    public List<OwnerWalletAccountRequestDto>? WalletAccounts { get; set; }

    // Property fields
    /// <summary>
    /// معرّف نوع العقار
    /// property type ID
    /// </summary>
    public Guid PropertyTypeId { get; set; }
    /// <summary>
    /// اسم العقار
    /// property name
    /// </summary>
    public string PropertyName { get; set; } = string.Empty;
    /// <summary>
    /// العنوان
    /// address
    /// </summary>
    public string Address { get; set; } = string.Empty;
    /// <summary>
    /// المدينة
    /// city
    /// </summary>
    public string City { get; set; } = string.Empty;
    /// <summary>
    /// خط العرض
    /// latitude
    /// </summary>
    public double? Latitude { get; set; }
    /// <summary>
    /// خط الطول
    /// longitude
    /// </summary>
    public double? Longitude { get; set; }
    /// <summary>
    /// التقييم النجمي
    /// star rating
    /// </summary>
    public int StarRating { get; set; } = 3;
    /// <summary>
    /// الوصف
    /// description
    /// </summary>
    public string? Description { get; set; }
    /// <summary>
    /// العملة
    /// currency
    /// </summary>
    public string? Currency { get; set; }
}

    /// <summary>
    /// بيانات Owner Wallet Account.
    /// owner wallet account data.
    /// </summary>
public class OwnerWalletAccountRequestDto
{
    /// <summary>
    /// نوع المحفظة
    /// wallet type
    /// </summary>
    public PaymentMethodEnum WalletType { get; set; }
    /// <summary>
    /// رقم الحساب
    /// account number
    /// </summary>
    public string AccountNumber { get; set; } = string.Empty;
    /// <summary>
    /// اسم الحساب
    /// account name
    /// </summary>
    public string? AccountName { get; set; }
    /// <summary>
    /// كونه افتراضيًا
    /// default status
    /// </summary>
    public bool IsDefault { get; set; }
}
