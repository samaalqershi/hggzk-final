using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Properties.Queries.GetImageById
{
    /// <summary>
    /// استعلام للحصول على الصورة حسب المعرّف.
    /// Query for retrieving an image by identifier.
    /// </summary>
    public class GetImageByIdQuery : IRequest<ResultDto<ImageDto>>
    {
        /// <summary>
        /// معرّف الصورة.
        /// image identifier.
        /// </summary>
        public Guid ImageId { get; set; }
    }
} 
