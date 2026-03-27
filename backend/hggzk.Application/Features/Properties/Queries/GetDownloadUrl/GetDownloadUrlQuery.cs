using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Properties.Queries.GetDownloadUrl
{
    /// <summary>
    /// استعلام للحصول على رابط تنزيل الملف.
    /// Query for retrieving a file download URL.
    /// </summary>
    public class GetDownloadUrlQuery : IRequest<ResultDto<string>>
    {
        /// <summary>
        /// معرّف الصورة.
        /// image identifier.
        /// </summary>
        public Guid ImageId { get; set; }

        /// <summary>
        /// الحجم.
        /// size.
        /// </summary>
        public string? Size { get; set; }
    }
} 
