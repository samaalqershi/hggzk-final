using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Users.Commands.UpdateUser;

    /// <summary>
    /// طلب تحديث صورة الملف الشخصي.
    /// profile picture update request.
    /// </summary>
public class UpdateUserProfilePictureCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف المستخدم
    /// user ID
    /// </summary>
    public Guid UserId { get; set; } // معرف المستخدم
    /// <summary>
    /// رابط صورة الملف الشخصي
    /// profile image URL
    /// </summary>
    public string ProfileImageUrl { get; set; } = string.Empty; // رابط الصورة الجديدة
}
