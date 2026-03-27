using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties.DTOs;

namespace YemenBooking.Application.Features.Properties.Commands.ManageImages
{
    /// <summary>
    /// طلب نسخ الصورة.
    /// Request to copy image.
    /// </summary>
    public class CopyImageCommand : IRequest<ResultDto<ImageDto>>
    {
        /// <summary>
        /// معرّف الصورة.
        /// image identifier.
        /// </summary>
        public Guid ImageId { get; set; }

        /// <summary>
        /// معرّف العقار الهدف.
        /// target property identifier.
        /// </summary>
        public Guid? TargetPropertyId { get; set; }

        /// <summary>
        /// معرّف الوحدة الهدف.
        /// target unit identifier.
        /// </summary>
        public Guid? TargetUnitId { get; set; }
    }
} 
