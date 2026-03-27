using System;
using System.Collections.Generic;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Features.Properties.DTOs;

namespace YemenBooking.Application.Features.Properties.Commands.ManageImages
{
    /// <summary>
    /// طلب تحديث الصورة.
    /// Request to update image.
    /// </summary>
    public class UpdateImageCommand : IRequest<ResultDto<ImageDto>>
    {
        /// <summary>
        /// معرّف الصورة.
        /// image identifier.
        /// </summary>
        public Guid ImageId { get; set; }
        /// <summary>
        /// النص البديل.
        /// alternative text.
        /// </summary>
        public string? Alt { get; set; }
        /// <summary>
        /// أساسي.
        /// primary.
        /// </summary>
        public bool? IsPrimary { get; set; }
        /// <summary>
        /// الترتيب.
        /// order.
        /// </summary>
        public int? Order { get; set; }
        /// <summary>
        /// الوسوم.
        /// tags.
        /// </summary>
        public List<string>? Tags { get; set; }
        /// <summary>
        /// الفئة.
        /// category.
        /// </summary>
        public ImageCategory? Category { get; set; }
    }
} 
