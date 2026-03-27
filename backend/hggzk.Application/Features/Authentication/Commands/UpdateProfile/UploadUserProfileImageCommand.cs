using MediatR;
using YemenBooking.Application.Common.Models;
using System;

namespace YemenBooking.Application.Features.Authentication.Commands.UpdateProfile
{
    /// <summary>
    /// طلب رفع صورة الملف الشخصي.
    /// profile image upload request.
    /// </summary>
    public class UploadUserProfileImageCommand : IRequest<ResultDto<UploadUserProfileImageResponse>>
    {
        /// <summary>
        /// معرّف المستخدم
        /// user ID
        /// </summary>
        public Guid UserId { get; set; }

        /// <summary>
        /// اسم الملف
        /// file name
        /// </summary>
        public string FileName { get; set; } = string.Empty;

        /// <summary>
        /// نوع المحتوى
        /// content type
        /// </summary>
        public string ContentType { get; set; } = "application/octet-stream";

        /// <summary>
        /// حجم الملف بالبايت
        /// file size in bytes
        /// </summary>
        public byte[] FileBytes { get; set; } = Array.Empty<byte>();
    }

    /// <summary>
    /// نتيجة رفع صورة الملف الشخصي.
    /// profile image upload response.
    /// </summary>
    public class UploadUserProfileImageResponse
    {
        /// <summary>
        /// معرّف المستخدم
        /// user ID
        /// </summary>
        public Guid UserId { get; set; }
        /// <summary>
        /// رابط صورة الملف الشخصي
        /// profile image URL
        /// </summary>
        public string ProfileImageUrl { get; set; } = string.Empty;
        /// <summary>
        /// وقت آخر تحديث للصورة أو للسجل المرتبط بها.
        /// timestamp indicating when the image or related record was last updated.
        /// </summary>
        public DateTime UpdatedAt { get; set; }
    }
}
