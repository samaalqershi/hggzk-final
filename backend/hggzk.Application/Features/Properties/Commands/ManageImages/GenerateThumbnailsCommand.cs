using System;
using System.Collections.Generic;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties.DTOs;

namespace YemenBooking.Application.Features.Properties.Commands.ManageImages
{
    /// <summary>
    /// طلب توليد Thumbnails.
    /// Request to generate thumbnails.
    /// </summary>
    public class GenerateThumbnailsCommand : IRequest<ResultDto<ImageDto>>
    {
        /// <summary>
        /// معرّف الصورة الأصلية.
        /// Identifier of the source image.
        /// </summary>
        public Guid ImageId { get; set; }

        /// <summary>
        /// الأحجام المطلوب إنشاء الصور المصغرة بها.
        /// Target sizes for generating thumbnails.
        /// </summary>
        public List<string> Sizes { get; set; } = new List<string>();
    }
} 
