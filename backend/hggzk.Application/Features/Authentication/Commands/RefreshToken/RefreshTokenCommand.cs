using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Authentication;
using System;
using YemenBooking.Application.Features.Authentication.DTOs;

namespace YemenBooking.Application.Features.Authentication.Commands.RefreshToken
{
    /// <summary>
    /// طلب تحديث رمز الوصول.
    /// token refresh request.
    /// </summary>
    public class RefreshTokenCommand : IRequest<ResultDto<RefreshTokenResponse>>
{
    /// <summary>
    /// رمز الوصول
    /// access token
    /// </summary>
    public string AccessToken { get; set; } = string.Empty;
    
        /// <summary>
        /// رمز التحديث
        /// refresh token
        /// </summary>
        public string RefreshToken { get; set; } = string.Empty;
    }
}