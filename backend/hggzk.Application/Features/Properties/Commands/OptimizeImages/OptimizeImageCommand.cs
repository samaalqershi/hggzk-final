using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties.DTOs;

namespace YemenBooking.Application.Features.Properties.Commands.OptimizeImages
{
    /// <summary>
    /// طلب تحسين الصورة.
    /// Request to optimize image.
    /// </summary>
    public class OptimizeImageCommand : IRequest<ResultDto<ImageDto>>
    {
        /// <summary>
        /// معرّف الصورة.
        /// image identifier.
        /// </summary>
        public Guid ImageId { get; set; }
        /// <summary>
        /// إعدادات تحسين الصورة.
        /// image optimization settings.
        /// </summary>
        public ImageProcessingSettingsDto SettingsDto { get; set; } = null!;
    }
} 
