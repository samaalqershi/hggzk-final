using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Properties.Commands.ManageImages
{
    /// <summary>
    /// طلب حذف الصورة.
    /// Request to delete image.
    /// </summary>
    public class DeleteImageCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// معرّف الصورة.
        /// image identifier.
        /// </summary>
        public Guid ImageId { get; set; }

        /// <summary>
        /// نهائي.
        /// permanent.
        /// </summary>
        public bool Permanent { get; set; } = false;
    }
} 
