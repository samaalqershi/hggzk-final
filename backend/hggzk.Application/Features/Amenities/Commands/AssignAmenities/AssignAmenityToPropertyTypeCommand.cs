using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Amenities.Commands.AssignAmenities
{
    /// <summary>
    /// يخصّص مرفقًا لنوع عقار محدد.
    /// Assigns an amenity to a specific property type.
    /// </summary>
    public class AssignAmenityToPropertyTypeCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// معرف نوع العقار.
        /// Property type identifier.
        /// </summary>
        public Guid PropertyTypeId { get; set; }

        /// <summary>
        /// معرف المرفق المطلوب تخصيصه.
        /// Amenity identifier to assign.
        /// </summary>
        public Guid AmenityId { get; set; }

        /// <summary>
        /// يحدد ما إذا كان المرفق افتراضيًا لهذا النوع.
        /// Indicates whether the amenity is the default for this type.
        /// </summary>
        public bool IsDefault { get; set; }
    }
} 
