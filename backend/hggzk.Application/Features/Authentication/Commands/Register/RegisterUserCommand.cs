using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Authentication;
using YemenBooking.Core.ValueObjects;
using YemenBooking.Application.Features.Authentication.DTOs;

namespace YemenBooking.Application.Features.Authentication.Commands.Register
{
    /// <summary>
    /// طلب تسجيل مستخدم.
    /// user registration request.
    /// </summary>
    public class RegisterUserCommand : IRequest<ResultDto<RegisterUserResponse>>
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
        /// نوع الحساب المطلوب إنشاءه للمستخدم الجديد.
        /// account type to create for the new user.
        /// </summary>
        public string AccountType { get; set; } = "Client";
    }
}
