using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Authentication;
using System;
using YemenBooking.Application.Features.Authentication.DTOs;

namespace YemenBooking.Application.Features.Authentication.Commands.Logout
{
    /// <summary>
    /// طلب تسجيل الخروج.
    /// logout request.
    /// </summary>
    public class LogoutCommand : IRequest<ResultDto<LogoutResponse>>
{
    /// <summary>
    /// معرّف المستخدم
    /// user ID
    /// </summary>
    public Guid UserId { get; set; }
    
    /// <summary>
    /// رمز التحديث
    /// refresh token
    /// </summary>
    public string RefreshToken { get; set; } = string.Empty;
    
        /// <summary>
        /// تسجيل الخروج من جميع الأجهزة
        /// logout from all devices
        /// </summary>
        public bool LogoutFromAllDevices { get; set; } = false;
    }
}