using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Authentication;
using System;
using System.ComponentModel.DataAnnotations;
using YemenBooking.Application.Features.Authentication.DTOs;
using System.Collections.Generic;
using YemenBooking.Application.Features.Users.DTOs;

namespace YemenBooking.Application.Features.Authentication.Commands.UpdateUser
{
    /// <summary>
    /// طلب تحديث الملف الشخصي للمستخدم.
    /// user profile update request.
    /// </summary>
    public class UpdateUserProfileCommand : IRequest<ResultDto<UpdateUserProfileResponse>>
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
    /// رقم الهاتف
    /// phone number
    /// </summary>
    public string? Phone { get; set; }
    
    /// <summary>
    /// صورة الملف الشخصي بترميز Base64
    /// Base64 profile image
    /// </summary>
    public string? ProfileImageBase64 { get; set; }

    /// <summary>
    /// حسابات المحفظة
    /// wallet accounts
    /// </summary>
    public List<UserWalletAccountRequestDto>? WalletAccounts { get; set; }

    // Optional property fields (for Owners)
    /// <summary>
    /// معرّف العقار
    /// property ID
    /// </summary>
    public Guid? PropertyId { get; set; }
    /// <summary>
    /// اسم العقار
    /// property name
    /// </summary>
    public string? PropertyName { get; set; }
    /// <summary>
    /// عنوان العقار
    /// property address
    /// </summary>
    public string? PropertyAddress { get; set; }
    /// <summary>
    /// مدينة العقار
    /// property city
    /// </summary>
    public string? PropertyCity { get; set; }
    /// <summary>
    /// الوصف المختصر للعقار
    /// property short description
    /// </summary>
    public string? PropertyShortDescription { get; set; }
    /// <summary>
    /// وصف العقار
    /// property description
    /// </summary>
    public string? PropertyDescription { get; set; }
    /// <summary>
    /// عملة العقار
    /// property currency
    /// </summary>
    public string? PropertyCurrency { get; set; }
    /// <summary>
    /// التقييم النجمي للعقار
    /// property star rating
    /// </summary>
    public int? PropertyStarRating { get; set; }
    /// <summary>
    /// خط العرض للعقار
    /// property latitude
    /// </summary>
    public double? PropertyLatitude { get; set; }
    /// <summary>
    /// خط الطول للعقار
    /// property longitude
    /// </summary>
    public double? PropertyLongitude { get; set; }
    }
}