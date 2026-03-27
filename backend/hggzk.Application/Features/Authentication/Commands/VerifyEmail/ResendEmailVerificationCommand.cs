using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Authentication;
using System;
using System.ComponentModel.DataAnnotations;
using YemenBooking.Application.Features.Authentication.DTOs;

namespace YemenBooking.Application.Features.Authentication.Commands.VerifyEmail
{
    /// <summary>
    /// طلب إعادة إرسال رمز التحقق من البريد الإلكتروني.
    /// resend email verification request.
    /// </summary>
    public class ResendEmailVerificationCommand : IRequest<ResultDto<ResendEmailVerificationResponse>>
    {
        /// <summary>
        /// معرّف المستخدم
        /// user ID
        /// </summary>
        public Guid UserId { get; set; }
        
        /// <summary>
        /// البريد الإلكتروني
        /// email address
        /// </summary>
        [Required(ErrorMessage = "البريد الإلكتروني مطلوب")]
        [EmailAddress(ErrorMessage = "بريد إلكتروني غير صحيح")]
        public string Email { get; set; } = string.Empty;
    }
}