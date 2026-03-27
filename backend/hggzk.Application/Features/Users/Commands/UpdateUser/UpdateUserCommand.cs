using MediatR;
using YemenBooking.Application.Common.Models;
using System.Collections.Generic;
using YemenBooking.Application.Features.Users.DTOs;

namespace YemenBooking.Application.Features.Users.Commands.UpdateUser;

    /// <summary>
    /// طلب Update User.
    /// update user request.
    /// </summary>
public class UpdateUserCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف المستخدم
    /// user ID
    /// </summary>
    public Guid UserId { get; set; }

    /// <summary>
    /// الاسم
    /// name
    /// </summary>
    public string? Name { get; set; }

    /// <summary>
    /// البريد الإلكتروني
    /// email address
    /// </summary>
    public string? Email { get; set; }

    /// <summary>
    /// رقم الهاتف
    /// phone number
    /// </summary>
    public string? Phone { get; set; }

    /// <summary>
    /// صورة الملف الشخصي
    /// profile image
    /// </summary>
    public string? ProfileImage { get; set; }

    /// <summary>
    /// تأكيد البريد الإلكتروني
    /// email confirmed
    /// </summary>
    public bool? EmailConfirmed { get; set; }

    /// <summary>
    /// تأكيد رقم الهاتف
    /// phone number confirmed
    /// </summary>
    public bool? PhoneNumberConfirmed { get; set; }

    /// <summary>
    /// حسابات المحفظة
    /// wallet accounts
    /// </summary>
    public List<UserWalletAccountRequestDto>? WalletAccounts { get; set; }
} 