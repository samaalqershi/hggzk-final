using MediatR;
using YemenBooking.Application.Common.Models;
using System.Collections.Generic;
using YemenBooking.Application.Features.Users.DTOs;

namespace YemenBooking.Application.Features.Users.Commands.CreateUser
{
    /// <summary>
    /// طلب إنشاء مستخدم.
    /// user creation request.
    /// </summary>
    public class CreateUserCommand : IRequest<ResultDto<Guid>>
    {
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
        /// صورة الملف الشخصي
        /// profile image
        /// </summary>
        public string? ProfileImage { get; set; }

        /// <summary>
        /// اسم الدور
        /// role name
        /// </summary>
        public string? RoleName { get; set; }

        /// <summary>
        /// تأكيد البريد الإلكتروني
        /// email confirmed
        /// </summary>
        public bool EmailConfirmed { get; set; } = false;

        /// <summary>
        /// تأكيد رقم الهاتف
        /// phone number confirmed
        /// </summary>
        public bool PhoneNumberConfirmed { get; set; } = false;

        /// <summary>
        /// حسابات المحفظة
        /// wallet accounts
        /// </summary>
        public List<UserWalletAccountRequestDto>? WalletAccounts { get; set; }
    }
} 